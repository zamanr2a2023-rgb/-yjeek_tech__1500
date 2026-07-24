import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/dine_in_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/dine_in_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class DineInBrowseScreen extends ConsumerStatefulWidget {
  const DineInBrowseScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  ConsumerState<DineInBrowseScreen> createState() => _DineInBrowseScreenState();
}

class _DineInBrowseScreenState extends ConsumerState<DineInBrowseScreen> {
  bool _isGridView = true;
  bool _bookableOnly = false;
  bool _offersOnly = false;
  String _selectedFilter = DineInData.cuisineFilters.first;
  String _sort = 'rating';
  List<String> _cuisineFilters = DineInData.cuisineFilters;
  List<DineInRestaurant> _restaurants = DineInData.restaurants;
  bool _loading = true;

  /// Design: `rgba(44, 107, 71, 0.55)` over white → sage green.
  static const Color _screenBg = Color(0xFF8BAE9A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final repo = ref.read(dineInVendorsRepositoryProvider);
    setState(() => _loading = true);
    try {
      final filters = await repo.fetchCuisineFilters();
      final vendors = await repo.fetchVendors(
        cuisine: _selectedFilter,
        bookableOnly: _bookableOnly,
        offersOnly: _offersOnly,
        sort: _sort,
      );
      if (!mounted) return;
      setState(() {
        _cuisineFilters = filters;
        if (!_cuisineFilters.contains(_selectedFilter)) {
          _selectedFilter = 'All';
        }
        _restaurants = vendors;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _restaurants = const [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                      onTap: () => context.push(BrowseRoutes.dineInSearch()),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 13.h, 20.w, 0),
                    child: BrowseFilterChips(
                      options: _cuisineFilters,
                      selected: _selectedFilter,
                      onSelected: (v) {
                        setState(() => _selectedFilter = v);
                        _load();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 13.h, 20.w, 0),
                    child: DineInSortBar(
                      isGridView: _isGridView,
                      onViewChanged: (v) => setState(() => _isGridView = v),
                      bookableOnly: _bookableOnly,
                      onBookableChanged: (v) {
                        setState(() => _bookableOnly = v);
                        _load();
                      },
                      offersOnly: _offersOnly,
                      onOffersChanged: (v) {
                        setState(() => _offersOnly = v);
                        _load();
                      },
                      sort: _sort,
                      onSortChanged: (v) {
                        setState(() => _sort = v);
                        _load();
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_isGridView)
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
                        BrowseRoutes.dineInMenu(
                          restaurantId: _restaurants[index].id,
                        ),
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
                      BrowseRoutes.dineInMenu(
                        restaurantId: _restaurants[index].id,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: ShellBottomNavBar(
        currentIndex: widget.bottomNavIndex,
      ),
    );
  }
}
