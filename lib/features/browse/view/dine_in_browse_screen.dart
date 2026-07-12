import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  bool _bookableOnly = false;
  bool _offersOnly = false;
  String _selectedFilter = DineInData.cuisineFilters.first;

  /// Design: `rgba(44, 107, 71, 0.55)` over white → sage green.
  static const Color _screenBg = Color(0xFF8BAE9A);

  List<DineInRestaurant> get _restaurants {
    var list = DineInData.restaurantsForFilter(_selectedFilter);
    if (_bookableOnly) {
      list = list.where((r) => r.status == DineInVenueStatus.bookable).toList();
    }
    if (_offersOnly) {
      list = list
          .where((r) => r.badge != null && r.badge != 'Bookable')
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
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
                  padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
                  child: BrowseSearchBar(
                    hint: _isGridView
                        ? 'Search in Dine In…'
                        : 'Search dine-in restaurants…',
                    onTap: () {},
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 13.h, 20.w, 0),
                  child: BrowseFilterChips(
                    options: DineInData.cuisineFilters,
                    selected: _selectedFilter,
                    onSelected: (v) => setState(() => _selectedFilter = v),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 13.h, 20.w, 0),
                  child: DineInSortBar(
                    isGridView: _isGridView,
                    onViewChanged: (v) => setState(() => _isGridView = v),
                    bookableOnly: _bookableOnly,
                    onBookableChanged: (v) => setState(() => _bookableOnly = v),
                    offersOnly: _offersOnly,
                    onOffersChanged: (v) => setState(() => _offersOnly = v),
                  ),
                ),
              ],
            ),
          ),
          if (_isGridView)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 13.h, 20.w, 24.h),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 9.w,
                  childAspectRatio: 80.75 / 130,
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
              padding: EdgeInsets.fromLTRB(20.w, 13.h, 20.w, 24.h),
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
