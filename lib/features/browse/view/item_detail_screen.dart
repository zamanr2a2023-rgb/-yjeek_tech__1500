import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/item_detail_widgets.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/cart/model/pending_add_to_cart.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/geofence/model/active_geofence_order_context.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/l10n/locale_controller.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({
    super.key,
    required this.vendorId,
    required this.itemId,
    this.bottomNavIndex = 0,
    this.cartType,
  });

  final String vendorId;
  final String itemId;
  final int bottomNavIndex;

  /// `pickup` → PICKUP; `dine_in` → DINE_IN; otherwise DELIVERY.
  final String? cartType;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  int _quantity = 1;
  final Map<int, Set<int>> _selectedOptionsByGroup = {};
  final Set<int> _selectedAddons = {};
  final Set<int> _collapsedGroups = {};
  bool _addonsExpanded = true;
  bool _isGridView = true;
  bool _loading = true;
  bool _adding = false;
  bool _loadError = false;

  late BrowseRestaurant _restaurant;
  late BrowseMenuItem _item;
  String _description = '';
  String? _descriptionAr;
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
      final repo = ref.read(foodVendorsRepositoryProvider);
      final vendor = await repo.fetchVendor(widget.vendorId);
      final detail = await repo.fetchProductDetail(
        vendorId: widget.vendorId,
        itemId: widget.itemId,
      );
      if (!mounted) return;
      setState(() {
        _restaurant = vendor;
        _item = detail.item;
        _description = detail.description;
        _descriptionAr = detail.descriptionAr;
        _optionGroups = detail.optionGroups;
        _addons = detail.addons;
        _imageUrl = detail.imageUrl ?? detail.item.imageUrl;
        _selectedOptionsByGroup
          ..clear()
          ..addAll(initialOptionSelections(detail.optionGroups));
        _selectedAddons.clear();
        _collapsedGroups.clear();
        _addonsExpanded = true;
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

  String get _localizedDescription {
    final ar = _descriptionAr?.trim();
    if (ref.watch(localeControllerProvider).code == 'ar' &&
        ar != null &&
        ar.isNotEmpty) {
      return ar;
    }
    return _description;
  }

  String get _displayPrice {
    final base = double.tryParse(_item.price) ?? 0;
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
    final p = double.tryParse(_item.price) ?? 0;
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
      // Soft cap matches the "Select up to N" hint (all extras when no schema max).
      if (_selectedAddons.length >= _addons.length) return;
      _selectedAddons.add(index);
    });
  }

  Future<void> _addToCart({bool replaceCart = false}) async {
    if (_adding) return;

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

    final raw = (widget.cartType ?? '').toLowerCase().replaceAll('-', '_');
    final orderType = raw == 'pickup'
        ? 'PICKUP'
        : (raw == 'dine_in' || raw == 'dinein')
            ? 'DINE_IN'
            : 'DELIVERY';
    final geofenceTriggerId = resolveGeofenceTriggerId(
      ref,
      vendorId: widget.vendorId,
      orderType: orderType,
    );

    if (!ref.read(storageServiceProvider).hasSession) {
      rememberPendingAddToCart(
        ref,
        PendingAddToCart(
          productId: widget.itemId,
          quantity: _quantity,
          optionIds: optionIds,
          addonIds: addonIds,
          cartType: orderType,
          vendorId: widget.vendorId,
          geofenceTriggerId: geofenceTriggerId,
          replaceCart: replaceCart,
          returnPath: currentReturnPath(context),
          vertical: PendingCartVertical.food,
        ),
      );
    }
    if (!await requireLogin(context, ref)) return;
    if (!mounted) return;

    setState(() => _adding = true);
    final result = await ref.read(foodVendorsRepositoryProvider).addToCart(
          productId: widget.itemId,
          quantity: _quantity,
          optionIds: optionIds,
          addonIds: addonIds,
          replaceCart: replaceCart,
          cartType: orderType,
          vendorId: widget.vendorId,
          geofenceTriggerId: geofenceTriggerId,
        );

    if (!mounted) return;
    setState(() => _adding = false);

    if (result.ok) {
      clearPendingAddToCart(ref);
      ref.read(shellProvider.notifier).markCartUpdated(
            delivery: orderType == 'DELIVERY',
            pickup: orderType == 'PICKUP',
            dineIn: orderType == 'DINE_IN',
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_item.localizedName} added to cart'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    if (result.outOfRange) {
      rememberPendingAddToCart(
        ref,
        PendingAddToCart(
          productId: widget.itemId,
          quantity: _quantity,
          optionIds: optionIds,
          addonIds: addonIds,
          cartType: orderType,
          vendorId: widget.vendorId,
          geofenceTriggerId: geofenceTriggerId,
          replaceCart: replaceCart,
          vertical: PendingCartVertical.food,
        ),
      );
      await pushOutOfDelivery(context);
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
          : _loadError
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildImageSection()),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                _item.localizedName,
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
              if (_localizedDescription.trim().isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  _localizedDescription,
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
      height: 300.h,
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
                    errorWidget: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(-0.8, -0.6),
                          end: const Alignment(0.8, 0.8),
                          colors: [
                            _restaurant.gradientStart,
                            _restaurant.gradientEnd,
                          ],
                        ),
                      ),
                    ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(-0.8, -0.6),
                        end: const Alignment(0.8, 0.8),
                        colors: [
                          _restaurant.gradientStart,
                          _restaurant.gradientEnd,
                        ],
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: 0,
            left: 16.w,
            child: SafeArea(
              bottom: false,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.pop(),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '‹',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
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
          hint: group.selectionHint,
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
            multiple: group.allowsMultiple,
            itemCount: group.options.length,
            labelAt: (i) => group.options[i].label,
            priceAt: (i) => group.options[i].priceDisplay,
            selectedAt: (i) =>
                _selectedOptionsByGroup[gi]?.contains(i) ?? false,
            imageAt: (i) => group.options[i].imageUrl,
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
          hint: 'Optional · Select up to ${_addons.length}',
          expanded: _addonsExpanded,
          onTap: () => setState(() => _addonsExpanded = !_addonsExpanded),
        ),
        if (_addonsExpanded)
          ItemOptionsLayout(
            isGridView: _isGridView,
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
}
