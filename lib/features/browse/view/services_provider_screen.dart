import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/features/browse/retail/retail_store_configs.dart';
import 'package:yjeek_app/features/browse/retail/retail_store_screen.dart';

/// Service provider page — chips · accordion · list/grid.
///
/// Thin wrapper around [RetailStoreScreen].
class ServicesProviderScreen extends ConsumerWidget {
  const ServicesProviderScreen({
    super.key,
    required this.providerId,
    this.bottomNavIndex = 0,
  });

  final String providerId;
  final int bottomNavIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RetailStoreScreen(
      storeId: providerId,
      bottomNavIndex: bottomNavIndex,
      config: servicesStoreConfig(
        onOpenBooking: () => openServicesBooking(context),
      ),
    );
  }
}
