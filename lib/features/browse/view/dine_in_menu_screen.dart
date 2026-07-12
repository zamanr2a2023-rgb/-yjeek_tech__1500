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

  /// Design: `rgba(44, 107, 71, 0.55)` over white → sage green.
  static const Color _screenBg = Color(0xFF8BAE9A);

  DineInRestaurant get _restaurant => DineInData.restaurantById(widget.restaurantId);

  List<BrowseMenuItem> get _items => DineInData.veeraMenu
      .where((item) => item.section == _selectedSection)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
      body: Column(
        children: [
          DineInVendorHero(restaurant: _restaurant),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              children: [
                BrowseSearchBar(
                  hint: 'Search this menu…',
                  onTap: () {},
                ),
                SizedBox(height: 14.h),
                DineInStatusCard(
                  leftTitle: 'Open now',
                  leftSubtitle: 'Dine-in',
                  rightTitle: 'Table ${_restaurant.tableMin}+',
                  rightSubtitle: 'Walk-in',
                ),
                SizedBox(height: 14.h),
                BrowseFilterChips(
                  options: DineInData.menuSections,
                  selected: _selectedSection,
                  onSelected: (v) => setState(() => _selectedSection = v),
                ),
                SizedBox(height: 14.h),
                Text(
                  _selectedSection.toUpperCase(),
                  style: AppTextStyles.labelSmall(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4.h),
                for (var i = 0; i < _items.length; i++) ...[
                  DineInMenuItemRow(
                    item: _items[i],
                    gradientStart: _restaurant.gradientStart,
                    gradientEnd: _restaurant.gradientEnd,
                    onTap: () => context.push(
                      BrowseRoutes.dineInItemDetail(
                        restaurantId: widget.restaurantId,
                        itemId: _items[i].id,
                      ),
                    ),
                  ),
                  if (i < _items.length - 1)
                    Divider(height: 1, thickness: 1, color: const Color(0xFFE2E8DD).withValues(alpha: 0.55)),
                ],
              ],
            ),
          ),
          DineInOrderBar(onTap: () => context.goHome(tab: 2, dineInCart: true)),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
