import 'package:flutter/material.dart';
import 'package:yjeek_app/features/browse/retail/product_detail_strategies.dart';
import 'package:yjeek_app/features/browse/retail/universal_product_detail_screen.dart';

/// Service booking customise page — thin wrapper around universal detail.
class ServicesItemDetailScreen extends StatelessWidget {
  const ServicesItemDetailScreen({
    super.key,
    required this.providerId,
    required this.itemId,
    this.bottomNavIndex = 0,
  });

  final String providerId;
  final String itemId;
  final int bottomNavIndex;

  @override
  Widget build(BuildContext context) {
    return UniversalProductDetailScreen(
      storeId: providerId,
      productId: itemId,
      bottomNavIndex: bottomNavIndex,
      strategy: servicesProductDetailStrategy,
    );
  }
}
