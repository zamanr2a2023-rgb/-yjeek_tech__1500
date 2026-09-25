import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/item_detail_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';

/// Service booking customise page — help 2.md (grid/list · visits · Book now).
class ServicesItemDetailScreen extends ConsumerStatefulWidget {
  const ServicesItemDetailScreen({
    super.key,
    required this.providerId,
    required this.itemId,
    this.bottomNavIndex = 0,
  });

  final String providerId;
  final String itemId;
  final int bottomNavIndex;

  @override
  ConsumerState<ServicesItemDetailScreen> createState() =>
      _ServicesItemDetailScreenState();
}

class _ServicesItemDetailScreenState
    extends ConsumerState<ServicesItemDetailScreen> {
  int _quantity = 1;
  final Map<int, Set<int>> _selectedOptionsByGroup = {};
  final Set<int> _selectedAddons = {};
  final Set<int> _collapsedGroups = {};
  bool _addonsExpanded = true;
  bool _isGridView = true;
  bool _loading = true;
  bool _adding = false;

  ServiceMenuItem? _item;
  String _description = '';
  List<BrowseOptionGroup> _optionGroups = const [];
  List<BrowseAddonOption> _addons = const [];
  String? _imageUrl;
  String _quantityLabel = 'Sessions';

  bool get _hasCustomize =>
      _optionGroups.isNotEmpty || _addons.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final detail = await ref
          .read(servicesVendorsRepositoryProvider)
          .fetchProductDetail(
            providerId: widget.providerId,
            itemId: widget.itemId,
          );
      if (!mounted) return;
      setState(() {
        _item = detail.item;
        _description = detail.description;
        _optionGroups = detail.optionGroups;
        _addons = detail.addons;
        _imageUrl = detail.imageUrl;
        _quantityLabel = detail.quantityLabel;
        _selectedOptionsByGroup
          ..clear()
          ..addAll(initialOptionSelections(detail.optionGroups));
        for (final entry in _selectedOptionsByGroup.entries) {
          final gi = entry.key;
          if (gi < 0 || gi >= _optionGroups.length) continue;
          entry.value.removeWhere(
            (oi) =>
                oi < 0 ||
                oi >= _optionGroups[gi].options.length ||
                !_optionGroups[gi].options[oi].isAvailable,
          );
        }
        _selectedAddons.clear();
        _collapsedGroups.clear();
        _addonsExpanded = true;
        _quantity = 1;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String get _displayPrice {
    final item = _item;
    if (item == null) return '0.000';
    final base = double.tryParse(item.price) ?? 0;
    final optionsExtra =
        optionSelectionsExtraPrice(_optionGroups, _selectedOptionsByGroup);
    var addonTotal = 0.0;
    for (final index in _selectedAddons) {
      if (index >= 0 && index < _addons.length) {
        addonTotal += double.tryParse(_addons[index].price) ?? 0;
      }
    }
    return ((base + optionsExtra + addonTotal) * _quantity).toStringAsFixed(3);
  }

  void _toggleOption(int gi, int oi) {
    if (gi < 0 || gi >= _optionGroups.length) return;
    final group = _optionGroups[gi];
    if (oi < 0 ||
        oi >= group.options.length ||
        !group.options[oi].isAvailable) {
      return;
    }
    setState(() {
      final picks = _selectedOptionsByGroup.putIfAbsent(gi, () => <int>{});
      if (group.allowsMultiple) {
        if (picks.contains(oi)) {
          picks.remove(oi);
        } else {
          if (picks.length >= group.maxSelect) {
            picks.remove(picks.first);
          }
          picks.add(oi);
        }
      } else {
        picks
          ..clear()
          ..add(oi);
      }
    });
  }

  void _toggleAddon(int i) {
    setState(() {
      if (_selectedAddons.contains(i)) {
        _selectedAddons.remove(i);
      } else {
        _selectedAddons.add(i);
      }
    });
  }

  Future<void> _bookNow({bool replaceCart = false}) async {
    if (_adding) return;
    if (!await requireLogin(context, ref)) return;

    setState(() => _adding = true);

    final optionIds =
        optionSelectionIds(_optionGroups, _selectedOptionsByGroup);
    final addonIds = <String>[];
    for (final index in _selectedAddons) {
      if (index >= 0 &&
          index < _addons.length &&
          _addons[index].id != null) {
        addonIds.add(_addons[index].id!);
      }
    }

    final result = await ref.read(servicesVendorsRepositoryProvider).addToCart(
          productId: widget.itemId,
          quantity: _quantity,
          optionIds: optionIds,
          addonIds: addonIds,
          replaceCart: replaceCart,
        );

    if (!mounted) return;
    setState(() => _adding = false);

    if (result.ok) {
      if (!mounted) return;
      context.push(ServicesBookingRoutes.booking);
      return;
    }

    if (result.vendorConflict) {
      if (!mounted) return;
      showCartNewCartDialog(
        context,
        onConfirm: () => _bookNow(replaceCart: true),
      );
      return;
    }

    if (await redirectToLoginIfAuthError(context, ref, result.message)) {
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Could not start booking')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        bottomNavigationBar: ShellBottomNavBar(
          currentIndex: widget.bottomNavIndex,
        ),
      );
    }

    final item = _item;
    if (item == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load service',
                style: AppTextStyles.bodyMedium(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
        bottomNavigationBar: ShellBottomNavBar(
          currentIndex: widget.bottomNavIndex,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(child: _buildBody(item)),
          ItemAddToCartBar(
            label: 'Book now · BHD $_displayPrice',
            busyLabel: 'Booking…',
            busy: _adding,
            onTap: () => _bookNow(),
          ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(
        currentIndex: widget.bottomNavIndex,
      ),
    );
  }

  Widget _buildBody(ServiceMenuItem item) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildImageSection()),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                item.name,
                style: AppTextStyles.titleMedium(
                  color: AppColors.textPrimary,
                ).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'BHD ${item.price}',
                style: AppTextStyles.titleSmall(color: AppColors.primary)
                    .copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  height: 1.2,
                ),
              ),
              if (_description.trim().isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  _description,
                  style: AppTextStyles.bodyMedium(
                    color: const Color(0xFF6B6B6B),
                  ).copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    height: 1.25,
                  ),
                ),
              ],
              if (_hasCustomize) ...[
                SizedBox(height: 12.h),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E2E2),
                ),
                SizedBox(height: 4.h),
                ItemCustomizeHeader(
                  title: 'Customise your booking',
                  isGridView: _isGridView,
                  onViewChanged: (v) => setState(() => _isGridView = v),
                ),
                for (var gi = 0; gi < _optionGroups.length; gi++)
                  _buildOptionGroup(gi),
                if (_addons.isNotEmpty) _buildAddonsSection(),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E2E2),
                ),
              ],
              ItemQuantityRow(
                label: _quantityLabel,
                quantity: _quantity,
                onMinus: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
                onPlus: () => setState(() => _quantity++),
              ),
              SizedBox(height: 8.h),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 280.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: const Color(0xFFE8F5E9),
            child: _imageUrl != null && _imageUrl!.isNotEmpty
                ? AppNetworkImage(
                    url: _imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: const ColoredBox(color: Color(0xFFE8F5E9)),
                  )
                : null,
          ),
          Positioned(
            top: 0,
            left: 16.w,
            child: SafeArea(
              bottom: false,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(
                      BrowseRoutes.servicesProvider(
                        providerId: widget.providerId,
                      ),
                    );
                  }
                },
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 22.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionGroup(int gi) {
    final group = _optionGroups[gi];
    final expanded = !_collapsedGroups.contains(gi);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemOptionAccordionHeader(
          title: group.name,
          hint: _groupHint(group, gi),
          expanded: expanded,
          onTap: () => setState(() {
            if (expanded) {
              _collapsedGroups.add(gi);
            } else {
              _collapsedGroups.remove(gi);
            }
          }),
        ),
        if (expanded)
          ItemOptionsLayout(
            isGridView: _isGridView,
            gridStyle: ItemOptionGridStyle.chips,
            multiple: group.allowsMultiple,
            itemCount: group.options.length,
            labelAt: (i) => group.options[i].label,
            priceAt: (i) => _optionPriceLabel(group.options[i]),
            selectedAt: (i) =>
                _selectedOptionsByGroup[gi]?.contains(i) ?? false,
            imageAt: (_) => null,
            stockAt: (i) => group.options[i].stockLabel,
            enabledAt: (i) => group.options[i].isAvailable,
            onTapAt: (i) => _toggleOption(gi, i),
          ),
      ],
    );
  }

  Widget _buildAddonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemOptionAccordionHeader(
          title: 'Add extras',
          hint: 'Optional · Select any',
          expanded: _addonsExpanded,
          onTap: () => setState(() => _addonsExpanded = !_addonsExpanded),
        ),
        if (_addonsExpanded)
          ItemOptionsLayout(
            isGridView: _isGridView,
            gridStyle: ItemOptionGridStyle.cards,
            multiple: true,
            itemCount: _addons.length,
            labelAt: (i) => _addons[i].label,
            priceAt: (i) => _addons[i].priceLabel,
            selectedAt: (i) => _selectedAddons.contains(i),
            imageAt: (i) => _addons[i].imageUrl,
            onTapAt: _toggleAddon,
          ),
      ],
    );
  }

  String _optionPriceLabel(BrowseSizeOption opt) {
    if (opt.isIncluded) return 'Included';
    final p = opt.extraPrice;
    if (p == null || p.isEmpty) return 'Included';
    return '+BHD $p';
  }

  String _groupHint(BrowseOptionGroup group, int gi) {
    final picks = _selectedOptionsByGroup[gi];
    String? selectedLabel;
    if (picks != null && picks.isNotEmpty) {
      final oi = picks.first;
      if (oi >= 0 && oi < group.options.length) {
        selectedLabel = group.options[oi].label;
      }
    }
    if (group.isRequired) {
      if (selectedLabel != null && selectedLabel.isNotEmpty) {
        return 'Required · $selectedLabel';
      }
      return 'Required';
    }
    if (selectedLabel != null && selectedLabel.isNotEmpty) {
      return 'Optional · $selectedLabel';
    }
    return 'Optional · Select any';
  }
}
