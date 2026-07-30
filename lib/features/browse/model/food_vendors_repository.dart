import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';

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
    required this.options,
    required this.addons,
    this.imageUrl,
  });

  final BrowseMenuItem item;
  final String description;
  final List<BrowseSizeOption> options;
  final List<BrowseAddonOption> addons;
  final String? imageUrl;
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
  const FoodVendorsRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /vendors/cuisines?category=food
  Future<List<String>> fetchCuisineFilters() async {
    final response = await _apiClient.getJson(
      '/vendors/cuisines?category=food',
    );
    final data = response?['data'];
    final list = data is Map<String, dynamic> ? data['cuisines'] : null;
    if (list is! List || list.isEmpty) return BrowseData.cuisineFilters;

    final names = <String>['All'];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final name = item['name'] as String?;
        if (name != null && name.isNotEmpty) names.add(name);
      } else if (item is String && item.isNotEmpty) {
        names.add(item);
      }
    }
    return names.length > 1 ? names : BrowseData.cuisineFilters;
  }

  /// GET /vendors?category=food&sort=&cuisine=&freeDelivery=&q=&latitude=&longitude=&withinDeliveryRadius=
  Future<List<BrowseRestaurant>> fetchVendors({
    String? cuisine,
    bool freeDelivery = false,
    String sort = 'rating',
    String? query,
    double? latitude,
    double? longitude,
    bool withinDeliveryRadius = false,
  }) async {
    final params = <String, String>{
      'category': 'food',
      'sort': sort,
    };
    if (cuisine != null &&
        cuisine.isNotEmpty &&
        cuisine.toLowerCase() != 'all') {
      params['cuisine'] = cuisine;
    }
    if (freeDelivery) params['freeDelivery'] = 'true';
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
    return BrowseData.restaurantById(vendorId);
  }

  /// GET /vendors/:id/menu?q=
  Future<FoodVendorMenu> fetchVendorMenu(
    String vendorId, {
    String? query,
  }) async {
    final qs = (query != null && query.trim().isNotEmpty)
        ? '?q=${Uri.encodeQueryComponent(query.trim())}'
        : '';
    final response = await _apiClient.getJson('/vendors/$vendorId/menu$qs');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return _fallbackMenu(vendorId);
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

    if (sections.isEmpty || items.isEmpty) {
      if (query != null && query.trim().isNotEmpty) {
        return FoodVendorMenu(
          restaurant: restaurant,
          sections: const [],
          items: const [],
        );
      }
      return _fallbackMenu(vendorId);
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
      final fallback = BrowseData.menuItemById(itemId);
      return FoodProductDetail(
        item: fallback,
        description: BrowseData.mezzeLongDescription,
        options: BrowseData.mezzeSizes,
        addons: BrowseData.mezzeAddons,
      );
    }

    final item = browseMenuItemFromProductJson(
          data,
          section: data['menuSectionName'] as String? ?? 'Menu',
        ) ??
        BrowseData.menuItemById(itemId);

    final options = <BrowseSizeOption>[];
    final groups = data['optionGroups'];
    if (groups is List) {
      for (final group in groups) {
        if (group is! Map<String, dynamic>) continue;
        final opts = group['options'];
        if (opts is! List) continue;
        for (final opt in opts) {
          if (opt is! Map<String, dynamic>) continue;
          final id = opt['id']?.toString();
          final name = opt['name'] as String? ?? 'Option';
          final delta = opt['priceDelta'];
          final deltaNum = delta is num ? delta.toDouble() : 0.0;
          options.add(
            BrowseSizeOption(
              id: id,
              label: name,
              subtitle: deltaNum <= 0
                  ? 'Included'
                  : '+ BHD ${deltaNum.toStringAsFixed(1)}',
              extraPrice: deltaNum > 0 ? deltaNum.toStringAsFixed(3) : null,
            ),
          );
        }
      }
    }

    final addons = <BrowseAddonOption>[];
    final addonsRaw = data['addons'];
    if (addonsRaw is List) {
      for (final addon in addonsRaw) {
        if (addon is! Map<String, dynamic>) continue;
        final id = addon['id']?.toString();
        final name = addon['name'] as String? ?? 'Add-on';
        final price = addon['price'];
        final priceNum = price is num ? price.toDouble() : 0.0;
        addons.add(
          BrowseAddonOption(
            id: id,
            label: name,
            price: priceNum.toStringAsFixed(3),
          ),
        );
      }
    }

    return FoodProductDetail(
      item: item,
      description: (data['description'] as String?)?.trim().isNotEmpty == true
          ? data['description'] as String
          : item.description,
      options: options.isNotEmpty ? options : BrowseData.mezzeSizes,
      addons: addons.isNotEmpty ? addons : BrowseData.mezzeAddons,
      imageUrl: (data['imageUrl'] as String?)?.trim(),
    );
  }

  /// GET /cart?type=DELIVERY
  Future<FoodCartSummary> fetchDeliveryCart() async {
    if (!_storage.hasSession) return FoodCartSummary.empty;

    final response = await _apiClient.getJson(
      '/cart?type=DELIVERY',
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

  /// POST /cart/items?type=DELIVERY|PICKUP
  /// Returns null on success, conflict message on vendor conflict, or error text.
  Future<({bool ok, bool vendorConflict, String? message})> addToCart({
    required String productId,
    required int quantity,
    List<String> optionIds = const [],
    List<String> addonIds = const [],
    bool replaceCart = false,
    String cartType = 'DELIVERY',
  }) async {
    final type = cartType.toUpperCase() == 'PICKUP' ? 'PICKUP' : 'DELIVERY';
    final response = await _apiClient.postJson(
      '/cart/items?type=$type',
      {
        'productId': productId,
        'quantity': quantity,
        'replaceCart': replaceCart,
        'options': {
          if (optionIds.isNotEmpty) 'optionIds': optionIds,
          if (addonIds.isNotEmpty) 'addonIds': addonIds,
        },
      },
      bearerToken: _token,
    );

    if (response.ok) return (ok: true, vendorConflict: false, message: null);

    final error = response.json?['error'];
    final details = error is Map ? error['details'] : null;
    final detailCode = details is Map ? details['code']?.toString() : null;
    final code = error is Map ? error['code']?.toString() : null;
    final conflict = response.statusCode == 409 ||
        code == 'VENDOR_CART_CONFLICT' ||
        detailCode == 'VENDOR_CART_CONFLICT' ||
        code == 'CONFLICT';
    return (
      ok: false,
      vendorConflict: conflict,
      message: response.message ?? 'Could not add to cart',
    );
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
    if (list is! List || list.isEmpty) return BrowseData.recentSearches;

    final queries = <String>[];
    for (final raw in list) {
      if (raw is Map<String, dynamic>) {
        final q = raw['query'] as String?;
        if (q != null && q.trim().isNotEmpty) queries.add(q.trim());
      } else if (raw is String && raw.trim().isNotEmpty) {
        queries.add(raw.trim());
      }
    }
    return queries.isNotEmpty ? queries : BrowseData.recentSearches;
  }

  FoodVendorMenu _fallbackMenu(String vendorId) {
    final restaurant = BrowseData.restaurantById(vendorId);
    return FoodVendorMenu(
      restaurant: restaurant,
      sections: BrowseData.menuSections,
      items: BrowseData.greenKitchenMenu,
    );
  }
}

BrowseRestaurant? browseRestaurantFromVendorJson(Map<String, dynamic> json) {
  final id = (json['id'] ?? json['slug'])?.toString();
  final name = json['name'] as String?;
  if (id == null || id.isEmpty || name == null || name.isEmpty) return null;

  final tags = json['cuisineTags'];
  final cuisine = tags is List && tags.isNotEmpty
      ? tags.map((e) => e.toString()).where((e) => e.isNotEmpty).join(' · ')
      : (json['area'] as String? ?? 'Food');

  final ratingRaw = json['rating'];
  final rating = ratingRaw is num
      ? ratingRaw.toDouble()
      : double.tryParse(ratingRaw?.toString() ?? '') ?? 0;

  final deliveryMin = (json['deliveryTimeMin'] as num?)?.toInt() ?? 25;
  final freeDelivery = json['freeDelivery'] == true;
  final deliveryFeeRaw = json['deliveryFee'];
  final deliveryFee = deliveryFeeRaw is num
      ? deliveryFeeRaw.toStringAsFixed(1)
      : (deliveryFeeRaw?.toString() ?? '0.8');
  final minOrderRaw = json['minOrderAmount'];
  final minOrder = minOrderRaw is num
      ? minOrderRaw.toStringAsFixed(0)
      : (minOrderRaw?.toString() ?? '5');
  final distanceKm = json['distanceKm'];
  final distance = distanceKm is num
      ? '${distanceKm.toStringAsFixed(1)} km away'
      : 'Nearby';

  final reviewCountRaw = json['reviewCount'];
  final reviewCount = reviewCountRaw is num
      ? _formatReviewCount(reviewCountRaw.toInt())
      : '___';

  final badge = json['offerBadge'] as String?;
  final imageUrl = (json['coverUrl'] as String?)?.trim();
  final colors = _gradientForName(name);

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
    imageUrl: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : null,
    reviewCount: reviewCount,
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
  final imageUrl = (json['imageUrl'] as String?)?.trim();

  return BrowseMenuItem(
    id: id,
    name: name,
    description: description.isNotEmpty ? description : '___',
    price: priceStr,
    section: section,
    imageUrl: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : null,
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
