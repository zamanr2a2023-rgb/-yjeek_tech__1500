import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/features/location/provider/delivery_location_provider.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/food_vendors_repository.dart';
import 'package:yjeek_app/features/browse/model/vendor_menu_grouping.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/food_category_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/vendor_menu_widgets.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/cart/model/pending_add_to_cart.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/geofence/model/active_geofence_order_context.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/l10n/locale_controller.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/features/ui_content/view/ui_banner_widgets.dart';

class VendorMenuScreen extends ConsumerStatefulWidget {
  const VendorMenuScreen({
    super.key,
    required this.vendorId,
    this.bottomNavIndex = 0,
    this.cartType,
    this.returnTo,
  });

  final String vendorId;
  final int bottomNavIndex;

  /// When `pickup` / `dine_in`, item detail adds to that cart type.
  final String? cartType;

  /// Where to go when the route stack cannot pop (deep link / `go()` entry).
  final String? returnTo;

  @override
  ConsumerState<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends ConsumerState<VendorMenuScreen> {
  BrowseRestaurant? _restaurant;
  List<String> _sections = const [];
  List<BrowseMenuItem> _allItems = const [];
  List<VendorMenuChipGroup> _chipGroups = const [];
  String _selectedChip = '';
  final Set<String> _expandedAccordions = {};
  String _menuQuery = '';
  FoodCartSummary _cart = FoodCartSummary.empty;
  bool _loading = true;
  bool _loadedOnce = false;
  bool _menuSwitching = false;
  String? _addingItemId;
  Timer? _searchDebounce;
  bool _isGridView = false;
  bool _searchVisible = false;
  late FoodOrderType _orderType;
  late String _cartMode;
  int _loadGen = 0;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _menuScroll = ScrollController();
  final Map<
      String,
      ({
        List<String> sections,
        List<BrowseMenuItem> items,
        List<VendorMenuChipGroup> chipGroups,
      })> _menuCache = {};
  VendorMenuChipGroup? get _activeChipGroup {
    for (final g in _chipGroups) {
      if (g.label == _selectedChip) return g;
    }
    return _chipGroups.isNotEmpty ? _chipGroups.first : null;
  }

  bool get _isPickup => _cartMode == 'PICKUP';
  bool get _isDineIn => _cartMode == 'DINE_IN';

  /// Query param for item-detail / routes (`pickup` | `dine_in` | null).
  String? get _routeCartType {
    if (_isPickup) return 'pickup';
    if (_isDineIn) return 'dine_in';
    return null;
  }

  String get _apiCartType {
    if (_isPickup) return 'PICKUP';
    if (_isDineIn) return 'DINE_IN';
    return 'DELIVERY';
  }

  void _applyMenuChipGroups(List<VendorMenuChipGroup> groups) {
    _chipGroups = groups.isNotEmpty
        ? groups
        : buildVendorMenuChipGroups(sections: _sections, items: _allItems);
    if (_chipGroups.isEmpty) {
      _selectedChip = '';
      _expandedAccordions.clear();
      return;
    }
    if (!_chipGroups.any((g) => g.label == _selectedChip)) {
      _selectedChip = _chipGroups.first.label;
    }
    final chip = _activeChipGroup;
    final titles = chip?.accordions.map((a) => a.title).toList() ?? const [];
    _expandedAccordions.removeWhere((title) => !titles.contains(title));
    if (_expandedAccordions.isEmpty && titles.isNotEmpty) {
      _expandedAccordions.add(titles.first);
    }
  }

  void _onChipSelected(String chip) {
    setState(() {
      _selectedChip = chip;
      final group = _activeChipGroup;
      _expandedAccordions
        ..clear()
        ..addAll(
          group != null && group.accordions.isNotEmpty
              ? [group.accordions.first.title]
              : const <String>[],
        );
    });
  }

  void _onAccordionTap(String title) {
    setState(() {
      if (_expandedAccordions.contains(title)) {
        _expandedAccordions.remove(title);
      } else {
        _expandedAccordions.add(title);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final raw = (widget.cartType ?? '').toLowerCase().replaceAll('-', '_');
    if (raw == 'pickup') {
      _cartMode = 'PICKUP';
      _orderType = FoodOrderType.pickup;
    } else if (raw == 'dine_in' || raw == 'dinein') {
      _cartMode = 'DINE_IN';
      _orderType = FoodOrderType.dineIn;
    } else {
      _cartMode = 'DELIVERY';
      _orderType = FoodOrderType.delivery;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = ref.read(activeGeofenceOrderContextProvider);
      if (ctx != null && ctx.vendorId != widget.vendorId) {
        clearGeofenceOrderContext(ref);
      }
      _load();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _menuScroll.dispose();
    super.dispose();
  }

  void _onMenuQueryChanged(String value) {
    _menuQuery = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _load(query: value, soft: _loadedOnce);
    });
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) {
        _searchController.clear();
        if (_menuQuery.isNotEmpty) {
          _onMenuQueryChanged('');
        }
      }
    });
  }

  Future<void> _openVendorMap(BrowseRestaurant restaurant) async {
    final lat = restaurant.latitude;
    final lng = restaurant.longitude;
    final uri = lat != null && lng != null
        ? Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng')
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(restaurant.name)}',
          );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  double _expandedHeaderHeight(BuildContext context) =>
      VendorMenuLayout.expandedBodyHeight(
        context,
        searchVisible: _searchVisible,
      );

  Widget _menuBottomNav() {
    return HomeBottomNavBar(
      currentIndex: widget.bottomNavIndex,
      onTap: (index) {
        if (index == 2) {
          _openMatchingCart();
          return;
        }
        if (index == 0) {
          context.goHome(tab: 0);
          return;
        }
        if (index == widget.bottomNavIndex && context.canPop()) {
          context.pop();
          return;
        }
        context.goHome(tab: index);
      },
    );
  }

  void _openMatchingCart() {
    final notifier = ref.read(shellProvider.notifier);
    switch (_orderType) {
      case FoodOrderType.dineIn:
        notifier.openDineInCartWithItems();
      case FoodOrderType.pickup:
        notifier.openPickupCartWithItems();
      case FoodOrderType.delivery:
        notifier.openCartWithItems();
    }
    context.goHome(
      tab: 2,
      cartHasItems: _orderType == FoodOrderType.delivery,
      dineInCart: _orderType == FoodOrderType.dineIn,
      pickupCart: _orderType == FoodOrderType.pickup,
    );
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    final returnTo = widget.returnTo?.trim();
    if (returnTo != null && returnTo.isNotEmpty) {
      context.go(returnTo);
      return;
    }
    navigateBack(context);
  }

  double _pinnedFiltersHeightEstimate(BuildContext context) =>
      VendorMenuLayout.pinnedFiltersHeight(context);

  Widget _pinnedFiltersBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: VendorMenuCategoryChips(
            sections: _chipGroups.map((g) => g.label).toList(),
            selected: _selectedChip,
            onSelected: _onChipSelected,
          ),
        ),
        VendorMenuViewToggleRow(
          isGridView: _isGridView,
          onViewChanged: (v) => setState(() => _isGridView = v),
        ),
        SizedBox(height: 6.h),
      ],
    );
  }

  Widget _pinnedFilters() {
    return ColoredBox(
      color: AppColors.white,
      child: SizedBox(
        height: _pinnedFiltersHeightEstimate(context),
        child: ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            child: _pinnedFiltersBody(),
          ),
        ),
      ),
    );
  }

  void _onOrderTypeChanged(FoodOrderType type) {
    final restaurant = _restaurant;
    if (restaurant == null) return;
    if (_orderType == type) return;

    switch (type) {
      case FoodOrderType.delivery:
        if (!restaurant.supportsDelivery) return;
        _switchOrderType(FoodOrderType.delivery, 'DELIVERY');
      case FoodOrderType.dineIn:
        if (!restaurant.supportsDineIn) return;
        _switchOrderType(FoodOrderType.dineIn, 'DINE_IN');
      case FoodOrderType.pickup:
        if (!restaurant.supportsPickup) return;
        _switchOrderType(FoodOrderType.pickup, 'PICKUP');
    }
  }

  void _switchOrderType(FoodOrderType type, String cartMode) {
    final cacheKey = '$cartMode|${_menuQuery.trim()}';
    final cached = _menuCache[cacheKey];

    setState(() {
      _orderType = type;
      _cartMode = cartMode;
      if (cached != null) {
        _sections = cached.sections;
        _allItems = cached.items;
        _applyMenuChipGroups(cached.chipGroups);
        _menuSwitching = false;
        _loading = false;
      } else {
        _menuSwitching = true;
      }
    });

    // Soft reload: keep UI mounted; refresh menu + matching cart.
    _load(query: _menuQuery, soft: true);
  }

  String get _menuOrderTypeParam {
    switch (_orderType) {
      case FoodOrderType.delivery:
        return 'DELIVERY';
      case FoodOrderType.pickup:
        return 'PICKUP';
      case FoodOrderType.dineIn:
        return 'DINE_IN';
    }
  }

  Set<FoodOrderType> get _enabledOrderTypes {
    final r = _restaurant;
    if (r == null) {
      return {_orderType};
    }
    return {
      if (r.supportsDelivery) FoodOrderType.delivery,
      if (r.supportsDineIn) FoodOrderType.dineIn,
      if (r.supportsPickup) FoodOrderType.pickup,
    };
  }

  Future<void> _load({String? query, bool soft = false}) async {
    final q = query ?? _menuQuery;
    final requestedOrderType = _menuOrderTypeParam;
    final requestedCartMode = _cartMode;
    final cacheKey = '$requestedOrderType|${q.trim()}';
    final gen = ++_loadGen;
    final showBlocking = !_loadedOnce;

    if (showBlocking) {
      setState(() => _loading = true);
    } else if (soft && !_menuCache.containsKey(cacheKey)) {
      setState(() => _menuSwitching = true);
    }

    try {
      final repo = ref.read(foodVendorsRepositoryProvider);
      var delivery = ref.read(deliveryLocationProvider).valueOrNull;
      if (delivery == null || !delivery.hasCoordinates) {
        await ref.read(deliveryLocationProvider.notifier).refresh();
        delivery = ref.read(deliveryLocationProvider).valueOrNull;
      }
      if (!mounted || gen != _loadGen) return;
      final lat = delivery?.latitude;
      final lng = delivery?.longitude;
      var menu = await repo.fetchVendorMenu(
        widget.vendorId,
        query: q,
        orderType: requestedOrderType,
        latitude: lat,
        longitude: lng,
      );
      if (!mounted || gen != _loadGen) return;

      var restaurant = menu.restaurant;
      final enabled = <FoodOrderType>{
        if (restaurant.supportsDelivery) FoodOrderType.delivery,
        if (restaurant.supportsDineIn) FoodOrderType.dineIn,
        if (restaurant.supportsPickup) FoodOrderType.pickup,
      };
      var effectiveOrderType = _orderType;
      var effectiveCartMode = requestedCartMode;
      var effectiveOrderParam = requestedOrderType;
      if (!enabled.contains(effectiveOrderType) && enabled.isNotEmpty) {
        effectiveOrderType = enabled.first;
        effectiveCartMode = switch (effectiveOrderType) {
          FoodOrderType.pickup => 'PICKUP',
          FoodOrderType.dineIn => 'DINE_IN',
          FoodOrderType.delivery => 'DELIVERY',
        };
        effectiveOrderParam = effectiveCartMode;
        menu = await repo.fetchVendorMenu(
          widget.vendorId,
          query: q,
          orderType: effectiveOrderParam,
          latitude: lat,
          longitude: lng,
        );
        if (!mounted || gen != _loadGen) return;
        restaurant = menu.restaurant;
      }

      final cart = await repo.fetchDeliveryCart(cartType: effectiveCartMode);
      if (!mounted || gen != _loadGen) return;

      // Only resolve GPS distance once — reuse on soft order-type switches.
      if (_restaurant?.distanceKm == null ||
          restaurant.latitude != _restaurant?.latitude ||
          restaurant.longitude != _restaurant?.longitude) {
        var delivery = ref.read(deliveryLocationProvider).valueOrNull;
        if (delivery == null || !delivery.hasCoordinates) {
          await ref.read(deliveryLocationProvider.notifier).refresh();
          delivery = ref.read(deliveryLocationProvider).valueOrNull;
        }
        if (!mounted || gen != _loadGen) return;
        if (delivery != null &&
            delivery.hasCoordinates &&
            restaurant.latitude != null &&
            restaurant.longitude != null) {
          final km = _haversineKm(
            delivery.latitude!,
            delivery.longitude!,
            restaurant.latitude!,
            restaurant.longitude!,
          );
          restaurant = restaurant.copyWith(
            distanceKm: km,
            distance: '${km.toStringAsFixed(1)} km',
          );
        }
      } else if (_restaurant?.distanceKm != null) {
        restaurant = restaurant.copyWith(
          distanceKm: _restaurant!.distanceKm,
          distance: _restaurant!.distance,
        );
      }

      final sections = menu.sections.isEmpty && menu.items.isNotEmpty
          ? menu.items.map((e) => e.section).toSet().toList()
          : menu.sections;
      final storeKey = '$effectiveOrderParam|${q.trim()}';
      _menuCache[storeKey] = (
        sections: sections,
        items: menu.items,
        chipGroups: menu.chipGroups,
      );
      setState(() {
        _orderType = effectiveOrderType;
        _cartMode = effectiveCartMode;
        _restaurant = restaurant;
        _sections = sections;
        _allItems = menu.items;
        _applyMenuChipGroups(menu.chipGroups);
        _cart = cart;
        _loading = false;
        _menuSwitching = false;
        _loadedOnce = true;
        _menuQuery = q;
      });
    } catch (_) {
      if (!mounted || gen != _loadGen) return;
      setState(() {
        if (!_loadedOnce) {
          _sections = const [];
          _allItems = const [];
          _chipGroups = const [];
          _selectedChip = '';
          _expandedAccordions.clear();
          _restaurant = null;
        }
        _loading = false;
        _menuSwitching = false;
        _loadedOnce = true;
      });
    }
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthKm * c;
  }

  double _degToRad(double deg) => deg * math.pi / 180;

  Future<void> _onItemAction(BrowseMenuItem item) async {
    if (item.hasModifiers) {
      await _openItem(item);
      return;
    }
    await _addItemDirectly(item);
  }

  Future<void> _openItem(BrowseMenuItem item) async {
    final cartVendorId = _cart.vendorId;
    final needsReplace =
        cartVendorId != null &&
        cartVendorId.isNotEmpty &&
        cartVendorId != widget.vendorId &&
        _cart.itemCount > 0;

    void goDetail() {
      context
          .push(
            BrowseRoutes.itemDetail(
              vendorId: widget.vendorId,
              itemId: item.id,
              cartType: _routeCartType,
            ),
          )
          .then((_) {
            if (mounted) _load(query: _menuQuery, soft: true);
          });
    }

    if (needsReplace) {
      showCartNewCartDialog(context, onConfirm: goDetail);
      return;
    }
    goDetail();
  }

  Future<void> _addItemDirectly(BrowseMenuItem item) async {
    if (_addingItemId != null) return;

    if (!ref.read(storageServiceProvider).hasSession) {
      rememberPendingAddToCart(
        ref,
        PendingAddToCart(
          productId: item.id,
          quantity: 1,
          cartType: _apiCartType,
          vendorId: widget.vendorId,
          geofenceTriggerId: resolveGeofenceTriggerId(
            ref,
            vendorId: widget.vendorId,
            orderType: _apiCartType,
          ),
          returnPath: currentReturnPath(context),
          vertical: PendingCartVertical.food,
        ),
      );
    }
    if (!await requireLogin(context, ref)) return;
    if (!mounted) return;

    final cartVendorId = _cart.vendorId;
    final needsReplace =
        cartVendorId != null &&
        cartVendorId.isNotEmpty &&
        cartVendorId != widget.vendorId &&
        _cart.itemCount > 0;

    Future<void> doAdd({bool replace = false}) async {
      setState(() => _addingItemId = item.id);
      final rangeArgs = ref
          .read(deliveryLocationProvider)
          .valueOrNull
          ?.forRangeCheck;
      final result = await ref
          .read(foodVendorsRepositoryProvider)
          .addToCart(
            productId: item.id,
            quantity: 1,
            replaceCart: replace,
            cartType: _apiCartType,
            vendorId: widget.vendorId,
            geofenceTriggerId: resolveGeofenceTriggerId(
              ref,
              vendorId: widget.vendorId,
              orderType: _apiCartType,
            ),
            deliveryAddressId: rangeArgs?.addressId,
            deliveryLatitude: rangeArgs?.latitude,
            deliveryLongitude: rangeArgs?.longitude,
          );
      if (!mounted) return;
      setState(() => _addingItemId = null);

      if (result.ok) {
        clearPendingAddToCart(ref);
        ref
            .read(shellProvider.notifier)
            .markCartUpdated(
              delivery: _cartMode == 'DELIVERY',
              pickup: _cartMode == 'PICKUP',
              dineIn: _cartMode == 'DINE_IN',
            );
        try {
          final cart = await ref
              .read(foodVendorsRepositoryProvider)
              .fetchDeliveryCart(cartType: _apiCartType);
          if (mounted) setState(() => _cart = cart);
        } catch (_) {}
        if (!mounted) return;
        final notice = result.message;
        if (notice != null && notice.isNotEmpty) {
          await acknowledgeExtraDeliveryCharge(context, notice);
          if (!mounted) return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.localizedName} added to cart'),
            duration: const Duration(seconds: 1),
          ),
        );
        return;
      }
      if (result.outOfRange) {
        rememberPendingAddToCart(
          ref,
          PendingAddToCart(
            productId: item.id,
            quantity: 1,
            cartType: _apiCartType,
            vendorId: widget.vendorId,
            geofenceTriggerId: resolveGeofenceTriggerId(
              ref,
              vendorId: widget.vendorId,
              orderType: _apiCartType,
            ),
            replaceCart: replace,
            vertical: PendingCartVertical.food,
          ),
        );
        await pushOutOfDelivery(context);
        return;
      }
      if (result.vendorConflict) {
        showCartNewCartDialog(context, onConfirm: () => doAdd(replace: true));
        return;
      }
      if (await redirectToLoginIfAuthError(context, ref, result.message)) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Could not add to cart')),
      );
    }

    if (needsReplace) {
      showCartNewCartDialog(context, onConfirm: () => doAdd(replace: true));
      return;
    }
    await doAdd();
  }

  Widget _buildMenuBody() {
    final chip = _activeChipGroup;
    if (chip == null || chip.accordions.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        child: Text(
          _menuQuery.trim().isEmpty
              ? 'No items available right now'
              : 'No items found',
          style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
        ),
      );
    }

    final children = <Widget>[];
    for (final accordion in chip.accordions) {
      final expanded = _expandedAccordions.contains(accordion.title);
      children.add(
        VendorMenuSectionHeader(
          title: accordion.title,
          expanded: expanded,
          onTap: () => _onAccordionTap(accordion.title),
        ),
      );
      if (!expanded) continue;

      if (accordion.allItems.isEmpty) {
        children.add(
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: Text(
              _menuQuery.trim().isEmpty
                  ? 'No items in this category'
                  : 'No items found',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ),
        );
        continue;
      }

      for (final group in accordion.groups) {
        final label = group.label?.trim();
        if (label != null && label.isNotEmpty) {
          children.add(VendorMenuSubgroupLabel(label: label));
        }

        if (_isGridView) {
          children.add(
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  childAspectRatio: 0.72,
                ),
                itemCount: group.items.length,
                itemBuilder: (context, index) {
                  final item = group.items[index];
                  return VendorMenuGridItem(
                    item: item,
                    onTap: () => _openItem(item),
                    onAdd: () => _onItemAction(item),
                    isAdding: _addingItemId == item.id,
                  );
                },
              ),
            ),
          );
        } else {
          for (var i = 0; i < group.items.length; i++) {
            final item = group.items[i];
            children.add(
              VendorMenuItemRow(
                item: item,
                onTap: () => _openItem(item),
                onAdd: () => _onItemAction(item),
                isAdding: _addingItemId == item.id,
              ),
            );
            if (i < group.items.length - 1) {
              children.add(
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE2E2E2),
                  ),
                ),
              );
            }
          }
        }
      }
      children.add(SizedBox(height: 4.h));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeControllerProvider);
    if (!_loadedOnce && _loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        bottomNavigationBar: ShellBottomNavBar(
          currentIndex: widget.bottomNavIndex,
        ),
      );
    }
    final restaurant = _restaurant;
    if (restaurant == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Could not load this menu',
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          ),
        ),
        bottomNavigationBar: ShellBottomNavBar(
          currentIndex: widget.bottomNavIndex,
        ),
      );
    }
    final showFilters = _chipGroups.isNotEmpty;
    final collapsedHeight = VendorMenuCollapsedBar.contentHeight(context);
    final footerHeight = showFilters
        ? _pinnedFiltersHeightEstimate(context)
        : 0.0;
    final expandedHeight = math.max(
      _expandedHeaderHeight(context),
      collapsedHeight,
    );
    final expandedHeader = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VendorMenuCoverHeader(
          restaurant: restaurant,
          onBack: _handleBack,
          onSearchTap: _toggleSearch,
          showSearchField: _searchVisible,
          searchController: _searchController,
          onSearchChanged: _onMenuQueryChanged,
          onSearchClose: _toggleSearch,
        ),
        VendorMenuIdentityBar(restaurant: restaurant),
        VendorMenuOrderTypeTabs(
          selected: _orderType,
          onChanged: _onOrderTypeChanged,
          enabledTypes: _enabledOrderTypes,
        ),
        VendorMenuStatsRow(restaurant: restaurant, orderType: _orderType),
        const Divider(height: 1, color: Color(0xFFE2E2E2)),
      ],
    );

    final canPopRoute = context.canPop();
    return PopScope(
      canPop: canPopRoute,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: _menuScroll,
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _VendorMenuCollapseDelegate(
                      expanded: expandedHeader,
                      collapsed: VendorMenuCollapsedBar(
                        restaurant: restaurant,
                        onBack: _handleBack,
                        onPinTap: () => _openVendorMap(restaurant),
                      ),
                      pinnedFooter: showFilters
                          ? _pinnedFilters()
                          : const SizedBox.shrink(),
                      expandedBodyHeight: expandedHeight,
                      collapsedBodyHeight: collapsedHeight,
                      footerHeight: footerHeight,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: UiPlacementBanner(
                      placementKey: 'store_top',
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: UiPlacementBanner(
                      placementKey: 'store_mid',
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    ),
                  ),
                  if (_menuSwitching)
                    const SliverToBoxAdapter(
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        color: AppColors.primary,
                        backgroundColor: Color(0xFFE8F5E9),
                      ),
                    ),
                  if (_loading && !_loadedOnce)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: _buildMenuBody(),
                      ),
                    ),
                ],
              ),
            ),
            BrowseCartBar(
              itemCount: _cart.itemCount,
              totalLabel: _cart.totalLabel,
              onTap: _openMatchingCart,
            ),
          ],
        ),
        bottomNavigationBar: _menuBottomNav(),
      ),
    );
  }
}

class _VendorMenuCollapseDelegate extends SliverPersistentHeaderDelegate {
  _VendorMenuCollapseDelegate({
    required this.expanded,
    required this.collapsed,
    required this.pinnedFooter,
    required this.expandedBodyHeight,
    required this.collapsedBodyHeight,
    required this.footerHeight,
  });

  final Widget expanded;
  final Widget collapsed;
  final Widget pinnedFooter;
  final double expandedBodyHeight;
  final double collapsedBodyHeight;
  final double footerHeight;

  @override
  double get maxExtent => expandedBodyHeight + footerHeight;

  @override
  double get minExtent => collapsedBodyHeight + footerHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final t = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    final bodyHeight = expandedBodyHeight - shrinkOffset;
    final visibleBody = bodyHeight < collapsedBodyHeight
        ? collapsedBodyHeight
        : bodyHeight;
    final expandedInteractive = t <= 0.5;
    final collapsedInteractive = t > 0.5;

    return ColoredBox(
      color: AppColors.white,
      child: Column(
        children: [
          SizedBox(
            height: visibleBody,
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0),
                    child: IgnorePointer(
                      ignoring: !expandedInteractive,
                      child: OverflowBox(
                        alignment: Alignment.topCenter,
                        maxHeight: double.infinity,
                        child: expanded,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: IgnorePointer(
                      ignoring: !collapsedInteractive,
                      child: collapsed,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (footerHeight > 0)
            SizedBox(
              height: footerHeight,
              child: ClipRect(child: pinnedFooter),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _VendorMenuCollapseDelegate oldDelegate) {
    return expandedBodyHeight != oldDelegate.expandedBodyHeight ||
        collapsedBodyHeight != oldDelegate.collapsedBodyHeight ||
        footerHeight != oldDelegate.footerHeight ||
        expanded != oldDelegate.expanded ||
        collapsed != oldDelegate.collapsed ||
        pinnedFooter != oldDelegate.pinnedFooter;
  }
}
