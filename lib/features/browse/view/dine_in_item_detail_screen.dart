import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/dine_in_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class DineInItemDetailScreen extends ConsumerStatefulWidget {
  const DineInItemDetailScreen({
    super.key,
    required this.restaurantId,
    required this.itemId,
    this.bottomNavIndex = 0,
  });

  final String restaurantId;
  final String itemId;
  final int bottomNavIndex;

  @override
  ConsumerState<DineInItemDetailScreen> createState() =>
      _DineInItemDetailScreenState();
}

class _DineInItemDetailScreenState
    extends ConsumerState<DineInItemDetailScreen> {
  int _quantity = 1;
  int _selectedSize = 0;
  final Set<int> _selectedAddons = {};
  bool _loading = true;
  bool _adding = false;

  BrowseMenuItem _item = DineInData.veeraMenu.first;
  String _description = DineInData.mezzeLongDescription;
  List<BrowseSizeOption> _sizes = DineInData.mezzeSizes;
  List<BrowseAddonOption> _addons = DineInData.mezzeAddons;
  String? _imageUrl;

  /// Design: `rgba(44, 107, 71, 0.55)` over white → sage green.
  static const Color _screenBg = Color(0xFF8BAE9A);

  @override
  void initState() {
    super.initState();
    _item = DineInData.menuItemById(widget.itemId);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(dineInVendorsRepositoryProvider);
      final detail = await repo.fetchProductDetail(
        vendorId: widget.restaurantId,
        itemId: widget.itemId,
      );
      if (!mounted) return;
      setState(() {
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

    final result = await ref.read(dineInVendorsRepositoryProvider).addToCart(
          productId: widget.itemId,
          quantity: _quantity,
          optionIds: optionIds,
          addonIds: addonIds,
          replaceCart: replaceCart,
        );

    if (!mounted) return;
    setState(() => _adding = false);

    if (result.ok) {
      context.goHome(tab: 2, dineInCart: true);
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
      backgroundColor: _screenBg,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                SizedBox(
                  height: 260.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_imageUrl != null && _imageUrl!.isNotEmpty)
                        Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(-0.6, -1),
                                end: Alignment(0.6, 1),
                                colors: [Color(0xFF6B8A3A), Color(0xFF15302B)],
                              ),
                            ),
                          ),
                        )
                      else
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(-0.6, -1),
                              end: Alignment(0.6, 1),
                              colors: [Color(0xFF6B8A3A), Color(0xFF15302B)],
                            ),
                          ),
                        ),
                      Positioned(
                        top: 18.h,
                        left: 18.w,
                        child: SafeArea(
                          bottom: false,
                          child: GestureDetector(
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
                          Text(
                            'BHD ${_item.price.replaceAll('.000', '.0')}',
                            style: AppTextStyles.titleSmall(
                              color: AppColors.textPrimary,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _description,
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'CHOOSE SIZE',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      for (var i = 0; i < _sizes.length; i++) ...[
                        if (i > 0) SizedBox(height: 10.h),
                        BrowseSizeOptionCard(
                          option: _sizes[i],
                          selected: _selectedSize == i,
                          onTap: () => setState(() => _selectedSize = i),
                        ),
                      ],
                      SizedBox(height: 16.h),
                      Text(
                        'ADD-ONS',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          height: 1.3,
                        ),
                      ),
                      for (var i = 0; i < _addons.length; i++)
                        BrowseAddonRow(
                          addon: _addons[i],
                          checked: _selectedAddons.contains(i),
                          splitPrice: true,
                          onChanged: (v) => setState(() {
                            if (v) {
                              _selectedAddons.add(i);
                            } else {
                              _selectedAddons.remove(i);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 30.h),
                  child: Row(
                    children: [
                      Container(
                        height: 46.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(color: const Color(0xFFE2E8DD)),
                        ),
                        child: Row(
                          children: [
                            _qtyButton('−', () {
                              if (_quantity > 1) setState(() => _quantity--);
                            }),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                '$_quantity',
                                style: AppTextStyles.labelMedium(
                                  color: AppColors.textPrimary,
                                ).copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.sp,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            _qtyButton('+', () => setState(() => _quantity++)),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: _adding ? null : () => _addToCart(),
                          child: Container(
                            height: 55.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(28.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _adding
                                  ? 'Adding…'
                                  : 'Add to order · BHD $_displayPrice',
                              style: AppTextStyles.labelMedium(
                                color: AppColors.white,
                              ).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar:
          ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }

  Widget _qtyButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
    );
  }
}
