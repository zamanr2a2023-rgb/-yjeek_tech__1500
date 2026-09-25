import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/maps_config.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/model/fashion_menu_grouping.dart';
import 'package:yjeek_app/features/browse/model/vendor_menu_grouping.dart';
import 'package:yjeek_app/features/browse/view/widgets/fashion_vendor_store_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/retail_vendor_store_scaffold.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

/// Fashion / retail / pharmacy vendor page — categories · list/grid.
class ElectronicsStoreScreen extends ConsumerStatefulWidget {
  const ElectronicsStoreScreen({
    super.key,
    required this.storeId,
    this.bottomNavIndex = 0,
  });

  final String storeId;
  final int bottomNavIndex;

  @override
  ConsumerState<ElectronicsStoreScreen> createState() =>
      _ElectronicsStoreScreenState();
}

class _ElectronicsStoreScreenState
    extends ConsumerState<ElectronicsStoreScreen> {
  ElectronicsStore? _store;
  List<VendorMenuChipGroup> _chipGroups = const [];
  String _selectedChip = '';
  String _expandedAccordion = '';
  String _query = '';
  bool _isGridView = false;
  bool _searchOpen = false;
  bool _loading = true;
  bool _loadedOnce = false;
  String? _addingItemId;
  Timer? _debounce;
  PharmacyDeliveryMode _pharmacyMode = PharmacyDeliveryMode.deliverNow;

  @override
  void initState() {
    super.initState();
    _isGridView = ref.read(storageServiceProvider).retailCategoryGridView;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _setGridView(bool isGrid) async {
    setState(() => _isGridView = isGrid);
    await ref.read(storageServiceProvider).setRetailCategoryGridView(isGrid);
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  void _applyGrouping({
    required List<String> sections,
    required List<BrowseMenuItem> items,
  }) {
    _chipGroups = buildFashionMenuChipGroups(
      sections: sections,
      items: items,
    );
    if (_chipGroups.isEmpty) {
      _selectedChip = '';
      _expandedAccordion = '';
      return;
    }
    if (!_chipGroups.any((g) => g.label == _selectedChip)) {
      _selectedChip = _chipGroups.first.label;
    }
    _expandedAccordion = _selectedChip;
  }

  void _onChipSelected(String chip) {
    setState(() {
      _selectedChip = chip;
      _expandedAccordion = chip;
    });
  }

  void _onAccordionTap(String title) {
    setState(() {
      if (_expandedAccordion == title) {
        _expandedAccordion = '';
      } else {
        _expandedAccordion = title;
        _selectedChip = title;
      }
    });
  }

  double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _degToRad(double deg) => deg * math.pi / 180;

  Future<({double lat, double lng})> _customerCoords() async {
    try {
      final addr =
          await ref.read(addressesRepositoryProvider).defaultAddress();
      if (addr?.latitude != null && addr?.longitude != null) {
        return (lat: addr!.latitude!, lng: addr.longitude!);
      }
    } catch (_) {}
    return (lat: MapsConfig.defaultLat, lng: MapsConfig.defaultLng);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final electronics = ref.read(electronicsVendorsRepositoryProvider);
      final food = ref.read(foodVendorsRepositoryProvider);

      final store = await electronics.fetchStore(widget.storeId);
      final fallbackLabel = store.categoryLabel ??
          (store.categories.toLowerCase().contains('flower')
              ? 'Flowers'
              : store.categories.toLowerCase().contains('pharm')
                  ? 'Pharmacy'
                  : store.categories.isNotEmpty
                      ? store.categories
                      : 'Electronics');

      var distanceKm = store.distanceKm;
      if (distanceKm == null &&
          store.latitude != null &&
          store.longitude != null) {
        final me = await _customerCoords();
        distanceKm = _haversineKm(
          me.lat,
          me.lng,
          store.latitude!,
          store.longitude!,
        );
      }

      final storeForUi = store.copyWith(
        categoryLabel: fallbackLabel,
        distanceKm: distanceKm,
      );

      if (storeForUi.hasPharmacyDeliveryModes &&
          !storeForUi.onDemandInRadius) {
        _pharmacyMode = PharmacyDeliveryMode.scheduled;
      } else if (storeForUi.hasPharmacyDeliveryModes &&
          storeForUi.onDemandInRadius &&
          !_loadedOnce) {
        _pharmacyMode = PharmacyDeliveryMode.deliverNow;
      }

      final menu = await food.fetchVendorMenu(
        widget.storeId,
        query: _query,
      );

      var sections = menu.sections;
      var items = menu.items;

      // Flat products fallback when menu has no sections.
      if (sections.isEmpty) {
        final products = await electronics.fetchProducts(
          widget.storeId,
          query: _query,
        );
        if (products.isNotEmpty) {
          sections = const ['Products'];
          items = [
            for (final p in products)
              BrowseMenuItem(
                id: p.id,
                name: p.name,
                description: p.specs.isNotEmpty ? p.specs : '___',
                price: p.price,
                section: 'Products',
              ),
          ];
        }
      }

      items = [
        for (final i in items)
          i.name.toLowerCase().contains('prescription')
              ? BrowseMenuItem(
                  id: i.id,
                  name: i.name,
                  description: i.description,
                  price: '—',
                  section: i.section,
                  hasModifiers: i.hasModifiers,
                  imageUrl: i.imageUrl,
                  badges: i.badges,
                )
              : i,
      ];

      if (!mounted) return;
      setState(() {
        _store = storeForUi;
        _applyGrouping(sections: sections, items: items);
        _loading = false;
        _loadedOnce = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _store = null;
        _chipGroups = const [];
        _loading = false;
        _loadedOnce = true;
      });
    }
  }

  void _openProduct(BrowseMenuItem item) {
    context.push(
      BrowseRoutes.electronicsProductDetail(
        storeId: widget.storeId,
        productId: item.id,
      ),
    );
  }

  Future<void> _onAdd(BrowseMenuItem item) async {
    if (item.hasModifiers || item.price == '—') {
      _openProduct(item);
      return;
    }
    if (_addingItemId != null) return;
    if (!await requireLogin(context, ref)) return;

    final cart = await ref.read(electronicsVendorsRepositoryProvider).fetchCart();
    final cartVendorId = cart.vendorId;
    final needsReplace = cartVendorId != null &&
        cartVendorId.isNotEmpty &&
        cartVendorId != widget.storeId &&
        cart.itemCount > 0;

    Future<void> doAdd({bool replace = false}) async {
      setState(() => _addingItemId = item.id);
      final result =
          await ref.read(electronicsVendorsRepositoryProvider).addToCart(
                productId: item.id,
                quantity: 1,
                replaceCart: replace,
              );
      if (!mounted) return;
      setState(() => _addingItemId = null);

      if (result.ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.localizedName} added to cart'),
            duration: const Duration(seconds: 1),
          ),
        );
        return;
      }
      if (result.vendorConflict) {
        showCartNewCartDialog(
          context,
          onConfirm: () => doAdd(replace: true),
        );
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

  @override
  Widget build(BuildContext context) {
    if (!_loadedOnce && _loading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        bottomNavigationBar: ShellBottomNavBar(
          currentIndex: widget.bottomNavIndex,
        ),
      );
    }

    final store = _store;
    if (store == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: const Center(child: Text('Could not load store')),
        bottomNavigationBar: ShellBottomNavBar(
          currentIndex: widget.bottomNavIndex,
        ),
      );
    }

    final isPharmacy = store.hasPharmacyDeliveryModes;

    return RetailVendorStoreScaffold(
      store: store,
      chipGroups: _chipGroups,
      selectedChip: _selectedChip,
      expandedAccordion: _expandedAccordion,
      isGridView: _isGridView,
      searchOpen: _searchOpen,
      loading: _loading,
      query: _query,
      addingItemId: _addingItemId,
      bottomNavIndex: widget.bottomNavIndex,
      orderMeta: isPharmacy
          ? PharmacyVendorOrderMeta(
              store: store,
              mode: _pharmacyMode,
              onModeChanged: (m) {
                if (m == PharmacyDeliveryMode.deliverNow &&
                    !store.onDemandInRadius) {
                  return;
                }
                setState(() => _pharmacyMode = m);
              },
            )
          : FashionVendorOrderMeta(store: store),
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else if (isPharmacy) {
          context.go(BrowseRoutes.retailCategory(slug: 'pharmacy'));
        } else {
          context.go(BrowseRoutes.electronicsBrowse());
        }
      },
      onSearchToggle: () {
        setState(() {
          _searchOpen = !_searchOpen;
          if (!_searchOpen && _query.isNotEmpty) {
            _query = '';
            _load();
          }
        });
      },
      onQueryChanged: _onQueryChanged,
      onCancelSearch: () {
        setState(() {
          _searchOpen = false;
          _query = '';
        });
        _load();
      },
      onRefresh: _load,
      onChipSelected: _onChipSelected,
      onAccordionTap: _onAccordionTap,
      onGridChanged: _setGridView,
      onOpenItem: _openProduct,
      onAddItem: _onAdd,
    );
  }
}
