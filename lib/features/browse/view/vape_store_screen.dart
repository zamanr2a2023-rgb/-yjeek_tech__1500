import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/vape_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/vape_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

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
  // Figma store screen shows sticky View cart with 1 item already in cart.
  int _cartCount = 1;
  double _cartTotalValue = 6.5;

  VapeStore get _store => VapeData.storeById(widget.storeId);

  List<VapeProduct> get _products =>
      VapeData.productsForStore(widget.storeId, _selectedCategory);

  String get _cartTotalLabel => _cartTotalValue.toStringAsFixed(3);

  void _addProduct(VapeProduct product) {
    final price = double.tryParse(product.price) ?? 0;
    setState(() {
      _cartCount++;
      _cartTotalValue += price;
    });
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
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              children: [
                const VapeAgeBanner(),
                SizedBox(height: 14.h),
                BrowseFilterChips(
                  options: VapeData.categories,
                  selected: _selectedCategory,
                  activeColor: _vapeGreen,
                  inactiveBorderColor: const Color(0xFFE6E8E6),
                  onSelected: (v) => setState(() => _selectedCategory = v),
                ),
                SizedBox(height: 12.h),
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
          VapeViewCartBar(
            itemCount: _cartCount,
            total: _cartTotalLabel,
            onTap: _openVapeCart,
          ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
