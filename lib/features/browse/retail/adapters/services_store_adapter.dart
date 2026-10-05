import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/model/food_vendors_repository.dart';
import 'package:yjeek_app/features/browse/model/services_vendors_repository.dart';
import 'package:yjeek_app/features/browse/retail/retail_store_config.dart';
import 'package:yjeek_app/features/cart/model/pending_add_to_cart.dart';

Future<RetailCatalog> loadServicesCatalog(
  WidgetRef ref, {
  required String storeId,
  required String query,
  required bool loadedOnce,
}) async {
  final servicesRepo = ref.read(servicesVendorsRepositoryProvider);
  final foodRepo = ref.read(foodVendorsRepositoryProvider);

  final menu = await foodRepo.fetchVendorMenu(storeId, query: query);
  final cart = await servicesRepo.fetchServiceCart();
  final provider = await servicesRepo.fetchProvider(storeId);

  final modifiersById = <String, bool>{
    for (final i in menu.items) i.id: i.hasModifiers,
  };

  final storeUi = ElectronicsStore(
    id: provider.id,
    name: provider.name,
    rating: provider.rating,
    reviewCount: '${provider.reviewCount}',
    distance: provider.distance,
    categories: provider.category,
    productCount: menu.items.length,
    gradientStart: provider.gradientStart,
    gradientEnd: provider.gradientEnd,
    hasRating: provider.hasRating,
    area: provider.area ?? provider.locationLabel,
    imageUrl: provider.imageUrl,
    logoUrl: provider.imageUrl,
    coverUrl: provider.coverUrl ?? menu.restaurant.displayCoverUrl,
    offerBadge: provider.offerBadge,
    categoryLabel: provider.category,
    minOrderAmount: null,
  );

  return RetailCatalog(
    store: storeUi,
    sections: menu.sections,
    items: menu.items,
    chipGroups: menu.chipGroups,
    serviceItemsById: modifiersById,
    cartItemCount: cart.itemCount,
    cartTotalLabel: cart.totalLabel,
    cartVendorId: cart.vendorId,
  );
}

Future<RetailAddResult> servicesQuickAdd(
  WidgetRef ref, {
  required String storeId,
  required BrowseMenuItem item,
  required bool replaceCart,
}) async {
  final result = await ref.read(servicesVendorsRepositoryProvider).addToCart(
        productId: item.id,
        quantity: 1,
        replaceCart: replaceCart,
      );
  return RetailAddResult(
    ok: result.ok,
    vendorConflict: result.vendorConflict,
    message: result.message,
  );
}

bool servicesShouldOpenDetail(BrowseMenuItem item) => item.hasModifiers;

const servicesPendingVertical = PendingCartVertical.services;
