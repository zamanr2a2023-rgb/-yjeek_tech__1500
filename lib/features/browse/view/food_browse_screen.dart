import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/browse_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/services/location_service.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/home/model/home_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class FoodBrowseScreen extends ConsumerStatefulWidget {
  const FoodBrowseScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  ConsumerState<FoodBrowseScreen> createState() => _FoodBrowseScreenState();
}

class _FoodBrowseScreenState extends ConsumerState<FoodBrowseScreen> {
  bool _isGridView = true;
  bool _freeDeliveryOnly = false;
  String _selectedFilter = 'All';
  String _sort = 'rating';
  List<String> _cuisineFilters = const ['All'];
  List<BrowseRestaurant> _restaurants = const [];
  bool _loading = true;
  bool _locationDenied = false;
  bool _outsideDeliveryArea = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final repo = ref.read(foodVendorsRepositoryProvider);
    setState(() => _loading = true);
    try {
      final position = await const LocationService().currentPosition();
      final filters = await repo.fetchCuisineFilters();
      final hasLocation = position != null;
      final sort = hasLocation && _sort == 'rating' ? 'distance' : _sort;
      var vendors = await repo.fetchVendors(
        cuisine: _selectedFilter,
        freeDelivery: _freeDeliveryOnly,
        sort: sort,
        latitude: position?.lat,
        longitude: position?.lng,
        withinDeliveryRadius: hasLocation,
      );
      // GPS outside Bahrain (or far from vendors) → radius filter is empty.
      // Fall back to the full catalog so Food is never a blank page.
      var outsideArea = false;
      if (hasLocation && vendors.isEmpty) {
        vendors = await repo.fetchVendors(
          cuisine: _selectedFilter,
          freeDelivery: _freeDeliveryOnly,
          sort: _sort,
          latitude: position?.lat,
          longitude: position?.lng,
          withinDeliveryRadius: false,
        );
        outsideArea = vendors.isNotEmpty;
      }
      if (!mounted) return;
      setState(() {
        _cuisineFilters = filters;
        if (!_cuisineFilters.contains(_selectedFilter)) {
          _selectedFilter = 'All';
        }
        _restaurants = vendors;
        _locationDenied = !hasLocation;
        _outsideDeliveryArea = outsideArea;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _restaurants = const [];
        _outsideDeliveryArea = false;
        _loading = false;
      });
    }
  }

  List<BrandItem> get _orderAgainBrands {
    final vendors = ref.watch(homeFeedProvider).valueOrNull?.reorderVendors;
    if (vendors == null || vendors.isEmpty) {
      return const [];
    }
    return vendors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(homeFeedProvider);
          ref.invalidate(foodCuisineFiltersProvider);
          await _load();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    child:                     BrowseSearchBar(
                      hint: BrowseStrings.searchInFood,
                      onTap: () => context.push(BrowseRoutes.foodSearch()),
                    ),
                  ),
                  if (_locationDenied)
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                      child: Text(
                        BrowseStrings.enableLocationFood,
                        style: AppTextStyles.caption(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else if (_outsideDeliveryArea)
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                      child: Text(
                        BrowseStrings.noRestaurantsNearby,
                        style: AppTextStyles.caption(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
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
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                    child:                     BrowseOrderAgainRow(
                      brands: _orderAgainBrands,
                      onSeeAll: () => context.goHome(tab: 1),
                      onBrandTap: (vendorId, name) {
                        if (vendorId == null || vendorId.isEmpty) return;
                        context.push(BrowseRoutes.vendorMenu(vendorId: vendorId));
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                    child: BrowseSortBar(
                      isGridView: _isGridView,
                      onViewChanged: (v) => setState(() => _isGridView = v),
                      freeDeliveryOnly: _freeDeliveryOnly,
                      onFreeDeliveryChanged: (v) {
                        setState(() => _freeDeliveryOnly = v);
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
                        BrowseRoutes.vendorMenu(
                          vendorId: _restaurants[index].id,
                        ),
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
                      BrowseRoutes.vendorMenu(
                        vendorId: _restaurants[index].id,
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
