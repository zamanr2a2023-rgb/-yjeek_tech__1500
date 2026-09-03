import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/l10n/locale_controller.dart';
import 'package:yjeek_app/routes/app_router.dart';

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
  /// `pickup` → POST /cart/items?type=PICKUP; otherwise DELIVERY.
  final String? cartType;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  int _quantity = 1;
  final Map<int, Set<int>> _selectedOptionsByGroup = {};
  final Set<int> _selectedAddons = {};
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
    return ((base + optionExtra + addonTotal) * _quantity).toStringAsFixed(1);
  }

  void _toggleOption(int groupIndex, int optionIndex) {
    if (groupIndex < 0 || groupIndex >= _optionGroups.length) return;
    final group = _optionGroups[groupIndex];
    if (optionIndex < 0 || optionIndex >= group.options.length) return;

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

  Future<void> _addToCart({bool replaceCart = false}) async {
    if (_adding) return;
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

    final isPickup = (widget.cartType ?? '').toLowerCase() == 'pickup';
    final result = await ref.read(foodVendorsRepositoryProvider).addToCart(
          productId: widget.itemId,
          quantity: _quantity,
          optionIds: optionIds,
          addonIds: addonIds,
          replaceCart: replaceCart,
          cartType: isPickup ? 'PICKUP' : 'DELIVERY',
        );

    if (!mounted) return;
    setState(() => _adding = false);

    if (result.ok) {
      context.goHome(
        tab: 2,
        cartHasItems: !isPickup,
        pickupCart: isPickup,
      );
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
      backgroundColor: AppColors.background,
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
                SizedBox(
                  height: 260.h,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_imageUrl != null && _imageUrl!.isNotEmpty)
                        Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => DecoratedBox(
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
                      else
                        DecoratedBox(
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
                      Positioned(
                        top: 0,
                        left: 18.w,
                        child: SafeArea(
                          bottom: false,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => context.pop(),
                            child: Container(
                              width: 38.w,
                              height: 38.w,
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '‹',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: AppColors.background,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 8.h),
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                _item.localizedName,
                                style: AppTextStyles.titleMedium(
                                  color: AppColors.textPrimary,
                                ).copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22.sp,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'BHD ${_item.price.replaceAll('.000', '.0')}',
                              style: AppTextStyles.titleSmall(
                                color: AppColors.primary,
                              ).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18.sp,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        if (_localizedDescription.trim().isNotEmpty)
                          Text(
                            _localizedDescription,
                            style: AppTextStyles.bodyMedium(
                              color: const Color(0xFF6B7B6E),
                            ).copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                              height: 1.3,
                            ),
                          ),
                        if (_optionGroups.isNotEmpty)
                          for (var gi = 0; gi < _optionGroups.length; gi++) ...[
                            SizedBox(height: 16.h),
                            Text(
                              _optionGroups[gi].name.toUpperCase(),
                              style: AppTextStyles.labelSmall(
                                color: const Color(0xFF6B7B6E),
                              ).copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                                height: 1.3,
                              ),
                            ),
                            if (_optionGroups[gi].allowsMultiple &&
                                _optionGroups[gi].maxSelect > 1)
                              Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(
                                  'Choose up to ${_optionGroups[gi].maxSelect}',
                                  style: AppTextStyles.caption(
                                    color: const Color(0xFF6B7B6E),
                                  ).copyWith(fontSize: 11.sp),
                                ),
                              ),
                            SizedBox(height: 10.h),
                            for (var oi = 0;
                                oi < _optionGroups[gi].options.length;
                                oi++) ...[
                              if (oi > 0) SizedBox(height: 8.h),
                              BrowseSizeOptionCard(
                                option: _optionGroups[gi].options[oi],
                                selected: _selectedOptionsByGroup[gi]
                                        ?.contains(oi) ??
                                    false,
                                multiple: _optionGroups[gi].allowsMultiple,
                                onTap: () => _toggleOption(gi, oi),
                              ),
                            ],
                          ],
                        if (_addons.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Text(
                            'Add-ons',
                            style: AppTextStyles.labelSmall(
                              color: const Color(0xFF6B7B6E),
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          for (var i = 0; i < _addons.length; i++)
                            BrowseAddonRow(
                              addon: _addons[i],
                              checked: _selectedAddons.contains(i),
                              onChanged: (v) => setState(() {
                                if (v) {
                                  _selectedAddons.add(i);
                                } else {
                                  _selectedAddons.remove(i);
                                }
                              }),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8DD))),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(color: const Color(0xFFE2E8DD)),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              _qtyButton(Icons.remove, () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              }),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                child: Text(
                                  '$_quantity',
                                  style: AppTextStyles.labelMedium(
                                    color: AppColors.textPrimary,
                                  ).copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ),
                              _qtyButton(
                                Icons.add,
                                () => setState(() => _quantity++),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _adding ? null : () => _addToCart(),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _adding
                                    ? 'Adding…'
                                    : 'Add to cart · BHD $_displayPrice',
                                style: AppTextStyles.labelMedium(
                                  color: AppColors.white,
                                ).copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar:
          ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Icon(icon, size: 18.sp, color: AppColors.textPrimary),
      ),
    );
  }
}
