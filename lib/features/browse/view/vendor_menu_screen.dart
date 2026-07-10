import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class VendorMenuScreen extends StatefulWidget {
  const VendorMenuScreen({
    super.key,
    required this.vendorId,
    this.bottomNavIndex = 0,
  });

  final String vendorId;
  final int bottomNavIndex;

  @override
  State<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends State<VendorMenuScreen> {
  String _selectedSection = BrowseData.menuSections.first;

  BrowseRestaurant get _restaurant => BrowseData.restaurantById(widget.vendorId);

  List<BrowseMenuItem> get _items => BrowseData.greenKitchenMenu
      .where((item) => item.section == _selectedSection)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BrowseVendorHero(restaurant: _restaurant),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
              children: [
                BrowseSearchBar(
                  hint: 'Search this menu…',
                  onTap: () {},
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _statChip('${_restaurant.deliveryMin} min Delivery'),
                    SizedBox(width: 8.w),
                    _statChip('BHD ${_restaurant.deliveryFee} Fee'),
                    SizedBox(width: 8.w),
                    _statChip('BHD ${_restaurant.minOrder} Min order'),
                  ],
                ),
                SizedBox(height: 14.h),
                BrowseFilterChips(
                  options: BrowseData.menuSections,
                  selected: _selectedSection,
                  onSelected: (v) => setState(() => _selectedSection = v),
                ),
                SizedBox(height: 8.h),
                Text(
                  _selectedSection.toUpperCase(),
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    letterSpacing: 0.5,
                  ),
                ),
                ..._items.map(
                  (item) => BrowseMenuItemRow(
                    item: item,
                    gradientStart: _restaurant.gradientStart,
                    gradientEnd: _restaurant.gradientEnd,
                    onTap: () {
                      if (widget.vendorId != BrowseRoutes.defaultVendorId) {
                        showCartNewCartDialog(
                          context,
                          onConfirm: () => context.push(
                            BrowseRoutes.itemDetail(
                              vendorId: widget.vendorId,
                              itemId: item.id,
                            ),
                          ),
                        );
                        return;
                      }
                      context.push(
                        BrowseRoutes.itemDetail(
                          vendorId: widget.vendorId,
                          itemId: item.id,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          BrowseCartBar(onTap: () => context.goHome(tab: 2, cartHasItems: true)),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }

  Widget _statChip(String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
