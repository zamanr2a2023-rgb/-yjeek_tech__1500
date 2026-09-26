import 'package:flutter/material.dart';
import 'package:yjeek_app/features/browse/retail/product_detail_strategies.dart';
import 'package:yjeek_app/features/browse/retail/universal_product_detail_screen.dart';

/// Vape item page — thin wrapper around universal detail (+ age banner).
class VapeProductDetailScreen extends StatelessWidget {
  const VapeProductDetailScreen({
    super.key,
    required this.storeId,
    required this.productId,
    this.bottomNavIndex = 0,
  });

  final String storeId;
  final String productId;
  final int bottomNavIndex;

  @override
  Widget build(BuildContext context) {
    return UniversalProductDetailScreen(
      storeId: storeId,
      productId: productId,
      bottomNavIndex: bottomNavIndex,
      strategy: vapeProductDetailStrategy,
    );
  }
}
