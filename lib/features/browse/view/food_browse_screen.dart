import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class FoodBrowseScreen extends StatefulWidget {
  const FoodBrowseScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  State<FoodBrowseScreen> createState() => _FoodBrowseScreenState();
}

class _FoodBrowseScreenState extends State<FoodBrowseScreen> {
  bool _isGridView = true;
  bool _freeDeliveryOnly = false;
  String _selectedFilter = BrowseData.cuisineFilters.first;

  List<BrowseRestaurant> get _restaurants {
    var list = BrowseData.restaurantsForFilter(_selectedFilter);
    if (_freeDeliveryOnly) {
      list = list.where((r) => r.freeDelivery).toList();
    }
    return list;
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
                  title: BrowseData.category,
                  onCart: () => context.goHome(tab: 2, emptyCart: true),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: BrowseSearchBar(
                    hint: 'Search in Food…',
                    onTap: () => context.push(BrowseRoutes.foodSearch()),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
                  child: BrowseFilterChips(
                    options: BrowseData.cuisineFilters,
                    selected: _selectedFilter,
                    onSelected: (v) => setState(() => _selectedFilter = v),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: BrowseOrderAgainRow(
                    onSeeAll: () => context.goHome(tab: 1),
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
                  mainAxisSpacing: 9.h,
                  crossAxisSpacing: 9.w,
                  childAspectRatio: 80.75 / 130,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => BrowseRestaurantGridCard(
                    restaurant: _restaurants[index],
                    onTap: () => context.push(
                      BrowseRoutes.vendorMenu(vendorId: _restaurants[index].id),
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
                itemBuilder: (context, index) => BrowseRestaurantListCard(
                  restaurant: _restaurants[index],
                  onTap: () => context.push(
                    BrowseRoutes.vendorMenu(vendorId: _restaurants[index].id),
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
