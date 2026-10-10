import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/browse_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/location/provider/delivery_location_provider.dart';
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
  const FoodBrowseScreen({
    super.key,
    this.bottomNavIndex = 0,
    this.categorySlug,
  });

  final int bottomNavIndex;

  /// Store type slug from the category tile. Null means the Food store type.
  final String? categorySlug;

  @override
  ConsumerState<FoodBrowseScreen> createState() => _FoodBrowseScreenState();
}

class _FoodBrowseScreenState extends ConsumerState<FoodBrowseScreen> {
  String get _storeCategory {
    final slug = widget.categorySlug?.trim();
    if (slug == null || slug.isEmpty) return 'food';
    return slug;
  }

  void _openVendorMenu(String vendorId, {String? cartType}) {
    context.push(
      BrowseRoutes.vendorMenu(
        vendorId: vendorId,
        tab: widget.bottomNavIndex,
        cartType: cartType ?? _cartTypeFor(_orderType),
        returnTo: BrowseRoutes.foodBrowse(
          tab: widget.bottomNavIndex,
          category: _storeCategory,
        ),
      ),
    );
  }

  String? _cartTypeFor(FoodOrderType type) {
    return switch (type) {
      FoodOrderType.pickup => 'pickup',
      FoodOrderType.dineIn => 'dine_in',
      FoodOrderType.delivery => null,
    };
  }

  FoodOrderType _orderType = FoodOrderType.delivery;
  bool _isGridView = false;
  bool _freeDeliveryOnly = false;
  bool _openNow = false;
  bool _availableOnly = false;
  bool _readyIn15 = false;
  bool _hasOffers = false;
  bool _acceptsMyVouchers = false;
  double? _minRating;
  int? _maxDeliveryTime;
  final Set<String> _selectedCuisines = {};
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
      _hasOffers ||
      _acceptsMyVouchers ||
      _minRating != null ||
      _maxDeliveryTime != null;

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
    if (_selectedCuisines.isEmpty) return 'Cuisine';
    if (_selectedCuisines.length == 1) return _selectedCuisines.first;
    return '${_selectedCuisines.length} cuisines';
  }

  void _pruneSelectedCuisines() {
    _selectedCuisines.removeWhere((c) => !_cuisineFilters.contains(c));
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
    var delivery = ref.read(deliveryLocationProvider).valueOrNull;
    if (delivery == null || !delivery.hasCoordinates) {
      await ref.read(deliveryLocationProvider.notifier).refresh(force: true);
      delivery = ref.read(deliveryLocationProvider).valueOrNull;
    }
    final hasLocation = delivery?.hasCoordinates ?? false;
    final lat = delivery?.latitude;
    final lng = delivery?.longitude;
    final apiFilters = await repo.fetchCuisineFilters(category: _storeCategory);
    final cuisines = _selectedCuisines.toList();
    // Same discovery scope as Pickup/Dine-in — do not hide vendors outside
    // delivery radius on the list (checkout still validates range).
    var vendors = await repo.fetchVendors(
      category: _storeCategory,
      cuisines: cuisines,
      freeDelivery: _freeDeliveryOnly,
      openNow: _openNow,
      hasOffers: _hasOffers,
      acceptsMyVouchers: _acceptsMyVouchers,
      minRating: _minRating,
      maxDeliveryTime: _maxDeliveryTime,
      sort: _sort,
      latitude: lat,
      longitude: lng,
      withinDeliveryRadius: false,
      supportsDelivery: true,
    );
    vendors = vendors.where((r) => r.supportsDelivery).toList();
    // Cuisine tags may be unset on vendors — soft-match when catalog filter is empty.
    if (cuisines.isNotEmpty && vendors.isEmpty) {
      final unfiltered = await repo.fetchVendors(
        category: _storeCategory,
        freeDelivery: _freeDeliveryOnly,
        openNow: _openNow,
        hasOffers: _hasOffers,
        acceptsMyVouchers: _acceptsMyVouchers,
        minRating: _minRating,
        maxDeliveryTime: _maxDeliveryTime,
        sort: _sort,
        latitude: lat,
        longitude: lng,
        withinDeliveryRadius: false,
        supportsDelivery: true,
      );
      vendors = unfiltered
          .where(
            (r) =>
                r.supportsDelivery &&
                (vendorMatchesCuisineQuery(r, cuisines) ||
                    cuisines.any(
                      (c) => r.name.toLowerCase().contains(c.toLowerCase()),
                    )),
          )
          .toList();
    }
    const outsideArea = false;
    if (!mounted) return;
    final filters = _mergeCuisineFilters(apiFilters, vendors);
    setState(() {
      _cuisineFilters = filters;
      _pruneSelectedCuisines();
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
      for (final tag in v.cuisineTags) {
        final trimmed = tag.trim();
        if (trimmed.isNotEmpty) fromVendors.add(trimmed);
      }
      final primary = v.cuisine.trim();
      if (primary.isNotEmpty && primary.toLowerCase() != 'food') {
        fromVendors.add(primary);
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
    final foodRepo = ref.read(foodVendorsRepositoryProvider);
    var delivery = ref.read(deliveryLocationProvider).valueOrNull;
    if (delivery == null || !delivery.hasCoordinates) {
      await ref.read(deliveryLocationProvider.notifier).refresh(force: true);
      delivery = ref.read(deliveryLocationProvider).valueOrNull;
    }
    final hasLocation = delivery?.hasCoordinates ?? false;
    final lat = delivery?.latitude;
    final lng = delivery?.longitude;
    final apiFilters = await foodRepo.fetchCuisineFilters(
      category: _storeCategory,
    );
    final cuisines = _selectedCuisines.toList();
    var vendors = await foodRepo.fetchVendors(
      category: _storeCategory,
      cuisines: cuisines,
      openNow: _openNow,
      sort: _sort,
      latitude: lat,
      longitude: lng,
      supportsDelivery: false,
      supportsDineIn: true,
    );
    vendors = vendors.where((r) => r.supportsDineIn).toList();
    if (cuisines.isNotEmpty && vendors.isEmpty) {
      final unfiltered = await foodRepo.fetchVendors(
        category: _storeCategory,
        openNow: _openNow,
        sort: _sort,
        latitude: lat,
        longitude: lng,
        supportsDelivery: false,
        supportsDineIn: true,
      );
      vendors = unfiltered
          .where(
            (r) =>
                r.supportsDineIn &&
                (vendorMatchesCuisineQuery(r, cuisines) ||
                    cuisines.any(
                      (c) => r.name.toLowerCase().contains(c.toLowerCase()),
                    )),
          )
          .toList();
    }
    if (!mounted) return;
    final filters = _mergeCuisineFilters(apiFilters, vendors);
    setState(() {
      _cuisineFilters = filters;
      _pruneSelectedCuisines();
      _dineInRestaurants = vendors.map(_dineInFromFoodVendor).toList();
      _locationDenied = !hasLocation;
      _outsideDeliveryArea = false;
      _loading = false;
    });
  }

  Future<void> _loadPickup() async {
    final foodRepo = ref.read(foodVendorsRepositoryProvider);
    var delivery = ref.read(deliveryLocationProvider).valueOrNull;
    if (delivery == null || !delivery.hasCoordinates) {
      await ref.read(deliveryLocationProvider.notifier).refresh(force: true);
      delivery = ref.read(deliveryLocationProvider).valueOrNull;
    }
    final hasLocation = delivery?.hasCoordinates ?? false;
    final lat = delivery?.latitude;
    final lng = delivery?.longitude;
    final apiFilters = await foodRepo.fetchCuisineFilters(
      category: _storeCategory,
    );
    final cuisines = _selectedCuisines.toList();
    var vendors = await foodRepo.fetchVendors(
      category: _storeCategory,
      cuisines: cuisines,
      openNow: _openNow,
      sort: 'distance',
      latitude: lat,
      longitude: lng,
      supportsDelivery: false,
      supportsPickup: true,
    );
    vendors = vendors.where((r) => r.supportsPickup).toList();
    if (cuisines.isNotEmpty && vendors.isEmpty) {
      final unfiltered = await foodRepo.fetchVendors(
        category: _storeCategory,
        openNow: _openNow,
        sort: 'distance',
        latitude: lat,
        longitude: lng,
        supportsDelivery: false,
        supportsPickup: true,
      );
      vendors = unfiltered
          .where(
            (r) =>
                r.supportsPickup &&
                (vendorMatchesCuisineQuery(r, cuisines) ||
                    cuisines.any(
                      (c) => r.name.toLowerCase().contains(c.toLowerCase()),
                    )),
          )
          .toList();
    }
    if (!mounted) return;
    final spots = vendors.map(_pickupSpotFromFoodVendor).toList();
    final merged = _mergeCuisineFilters(apiFilters, vendors);
    setState(() {
      _cuisineFilters = merged;
      _pruneSelectedCuisines();
      _pickupSpots = spots;
      _locationDenied = !hasLocation;
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
      _acceptsMyVouchers = false;
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
        ({
          double? minRating,
          int? maxDeliveryTime,
          bool hasOffers,
          bool acceptsMyVouchers,
        })>(
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
        acceptsMyVouchers: _acceptsMyVouchers,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _minRating = result.minRating;
      _maxDeliveryTime = result.maxDeliveryTime;
      _hasOffers = result.hasOffers;
      _acceptsMyVouchers = result.acceptsMyVouchers;
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
      builder: (sheetContext) {
        final options = _cuisineFilters.isEmpty
            ? const ['All']
            : _cuisineFilters;
        return StatefulBuilder(
          builder: (context, sheetSetState) {
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
                        final isAll = cuisine == 'All';
                        final selected = isAll
                            ? _selectedCuisines.isEmpty
                            : _selectedCuisines.contains(cuisine);
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
                            if (isAll) {
                              Navigator.pop(context);
                              setState(() => _selectedCuisines.clear());
                              _load();
                              return;
                            }
                            setState(() {
                              if (_selectedCuisines.contains(cuisine)) {
                                _selectedCuisines.remove(cuisine);
                              } else {
                                _selectedCuisines.add(cuisine);
                              }
                            });
                            sheetSetState(() {});
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
      },
    );
  }

  VoidCallback get _searchTap {
    switch (_orderType) {
      case FoodOrderType.delivery:
        return () => context.push(
          BrowseRoutes.foodSearch(category: _storeCategory),
        );
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
      body: SafeArea(
        bottom: false,
        minimum: EdgeInsets.only(
          top: MediaQuery.viewPaddingOf(context).top,
        ),
        child: RefreshIndicator(
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
                        _openVendorMenu(vendorId);
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
      ),
      bottomNavigationBar: ShellBottomNavBar(
        currentIndex: widget.bottomNavIndex,
      ),
    );
  }

  SliverGridDelegate _foodBrowseGridDelegate() {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 0.82,
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
                gridDelegate: _foodBrowseGridDelegate(),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final restaurant = _filteredDelivery[index];
                    return FoodDeliveryGridCard(
                      restaurant: restaurant,
                      onTap: () => _openVendorMenu(restaurant.id),
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
                  onTap: () => _openVendorMenu(restaurant.id),
                );
              },
            ),
          ),
        ];
      case FoodOrderType.dineIn:
        if (_isGridView) {
          return [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
              sliver: SliverGrid(
                gridDelegate: _foodBrowseGridDelegate(),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final restaurant = _filteredDineIn[index];
                    return FoodDineInGridCard(
                      restaurant: restaurant,
                      onTap: () => _openVendorMenu(restaurant.id),
                    );
                  },
                  childCount: _filteredDineIn.length,
                ),
              ),
            ),
          ];
        }
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
                  onTap: () => _openVendorMenu(restaurant.id),
                );
              },
            ),
          ),
        ];
      case FoodOrderType.pickup:
        if (_isGridView) {
          return [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
              sliver: SliverGrid(
                gridDelegate: _foodBrowseGridDelegate(),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final spot = _filteredPickup[index];
                    return FoodPickupGridCard(
                      spot: spot,
                      onTap: () => _openVendorMenu(spot.id, cartType: 'pickup'),
                    );
                  },
                  childCount: _filteredPickup.length,
                ),
              ),
            ),
          ];
        }
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
                  onTap: () => _openVendorMenu(spot.id, cartType: 'pickup'),
                );
              },
            ),
          ),
        ];
    }
  }
}

DineInRestaurant _dineInFromFoodVendor(BrowseRestaurant r) {
  final label = r.dineInAvailableLabel?.trim();
  return DineInRestaurant(
    id: r.id,
    name: r.name,
    cuisine: r.cuisine,
    rating: r.rating,
    gradientStart: r.gradientStart,
    gradientEnd: r.gradientEnd,
    badge: r.badge,
    distance: r.distance,
    status: r.isOpen ? DineInVenueStatus.open : DineInVenueStatus.closed,
    subtitle: r.area,
    reviewCount: r.reviewCount,
    tableMin: r.dineInTablesAvailable ?? 2,
    statusLabel: label?.isNotEmpty == true
        ? label!
        : (r.isOpen ? 'Open now' : 'Closed'),
    imageUrl: r.displayLogoUrl,
  );
}

PickupSpot _pickupSpotFromFoodVendor(BrowseRestaurant r) {
  final ready = r.readyInMin ?? r.prepTimeMin ?? r.deliveryMin;
  final cuisine = r.cuisine.trim();
  return PickupSpot(
    id: r.id,
    name: r.name,
    rating: r.rating,
    categoryLabel: cuisine.isNotEmpty ? cuisine : 'Food',
    distance: r.distance,
    pickupEta: '~$ready min',
    imageUrl: r.displayLogoUrl,
    gradientStart: r.gradientStart,
    gradientEnd: r.gradientEnd,
  );
}
