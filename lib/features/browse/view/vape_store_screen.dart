import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/features/browse/retail/retail_store_configs.dart';
import 'package:yjeek_app/features/browse/retail/retail_store_screen.dart';

/// Vape vendor page — age banner · category chips · accordion list/grid.
///
/// Thin wrapper around [RetailStoreScreen].
class VapeStoreScreen extends ConsumerWidget {
  const VapeStoreScreen({
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
      config: vapeStoreConfig(
        onOpenCart: () => openVapeCartFromStore(ref, context),
      ),
    );
  }
}
