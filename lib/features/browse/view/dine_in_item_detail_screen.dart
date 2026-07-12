import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/dine_in_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class DineInItemDetailScreen extends StatefulWidget {
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
  State<DineInItemDetailScreen> createState() => _DineInItemDetailScreenState();
}

class _DineInItemDetailScreenState extends State<DineInItemDetailScreen> {
  int _quantity = 1;
  int _selectedSize = 0;
  final Set<int> _selectedAddons = {};

  /// Design: `rgba(44, 107, 71, 0.55)` over white → sage green.
  static const Color _screenBg = Color(0xFF8BAE9A);

  BrowseMenuItem get _item => DineInData.menuItemById(widget.itemId);

  String get _displayPrice {
    final base = double.tryParse(_item.price) ?? 20;
    final extra = _selectedSize == 1 ? 8.0 : 0.0;
    var addonTotal = 0.0;
    for (final index in _selectedAddons) {
      addonTotal += double.tryParse(DineInData.mezzeAddons[index].price) ?? 0;
    }
    final total = (base + extra + addonTotal) * _quantity;
    return total.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
      body: Column(
        children: [
          SizedBox(
            height: 260.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
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
                        style: AppTextStyles.titleMedium(color: AppColors.textPrimary).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 22.sp,
                          height: 1.3,
                        ),
                      ),
                    ),
                    Text(
                      'BHD ${_item.price.replaceAll('.000', '.0')}',
                      style: AppTextStyles.titleSmall(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  DineInData.mezzeLongDescription,
                  style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'CHOOSE SIZE',
                  style: AppTextStyles.labelSmall(color: AppColors.textPrimary).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 10.h),
                for (var i = 0; i < DineInData.mezzeSizes.length; i++) ...[
                  if (i > 0) SizedBox(height: 10.h),
                  BrowseSizeOptionCard(
                    option: DineInData.mezzeSizes[i],
                    selected: _selectedSize == i,
                    onTap: () => setState(() => _selectedSize = i),
                  ),
                ],
                SizedBox(height: 16.h),
                Text(
                  'ADD-ONS',
                  style: AppTextStyles.labelSmall(color: AppColors.textPrimary).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
                for (var i = 0; i < DineInData.mezzeAddons.length; i++)
                  BrowseAddonRow(
                    addon: DineInData.mezzeAddons[i],
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
                          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
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
                    onTap: () => context.goHome(tab: 2, dineInCart: true),
                    child: Container(
                      height: 55.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Add to order · BHD $_displayPrice',
                        style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
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
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
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
