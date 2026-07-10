import 'package:yjeek_app/routes/route_names.dart';

abstract final class BrowseRoutes {
  static const defaultVendorId = 'green-kitchen';
  static const defaultItemId = 'mezze-platter';
  static const defaultDineInRestaurantId = 'veera';
  static const defaultDineInItemId = 'mezze-platter';
  static const defaultServicesProviderId = 'glow-beauty-lounge';
  static const defaultServicesItemId = 'haircut-styling';
  static const defaultElectronicsStoreId = 'techhub-electronics';
  static const defaultElectronicsProductId = 'nova-12';
  static const defaultVapeStoreId = 'vapeology-bahrain';
  static const defaultVapeProductId = 'mango-ice-disposable';

  static String foodBrowse({int tab = 0}) {
    if (tab == 0) return RouteNames.foodBrowse;
    return '${RouteNames.foodBrowse}?tab=$tab';
  }

  static String foodSearch({String? query, int tab = 0}) {
    final queryBuffer = StringBuffer(RouteNames.foodSearch);
    final params = <String>[];
    if (query != null && query.isNotEmpty) params.add('q=$query');
    if (tab != 0) params.add('tab=$tab');
    if (params.isNotEmpty) queryBuffer.write('?${params.join('&')}');
    return queryBuffer.toString();
  }

  static String vendorMenu({
    String? vendorId,
    int tab = 0,
  }) {
    final id = vendorId ?? defaultVendorId;
    final buffer = StringBuffer('${RouteNames.vendorMenu}?id=$id');
    if (tab != 0) buffer.write('&tab=$tab');
    return buffer.toString();
  }

  static String itemDetail({
    String? vendorId,
    String? itemId,
    int tab = 0,
  }) {
    final id = vendorId ?? defaultVendorId;
    final item = itemId ?? defaultItemId;
    final buffer = StringBuffer('${RouteNames.itemDetail}?vendor=$id&item=$item');
    if (tab != 0) buffer.write('&tab=$tab');
    return buffer.toString();
  }

  static String dineInBrowse({int tab = 0}) {
    if (tab == 0) return RouteNames.dineInBrowse;
    return '${RouteNames.dineInBrowse}?tab=$tab';
  }

  static String dineInOrderAgain({int tab = 0}) {
    if (tab == 0) return RouteNames.dineInOrderAgain;
    return '${RouteNames.dineInOrderAgain}?tab=$tab';
  }

  static String dineInMenu({
    String? restaurantId,
    int tab = 0,
  }) {
    final id = restaurantId ?? defaultDineInRestaurantId;
    final buffer = StringBuffer('${RouteNames.dineInMenu}?id=$id');
    if (tab != 0) buffer.write('&tab=$tab');
    return buffer.toString();
  }

  static String dineInItemDetail({
    String? restaurantId,
    String? itemId,
    int tab = 0,
  }) {
    final id = restaurantId ?? defaultDineInRestaurantId;
    final item = itemId ?? defaultDineInItemId;
    final buffer = StringBuffer('${RouteNames.dineInItemDetail}?restaurant=$id&item=$item');
    if (tab != 0) buffer.write('&tab=$tab');
    return buffer.toString();
  }

  static String servicesBrowse({int tab = 0}) {
    if (tab == 0) return RouteNames.servicesBrowse;
    return '${RouteNames.servicesBrowse}?tab=$tab';
  }

  static String servicesCategory({
    required String categoryId,
    int tab = 0,
  }) {
    final buffer = StringBuffer('${RouteNames.servicesCategory}?id=$categoryId');
    if (tab != 0) buffer.write('&tab=$tab');
    return buffer.toString();
  }

  static String servicesProvider({
    String? providerId,
    int tab = 0,
  }) {
    final id = providerId ?? defaultServicesProviderId;
    final buffer = StringBuffer('${RouteNames.servicesProvider}?id=$id');
    if (tab != 0) buffer.write('&tab=$tab');
    return buffer.toString();
  }

  static String servicesItemDetail({
    String? providerId,
    String? itemId,
    int tab = 0,
  }) {
    final id = providerId ?? defaultServicesProviderId;
    final item = itemId ?? defaultServicesItemId;
    final buffer = StringBuffer('${RouteNames.servicesItemDetail}?provider=$id&item=$item');
    if (tab != 0) buffer.write('&tab=$tab');
    return buffer.toString();
  }

  static String electronicsBrowse({int tab = 0}) {
    if (tab == 0) return RouteNames.electronicsBrowse;
    return '${RouteNames.electronicsBrowse}?tab=$tab';
  }

  static String electronicsStore({
    String? storeId,
    int tab = 0,
  }) {
    final id = storeId ?? defaultElectronicsStoreId;
    final buffer = StringBuffer('${RouteNames.electronicsStore}?id=$id');
    if (tab != 0) buffer.write('&tab=$tab');
    return buffer.toString();
  }

  static String electronicsProductDetail({
    String? storeId,
    String? productId,
    int tab = 0,
  }) {
    final id = storeId ?? defaultElectronicsStoreId;
    final product = productId ?? defaultElectronicsProductId;
    final buffer =
        StringBuffer('${RouteNames.electronicsProductDetail}?store=$id&product=$product');
    if (tab != 0) buffer.write('&tab=$tab');
    return buffer.toString();
  }

  static String vapeBrowse({int tab = 0}) {
    if (tab == 0) return RouteNames.vapeBrowse;
    return '${RouteNames.vapeBrowse}?tab=$tab';
  }

  static String vapeStore({
    String? storeId,
    int tab = 0,
  }) {
    final id = storeId ?? defaultVapeStoreId;
    final buffer = StringBuffer('${RouteNames.vapeStore}?id=$id');
    if (tab != 0) buffer.write('&tab=$tab');
    return buffer.toString();
  }

  static String vapeProductDetail({
    String? storeId,
    String? productId,
    int tab = 0,
  }) {
    final id = storeId ?? defaultVapeStoreId;
    final product = productId ?? defaultVapeProductId;
    final buffer =
        StringBuffer('${RouteNames.vapeProductDetail}?store=$id&product=$product');
    if (tab != 0) buffer.write('&tab=$tab');
    return buffer.toString();
  }

  static String pickupBrowse({int tab = 0}) {
    if (tab == 0) return RouteNames.pickupBrowse;
    return '${RouteNames.pickupBrowse}?tab=$tab';
  }

  static String pickupCategories({int tab = 0}) {
    if (tab == 0) return RouteNames.pickupCategories;
    return '${RouteNames.pickupCategories}?tab=$tab';
  }
}
