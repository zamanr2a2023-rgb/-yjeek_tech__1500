import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/model/fashion_menu_grouping.dart';
import 'package:yjeek_app/features/browse/model/vendor_menu_grouping.dart';
import 'package:yjeek_app/features/browse/retail/retail_store_config.dart';
import 'package:yjeek_app/features/browse/view/widgets/fashion_vendor_store_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/retail_vendor_store_scaffold.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/cart/model/pending_add_to_cart.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

/// Unified store page for Electronics / Vape / Services (not Food or Dine-in).
class RetailStoreScreen extends ConsumerStatefulWidget {
  const RetailStoreScreen({
    super.key,
    required this.storeId,
    required this.config,
    this.bottomNavIndex = 0,
  });

  final String storeId;
  final RetailStoreConfig config;
  final int bottomNavIndex;

  @override
  ConsumerState<RetailStoreScreen> createState() => _RetailStoreScreenState();
}

class _RetailStoreScreenState extends ConsumerState<RetailStoreScreen> {
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
  int _cartItemCount = 0;
  String _cartTotalLabel = '0.000';
  String? _cartVendorId;

  RetailStoreConfig get config => widget.config;

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
      final catalog = await config.loadCatalog(
        ref,
        storeId: widget.storeId,
        query: _query,
        loadedOnce: _loadedOnce,
      );

      if (catalog.store.hasPharmacyDeliveryModes &&
          !catalog.store.onDemandInRadius) {
        _pharmacyMode = PharmacyDeliveryMode.scheduled;
      } else if (catalog.store.hasPharmacyDeliveryModes &&
          catalog.store.onDemandInRadius &&
          !_loadedOnce) {
        _pharmacyMode = PharmacyDeliveryMode.deliverNow;
      }

      if (!mounted) return;
      setState(() {
        _store = catalog.store;
        _cartItemCount = catalog.cartItemCount;
        _cartTotalLabel = catalog.cartTotalLabel;
        _cartVendorId = catalog.cartVendorId;
        _applyGrouping(sections: catalog.sections, items: catalog.items);
        _loading = false;
        _loadedOnce = true;
      });

      await config.afterLoad?.call(
        context,
        ref,
        storeId: widget.storeId,
      );
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
    final route = config.productDetailRoute(
      storeId: widget.storeId,
      productId: item.id,
    );
    final future = context.push(route);
    if (config.vertical == RetailStoreVertical.services) {
      future.then((_) {
        if (mounted) _load();
      });
    }
  }

  Future<void> _onAdd(BrowseMenuItem item) async {
    final openDetail = config.shouldOpenDetail?.call(item) ??
        item.hasModifiers || item.price == '—';
    if (openDetail) {
      // Services: vendor-conflict check before opening detail with modifiers.
      if (config.vertical == RetailStoreVertical.services) {
        final needsReplace = _cartVendorId != null &&
            _cartVendorId!.isNotEmpty &&
            _cartVendorId != widget.storeId &&
            _cartItemCount > 0;
        if (needsReplace) {
          showCartNewCartDialog(context, onConfirm: () => _openProduct(item));
          return;
        }
      }
      _openProduct(item);
      return;
    }
    if (_addingItemId != null) return;

    if (!ref.read(storageServiceProvider).hasSession) {
      rememberPendingAddToCart(
        ref,
        PendingAddToCart(
          productId: item.id,
          quantity: 1,
          vendorId: widget.storeId,
          cartType: config.vertical == RetailStoreVertical.services
              ? 'SERVICE'
              : 'DELIVERY',
          returnPath: currentReturnPath(context),
          vertical: config.pendingVertical,
        ),
      );
    }

    if (config.beforeAdd != null) {
      if (!await config.beforeAdd!(context, ref, item)) return;
    } else {
      if (!await requireLogin(context, ref)) return;
    }
    if (!mounted) return;

    final needsReplace = _cartVendorId != null &&
        _cartVendorId!.isNotEmpty &&
        _cartVendorId != widget.storeId &&
        _cartItemCount > 0;

    // Electronics fetches cart at add-time (may be empty until login).
    if (config.vertical == RetailStoreVertical.electronics) {
      final cart =
          await ref.read(electronicsVendorsRepositoryProvider).fetchCart();
      final cartVendorId = cart.vendorId;
      final elecReplace = cartVendorId != null &&
          cartVendorId.isNotEmpty &&
          cartVendorId != widget.storeId &&
          cart.itemCount > 0;
      if (elecReplace) {
        showCartNewCartDialog(
          context,
          onConfirm: () => _doAdd(item, replace: true),
        );
        return;
      }
      await _doAdd(item);
      return;
    }

    if (needsReplace) {
      showCartNewCartDialog(
        context,
        onConfirm: () => _doAdd(item, replace: true),
      );
      return;
    }
    await _doAdd(item);
  }

  Future<void> _doAdd(BrowseMenuItem item, {bool replace = false}) async {
    setState(() => _addingItemId = item.id);
    final result = await config.quickAdd(
      ref,
      storeId: widget.storeId,
      item: item,
      replaceCart: replace,
    );
    if (!mounted) return;
    setState(() => _addingItemId = null);

    if (result.ok) {
      clearPendingAddToCart(ref);
      if (config.afterAddSuccess != null) {
        await config.afterAddSuccess!(
          context,
          ref,
          item: item,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.localizedName} added to cart'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
      // Refresh cart badges for vape/services.
      if (config.vertical != RetailStoreVertical.electronics) {
        await _load();
      }
      return;
    }

    if (result.outOfRange) {
      rememberPendingAddToCart(
        ref,
        PendingAddToCart(
          productId: item.id,
          quantity: 1,
          vendorId: widget.storeId,
          replaceCart: replace,
          vertical: config.pendingVertical,
        ),
      );
      await pushOutOfDelivery(context);
      return;
    }

    if (result.vendorConflict) {
      showCartNewCartDialog(
        context,
        onConfirm: () => _doAdd(item, replace: true),
      );
      return;
    }

    if (await redirectToLoginIfAuthError(context, ref, result.message)) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message ??
              (config.vertical == RetailStoreVertical.services
                  ? 'Could not add to booking'
                  : 'Could not add to cart'),
        ),
      ),
    );
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
        body: Center(child: Text(config.errorMessage)),
        bottomNavigationBar: ShellBottomNavBar(
          currentIndex: widget.bottomNavIndex,
        ),
      );
    }

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
      searchHint: config.searchHint,
      emptyMessage: config.emptyMessage,
      emptySearchMessage: config.emptySearchMessage,
      orderMeta: config.orderMetaBuilder?.call(
        store: store,
        pharmacyMode: _pharmacyMode,
        onPharmacyModeChanged: (m) {
          if (m == PharmacyDeliveryMode.deliverNow &&
              !store.onDemandInRadius) {
            return;
          }
          setState(() => _pharmacyMode = m);
        },
      ),
      banner: config.bannerBuilder?.call(),
      bottomBar: config.bottomBarBuilder?.call(
        cartItemCount: _cartItemCount,
        cartTotalLabel: _cartTotalLabel,
        onCartTap: config.onCartTap ?? () {},
      ),
      onBack: () => config.onBack(context, store: store),
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
      onOpenItem: (item) {
        if (config.vertical == RetailStoreVertical.services) {
          final needsReplace = _cartVendorId != null &&
              _cartVendorId!.isNotEmpty &&
              _cartVendorId != widget.storeId &&
              _cartItemCount > 0;
          if (needsReplace) {
            showCartNewCartDialog(context, onConfirm: () => _openProduct(item));
            return;
          }
        }
        _openProduct(item);
      },
      onAddItem: _onAdd,
    );
  }
}
