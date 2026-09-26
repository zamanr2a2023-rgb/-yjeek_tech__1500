import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/fashion_vendor_store_widgets.dart';
import 'package:yjeek_app/features/cart/model/pending_add_to_cart.dart';

enum RetailStoreVertical { electronics, vape, services }

class RetailCatalog {
  const RetailCatalog({
    required this.store,
    required this.sections,
    required this.items,
    this.serviceItemsById,
    this.cartItemCount = 0,
    this.cartTotalLabel = '0.000',
    this.cartVendorId,
  });

  final ElectronicsStore store;
  final List<String> sections;
  final List<BrowseMenuItem> items;

  /// Services only — used to detect modifiers before quick-add.
  final Map<String, bool>? serviceItemsById;

  final int cartItemCount;
  final String cartTotalLabel;
  final String? cartVendorId;
}

class RetailAddResult {
  const RetailAddResult({
    required this.ok,
    this.vendorConflict = false,
    this.outOfRange = false,
    this.message,
  });

  final bool ok;
  final bool vendorConflict;
  final bool outOfRange;
  final String? message;
}

/// Loads store header + menu sections/items for a vertical.
typedef RetailCatalogLoader = Future<RetailCatalog> Function(
  WidgetRef ref, {
  required String storeId,
  required String query,
  required bool loadedOnce,
});

/// Vertical-specific cart quick-add.
typedef RetailQuickAdd = Future<RetailAddResult> Function(
  WidgetRef ref, {
  required String storeId,
  required BrowseMenuItem item,
  required bool replaceCart,
});

/// Optional pre-add gate (e.g. vape age verification). Returns false to abort.
typedef RetailBeforeAdd = Future<bool> Function(
  BuildContext context,
  WidgetRef ref,
  BrowseMenuItem item,
);

typedef RetailShouldOpenDetail = bool Function(BrowseMenuItem item);

typedef RetailProductDetailRoute = String Function({
  required String storeId,
  required String productId,
});

typedef RetailBackHandler = void Function(
  BuildContext context, {
  required ElectronicsStore store,
});

typedef RetailOrderMetaBuilder = Widget? Function({
  required ElectronicsStore store,
  required PharmacyDeliveryMode pharmacyMode,
  required ValueChanged<PharmacyDeliveryMode> onPharmacyModeChanged,
});

typedef RetailBannerBuilder = Widget? Function();

typedef RetailBottomBarBuilder = Widget? Function({
  required int cartItemCount,
  required String cartTotalLabel,
  required VoidCallback onCartTap,
});

typedef RetailAfterAddSuccess = Future<void> Function(
  BuildContext context,
  WidgetRef ref, {
  required BrowseMenuItem item,
});

typedef RetailAfterLoad = Future<void> Function(
  BuildContext context,
  WidgetRef ref, {
  required String storeId,
});

class RetailStoreConfig {
  const RetailStoreConfig({
    required this.vertical,
    required this.pendingVertical,
    required this.loadCatalog,
    required this.quickAdd,
    required this.productDetailRoute,
    required this.onBack,
    this.beforeAdd,
    this.shouldOpenDetail,
    this.orderMetaBuilder,
    this.bannerBuilder,
    this.bottomBarBuilder,
    this.onCartTap,
    this.afterAddSuccess,
    this.afterLoad,
    this.searchHint = 'Search products…',
    this.emptyMessage = 'No items available right now',
    this.emptySearchMessage = 'No items found',
    this.errorMessage = 'Could not load store',
  });

  final RetailStoreVertical vertical;
  final PendingCartVertical pendingVertical;
  final RetailCatalogLoader loadCatalog;
  final RetailQuickAdd quickAdd;
  final RetailProductDetailRoute productDetailRoute;
  final RetailBackHandler onBack;
  final RetailBeforeAdd? beforeAdd;
  final RetailShouldOpenDetail? shouldOpenDetail;
  final RetailOrderMetaBuilder? orderMetaBuilder;
  final RetailBannerBuilder? bannerBuilder;
  final RetailBottomBarBuilder? bottomBarBuilder;
  final VoidCallback? onCartTap;
  final RetailAfterAddSuccess? afterAddSuccess;
  final RetailAfterLoad? afterLoad;
  final String searchHint;
  final String emptyMessage;
  final String emptySearchMessage;
  final String errorMessage;
}
