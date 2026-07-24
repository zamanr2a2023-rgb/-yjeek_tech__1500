import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/electronics_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

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
  String _selectedFilter = ElectronicsData.productFilters.first;
  String _query = '';
  ElectronicsStore _store = ElectronicsData.stores.first;
  List<ElectronicsProduct> _products = const [];
  bool _loading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    try {
      _store = ElectronicsData.storeById(widget.storeId);
    } catch (_) {}
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(electronicsVendorsRepositoryProvider);
      final store = await repo.fetchStore(widget.storeId);
      final products = await repo.fetchProducts(
        widget.storeId,
        query: _query,
        filter: _selectedFilter,
      );
      if (!mounted) return;
      setState(() {
        _store = ElectronicsStore(
          id: store.id,
          name: store.name,
          rating: store.rating,
          reviewCount: store.reviewCount,
          distance: store.distance,
          categories: store.categories,
          productCount: products.isNotEmpty
              ? products.length
              : store.productCount,
          gradientStart: store.gradientStart,
          gradientEnd: store.gradientEnd,
          freeDelivery: store.freeDelivery,
        );
        _products = products;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _products = const [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F2),
      body: Column(
        children: [
          ElectronicsStoreTopBar(store: _store),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                    children: [
                      BrowseSearchBar(
                        hint: ElectronicsData.searchHint,
                        value: _query,
                        autofocus: false,
                        onChanged: _onQueryChanged,
                      ),
                      SizedBox(height: 14.h),
                      ElectronicsFilterChips(
                        options: ElectronicsData.productFilters,
                        selected: _selectedFilter,
                        onSelected: (v) {
                          setState(() => _selectedFilter = v);
                          _load();
                        },
                      ),
                      SizedBox(height: 14.h),
                      ..._products.map(
                        (product) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: ElectronicsProductRow(
                            product: product,
                            onTap: () => context.push(
                              BrowseRoutes.electronicsProductDetail(
                                storeId: widget.storeId,
                                productId: product.id,
                              ),
                            ),
                            onAdd: () => context.push(
                              BrowseRoutes.electronicsProductDetail(
                                storeId: widget.storeId,
                                productId: product.id,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(
        currentIndex: widget.bottomNavIndex,
      ),
    );
  }
}
