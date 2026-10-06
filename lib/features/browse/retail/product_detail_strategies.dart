import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/pharmacy_order_modes.dart';
import 'package:yjeek_app/features/browse/model/pharmacy_repository.dart';
import 'package:yjeek_app/features/catalog/model/catalog_product.dart';
import 'package:yjeek_app/features/browse/utils/vape_age_gate.dart';
import 'package:yjeek_app/features/cart/model/pending_add_to_cart.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';

class UniversalProductDetail {
  const UniversalProductDetail({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.optionGroups,
    required this.addons,
    this.imageUrl,
    this.imageUrls = const [],
    this.quantityLabel = 'Quantity',
    this.catalog,
  });

  final String id;
  final String name;
  final String price;
  final String description;
  final List<BrowseOptionGroup> optionGroups;
  final List<BrowseAddonOption> addons;
  final String? imageUrl;
  final List<String> imageUrls;
  final String quantityLabel;

  /// Present when the product payload was parsed as a catalog document.
  /// Services details omit it and stay on the modifier flow.
  final CatalogProduct? catalog;

  /// Variant SKU flow. Missing, `MODIFIERS`, and unknown modes stay on
  /// option groups. Store type slug is not consulted.
  bool get usesVariantSelection {
    final c = catalog;
    if (c == null) return false;
    if (c.catalogMode == CatalogMode.variants) return true;
    if (c.catalogMode == CatalogMode.modifiers) return false;
    return c.variants.isNotEmpty && c.axes.isNotEmpty;
  }
}

class UniversalAddResult {
  const UniversalAddResult({
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

typedef ProductDetailLoader =
    Future<UniversalProductDetail> Function(
      WidgetRef ref, {
      required String storeId,
      required String productId,
    });

typedef ProductDetailAdder =
    Future<UniversalAddResult> Function(
      WidgetRef ref, {
      required String storeId,
      required String productId,
      required int quantity,
      required List<String> optionIds,
      required List<String> addonIds,
      required bool replaceCart,
      String? variantId,
    });

typedef ProductDetailBeforeAdd =
    Future<bool> Function(
      BuildContext context,
      WidgetRef ref, {
      required String productName,
    });

typedef ProductDetailAfterSuccess =
    Future<void> Function(
      BuildContext context,
      WidgetRef ref, {
      required String productName,
    });

class ProductDetailStrategy {
  const ProductDetailStrategy({
    required this.pendingVertical,
    required this.load,
    required this.add,
    required this.fallbackStoreRoute,
    required this.ctaVerb,
    this.beforeAdd,
    this.afterSuccess,
    this.showAgeBanner = false,
    this.cartType = 'DELIVERY',
  });

  final PendingCartVertical pendingVertical;
  final ProductDetailLoader load;
  final ProductDetailAdder add;
  final String Function(String storeId) fallbackStoreRoute;
  final String ctaVerb;
  final ProductDetailBeforeAdd? beforeAdd;
  final ProductDetailAfterSuccess? afterSuccess;
  final bool showAgeBanner;
  final String cartType;
}

Future<UniversalProductDetail> _loadFoodStyleDetail(
  WidgetRef ref, {
  required String storeId,
  required String productId,
}) async {
  final detail = await ref
      .read(foodVendorsRepositoryProvider)
      .fetchProductDetail(vendorId: storeId, itemId: productId);
  return UniversalProductDetail(
    id: detail.item.id,
    name: detail.item.localizedName,
    price: detail.item.price,
    description: detail.description,
    optionGroups: detail.optionGroups,
    addons: detail.addons,
    imageUrl: detail.imageUrl ?? detail.item.imageUrl,
    imageUrls: detail.imageUrls,
    catalog: detail.catalog,
  );
}

final electronicsProductDetailStrategy = ProductDetailStrategy(
  pendingVertical: PendingCartVertical.electronics,
  load: _loadFoodStyleDetail,
  ctaVerb: 'Add to Cart',
  fallbackStoreRoute: (storeId) =>
      BrowseRoutes.electronicsStore(storeId: storeId),
  add:
      (
        ref, {
        required storeId,
        required productId,
        required quantity,
        required optionIds,
        required addonIds,
        required replaceCart,
        variantId,
      }) async {
        final session = ref.read(pharmacySessionProvider);
        if (session != null &&
            session.matches(storeId) &&
            session.mode == PharmacyDeliveryMode.deliverNow) {
          final result = await ref.read(pharmacyRepositoryProvider).addDeliverNow(
                productId: productId,
                quantity: quantity,
                optionIds: optionIds,
                addonIds: addonIds,
                replaceCart: replaceCart,
                variantId: variantId,
              );
          if (result.ok) {
            ref.read(shellProvider.notifier).markCartUpdated(delivery: true);
          }
          return UniversalAddResult(
            ok: result.ok,
            vendorConflict: result.vendorConflict,
            message: result.message,
          );
        }
        final result = await ref
            .read(electronicsVendorsRepositoryProvider)
            .addToCart(
              productId: productId,
              quantity: quantity,
              optionIds: optionIds,
              addonIds: addonIds,
              replaceCart: replaceCart,
              vendorId: storeId,
              variantId: variantId,
            );
        if (result.ok) {
          ref.read(shellProvider.notifier).markCartUpdated(delivery: true);
        }
        return UniversalAddResult(
          ok: result.ok,
          vendorConflict: result.vendorConflict,
          outOfRange: result.outOfRange,
          message: result.message,
        );
      },
);

final vapeProductDetailStrategy = ProductDetailStrategy(
  pendingVertical: PendingCartVertical.vape,
  load: _loadFoodStyleDetail,
  ctaVerb: 'Add to Cart',
  showAgeBanner: true,
  fallbackStoreRoute: (storeId) => BrowseRoutes.vapeStore(storeId: storeId),
  beforeAdd: (context, ref, {required productName}) =>
      ensureVapeAgeVerifiedForPurchase(context, ref, productName: productName),
  add:
      (
        ref, {
        required storeId,
        required productId,
        required quantity,
        required optionIds,
        required addonIds,
        required replaceCart,
        variantId,
      }) async {
        final result = await ref
            .read(vapeVendorsRepositoryProvider)
            .addToCart(
              productId: productId,
              quantity: quantity,
              optionIds: optionIds,
              addonIds: addonIds,
              replaceCart: replaceCart,
              vendorId: storeId,
              variantId: variantId,
            );
        if (result.ok) {
          ref
              .read(shellProvider.notifier)
              .markCartUpdated(vape: true, delivery: true);
        }
        return UniversalAddResult(
          ok: result.ok,
          vendorConflict: result.vendorConflict,
          outOfRange: result.outOfRange,
          message: result.message,
        );
      },
);

final servicesProductDetailStrategy = ProductDetailStrategy(
  pendingVertical: PendingCartVertical.services,
  cartType: 'SERVICE',
  ctaVerb: 'Book now',
  fallbackStoreRoute: (storeId) =>
      BrowseRoutes.servicesProvider(providerId: storeId),
  load: (ref, {required storeId, required productId}) async {
    final detail = await ref
        .read(servicesVendorsRepositoryProvider)
        .fetchProductDetail(providerId: storeId, itemId: productId);
    return UniversalProductDetail(
      id: detail.item.id,
      name: detail.item.name,
      price: detail.item.price,
      description: detail.description,
      optionGroups: detail.optionGroups,
      addons: detail.addons,
      imageUrl: detail.imageUrl,
      imageUrls: detail.imageUrl != null && detail.imageUrl!.isNotEmpty
          ? [detail.imageUrl!]
          : const [],
      quantityLabel: detail.quantityLabel,
    );
  },
  add:
      (
        ref, {
        required storeId,
        required productId,
        required quantity,
        required optionIds,
        required addonIds,
        required replaceCart,
        variantId,
      }) async {
        final result = await ref
            .read(servicesVendorsRepositoryProvider)
            .addToCart(
              productId: productId,
              quantity: quantity,
              optionIds: optionIds,
              addonIds: addonIds,
              replaceCart: replaceCart,
            );
        return UniversalAddResult(
          ok: result.ok,
          vendorConflict: result.vendorConflict,
          message: result.message,
        );
      },
  afterSuccess: (context, ref, {required productName}) async {
    if (!context.mounted) return;
    context.push(ServicesBookingRoutes.booking);
  },
);
