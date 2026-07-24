import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({
    super.key,
    required this.vendorId,
    required this.itemId,
    this.bottomNavIndex = 0,
  });

  final String vendorId;
  final String itemId;
  final int bottomNavIndex;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  int _quantity = 1;
  int _selectedSize = 0;
  final Set<int> _selectedAddons = {};
  bool _loading = true;
  bool _adding = false;

  BrowseRestaurant _restaurant = BrowseData.restaurants.first;
  BrowseMenuItem _item = BrowseData.greenKitchenMenu.first;
  String _description = BrowseData.mezzeLongDescription;
  List<BrowseSizeOption> _sizes = BrowseData.mezzeSizes;
  List<BrowseAddonOption> _addons = BrowseData.mezzeAddons;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _restaurant = BrowseData.restaurantById(widget.vendorId);
    _item = BrowseData.menuItemById(widget.itemId);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
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
        _sizes = detail.options;
        _addons = detail.addons;
        _imageUrl = detail.imageUrl ?? detail.item.imageUrl;
        _selectedSize = 0;
        _selectedAddons.clear();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _displayPrice {
    final base = double.tryParse(_item.price) ?? 0;
    final sizeExtra = _selectedSize >= 0 && _selectedSize < _sizes.length
        ? (double.tryParse(_sizes[_selectedSize].extraPrice ?? '') ?? 0.0)
        : 0.0;
    var addonTotal = 0.0;
    for (final index in _selectedAddons) {
      if (index >= 0 && index < _addons.length) {
        addonTotal += double.tryParse(_addons[index].price) ?? 0;
      }
    }
    return ((base + sizeExtra + addonTotal) * _quantity).toStringAsFixed(1);
  }

  Future<void> _addToCart({bool replaceCart = false}) async {
    if (_adding) return;
    setState(() => _adding = true);
    final optionIds = <String>[];
    if (_selectedSize >= 0 &&
        _selectedSize < _sizes.length &&
        _sizes[_selectedSize].id != null) {
      optionIds.add(_sizes[_selectedSize].id!);
    }
    final addonIds = <String>[];
    for (final index in _selectedAddons) {
      if (index >= 0 &&
          index < _addons.length &&
          _addons[index].id != null) {
        addonIds.add(_addons[index].id!);
      }
    }

    final result = await ref.read(foodVendorsRepositoryProvider).addToCart(
          productId: widget.itemId,
          quantity: _quantity,
          optionIds: optionIds,
          addonIds: addonIds,
          replaceCart: replaceCart,
        );

    if (!mounted) return;
    setState(() => _adding = false);

    if (result.ok) {
      context.goHome(tab: 2, cartHasItems: true);
      return;
    }

    if (result.vendorConflict) {
      showCartNewCartDialog(
        context,
        onConfirm: () => _addToCart(replaceCart: true),
      );
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
                                _item.name,
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
                        Text(
                          _description,
                          style: AppTextStyles.bodyMedium(
                            color: const Color(0xFF6B7B6E),
                          ).copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                            height: 1.3,
                          ),
                        ),
                        if (_sizes.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Text(
                            'CHOOSE SIZE',
                            style: AppTextStyles.labelSmall(
                              color: const Color(0xFF6B7B6E),
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          for (var i = 0; i < _sizes.length; i++) ...[
                            if (i > 0) SizedBox(height: 8.h),
                            BrowseSizeOptionCard(
                              option: _sizes[i],
                              selected: _selectedSize == i,
                              onTap: () => setState(() => _selectedSize = i),
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
