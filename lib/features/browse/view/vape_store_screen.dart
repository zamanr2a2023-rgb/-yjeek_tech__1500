import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/model/fashion_menu_grouping.dart';
import 'package:yjeek_app/features/browse/model/vendor_menu_grouping.dart';
import 'package:yjeek_app/features/browse/utils/vape_age_gate.dart';
import 'package:yjeek_app/features/browse/view/widgets/fashion_vendor_store_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/retail_vendor_store_scaffold.dart';
import 'package:yjeek_app/features/browse/view/widgets/vape_widgets.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

/// Vape vendor page — age banner · Scheduled · category chips · accordion list/grid.
class VapeStoreScreen extends ConsumerStatefulWidget {
  const VapeStoreScreen({
    super.key,
    required this.storeId,
    this.bottomNavIndex = 0,
  });

  final String storeId;
  final int bottomNavIndex;

  @override
  ConsumerState<VapeStoreScreen> createState() => _VapeStoreScreenState();
}

class _VapeStoreScreenState extends ConsumerState<VapeStoreScreen> {
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
  int _cartCount = 0;
  String _cartTotal = '0.000';
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

  Future<void> _refreshCart() async {
    try {
      final cart = await ref.read(vapeVendorsRepositoryProvider).fetchCart();
      if (!mounted) return;
      setState(() {
        _cartCount = cart.itemCount;
        _cartTotal = cart.totalLabel;
      });
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final electronics = ref.read(electronicsVendorsRepositoryProvider);
      final food = ref.read(foodVendorsRepositoryProvider);

      final store = await electronics.fetchStore(widget.storeId);
      // Ensure type label shows "Vape" on brand band.
      final storeForUi = ElectronicsStore(
        id: store.id,
        name: store.name,
        rating: store.rating,
        reviewCount: store.reviewCount,
        distance: store.distance,
        categories: store.categories,
        productCount: store.productCount,
        gradientStart: store.gradientStart,
        gradientEnd: store.gradientEnd,
        freeDelivery: store.freeDelivery,
        hasRating: store.hasRating,
        area: store.area,
        imageUrl: store.imageUrl,
        logoUrl: store.logoUrl,
        offerBadge: store.offerBadge,
        categoryLabel: store.categoryLabel ?? 'Vape',
        minOrderAmount: store.minOrderAmount,
      );

      final menu = await food.fetchVendorMenu(
        widget.storeId,
        query: _query,
      );

      var sections = menu.sections;
      var items = menu.items;

      if (sections.isEmpty) {
        final products =
            await ref.read(vapeVendorsRepositoryProvider).fetchProducts(
                  widget.storeId,
                  category: 'All',
                  query: _query,
                );
        if (products.isNotEmpty) {
          final byCat = <String, List<BrowseMenuItem>>{};
          for (final p in products) {
            final cat = p.category.trim().isEmpty ? 'Products' : p.category.trim();
            byCat.putIfAbsent(cat, () => []);
            byCat[cat]!.add(
              BrowseMenuItem(
                id: p.id,
                name: p.name,
                description: p.specs.isNotEmpty ? p.specs : '___',
                price: p.price,
                section: cat,
                hasModifiers: p.nicotineOptionIds.isNotEmpty,
              ),
            );
          }
          sections = byCat.keys.toList(growable: false);
          items = [for (final list in byCat.values) ...list];
        }
      }

      await _refreshCart();
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
      BrowseRoutes.vapeProductDetail(
        storeId: widget.storeId,
        productId: item.id,
      ),
    );
  }

  void _openVapeCart() {
    ref.read(shellProvider.notifier).openVapeCartWithItems();
    context.goHome(tab: 2, vapeCart: true);
  }

  Future<void> _onAdd(BrowseMenuItem item) async {
    if (item.hasModifiers) {
      _openProduct(item);
      return;
    }
    if (_addingItemId != null) return;
    if (!await ensureVapeAgeVerifiedForPurchase(
      context,
      ref,
      productName: item.localizedName,
    )) {
      return;
    }

    final cart = await ref.read(vapeVendorsRepositoryProvider).fetchCart();
    final cartVendorId = cart.vendorId;
    final needsReplace = cartVendorId != null &&
        cartVendorId.isNotEmpty &&
        cartVendorId != widget.storeId &&
        cart.itemCount > 0;

    Future<void> doAdd({bool replace = false}) async {
      setState(() => _addingItemId = item.id);
      final result = await ref.read(vapeVendorsRepositoryProvider).addToCart(
            productId: item.id,
            quantity: 1,
            replaceCart: replace,
            vendorId: widget.storeId,
          );
      if (!mounted) return;
      setState(() => _addingItemId = null);

      if (result.ok) {
        await _refreshCart();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.localizedName} added to cart'),
            duration: const Duration(seconds: 1),
          ),
        );
        return;
      }
      if (result.outOfRange) {
        await pushOutOfDelivery(context);
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
      banner: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
        child: const VapeAgeBanner(),
      ),
      orderMeta: FashionVendorOrderMeta(store: store),
      bottomBar: _cartCount > 0
          ? VapeViewCartBar(
              itemCount: _cartCount,
              total: _cartTotal,
              onTap: _openVapeCart,
            )
          : null,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(BrowseRoutes.vapeBrowse());
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
