import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/retail/adapters/electronics_store_adapter.dart';
import 'package:yjeek_app/features/browse/retail/adapters/services_store_adapter.dart';
import 'package:yjeek_app/features/browse/retail/adapters/vape_store_adapter.dart';
import 'package:yjeek_app/features/browse/retail/retail_store_config.dart';
import 'package:yjeek_app/features/browse/utils/vape_age_gate.dart';
import 'package:yjeek_app/features/browse/view/widgets/fashion_vendor_store_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/services_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/vape_widgets.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/cart/model/pending_add_to_cart.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';
import 'package:yjeek_app/routes/app_router.dart';

RetailStoreConfig electronicsStoreConfig() {
  return RetailStoreConfig(
    vertical: RetailStoreVertical.electronics,
    pendingVertical: electronicsPendingVertical,
    loadCatalog: loadElectronicsCatalog,
    quickAdd: electronicsQuickAdd,
    shouldOpenDetail: electronicsShouldOpenDetail,
    productDetailRoute: ({required storeId, required productId}) =>
        BrowseRoutes.electronicsProductDetail(
          storeId: storeId,
          productId: productId,
        ),
    onBack: (context, {required store}) {
      if (context.canPop()) {
        context.pop();
      } else if (store.hasPharmacyDeliveryModes) {
        context.go(BrowseRoutes.retailCategory(slug: 'pharmacy'));
      } else {
        context.go(BrowseRoutes.electronicsBrowse());
      }
    },
    orderMetaBuilder: ({
      required store,
      required PharmacyDeliveryMode pharmacyMode,
      required ValueChanged<PharmacyDeliveryMode> onPharmacyModeChanged,
    }) {
      if (store.hasPharmacyDeliveryModes) {
        return PharmacyVendorOrderMeta(
          store: store,
          mode: pharmacyMode,
          onModeChanged: onPharmacyModeChanged,
        );
      }
      return FashionVendorOrderMeta(store: store);
    },
  );
}

RetailStoreConfig vapeStoreConfig({
  required VoidCallback onOpenCart,
}) {
  return RetailStoreConfig(
    vertical: RetailStoreVertical.vape,
    pendingVertical: vapePendingVertical,
    loadCatalog: loadVapeCatalog,
    quickAdd: vapeQuickAdd,
    beforeAdd: vapeBeforeAdd,
    shouldOpenDetail: vapeShouldOpenDetail,
    productDetailRoute: ({required storeId, required productId}) =>
        BrowseRoutes.vapeProductDetail(
          storeId: storeId,
          productId: productId,
        ),
    onBack: (context, {required store}) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(BrowseRoutes.vapeBrowse());
      }
    },
    orderMetaBuilder: ({
      required store,
      required pharmacyMode,
      required onPharmacyModeChanged,
    }) =>
        FashionVendorOrderMeta(store: store),
    bannerBuilder: () => Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      child: const VapeAgeBanner(),
    ),
    bottomBarBuilder: ({
      required cartItemCount,
      required cartTotalLabel,
      required onCartTap,
    }) {
      if (cartItemCount <= 0) return null;
      return VapeViewCartBar(
        itemCount: cartItemCount,
        total: cartTotalLabel,
        onTap: onCartTap,
      );
    },
    onCartTap: onOpenCart,
    afterLoad: (context, ref, {required storeId}) async {
      final pending = ref.read(pendingAddToCartProvider);
      if (pending == null || pending.vertical != PendingCartVertical.vape) {
        return;
      }
      if (pending.vendorId != null &&
          pending.vendorId!.isNotEmpty &&
          pending.vendorId != storeId) {
        return;
      }
      if (!await ensureVapeAgeVerifiedForPurchase(context, ref)) return;
      if (!context.mounted) return;
      final result = await retryPendingAddToCart(ref);
      if (!context.mounted) return;
      if (result.ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item added to cart'),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }
      if (result.outOfRange) {
        await pushOutOfDelivery(context);
      }
    },
  );
}

RetailStoreConfig servicesStoreConfig({
  required VoidCallback onOpenBooking,
}) {
  return RetailStoreConfig(
    vertical: RetailStoreVertical.services,
    pendingVertical: servicesPendingVertical,
    loadCatalog: loadServicesCatalog,
    quickAdd: servicesQuickAdd,
    shouldOpenDetail: servicesShouldOpenDetail,
    productDetailRoute: ({required storeId, required productId}) =>
        BrowseRoutes.servicesItemDetail(
          providerId: storeId,
          itemId: productId,
        ),
    onBack: (context, {required store}) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(BrowseRoutes.servicesBrowse());
      }
    },
    searchHint: 'Search services…',
    emptyMessage: 'No services available right now',
    emptySearchMessage: 'No services found',
    errorMessage: 'Could not load provider',
    bottomBarBuilder: ({
      required cartItemCount,
      required cartTotalLabel,
      required onCartTap,
    }) {
      if (cartItemCount <= 0) return null;
      return ServicesBookingBar(
        itemCount: cartItemCount,
        total: cartTotalLabel,
        onTap: onCartTap,
      );
    },
    onCartTap: onOpenBooking,
    afterAddSuccess: (context, ref, {required item}) async {
      // Reload happens in RetailStoreScreen; no snackbar (matches prior UX).
    },
  );
}

/// Helper used by vape wrapper to open cart tab.
void openVapeCartFromStore(WidgetRef ref, BuildContext context) {
  ref.read(shellProvider.notifier).openVapeCartWithItems();
  context.goHome(tab: 2, vapeCart: true);
}

void openServicesBooking(BuildContext context) {
  context.push(ServicesBookingRoutes.booking);
}
