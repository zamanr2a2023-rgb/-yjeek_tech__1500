import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/maps_config.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/retail/retail_store_config.dart';
import 'package:yjeek_app/features/cart/model/pending_add_to_cart.dart';

Future<({double lat, double lng})> _customerCoords(WidgetRef ref) async {
  try {
    final addr = await ref.read(addressesRepositoryProvider).defaultAddress();
    if (addr?.latitude != null && addr?.longitude != null) {
      return (lat: addr!.latitude!, lng: addr.longitude!);
    }
  } catch (_) {}
  return (lat: MapsConfig.defaultLat, lng: MapsConfig.defaultLng);
}

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  double degToRad(double deg) => deg * math.pi / 180;
  final dLat = degToRad(lat2 - lat1);
  final dLon = degToRad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(degToRad(lat1)) *
          math.cos(degToRad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

Future<RetailCatalog> loadElectronicsCatalog(
  WidgetRef ref, {
  required String storeId,
  required String query,
  required bool loadedOnce,
}) async {
  final electronics = ref.read(electronicsVendorsRepositoryProvider);
  final food = ref.read(foodVendorsRepositoryProvider);

  final store = await electronics.fetchStore(storeId);
  final fallbackLabel = store.categoryLabel ??
      (store.categories.toLowerCase().contains('flower')
          ? 'Flowers'
          : store.categories.toLowerCase().contains('pharm')
              ? 'Pharmacy'
              : store.categories.isNotEmpty
                  ? store.categories
                  : 'Electronics');

  var distanceKm = store.distanceKm;
  if (distanceKm == null &&
      store.latitude != null &&
      store.longitude != null) {
    final me = await _customerCoords(ref);
    distanceKm = _haversineKm(
      me.lat,
      me.lng,
      store.latitude!,
      store.longitude!,
    );
  }

  final storeForUi = store.copyWith(
    categoryLabel: fallbackLabel,
    distanceKm: distanceKm,
  );

  final menu = await food.fetchVendorMenu(storeId, query: query);
  var sections = menu.sections;
  var items = menu.items;

  if (sections.isEmpty) {
    final products = await electronics.fetchProducts(storeId, query: query);
    if (products.isNotEmpty) {
      sections = const ['Products'];
      items = [
        for (final p in products)
          BrowseMenuItem(
            id: p.id,
            name: p.name,
            description: p.specs.isNotEmpty ? p.specs : '___',
            price: p.price,
            section: 'Products',
          ),
      ];
    }
  }

  items = [
    for (final i in items)
      i.name.toLowerCase().contains('prescription')
          ? BrowseMenuItem(
              id: i.id,
              name: i.name,
              description: i.description,
              price: '—',
              section: i.section,
              hasModifiers: i.hasModifiers,
              imageUrl: i.imageUrl,
              badges: i.badges,
            )
          : i,
  ];

  return RetailCatalog(
    store: storeForUi,
    sections: sections,
    items: items,
  );
}

Future<RetailAddResult> electronicsQuickAdd(
  WidgetRef ref, {
  required String storeId,
  required BrowseMenuItem item,
  required bool replaceCart,
}) async {
  final result = await ref.read(electronicsVendorsRepositoryProvider).addToCart(
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

bool electronicsShouldOpenDetail(BrowseMenuItem item) =>
    item.hasModifiers || item.price == '—';

const electronicsPendingVertical = PendingCartVertical.electronics;
