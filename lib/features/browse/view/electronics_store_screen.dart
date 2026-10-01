import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/features/browse/retail/retail_store_configs.dart';
import 'package:yjeek_app/features/browse/retail/retail_store_screen.dart';

/// Fashion, electronics, and pharmacy vendor page.
///
/// Fashion and electronics stay on the scheduled cart. Pharmacy Deliver Now
/// and Scheduled come from `GET /vendors/:id/order-modes` inside
/// [RetailStoreScreen].
class ElectronicsStoreScreen extends ConsumerWidget {
  const ElectronicsStoreScreen({
    super.key,
    required this.storeId,
    this.bottomNavIndex = 0,
  });

  final String storeId;
  final int bottomNavIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RetailStoreScreen(
      storeId: storeId,
      bottomNavIndex: bottomNavIndex,
      config: electronicsStoreConfig(),
    );
  }
}
