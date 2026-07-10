import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class ItemDetailScreen extends StatefulWidget {
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
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _quantity = 1;
  int _selectedSize = 0;
  final Set<int> _selectedAddons = {};

  BrowseRestaurant get _restaurant => BrowseData.restaurantById(widget.vendorId);
  BrowseMenuItem get _item => BrowseData.menuItemById(widget.itemId);

  String get _displayPrice {
    final base = double.tryParse(_item.price) ?? 20;
    final extra = _selectedSize == 1 ? 8.0 : 0.0;
  var addonTotal = 0.0;
    for (final index in _selectedAddons) {
      addonTotal += double.tryParse(BrowseData.mezzeAddons[index].price) ?? 0;
    }
    final total = (base + extra + addonTotal) * _quantity;
    return total.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: 260.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_restaurant.gradientStart, _restaurant.gradientEnd],
                    ),
                  ),
                ),
                Positioned(
                  top: 18.h,
                  left: 18.w,
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
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          height: 1,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _item.name,
                        style: AppTextStyles.titleMedium(color: AppColors.textPrimary).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 22.sp,
                        ),
                      ),
                    ),
                    Text(
                      'BHD ${_item.price.replaceAll('.000', '.0')}',
                      style: AppTextStyles.titleSmall(color: AppColors.primary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  BrowseData.mezzeLongDescription,
                  style: AppTextStyles.bodyMedium(color: AppColors.textSecondary).copyWith(
                    fontSize: 14.sp,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'CHOOSE SIZE',
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 10.h),
                for (var i = 0; i < BrowseData.mezzeSizes.length; i++) ...[
                  if (i > 0) SizedBox(height: 8.h),
                  BrowseSizeOptionCard(
                    option: BrowseData.mezzeSizes[i],
                    selected: _selectedSize == i,
                    onTap: () => setState(() => _selectedSize = i),
                  ),
                ],
                SizedBox(height: 18.h),
                Text(
                  'Add-ons',
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
                for (var i = 0; i < BrowseData.mezzeAddons.length; i++)
                  BrowseAddonRow(
                    addon: BrowseData.mezzeAddons[i],
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
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      _qtyButton(Icons.remove, () {
                        if (_quantity > 1) setState(() => _quantity--);
                      }),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Text(
                          '$_quantity',
                          style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                              .copyWith(fontWeight: FontWeight.w700, fontSize: 15.sp),
                        ),
                      ),
                      _qtyButton(Icons.add, () => setState(() => _quantity++)),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.goHome(tab: 2, cartHasItems: true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Add to cart · BHD $_displayPrice',
                        style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
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
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
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
