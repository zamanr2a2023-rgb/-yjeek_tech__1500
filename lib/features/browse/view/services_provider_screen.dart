import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/model/fashion_menu_grouping.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/browse/model/services_vendors_repository.dart';
import 'package:yjeek_app/features/browse/model/vendor_menu_grouping.dart';
import 'package:yjeek_app/features/browse/view/widgets/retail_vendor_store_scaffold.dart';
import 'package:yjeek_app/features/browse/view/widgets/services_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';

/// Service provider page — details.md Figma (chips · accordion · list/grid).
class ServicesProviderScreen extends ConsumerStatefulWidget {
  const ServicesProviderScreen({
    super.key,
    required this.providerId,
    this.bottomNavIndex = 0,
  });

  final String providerId;
  final int bottomNavIndex;

  @override
  ConsumerState<ServicesProviderScreen> createState() =>
      _ServicesProviderScreenState();
}

class _ServicesProviderScreenState
    extends ConsumerState<ServicesProviderScreen> {
  ServiceProvider? _provider;
  ElectronicsStore? _storeUi;
  List<VendorMenuChipGroup> _chipGroups = const [];
  Map<String, ServiceMenuItem> _itemsById = const {};
  String _selectedChip = '';
  String _expandedAccordion = '';
  String _query = '';
  bool _isGridView = false;
  bool _searchOpen = false;
  bool _loading = true;
  bool _loadedOnce = false;
  String? _addingItemId;
  ServicesCartSummary _cart = ServicesCartSummary.empty;
  Timer? _debounce;

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

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(servicesVendorsRepositoryProvider);
      final menu = await repo.fetchProviderMenu(
        widget.providerId,
        query: _query,
      );
      final cart = await repo.fetchServiceCart();

      final provider = menu.provider;
      final byId = <String, ServiceMenuItem>{
        for (final i in menu.items) i.id: i,
      };
      final browseItems = [
        for (final i in menu.items)
          BrowseMenuItem(
            id: i.id,
            name: i.name,
            description: i.description,
            price: i.price,
            section: i.section,
            hasModifiers: i.hasModifiers,
          ),
      ];

      final storeUi = ElectronicsStore(
        id: provider.id,
        name: provider.name,
        rating: provider.rating,
        reviewCount: '${provider.reviewCount}',
        distance: provider.distance,
        categories: provider.category,
        productCount: menu.items.length,
        gradientStart: provider.gradientStart,
        gradientEnd: provider.gradientEnd,
        hasRating: provider.hasRating,
        area: provider.area ?? provider.locationLabel,
        imageUrl: provider.imageUrl,
        logoUrl: provider.imageUrl,
        offerBadge: provider.offerBadge,
        categoryLabel: provider.category,
        minOrderAmount: null,
      );

      if (!mounted) return;
      setState(() {
        _provider = provider;
        _storeUi = storeUi;
        _itemsById = byId;
        _cart = cart;
        _applyGrouping(sections: menu.sections, items: browseItems);
        _loading = false;
        _loadedOnce = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _provider = null;
        _storeUi = null;
        _loading = false;
        _loadedOnce = true;
      });
    }
  }

  Future<void> _openItem(BrowseMenuItem item) async {
    final cartVendorId = _cart.vendorId;
    final needsReplace = cartVendorId != null &&
        cartVendorId.isNotEmpty &&
        cartVendorId != widget.providerId &&
        _cart.itemCount > 0;

    void goDetail() {
      context
          .push(
            BrowseRoutes.servicesItemDetail(
              providerId: widget.providerId,
              itemId: item.id,
            ),
          )
          .then((_) {
        if (mounted) _load();
      });
    }

    if (needsReplace) {
      showCartNewCartDialog(context, onConfirm: goDetail);
      return;
    }
    goDetail();
  }

  Future<void> _onAdd(BrowseMenuItem item) async {
    final service = _itemsById[item.id];
    if (service != null && service.hasModifiers) {
      await _openItem(item);
      return;
    }
    if (_addingItemId != null) return;
    if (!await requireLogin(context, ref)) return;

    final cartVendorId = _cart.vendorId;
    final needsReplace = cartVendorId != null &&
        cartVendorId.isNotEmpty &&
        cartVendorId != widget.providerId &&
        _cart.itemCount > 0;

    Future<void> doAdd({bool replace = false}) async {
      setState(() => _addingItemId = item.id);
      final result = await ref.read(servicesVendorsRepositoryProvider).addToCart(
            productId: item.id,
            quantity: 1,
            replaceCart: replace,
          );
      if (!mounted) return;
      setState(() => _addingItemId = null);

      if (result.ok) {
        await _load();
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
        SnackBar(content: Text(result.message ?? 'Could not add to booking')),
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

    final store = _storeUi;
    if (store == null || _provider == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: const Center(child: Text('Could not load provider')),
        bottomNavigationBar: ShellBottomNavBar(
          currentIndex: widget.bottomNavIndex,
        ),
      );
    }

    final showBar = _cart.itemCount > 0;

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
      searchHint: 'Search services…',
      emptyMessage: 'No services available right now',
      emptySearchMessage: 'No services found',
      bottomBar: showBar
          ? ServicesBookingBar(
              itemCount: _cart.itemCount,
              total: _cart.totalLabel,
              onTap: () => context.push(ServicesBookingRoutes.booking),
            )
          : null,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(BrowseRoutes.servicesBrowse());
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
      onOpenItem: _openItem,
      onAddItem: _onAdd,
    );
  }
}
