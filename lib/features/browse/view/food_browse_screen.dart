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
import 'package:yjeek_app/features/browse/model/dine_in_data.dart';
import 'package:yjeek_app/features/browse/model/pickup_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/food_category_widgets.dart';
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
  FoodOrderType _orderType = FoodOrderType.delivery;
  bool _isGridView = false;
  bool _freeDeliveryOnly = false;
  bool _openNow = false;
  bool _availableOnly = false;
  bool _readyIn15 = false;
  bool _hasOffers = false;
  double? _minRating;
  int? _maxDeliveryTime;
  String _selectedCuisine = 'All';
  String _sort = 'distance';
  List<String> _cuisineFilters = const ['All'];
  List<BrowseRestaurant> _deliveryRestaurants = const [];
  List<DineInRestaurant> _dineInRestaurants = const [];
  List<PickupSpot> _pickupSpots = const [];
  bool _loading = true;
  bool _locationDenied = false;
  bool _outsideDeliveryArea = false;

  static final _sortOptionsDelivery = [
    ('distance', 'Nearest'),
    ('rating', BrowseStrings.topRated),
    ('popular', BrowseStrings.mostPopular),
    ('fastest', BrowseStrings.fastestDelivery),
  ];

  static final _sortOptionsDineIn = [
    ('distance', 'Nearest'),
    ('rating', BrowseStrings.topRated),
    ('popular', BrowseStrings.mostPopular),
  ];

  bool get _allFiltersActive =>
      _hasOffers || _minRating != null || _maxDeliveryTime != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  List<(String, String)> get _activeSortOptions {
    switch (_orderType) {
      case FoodOrderType.delivery:
        return _sortOptionsDelivery;
      case FoodOrderType.dineIn:
        return _sortOptionsDineIn;
      case FoodOrderType.pickup:
        return const [('distance', 'Nearest')];
    }
  }

  String get _sortLabel {
    for (final option in _activeSortOptions) {
      if (option.$1 == _sort) return option.$2;
    }
    return 'Nearest';
  }

  String get _cuisineChipLabel {
    if (_selectedCuisine == 'All') return 'Cuisine';
    return _selectedCuisine;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      switch (_orderType) {
        case FoodOrderType.delivery:
          await _loadDelivery();
        case FoodOrderType.dineIn:
          await _loadDineIn();
        case FoodOrderType.pickup:
          await _loadPickup();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _deliveryRestaurants = const [];
        _dineInRestaurants = const [];
        _pickupSpots = const [];
        _outsideDeliveryArea = false;
        _loading = false;
      });
    }
  }

  Future<void> _loadDelivery() async {
    final repo = ref.read(foodVendorsRepositoryProvider);
    final position = await const LocationService().currentPosition();
    final apiFilters = await repo.fetchCuisineFilters();
    final hasLocation = position != null;
    final cuisine =
        _selectedCuisine == 'All' ? null : _selectedCuisine;
    var vendors = await repo.fetchVendors(
      cuisine: cuisine,
      freeDelivery: _freeDeliveryOnly,
      openNow: _openNow,
      hasOffers: _hasOffers,
      minRating: _minRating,
      maxDeliveryTime: _maxDeliveryTime,
      sort: _sort,
      latitude: position?.lat,
      longitude: position?.lng,
      withinDeliveryRadius: hasLocation,
      supportsDelivery: true,
    );
    // Cuisine tags may be unset on vendors — soft-match name when catalog filter is empty.
    if (cuisine != null && vendors.isEmpty) {
      final unfiltered = await repo.fetchVendors(
        freeDelivery: _freeDeliveryOnly,
        openNow: _openNow,
        hasOffers: _hasOffers,
        minRating: _minRating,
        maxDeliveryTime: _maxDeliveryTime,
        sort: _sort,
        latitude: position?.lat,
        longitude: position?.lng,
        withinDeliveryRadius: hasLocation,
        supportsDelivery: true,
      );
      final q = cuisine.toLowerCase();
      vendors = unfiltered
          .where(
            (r) =>
                r.cuisine.toLowerCase().contains(q) ||
                r.name.toLowerCase().contains(q),
          )
          .toList();
    }
    var outsideArea = false;
    if (hasLocation && vendors.isEmpty) {
      vendors = await repo.fetchVendors(
        cuisine: cuisine,
        freeDelivery: _freeDeliveryOnly,
        openNow: _openNow,
        hasOffers: _hasOffers,
        minRating: _minRating,
        maxDeliveryTime: _maxDeliveryTime,
        sort: _sort,
        latitude: position.lat,
        longitude: position.lng,
        withinDeliveryRadius: false,
        supportsDelivery: true,
      );
      if (cuisine != null && vendors.isEmpty) {
        final unfiltered = await repo.fetchVendors(
          freeDelivery: _freeDeliveryOnly,
          openNow: _openNow,
          hasOffers: _hasOffers,
          minRating: _minRating,
          maxDeliveryTime: _maxDeliveryTime,
          sort: _sort,
          latitude: position.lat,
          longitude: position.lng,
          withinDeliveryRadius: false,
          supportsDelivery: true,
        );
        final q = cuisine.toLowerCase();
        vendors = unfiltered
            .where(
              (r) =>
                  r.cuisine.toLowerCase().contains(q) ||
                  r.name.toLowerCase().contains(q),
            )
            .toList();
      }
      outsideArea = vendors.isNotEmpty;
    }
    if (!mounted) return;
    final filters = _mergeCuisineFilters(apiFilters, vendors);
    setState(() {
      _cuisineFilters = filters;
      if (!_cuisineFilters.contains(_selectedCuisine)) {
        _selectedCuisine = 'All';
      }
      _deliveryRestaurants = vendors;
      _locationDenied = !hasLocation;
      _outsideDeliveryArea = outsideArea;
      _loading = false;
    });
  }

  /// Prefer API cuisine catalog; merge any tags present on loaded vendors.
  List<String> _mergeCuisineFilters(
    List<String> apiFilters,
    List<BrowseRestaurant> vendors,
  ) {
    final fromVendors = <String>{};
    for (final v in vendors) {
      for (final part in v.cuisine.split('·')) {
        final tag = part.trim();
        if (tag.isNotEmpty && tag.toLowerCase() != 'food') {
          fromVendors.add(tag);
        }
      }
    }
    final merged = <String>['All'];
    for (final name in apiFilters) {
      if (name != 'All' && !merged.contains(name)) merged.add(name);
    }
    final sortedTags = fromVendors.toList()..sort();
    for (final tag in sortedTags) {
      if (!merged.contains(tag)) merged.add(tag);
    }
    return merged;
  }

  Future<void> _loadDineIn() async {
    final repo = ref.read(dineInVendorsRepositoryProvider);
    final filters = await repo.fetchCuisineFilters();
    final vendors = await repo.fetchVendors(
      cuisine: _selectedCuisine == 'All' ? null : _selectedCuisine,
      sort: _sort,
    );
    if (!mounted) return;
    setState(() {
      _cuisineFilters = filters.length > 1 ? filters : const [
        'All',
        'Lebanese',
        'Grills',
        'Seafood',
        'Italian',
      ];
      if (!_cuisineFilters.contains(_selectedCuisine)) {
        _selectedCuisine = 'All';
      }
      _dineInRestaurants = vendors;
      _locationDenied = false;
      _outsideDeliveryArea = false;
      _loading = false;
    });
  }

  Future<void> _loadPickup() async {
    final repo = ref.read(pickupVendorsRepositoryProvider);
    final filters =
        await ref.read(foodVendorsRepositoryProvider).fetchCuisineFilters();
    final spots = await repo.fetchNearbySpots(categorySlug: 'food');
    if (!mounted) return;
    final labels = <String>{};
    for (final s in spots) {
      final label = s.categoryLabel.trim();
      if (label.isNotEmpty) labels.add(label);
    }
    final merged = <String>['All', ...filters.where((f) => f != 'All')];
    for (final label in (labels.toList()..sort())) {
      if (!merged.contains(label)) merged.add(label);
    }
    setState(() {
      _cuisineFilters = merged;
      _pickupSpots = spots;
      _locationDenied = false;
      _outsideDeliveryArea = false;
      _loading = false;
    });
  }

  List<BrowseRestaurant> get _filteredDelivery => _deliveryRestaurants;

  List<DineInRestaurant> get _filteredDineIn {
    var list = _dineInRestaurants;
    if (_openNow) {
      list = list
          .where((r) => r.status != DineInVenueStatus.closed)
          .toList();
    }
    if (_availableOnly) {
      list = list.where(dineInIsAvailableNow).toList();
    }
    return list;
  }

  List<PickupSpot> get _filteredPickup {
    var list = _pickupSpots;
    if (_readyIn15) {
      list = list.where((s) => pickupEtaMinutes(s) <= 15).toList();
    }
    if (_selectedCuisine != 'All') {
      final q = _selectedCuisine.toLowerCase();
      list = list
          .where((s) => s.categoryLabel.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  List<BrandItem> get _orderAgainBrands {
    final loggedIn = ref.watch(storageServiceProvider).hasSession;
    if (!loggedIn) return const [];
    final vendors = ref.watch(homeFeedProvider).valueOrNull?.reorderVendors;
    if (vendors == null || vendors.isEmpty) {
      return const [];
    }
    return vendors;
  }

  void _onOrderTypeChanged(FoodOrderType type) {
    if (_orderType == type) return;
    setState(() {
      _orderType = type;
      _isGridView = false;
      _freeDeliveryOnly = false;
      _openNow = false;
      _availableOnly = false;
      _readyIn15 = false;
      _hasOffers = false;
      _minRating = null;
      _maxDeliveryTime = null;
      if (type == FoodOrderType.pickup) {
        _sort = 'distance';
      }
    });
    _load();
  }

  Future<void> _showAllFiltersSheet() async {
    final result = await showModalBottomSheet<
        ({double? minRating, int? maxDeliveryTime, bool hasOffers})>(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => FoodAllFiltersSheet(
        minRating: _minRating,
        maxDeliveryTime: _maxDeliveryTime,
        hasOffers: _hasOffers,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _minRating = result.minRating;
      _maxDeliveryTime = result.maxDeliveryTime;
      _hasOffers = result.hasOffers;
    });
    await _load();
  }

  void _showCuisineSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        final options = _cuisineFilters.isEmpty
            ? const ['All']
            : _cuisineFilters;
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: options.length > 6 ? 0.55 : 0.35,
            minChildSize: 0.25,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                    child: Text(
                      'Cuisine',
                      style: AppTextStyles.titleSmall(
                        color: AppColors.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (options.length <= 1)
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                      child: Text(
                        'No cuisine options available yet.',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final cuisine = options[index];
                        final selected = _selectedCuisine == cuisine;
                        return ListTile(
                          title: Text(
                            cuisine,
                            style: TextStyle(
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          trailing: selected
                              ? const Icon(Icons.check, color: AppColors.primary)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() => _selectedCuisine = cuisine);
                            _load();
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  VoidCallback get _searchTap {
    switch (_orderType) {
      case FoodOrderType.delivery:
        return () => context.push(BrowseRoutes.foodSearch());
      case FoodOrderType.dineIn:
        return () => context.push(BrowseRoutes.dineInSearch());
      case FoodOrderType.pickup:
        return () => context.push(BrowseRoutes.pickupBrowse(category: 'food'));
    }
  }

  bool get _isEmpty {
    switch (_orderType) {
      case FoodOrderType.delivery:
        return _filteredDelivery.isEmpty;
      case FoodOrderType.dineIn:
        return _filteredDineIn.isEmpty;
      case FoodOrderType.pickup:
        return _filteredPickup.isEmpty;
    }
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
                    onSearch: _searchTap,
                    onCart: () => context.goHome(tab: 2, emptyCart: true),
                  ),
                  FoodOrderTypeTabs(
                    selected: _orderType,
                    onChanged: _onOrderTypeChanged,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
                    child: BrowseOrderAgainRow(
                      brands: _orderAgainBrands,
                      onSeeAll: () => context.goHome(tab: 1),
                      onBrandTap: (vendorId, name) {
                        if (vendorId == null || vendorId.isEmpty) return;
                        context.push(
                          BrowseRoutes.vendorMenu(vendorId: vendorId),
                        );
                      },
                    ),
                  ),
                  if (_orderType == FoodOrderType.delivery) ...[
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
                  ],
                  SizedBox(height: 12.h),
                  FoodQuickFilterRow(
                    orderType: _orderType,
                    freeDelivery: _freeDeliveryOnly,
                    openNow: _openNow,
                    availableOnly: _availableOnly,
                    readyIn15: _readyIn15,
                    cuisineLabel: _cuisineChipLabel,
                    sortLabel: _sortLabel,
                    sortOptions: _activeSortOptions,
                    filtersActive: _allFiltersActive,
                    onCuisineTap: _showCuisineSheet,
                    onFiltersTap: _orderType == FoodOrderType.delivery
                        ? _showAllFiltersSheet
                        : null,
                    onFreeDeliveryTap: () {
                      setState(() => _freeDeliveryOnly = !_freeDeliveryOnly);
                      _load();
                    },
                    onOpenNowTap: () {
                      setState(() => _openNow = !_openNow);
                      if (_orderType == FoodOrderType.delivery) {
                        _load();
                      }
                    },
                    onAvailableTap: () =>
                        setState(() => _availableOnly = !_availableOnly),
                    onReadyIn15Tap: () =>
                        setState(() => _readyIn15 = !_readyIn15),
                    onSortSelected: (v) {
                      setState(() => _sort = v);
                      _load();
                    },
                  ),
                  if (_orderType == FoodOrderType.delivery)
                    FoodViewToggleRow(
                      isGridView: _isGridView,
                      onViewChanged: (v) => setState(() => _isGridView = v),
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
            else if (_isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No restaurants found',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ..._buildListSlivers(),
          ],
        ),
      ),
      bottomNavigationBar: ShellBottomNavBar(
        currentIndex: widget.bottomNavIndex,
      ),
    );
  }

  List<Widget> _buildListSlivers() {
    switch (_orderType) {
      case FoodOrderType.delivery:
        if (_isGridView) {
          return [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final restaurant = _filteredDelivery[index];
                    return FoodDeliveryGridCard(
                      restaurant: restaurant,
                      onTap: () => context.push(
                        BrowseRoutes.vendorMenu(vendorId: restaurant.id),
                      ),
                    );
                  },
                  childCount: _filteredDelivery.length,
                ),
              ),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
            sliver: SliverList.separated(
              itemCount: _filteredDelivery.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final restaurant = _filteredDelivery[index];
                return FoodDeliveryListCard(
                  restaurant: restaurant,
                  onTap: () => context.push(
                    BrowseRoutes.vendorMenu(vendorId: restaurant.id),
                  ),
                );
              },
            ),
          ),
        ];
      case FoodOrderType.dineIn:
        return [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
            sliver: SliverList.separated(
              itemCount: _filteredDineIn.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final restaurant = _filteredDineIn[index];
                return FoodDineInListCard(
                  restaurant: restaurant,
                  onTap: () => context.push(
                    BrowseRoutes.dineInMenu(restaurantId: restaurant.id),
                  ),
                );
              },
            ),
          ),
        ];
      case FoodOrderType.pickup:
        return [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
            sliver: SliverList.separated(
              itemCount: _filteredPickup.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final spot = _filteredPickup[index];
                return FoodPickupListCard(
                  spot: spot,
                  onTap: () => context.push(
                    BrowseRoutes.vendorMenu(
                      vendorId: spot.id,
                      cartType: 'pickup',
                    ),
                  ),
                );
              },
            ),
          ),
        ];
    }
  }
}
