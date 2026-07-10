import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/vape_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/vape_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class VapeStoreScreen extends StatefulWidget {
  const VapeStoreScreen({
    super.key,
    required this.storeId,
    this.bottomNavIndex = 0,
  });

  final String storeId;
  final int bottomNavIndex;

  @override
  State<VapeStoreScreen> createState() => _VapeStoreScreenState();
}

class _VapeStoreScreenState extends State<VapeStoreScreen> {
  String _selectedCategory = VapeData.categories.first;
  int _cartCount = 0;
  String _cartTotal = '0.000';

  VapeStore get _store => VapeData.storeById(widget.storeId);

  List<VapeProduct> get _products =>
      VapeData.productsForStore(widget.storeId, _selectedCategory);

  void _addProduct(VapeProduct product) {
    setState(() {
      _cartCount++;
      _cartTotal = product.price;
    });
    context.push(
      BrowseRoutes.vapeProductDetail(
        storeId: widget.storeId,
        productId: product.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          VapeStoreTopBar(
            store: _store,
            onCart: () => context.goHome(tab: 2),
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
                  onSelected: (v) => setState(() => _selectedCategory = v),
                ),
                SizedBox(height: 8.h),
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
          if (_cartCount > 0)
            VapeViewCartBar(
              itemCount: _cartCount,
              total: _cartTotal,
              onTap: () => context.goHome(tab: 2),
            ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
