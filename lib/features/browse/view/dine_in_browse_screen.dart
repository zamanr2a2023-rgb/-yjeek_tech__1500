import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/dine_in_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/dine_in_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class DineInBrowseScreen extends StatefulWidget {
  const DineInBrowseScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  State<DineInBrowseScreen> createState() => _DineInBrowseScreenState();
}

class _DineInBrowseScreenState extends State<DineInBrowseScreen> {
  bool _isGridView = true;
  bool _freeDeliveryOnly = false;
  String _selectedFilter = DineInData.cuisineFilters.first;

  List<DineInRestaurant> get _restaurants {
    return DineInData.restaurantsForFilter(_selectedFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrowseTopBar(
                  title: DineInData.category,
                  onCart: () => context.goHome(tab: 2, dineInCart: true),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: BrowseSearchBar(
                    hint: _isGridView
                        ? 'Search in Dine In…'
                        : 'Search dine-in restaurants…',
                    onTap: () {},
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
                  child: BrowseFilterChips(
                    options: DineInData.cuisineFilters,
                    selected: _selectedFilter,
                    onSelected: (v) => setState(() => _selectedFilter = v),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: DineInOrderAgainRow(
                    onSeeAll: () => context.push(BrowseRoutes.dineInOrderAgain()),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: BrowseSortBar(
                    isGridView: _isGridView,
                    onViewChanged: (v) => setState(() => _isGridView = v),
                    freeDeliveryOnly: _freeDeliveryOnly,
                    onFreeDeliveryChanged: (v) => setState(() => _freeDeliveryOnly = v),
                  ),
                ),
              ],
            ),
          ),
          if (_isGridView)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8.h,
                  crossAxisSpacing: 8.w,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => DineInRestaurantGridCard(
                    restaurant: _restaurants[index],
                    onTap: () => context.push(
                      BrowseRoutes.dineInMenu(restaurantId: _restaurants[index].id),
                    ),
                  ),
                  childCount: _restaurants.length,
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
              sliver: SliverList.separated(
                itemCount: _restaurants.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (context, index) => DineInRestaurantListCard(
                  restaurant: _restaurants[index],
                  onTap: () => context.push(
                    BrowseRoutes.dineInMenu(restaurantId: _restaurants[index].id),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
