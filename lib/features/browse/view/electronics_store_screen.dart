import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/electronics_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class ElectronicsStoreScreen extends StatefulWidget {
  const ElectronicsStoreScreen({
    super.key,
    required this.storeId,
    this.bottomNavIndex = 0,
  });

  final String storeId;
  final int bottomNavIndex;

  @override
  State<ElectronicsStoreScreen> createState() => _ElectronicsStoreScreenState();
}

class _ElectronicsStoreScreenState extends State<ElectronicsStoreScreen> {
  String _selectedFilter = ElectronicsData.productFilters.first;

  ElectronicsStore get _store => ElectronicsData.storeById(widget.storeId);

  List<ElectronicsProduct> get _products =>
      ElectronicsData.productsForFilter(widget.storeId, _selectedFilter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F2),
      body: Column(
        children: [
          ElectronicsStoreTopBar(store: _store),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              children: [
                BrowseSearchBar(
                  hint: ElectronicsData.searchHint,
                  onTap: () {},
                ),
                SizedBox(height: 14.h),
                ElectronicsFilterChips(
                  options: ElectronicsData.productFilters,
                  selected: _selectedFilter,
                  onSelected: (v) => setState(() => _selectedFilter = v),
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
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
