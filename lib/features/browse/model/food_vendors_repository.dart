import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/core/utils/api_media_url.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';
import 'package:yjeek_app/l10n/l10n.dart';

class FoodVendorMenu {
  const FoodVendorMenu({
    required this.restaurant,
    required this.sections,
    required this.items,
  });

  final BrowseRestaurant restaurant;
  final List<String> sections;
  final List<BrowseMenuItem> items;
}

class FoodProductDetail {
  const FoodProductDetail({
    required this.item,
    required this.description,
    required this.optionGroups,
    required this.addons,
    this.imageUrl,
    this.descriptionAr,
  });

  final BrowseMenuItem item;
  final String description;
  final String? descriptionAr;
  final List<BrowseOptionGroup> optionGroups;
  final List<BrowseAddonOption> addons;
  final String? imageUrl;

  String get localizedDescription {
    if (L10n.isArabic) {
      final ar = descriptionAr?.trim();
      if (ar != null && ar.isNotEmpty) return ar;
    }
    return description;
  }
}

class FoodCartSummary {
  const FoodCartSummary({
    required this.itemCount,
    required this.totalLabel,
    this.vendorId,
  });

  final int itemCount;
  final String totalLabel;
  final String? vendorId;

  static const empty = FoodCartSummary(itemCount: 0, totalLabel: '0.000');
}

class FoodVendorsRepository {
  const FoodVendorsRepository(
    this._apiClient,
    this._storage, {
    AddressesRepository? addresses,
  }) : _addresses = addresses;

  final ApiClient _apiClient;
  final StorageService _storage;
  final AddressesRepository? _addresses;

  String? get _token => _storage.token;

  /// GET /vendors/cuisines?category=food
  Future<List<String>> fetchCuisineFilters() async {
    final response = await _apiClient.getJson(
      '/vendors/cuisines?category=food',
    );
    final data = response?['data'];
    final list = data is Map<String, dynamic> ? data['cuisines'] : null;
    if (list is! List || list.isEmpty) return const ['All'];

    final names = <String>['All'];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final name = item['name'] as String?;
        if (name != null && name.isNotEmpty) names.add(name);
      } else if (item is String && item.isNotEmpty) {
        names.add(item);
      }
    }
    return names.length > 1 ? names : const ['All'];
  }

  /// GET /vendors?category=food&supportsDelivery=&sort=&cuisine=&freeDelivery=&openNow=&minRating=&maxDeliveryTime=&hasOffers=&q=&latitude=&longitude=&withinDeliveryRadius=
  Future<List<BrowseRestaurant>> fetchVendors({
    String? cuisine,
    bool freeDelivery = false,
    bool openNow = false,
    bool hasOffers = false,
    double? minRating,
    int? maxDeliveryTime,
    String sort = 'rating',
    String? query,
    double? latitude,
    double? longitude,
    bool withinDeliveryRadius = false,
    bool supportsDelivery = true,
  }) async {
    final params = <String, String>{
      'category': 'food',
      'sort': sort,
    };
    if (supportsDelivery) params['supportsDelivery'] = 'true';
    if (cuisine != null &&
        cuisine.isNotEmpty &&
        cuisine.toLowerCase() != 'all') {
      params['cuisine'] = cuisine;
    }
    if (freeDelivery) params['freeDelivery'] = 'true';
    if (openNow) params['openNow'] = 'true';
    if (hasOffers) params['hasOffers'] = 'true';
    if (minRating != null && minRating > 0) {
      params['minRating'] = minRating.toString();
    }
    if (maxDeliveryTime != null && maxDeliveryTime > 0) {
      params['maxDeliveryTime'] = maxDeliveryTime.toString();
    }
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    if (latitude != null && longitude != null) {
      params['latitude'] = latitude.toString();
      params['longitude'] = longitude.toString();
      if (withinDeliveryRadius) {
        params['withinDeliveryRadius'] = 'true';
      }
    }

    final qs = params.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}='
              '${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');

    final response = await _apiClient.getJson('/vendors?$qs');
    final data = response?['data'];
    if (data is! List) return const [];

    final items = <BrowseRestaurant>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = browseRestaurantFromVendorJson(raw);
      if (mapped != null) items.add(mapped);
    }
    return items;
  }

  /// GET /vendors/:id
  Future<BrowseRestaurant> fetchVendor(String vendorId) async {
    final response = await _apiClient.getJson('/vendors/$vendorId');
    final data = response?['data'];
    if (data is Map<String, dynamic>) {
      final mapped = browseRestaurantFromVendorJson(data);
      if (mapped != null) return mapped;
    }
    throw StateError('Food vendor not found: $vendorId');
  }

  /// GET /vendors/:id/menu?q=&orderType=DELIVERY|PICKUP|DINE_IN
  Future<FoodVendorMenu> fetchVendorMenu(
    String vendorId, {
    String? query,
    String? orderType,
  }) async {
    final params = <String, String>{};
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    if (orderType != null && orderType.trim().isNotEmpty) {
      params['orderType'] = orderType.trim().toUpperCase();
    }
    final qs = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final response = await _apiClient.getJson('/vendors/$vendorId/menu$qs');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      final restaurant = await fetchVendor(vendorId);
      return FoodVendorMenu(
        restaurant: restaurant,
        sections: const [],
        items: const [],
      );
    }

    final vendorRaw = data['vendor'];
    final restaurant = vendorRaw is Map<String, dynamic>
        ? (browseRestaurantFromVendorJson({
              ...vendorRaw,
              'id': vendorRaw['id'] ?? vendorId,
              'slug': vendorRaw['slug'] ?? vendorId,
            }) ??
            await fetchVendor(vendorId))
        : await fetchVendor(vendorId);

    final sectionsRaw = data['sections'];
    final sections = <String>[];
    final items = <BrowseMenuItem>[];
    if (sectionsRaw is List) {
      for (final section in sectionsRaw) {
        if (section is! Map<String, dynamic>) continue;
        final sectionName = (section['name'] as String?)?.trim();
        if (sectionName == null || sectionName.isEmpty) continue;
        final products = section['products'];
        if (products is! List || products.isEmpty) continue;
        sections.add(sectionName);
        for (final product in products) {
          if (product is! Map<String, dynamic>) continue;
          final mapped = browseMenuItemFromProductJson(
            product,
            section: sectionName,
          );
          if (mapped != null) items.add(mapped);
        }
      }
    }

    return FoodVendorMenu(
      restaurant: restaurant,
      sections: sections,
      items: items,
    );
  }

  /// GET /vendors/:id/products/:productId
  Future<FoodProductDetail> fetchProductDetail({
    required String vendorId,
    required String itemId,
  }) async {
    final response = await _apiClient.getJson(
      '/vendors/$vendorId/products/$itemId',
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Product not found');
    }

    final item = browseMenuItemFromProductJson(
          data,
          section: data['menuSectionName'] as String? ?? 'Menu',
        );
    if (item == null) {
      throw StateError('Product not found');
    }

    final optionGroups = browseOptionGroupsFromJson(data['optionGroups']);

    final addons = <BrowseAddonOption>[];
    final addonsRaw = data['addons'];
    if (addonsRaw is List) {
      for (final addon in addonsRaw) {
        if (addon is! Map<String, dynamic>) continue;
        final id = addon['id']?.toString();
        final nameEn = addon['name'] as String? ?? 'Add-on';
        final nameAr = (addon['nameAr'] as String?)?.trim();
        final name = (L10n.isArabic && nameAr != null && nameAr.isNotEmpty)
            ? nameAr
            : nameEn;
        final price = addon['price'];
        final priceNum = price is num ? price.toDouble() : 0.0;
        addons.add(
          BrowseAddonOption(
            id: id,
            label: name,
            price: priceNum.toStringAsFixed(3),
            imageUrl: resolveApiMediaUrl(addon['imageUrl'] as String?),
          ),
        );
      }
    }

    final descEn = (data['description'] as String?)?.trim() ?? '';
    final descAr = (data['descriptionAr'] as String?)?.trim() ?? '';
    final description = descEn.isNotEmpty ? descEn : item.description;

    return FoodProductDetail(
      item: item,
      description: description.isNotEmpty ? description : item.description,
      descriptionAr: descAr.isNotEmpty ? descAr : item.descriptionAr,
      optionGroups: optionGroups,
      addons: addons,
      imageUrl: resolveApiMediaUrl(data['imageUrl'] as String?) ??
          resolveApiMediaUrlFromList(data['imageUrls']) ??
          item.imageUrl,
    );
  }

  /// GET /cart?type=DELIVERY|PICKUP|DINE_IN
  Future<FoodCartSummary> fetchDeliveryCart({String cartType = 'DELIVERY'}) async {
    if (!_storage.hasSession) return FoodCartSummary.empty;

    final type = _normalizeCartType(cartType);
    final response = await _apiClient.getJson(
      '/cart?type=$type',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return FoodCartSummary.empty;

    final items = data['items'];
    var count = (data['itemCount'] as num?)?.toInt();
    if (count == null && items is List) {
      count = 0;
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          count = count! + ((item['quantity'] as num?)?.toInt() ?? 1);
        }
      }
    }
    final summary = data['summary'];
    final total = summary is Map<String, dynamic>
        ? summary['totalAmount']
        : null;
    final totalNum = total is num ? total.toDouble() : 0.0;
    final vendor = data['vendor'];
    final vendorId = vendor is Map<String, dynamic>
        ? vendor['id']?.toString()
        : data['vendorId']?.toString();

    return FoodCartSummary(
      itemCount: count ?? 0,
      totalLabel: totalNum.toStringAsFixed(3),
      vendorId: vendorId,
    );
  }

  /// POST /cart/items?type=DELIVERY|PICKUP|DINE_IN
  /// Returns null on success, conflict message on vendor conflict, or error text.
  Future<({bool ok, bool vendorConflict, bool outOfRange, String? message})>
      addToCart({
    required String productId,
    required int quantity,
    List<String> optionIds = const [],
    List<String> addonIds = const [],
    bool replaceCart = false,
    String cartType = 'DELIVERY',
    String? vendorId,
    String? geofenceTriggerId,
  }) async {
    final type = _normalizeCartType(cartType);

    if (type == 'DELIVERY' &&
        _addresses != null &&
        _storage.hasSession &&
        vendorId != null &&
        vendorId.isNotEmpty) {
      final range = await checkDeliveryRange(
        addresses: _addresses!,
        vendorId: vendorId,
        failClosed: false,
      );
      if (range.isOutOfRange) {
        return (
          ok: false,
          vendorConflict: false,
          outOfRange: true,
          message: 'This address is outside the vendor delivery area',
        );
      }
    }

    final response = await _apiClient.postJson(
      '/cart/items?type=$type',
      {
        'productId': productId,
        'quantity': quantity,
        'replaceCart': replaceCart,
        if (geofenceTriggerId != null && geofenceTriggerId.isNotEmpty)
          'geofenceTriggerId': geofenceTriggerId,
        'options': {
          if (optionIds.isNotEmpty) 'optionIds': optionIds,
          if (addonIds.isNotEmpty) 'addonIds': addonIds,
        },
      },
      bearerToken: _token,
    );

    if (response.ok) {
      return (ok: true, vendorConflict: false, outOfRange: false, message: null);
    }

    final error = response.json?['error'];
    final details = error is Map ? error['details'] : null;
    final detailCode = details is Map ? details['code']?.toString() : null;
    final code = error is Map ? error['code']?.toString() : null;
    final outOfRange = isOutOfDeliveryRangeCode(code) ||
        isOutOfDeliveryRangeCode(detailCode) ||
        isOutOfDeliveryRangeMessage(response.message);
    final conflict = !outOfRange &&
        (response.statusCode == 409 ||
            code == 'VENDOR_CART_CONFLICT' ||
            detailCode == 'VENDOR_CART_CONFLICT' ||
            code == 'CONFLICT');
    return (
      ok: false,
      vendorConflict: conflict,
      outOfRange: outOfRange,
      message: response.message ?? 'Could not add to cart',
    );
  }

  static String _normalizeCartType(String cartType) {
    final t = cartType.trim().toUpperCase().replaceAll('-', '_');
    if (t == 'PICKUP') return 'PICKUP';
    if (t == 'DINE_IN' || t == 'DINEIN') return 'DINE_IN';
    return 'DELIVERY';
  }

  /// GET /search/history
  Future<List<String>> fetchRecentSearches() async {
    final response = await _apiClient.getJson(
      '/search/history',
      bearerToken: _token,
    );
    final data = response?['data'];
    final list = data is List
        ? data
        : (data is Map<String, dynamic> ? data['items'] ?? data['history'] : null);
    if (list is! List || list.isEmpty) return const [];

    final queries = <String>[];
    for (final raw in list) {
      if (raw is Map<String, dynamic>) {
        final q = raw['query'] as String?;
        if (q != null && q.trim().isNotEmpty) queries.add(q.trim());
      } else if (raw is String && raw.trim().isNotEmpty) {
        queries.add(raw.trim());
      }
    }
    return queries;
  }
}

BrowseRestaurant? browseRestaurantFromVendorJson(Map<String, dynamic> json) {
  final id = (json['id'] ?? json['slug'])?.toString();
  final name = json['name'] as String?;
  if (id == null || id.isEmpty || name == null || name.isEmpty) return null;

  final tags = json['cuisineTags'];
  final categoryLabel = (json['categoryLabel'] as String?)?.trim() ??
      (json['serviceCategory'] as String?)?.trim();
  final cuisine = tags is List && tags.isNotEmpty
      ? tags.map((e) => e.toString()).where((e) => e.isNotEmpty).join(' · ')
      : (categoryLabel != null && categoryLabel.isNotEmpty
          ? categoryLabel
          : 'Food');

  final reviewCountRaw = json['reviewCount'];
  final reviewCountValue = reviewCountRaw is num ? reviewCountRaw.toInt() : 0;
  final ratingRaw = json['rating'];
  final ratingParsed = ratingRaw is num
      ? ratingRaw.toDouble()
      : double.tryParse(ratingRaw?.toString() ?? '') ?? 0;
  final hasRating = json['hasRating'] == true ||
      (reviewCountValue > 0 && ratingParsed > 0);
  final rating = hasRating ? ratingParsed : 0.0;

  final arrivesIn = (json['arrivesInMin'] as num?)?.toInt();
  final readyIn = (json['readyInMin'] as num?)?.toInt() ??
      (json['pickupEtaMin'] as num?)?.toInt();
  final prepTime = (json['prepTimeMin'] as num?)?.toInt();
  final deliveryMin = arrivesIn ??
      (json['deliveryTimeMin'] as num?)?.toInt() ??
      25;
  final freeDelivery = json['freeDelivery'] == true;
  final deliveryFeeRaw = json['deliveryFee'];
  final deliveryFee = deliveryFeeRaw is num
      ? deliveryFeeRaw.toStringAsFixed(1)
      : (deliveryFeeRaw?.toString() ?? '0.8');
  final minOrderRaw = json['minOrderAmount'];
  final minOrder = minOrderRaw is num
      ? minOrderRaw.toStringAsFixed(0)
      : (minOrderRaw?.toString() ?? '5');
  final distanceKmRaw = json['distanceKm'];
  final distanceKm = distanceKmRaw is num ? distanceKmRaw.toDouble() : null;
  final distance = distanceKm != null
      ? '${distanceKm.toStringAsFixed(1)} km'
      : 'Nearby';

  final reviewCount = reviewCountValue > 0
      ? _formatReviewCount(reviewCountValue)
      : '___';

  final badge = json['offerBadge'] as String?;
  final imageUrl = resolveApiMediaUrl(json['coverUrl'] as String?) ??
      resolveApiMediaUrl(json['logoUrl'] as String?) ??
      resolveApiMediaUrlFromList(json['imageUrls']);
  final colors = _gradientForName(name);
  final area = (json['area'] as String?)?.trim().isNotEmpty == true
      ? (json['area'] as String).trim()
      : ((json['city'] as String?)?.trim().isNotEmpty == true
          ? (json['city'] as String).trim()
          : null);
  final openStatus = (json['openStatus'] as String?)?.toUpperCase();
  // Only treat explicit OPEN as open — UNKNOWN used to pass Open now wrongly.
  final isOpen = openStatus == 'OPEN';

  final dineIn = json['dineInAvailability'];
  String? dineInLabel;
  int? dineInTables;
  if (dineIn is Map<String, dynamic>) {
    dineInLabel = dineIn['label'] as String?;
    dineInTables = (dineIn['tablesAvailable'] as num?)?.toInt();
  }

  final lat = json['latitude'];
  final lng = json['longitude'];

  return BrowseRestaurant(
    id: id,
    name: name,
    cuisine: cuisine,
    rating: double.parse(rating.toStringAsFixed(1)),
    gradientStart: colors.$1,
    gradientEnd: colors.$2,
    badge: badge,
    deliveryMin: deliveryMin,
    freeDelivery: freeDelivery,
    deliveryFee: deliveryFee,
    minOrder: minOrder,
    distance: distance,
    imageUrl: imageUrl,
    reviewCount: reviewCount,
    reviewCountValue: reviewCountValue,
    hasRating: hasRating,
    area: area,
    isOpen: isOpen,
    prepTimeMin: prepTime,
    arrivesInMin: arrivesIn ?? deliveryMin,
    readyInMin: readyIn,
    distanceKm: distanceKm,
    latitude: lat is num ? lat.toDouble() : null,
    longitude: lng is num ? lng.toDouble() : null,
    isBookable: json['isBookable'] == true,
    dineInAvailableLabel: dineInLabel,
    dineInTablesAvailable: dineInTables,
    categoryLabel: categoryLabel,
    supportsDelivery: json['supportsDelivery'] != false,
    supportsPickup: json['supportsPickup'] == true,
    supportsDineIn: json['supportsDineIn'] == true,
  );
}

BrowseMenuItem? browseMenuItemFromProductJson(
  Map<String, dynamic> json, {
  required String section,
}) {
  final id = json['id']?.toString();
  final name = json['name'] as String?;
  if (id == null || id.isEmpty || name == null || name.isEmpty) return null;
  final price = json['price'];
  final priceStr = price is num
      ? price.toStringAsFixed(3)
      : (price?.toString() ?? '0.000');
  final description = (json['description'] as String?)?.trim() ?? '';
  final nameAr = (json['nameAr'] as String?)?.trim();
  final descriptionAr = (json['descriptionAr'] as String?)?.trim();
  final imageUrl = resolveApiMediaUrl(json['imageUrl'] as String?) ??
      resolveApiMediaUrlFromList(json['imageUrls']);

  final optionGroups = json['optionGroups'];
  final addons = json['addons'];
  final count = json['_count'];
  final optionCount = optionGroups is List
      ? optionGroups.length
      : (count is Map ? (count['optionGroups'] as num?)?.toInt() ?? 0 : 0);
  final addonCount = addons is List
      ? addons.length
      : (count is Map ? (count['addons'] as num?)?.toInt() ?? 0 : 0);
  // Prefer explicit API flag; fall back to counts so plain items can "+" add.
  final hasModifiers = json['hasModifiers'] == true ||
      optionCount > 0 ||
      addonCount > 0;

  final badgesRaw = json['badges'];
  final badges = <String>[];
  if (badgesRaw is List) {
    for (final b in badgesRaw) {
      final s = b?.toString().trim();
      if (s != null && s.isNotEmpty) badges.add(s);
    }
  }

  return BrowseMenuItem(
    id: id,
    name: name,
    nameAr: (nameAr != null && nameAr.isNotEmpty) ? nameAr : null,
    description: description.isNotEmpty ? description : '___',
    descriptionAr:
        (descriptionAr != null && descriptionAr.isNotEmpty) ? descriptionAr : null,
    price: priceStr,
    section: section,
    imageUrl: imageUrl,
    hasModifiers: hasModifiers,
    badges: badges,
  );
}

String _formatReviewCount(int count) {
  if (count >= 1000) {
    final k = count / 1000;
    final label = k >= 10 ? k.toStringAsFixed(0) : k.toStringAsFixed(1);
    return '${label}k';
  }
  return count.toString();
}

(Color, Color) _gradientForName(String name) {
  final base = HomeBrandStyle.forName(name);
  return (base, const Color(0xFF15302B));
}
