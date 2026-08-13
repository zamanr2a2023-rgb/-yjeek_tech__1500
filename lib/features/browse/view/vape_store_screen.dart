import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/auth/view/widgets/checkout_login_sheet.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/vape_data.dart';
import 'package:yjeek_app/features/browse/model/vape_vendors_repository.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/vape_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/features/ui_content/view/ui_banner_widgets.dart';

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
  static const _vapeGreen = Color(0xFF4DB04F);

  String _selectedCategory = VapeData.categories.first;
  VapeStore _store = VapeData.stores.first;
  List<VapeProduct> _products = const [];
  VapeCartSummary _cart = VapeCartSummary.empty;
  bool _loading = true;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    try {
      _store = VapeData.storeById(widget.storeId);
    } catch (_) {}
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(vapeVendorsRepositoryProvider);
      final store = await repo.fetchStore(widget.storeId);
      final products = await repo.fetchProducts(
        widget.storeId,
        category: _selectedCategory,
      );
      final cart = await repo.fetchCart();
      if (!mounted) return;
      setState(() {
        _store = store;
        _products = products;
        _cart = cart;
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

  Future<void> _refreshCart() async {
    try {
      final cart = await ref.read(vapeVendorsRepositoryProvider).fetchCart();
      if (!mounted) return;
      setState(() => _cart = cart);
    } catch (_) {}
  }

  Future<void> _addProduct(
    VapeProduct product, {
    bool replaceCart = false,
  }) async {
    if (_adding) return;

    final storage = ref.read(storageServiceProvider);
    if (!storage.hasSession) {
      await CheckoutLoginSheet.show(context);
      return;
    }

    setState(() => _adding = true);

    final repo = ref.read(vapeVendorsRepositoryProvider);
    // Resolve default nicotine option when product has a required group.
    var optionIds = <String>[];
    try {
      final detail = await repo.fetchProductDetail(
        storeId: widget.storeId,
        productId: product.id,
      );
      if (detail.nicotineOptionIds.isNotEmpty) {
        optionIds = [detail.nicotineOptionIds.first];
      }
    } catch (_) {}

    final result = await repo.addToCart(
      productId: product.id,
      quantity: 1,
      optionIds: optionIds,
      replaceCart: replaceCart,
    );

    if (!mounted) return;
    setState(() => _adding = false);

    if (result.ok) {
      await _refreshCart();
      return;
    }

    if (result.vendorConflict) {
      showCartNewCartDialog(
        context,
        onConfirm: () => _addProduct(product, replaceCart: true),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Could not add to cart')),
    );
  }

  void _openVapeCart() {
    ref.read(shellProvider.notifier).openVapeCartWithItems();
    context.goHome(tab: 2, vapeCart: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          VapeStoreTopBar(
            store: _store,
            onCart: _openVapeCart,
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                    children: [
                      const UiPlacementBanner(
                        placementKey: 'store_top',
                        padding: EdgeInsets.only(bottom: 14),
                      ),
                      const VapeAgeBanner(),
                      SizedBox(height: 14.h),
                      BrowseFilterChips(
                        options: VapeData.categories,
                        selected: _selectedCategory,
                        activeColor: _vapeGreen,
                        inactiveBorderColor: const Color(0xFFE6E8E6),
                        onSelected: (v) {
                          setState(() => _selectedCategory = v);
                          _load();
                        },
                      ),
                      SizedBox(height: 12.h),
                      const UiPlacementBanner(
                        placementKey: 'store_mid',
                        padding: EdgeInsets.only(bottom: 12),
                      ),
                      ..._products.map(
                        (product) => VapeProductRow(
                          product: product,
                          gradientStart: _store.gradientStart,
                          gradientEnd: _store.gradientEnd,
                          onTap: () => context.push(
                            BrowseRoutes.vapeProductDetail(
                              storeId: widget.storeId,
                              productId: product.id,
                            ),
                          ),
                          onAdd: () => _addProduct(product),
                        ),
                      ),
                    ],
                  ),
          ),
          if (_cart.itemCount > 0)
            VapeViewCartBar(
              itemCount: _cart.itemCount,
              total: _cart.totalLabel,
              onTap: _openVapeCart,
            ),
        ],
      ),
      bottomNavigationBar:
          ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
