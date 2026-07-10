import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/dine_in_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/dine_in_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class DineInMenuScreen extends StatefulWidget {
  const DineInMenuScreen({
    super.key,
    required this.restaurantId,
    this.bottomNavIndex = 0,
  });

  final String restaurantId;
  final int bottomNavIndex;

  @override
  State<DineInMenuScreen> createState() => _DineInMenuScreenState();
}

class _DineInMenuScreenState extends State<DineInMenuScreen> {
  String _selectedSection = DineInData.menuSections.first;

  DineInRestaurant get _restaurant => DineInData.restaurantById(widget.restaurantId);

  List<BrowseMenuItem> get _items => DineInData.veeraMenu
      .where((item) => item.section == _selectedSection)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          DineInVendorHero(restaurant: _restaurant),
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
                    _infoChip(Icons.schedule, 'Open now'),
                    SizedBox(width: 8.w),
                    _infoChip(Icons.table_restaurant_outlined, 'Table ${_restaurant.tableMin}+'),
                  ],
                ),
                SizedBox(height: 14.h),
                BrowseFilterChips(
                  options: DineInData.menuSections,
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
                    onTap: () => context.push(
                      BrowseRoutes.dineInItemDetail(
                        restaurantId: widget.restaurantId,
                        itemId: item.id,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          DineInOrderBar(onTap: () => context.goHome(tab: 2, dineInCart: true)),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.sp, color: AppColors.primary),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTextStyles.caption(color: AppColors.textPrimary).copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
