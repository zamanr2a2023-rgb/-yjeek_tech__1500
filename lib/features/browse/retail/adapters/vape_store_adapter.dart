import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/retail/retail_store_config.dart';
import 'package:yjeek_app/features/browse/utils/vape_age_gate.dart';
import 'package:yjeek_app/features/cart/model/pending_add_to_cart.dart';

Future<RetailCatalog> loadVapeCatalog(
  WidgetRef ref, {
  required String storeId,
  required String query,
  required bool loadedOnce,
}) async {
  final electronics = ref.read(electronicsVendorsRepositoryProvider);
  final food = ref.read(foodVendorsRepositoryProvider);

  final store = await electronics.fetchStore(storeId);
  final storeForUi = ElectronicsStore(
    id: store.id,
    name: store.name,
    rating: store.rating,
    reviewCount: store.reviewCount,
    distance: store.distance,
    categories: store.categories,
    productCount: store.productCount,
    gradientStart: store.gradientStart,
    gradientEnd: store.gradientEnd,
    freeDelivery: store.freeDelivery,
    hasRating: store.hasRating,
    area: store.area,
    imageUrl: store.imageUrl,
    logoUrl: store.logoUrl,
    offerBadge: store.offerBadge,
    categoryLabel: store.categoryLabel ?? 'Vape',
    minOrderAmount: store.minOrderAmount,
  );

  final menu = await food.fetchVendorMenu(storeId, query: query);
  var sections = menu.sections;
  var items = menu.items;

  if (sections.isEmpty) {
    final products = await ref.read(vapeVendorsRepositoryProvider).fetchProducts(
          storeId,
          category: 'All',
          query: query,
        );
    if (products.isNotEmpty) {
      final byCat = <String, List<BrowseMenuItem>>{};
      for (final p in products) {
        final cat =
            p.category.trim().isEmpty ? 'Products' : p.category.trim();
        byCat.putIfAbsent(cat, () => []);
        byCat[cat]!.add(
          BrowseMenuItem(
            id: p.id,
            name: p.name,
            description: p.specs.isNotEmpty ? p.specs : '___',
            price: p.price,
            section: cat,
            hasModifiers: p.nicotineOptionIds.isNotEmpty,
          ),
        );
      }
      sections = byCat.keys.toList(growable: false);
      items = [for (final list in byCat.values) ...list];
    }
  }

  var cartCount = 0;
  var cartTotal = '0.000';
  String? cartVendorId;
  try {
    final cart = await ref.read(vapeVendorsRepositoryProvider).fetchCart();
    cartCount = cart.itemCount;
    cartTotal = cart.totalLabel;
    cartVendorId = cart.vendorId;
  } catch (_) {}

  return RetailCatalog(
    store: storeForUi,
    sections: sections,
    items: items,
    cartItemCount: cartCount,
    cartTotalLabel: cartTotal,
    cartVendorId: cartVendorId,
  );
}

Future<bool> vapeBeforeAdd(
  BuildContext context,
  WidgetRef ref,
  BrowseMenuItem item,
) {
  return ensureVapeAgeVerifiedForPurchase(
    context,
    ref,
    productName: item.localizedName,
  );
}

Future<RetailAddResult> vapeQuickAdd(
  WidgetRef ref, {
  required String storeId,
  required BrowseMenuItem item,
  required bool replaceCart,
}) async {
  final result = await ref.read(vapeVendorsRepositoryProvider).addToCart(
        productId: item.id,
        quantity: 1,
        replaceCart: replaceCart,
        vendorId: storeId,
      );
  return RetailAddResult(
    ok: result.ok,
    vendorConflict: result.vendorConflict,
    outOfRange: result.outOfRange,
    message: result.message,
  );
}

bool vapeShouldOpenDetail(BrowseMenuItem item) => item.hasModifiers;

const vapePendingVertical = PendingCartVertical.vape;
