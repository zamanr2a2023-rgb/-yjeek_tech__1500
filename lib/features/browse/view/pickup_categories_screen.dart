import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/pickup_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/pickup_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class PickupCategoriesScreen extends StatefulWidget {
  const PickupCategoriesScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  State<PickupCategoriesScreen> createState() => _PickupCategoriesScreenState();
}

class _PickupCategoriesScreenState extends State<PickupCategoriesScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    // Figma PK6: light bg · search 44 · grid/list toggle · 4-col tiles · spotlight.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BrowseTopBar(
            title: PickupData.homeTitle,
            onCart: () => context.goHome(tab: 2),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 24.h),
              children: [
                BrowseSearchBar(
                  hint: PickupData.searchHint,
                  onTap: () {},
                ),
                SizedBox(height: 14.h),
                PickupCategoriesToolbar(
                  isGridView: _isGridView,
                  onViewChanged: (value) => setState(() => _isGridView = value),
                ),
                SizedBox(height: 14.h),
                if (_isGridView)
                  PickupCategoryGrid(
                    categories: PickupData.allCategories,
                    onCategoryTap: (_) {},
                  )
                else
                  PickupCategoryList(
                    categories: PickupData.allCategories,
                    onCategoryTap: (_) {},
                  ),
                SizedBox(height: 16.h),
                PickupSpotlightBanner(onOrderNow: () {}),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
