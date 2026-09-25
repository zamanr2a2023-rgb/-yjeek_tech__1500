import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/item_detail_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

/// Fashion / scheduled retail item page (Customize · grid/list · stay on add).
class ElectronicsProductDetailScreen extends ConsumerStatefulWidget {
  const ElectronicsProductDetailScreen({
    super.key,
    required this.storeId,
    required this.productId,
    this.bottomNavIndex = 0,
  });

  final String storeId;
  final String productId;
  final int bottomNavIndex;

  @override
  ConsumerState<ElectronicsProductDetailScreen> createState() =>
      _ElectronicsProductDetailScreenState();
}

class _ElectronicsProductDetailScreenState
    extends ConsumerState<ElectronicsProductDetailScreen> {
  int _quantity = 1;
  final Map<int, Set<int>> _selectedOptionsByGroup = {};
  final Set<int> _selectedAddons = {};
  final Set<int> _collapsedGroups = {};
  bool _addonsExpanded = true;
  bool _isGridView = true;
  bool _loading = true;
  bool _adding = false;
  bool _loadError = false;

  BrowseMenuItem? _item;
  String _description = '';
  List<BrowseOptionGroup> _optionGroups = const [];
  List<BrowseAddonOption> _addons = const [];
  String? _imageUrl;

  bool get _hasCustomize =>
      _optionGroups.isNotEmpty || _addons.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = false;
    });
    try {
      final detail =
          await ref.read(foodVendorsRepositoryProvider).fetchProductDetail(
                vendorId: widget.storeId,
                itemId: widget.productId,
              );
      if (!mounted) return;
      setState(() {
        _item = detail.item;
        _description = detail.description;
        _optionGroups = detail.optionGroups;
        _addons = detail.addons;
        _imageUrl = detail.imageUrl ?? detail.item.imageUrl;
        _selectedOptionsByGroup
          ..clear()
          ..addAll(initialOptionSelections(detail.optionGroups));
        // Drop defaults that are out of stock.
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
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = true;
        });
      }
    }
  }

  String get _displayPrice {
    final item = _item;
    if (item == null) return '0.000';
    final base = double.tryParse(item.price) ?? 0;
    final optionExtra = optionSelectionsExtraPrice(
      _optionGroups,
      _selectedOptionsByGroup,
    );
    var addonTotal = 0.0;
    for (final index in _selectedAddons) {
      if (index >= 0 && index < _addons.length) {
        addonTotal += double.tryParse(_addons[index].price) ?? 0;
      }
    }
    return ((base + optionExtra + addonTotal) * _quantity).toStringAsFixed(3);
  }

  String get _basePriceLabel {
    final item = _item;
    if (item == null) return 'BHD 0.000';
    final p = double.tryParse(item.price) ?? 0;
    return 'BHD ${p.toStringAsFixed(3)}';
  }

  void _toggleOption(int groupIndex, int optionIndex) {
    if (groupIndex < 0 || groupIndex >= _optionGroups.length) return;
    final group = _optionGroups[groupIndex];
    if (optionIndex < 0 || optionIndex >= group.options.length) return;
    if (!group.options[optionIndex].isAvailable) return;

    setState(() {
      final current = Set<int>.from(_selectedOptionsByGroup[groupIndex] ?? {});
      if (group.allowsMultiple) {
        if (current.contains(optionIndex)) {
          current.remove(optionIndex);
        } else if (current.length < group.maxSelect) {
          current.add(optionIndex);
        }
      } else {
        current
          ..clear()
          ..add(optionIndex);
      }
      _selectedOptionsByGroup[groupIndex] = current;
    });
  }

  void _toggleAddon(int index) {
    setState(() {
      if (_selectedAddons.contains(index)) {
        _selectedAddons.remove(index);
        return;
      }
      if (_selectedAddons.length >= _addons.length) return;
      _selectedAddons.add(index);
    });
  }

  Future<void> _addToCart({bool replaceCart = false}) async {
    if (_adding || _item == null) return;
    if (!await requireLogin(context, ref)) return;

    final validationError = validateOptionSelections(
      _optionGroups,
      _selectedOptionsByGroup,
    );
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    setState(() => _adding = true);
    final optionIds = optionSelectionIds(
      _optionGroups,
      _selectedOptionsByGroup,
    );
    final addonIds = <String>[];
    for (final index in _selectedAddons) {
      if (index >= 0 &&
          index < _addons.length &&
          _addons[index].id != null) {
        addonIds.add(_addons[index].id!);
      }
    }

    final result =
        await ref.read(electronicsVendorsRepositoryProvider).addToCart(
              productId: widget.productId,
              quantity: _quantity,
              optionIds: optionIds,
              addonIds: addonIds,
              replaceCart: replaceCart,
            );

    if (!mounted) return;
    setState(() => _adding = false);

    if (result.ok) {
      ref.read(shellProvider.notifier).markCartUpdated(scheduled: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_item!.localizedName} added to cart'),
          duration: const Duration(seconds: 1),
        ),
      );
      // Stay on page (Fashion requirement).
      return;
    }

    if (result.vendorConflict) {
      showCartNewCartDialog(
        context,
        onConfirm: () => _addToCart(replaceCart: true),
      );
      return;
    }

    if (await redirectToLoginIfAuthError(context, ref, result.message)) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Could not add to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _loadError || _item == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Could not load item',
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(child: _buildBody()),
                    ItemAddToCartBar(
                      label: 'Add to Cart · BHD $_displayPrice',
                      busy: _adding,
                      onTap: () => _addToCart(),
                    ),
                  ],
                ),
      bottomNavigationBar:
          ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }

  Widget _buildBody() {
    final item = _item!;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildImageSection()),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                item.localizedName,
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
                _basePriceLabel,
                style: AppTextStyles.titleSmall(color: AppColors.primary)
                    .copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  height: 1.2,
                ),
              ),
              if (_description.trim().isNotEmpty &&
                  _description.trim() != '___') ...[
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
                      BrowseRoutes.electronicsStore(storeId: widget.storeId),
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
    final style = _gridStyleFor(group.name);
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
            gridStyle: style,
            multiple: group.allowsMultiple,
            itemCount: group.options.length,
            labelAt: (i) => group.options[i].label,
            priceAt: (i) => group.options[i].priceDisplay,
            selectedAt: (i) =>
                _selectedOptionsByGroup[gi]?.contains(i) ?? false,
            imageAt: (i) => group.options[i].hasNetworkImage
                ? group.options[i].imageUrl
                : null,
            swatchColorAt: (i) => group.options[i].swatchColor,
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
            gridStyle: _addonsGridStyle,
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

  /// Flowers Figma: extras as chips; fashion/electronics keep cards.
  ItemOptionGridStyle get _addonsGridStyle {
    final flowerish = _optionGroups.any((g) {
      final n = g.name.toLowerCase();
      return n.contains('bouquet') || n.contains('flower');
    });
    return flowerish ? ItemOptionGridStyle.chips : ItemOptionGridStyle.cards;
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

  ItemOptionGridStyle _gridStyleFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('colour') || n.contains('color')) {
      return ItemOptionGridStyle.swatches;
    }
    if (n.contains('storage') ||
        n.contains('size') ||
        n.contains('memory') ||
        n.contains('bouquet')) {
      return ItemOptionGridStyle.chips;
    }
    return ItemOptionGridStyle.cards;
  }
}
