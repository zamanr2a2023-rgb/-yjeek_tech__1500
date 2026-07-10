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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          BrowseTopBar(
            title: PickupData.homeTitle,
            onCart: () => context.goHome(tab: 2),
          ),
          SizedBox(height: 12.h),
          BrowseSearchBar(
            hint: PickupData.searchHint,
            onTap: () {},
          ),
          SizedBox(height: 16.h),
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
          SizedBox(height: 18.h),
          PickupSpotlightBanner(onOrderNow: () {}),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
