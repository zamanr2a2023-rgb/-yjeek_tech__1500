import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/dine_in_data.dart';
import 'package:yjeek_app/features/browse/model/food_vendors_repository.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';

class DineInVendorMenu {
  const DineInVendorMenu({
    required this.restaurant,
    required this.sections,
    required this.items,
  });

  final DineInRestaurant restaurant;
  final List<String> sections;
  final List<BrowseMenuItem> items;
}

class DineInProductDetail {
  const DineInProductDetail({
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

class DineInCartSummary {
  const DineInCartSummary({
    required this.itemCount,
    required this.totalLabel,
    this.vendorId,
  });

  final int itemCount;
  final String totalLabel;
  final String? vendorId;

  static const empty = DineInCartSummary(itemCount: 0, totalLabel: '0.000');
}

class DineInVendorsRepository {
  const DineInVendorsRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /vendors/cuisines?category=dine_in
  Future<List<String>> fetchCuisineFilters() async {
    final response = await _apiClient.getJson(
      '/vendors/cuisines?category=dine_in',
    );
    final data = response?['data'];
    final list = data is Map<String, dynamic> ? data['cuisines'] : null;
    if (list is! List || list.isEmpty) {
      return DineInData.cuisineFilters;
    }

    final names = <String>['All'];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final name = item['name'] as String?;
        if (name != null && name.isNotEmpty) names.add(name);
      } else if (item is String && item.isNotEmpty) {
        names.add(item);
      }
    }
    return names.length > 1 ? names : DineInData.cuisineFilters;
  }

  /// GET /vendors?supportsDineIn=true&category=dine_in&sort=&cuisine=&isBookable=&hasOffers=&q=
  Future<List<DineInRestaurant>> fetchVendors({
    String? cuisine,
    bool bookableOnly = false,
    bool offersOnly = false,
    String sort = 'rating',
    String? query,
  }) async {
    final params = <String, String>{
      'supportsDineIn': 'true',
      'category': 'dine_in',
      'sort': sort,
    };
    if (cuisine != null &&
        cuisine.isNotEmpty &&
        cuisine.toLowerCase() != 'all') {
      params['cuisine'] = cuisine;
    }
    if (bookableOnly) params['isBookable'] = 'true';
    if (offersOnly) params['hasOffers'] = 'true';
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
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

    final items = <DineInRestaurant>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = dineInRestaurantFromVendorJson(raw);
      if (mapped != null) items.add(mapped);
    }
    return items;
  }

  /// GET /vendors/:id
  Future<DineInRestaurant> fetchVendor(String vendorId) async {
    final response = await _apiClient.getJson('/vendors/$vendorId');
    final data = response?['data'];
    if (data is Map<String, dynamic>) {
      final mapped = dineInRestaurantFromVendorJson(data);
      if (mapped != null) return mapped;
    }
    return DineInData.restaurantById(vendorId);
  }

  /// GET /vendors/:id/menu?q=
  Future<DineInVendorMenu> fetchVendorMenu(
    String vendorId, {
    String? query,
  }) async {
    final qs = (query != null && query.trim().isNotEmpty)
        ? '?q=${Uri.encodeQueryComponent(query.trim())}'
        : '';
    final response = await _apiClient.getJson('/vendors/$vendorId/menu$qs');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return DineInVendorMenu(
        restaurant: await fetchVendor(vendorId),
        sections: const [],
        items: const [],
      );
    }

    final vendorRaw = data['vendor'];
    final restaurant = vendorRaw is Map<String, dynamic>
        ? (dineInRestaurantFromVendorJson({
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

    return DineInVendorMenu(
      restaurant: restaurant,
      sections: sections,
      items: items,
    );
  }

  /// GET /vendors/:id/products/:productId
  Future<DineInProductDetail> fetchProductDetail({
    required String vendorId,
    required String itemId,
  }) async {
    final response = await _apiClient.getJson(
      '/vendors/$vendorId/products/$itemId',
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      final fallback = DineInData.menuItemById(itemId);
      return DineInProductDetail(
        item: fallback,
        description: DineInData.mezzeLongDescription,
        options: DineInData.mezzeSizes,
        addons: DineInData.mezzeAddons,
      );
    }

    final item = browseMenuItemFromProductJson(
          data,
          section: data['menuSectionName'] as String? ?? 'Menu',
        ) ??
        DineInData.menuItemById(itemId);

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

    return DineInProductDetail(
      item: item,
      description: (data['description'] as String?)?.trim().isNotEmpty == true
          ? data['description'] as String
          : item.description,
      options: options.isNotEmpty ? options : DineInData.mezzeSizes,
      addons: addons.isNotEmpty ? addons : DineInData.mezzeAddons,
      imageUrl: (data['imageUrl'] as String?)?.trim(),
    );
  }

  /// GET /cart?type=DINE_IN
  Future<DineInCartSummary> fetchDineInCart() async {
    final response = await _apiClient.getJson(
      '/cart?type=DINE_IN',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return DineInCartSummary.empty;

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

    return DineInCartSummary(
      itemCount: count ?? 0,
      totalLabel: totalNum.toStringAsFixed(3),
      vendorId: vendorId,
    );
  }

  /// POST /cart/items?type=DINE_IN
  Future<({bool ok, bool vendorConflict, String? message})> addToCart({
    required String productId,
    required int quantity,
    List<String> optionIds = const [],
    List<String> addonIds = const [],
    bool replaceCart = false,
  }) async {
    final response = await _apiClient.postJson(
      '/cart/items?type=DINE_IN',
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
        : (data is Map<String, dynamic>
            ? data['items'] ?? data['history']
            : null);
    if (list is! List || list.isEmpty) {
      return const ['VEERA', 'Lebanese', 'Sushi', 'Grill'];
    }

    final queries = <String>[];
    for (final raw in list) {
      if (raw is Map<String, dynamic>) {
        final q = raw['query'] as String?;
        if (q != null && q.trim().isNotEmpty) queries.add(q.trim());
      } else if (raw is String && raw.trim().isNotEmpty) {
        queries.add(raw.trim());
      }
    }
    return queries.isNotEmpty
        ? queries
        : const ['VEERA', 'Lebanese', 'Sushi', 'Grill'];
  }
}

DineInRestaurant? dineInRestaurantFromVendorJson(Map<String, dynamic> json) {
  final id = (json['id'] ?? json['slug'])?.toString();
  final name = json['name'] as String?;
  if (id == null || id.isEmpty || name == null || name.isEmpty) return null;

  final tags = json['cuisineTags'];
  final cuisine = tags is List && tags.isNotEmpty
      ? tags.first.toString()
      : (json['area'] as String? ?? 'Dine-in');

  final subtitle = tags is List && tags.isNotEmpty
      ? tags.map((e) => e.toString()).where((e) => e.isNotEmpty).join(' · ')
      : null;

  final ratingRaw = json['rating'];
  final rating = ratingRaw is num
      ? ratingRaw.toDouble()
      : double.tryParse(ratingRaw?.toString() ?? '') ?? 0;

  final reviewCountRaw = json['reviewCount'];
  final reviewCount = reviewCountRaw is num
      ? _formatReviewCount(reviewCountRaw.toInt())
      : '0';

  final distanceKm = json['distanceKm'];
  final distance = distanceKm is num
      ? '${distanceKm.toStringAsFixed(1)} km'
      : (json['area'] as String? ?? 'Nearby');

  final offerBadge = json['offerBadge'] as String?;
  final isBookable = json['isBookable'] == true;
  final openStatus = (json['openStatus'] as String?)?.toUpperCase();

  final badge = (offerBadge != null && offerBadge.trim().isNotEmpty)
      ? offerBadge.trim()
      : (isBookable ? 'Bookable' : null);

  // Open/closed from API; bookable is a badge/entry mode, not status override.
  final status = openStatus == 'CLOSED'
      ? DineInVenueStatus.closed
      : DineInVenueStatus.open;

  final statusLabel = (json['dineInStatusLabel'] as String?)?.trim().isNotEmpty ==
          true
      ? (json['dineInStatusLabel'] as String).trim()
      : (status == DineInVenueStatus.closed ? 'Closed' : 'Open now');

  final modeLabel =
      (json['dineInModeLabel'] as String?)?.trim().isNotEmpty == true
          ? (json['dineInModeLabel'] as String).trim()
          : 'Dine-in';

  final entryLabel =
      (json['dineInEntryLabel'] as String?)?.trim().isNotEmpty == true
          ? (json['dineInEntryLabel'] as String).trim()
          : (isBookable ? 'Bookable' : 'Walk-in');

  final tableMinRaw = json['dineInTableMin'] ?? json['tableMin'];
  final tableMin = tableMinRaw is num
      ? tableMinRaw.toInt()
      : int.tryParse(tableMinRaw?.toString() ?? '') ?? 2;

  final imageUrl = (json['coverUrl'] as String?)?.trim();
  final colors = _gradientForName(name);

  return DineInRestaurant(
    id: id,
    name: name,
    cuisine: cuisine,
    rating: double.parse(rating.toStringAsFixed(1)),
    gradientStart: colors.$1,
    gradientEnd: colors.$2,
    badge: badge,
    distance: distance,
    status: status,
    subtitle: subtitle,
    reviewCount: reviewCount,
    tableMin: tableMin > 0 ? tableMin : 2,
    statusLabel: statusLabel,
    modeLabel: modeLabel,
    entryLabel: entryLabel,
    imageUrl: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : null,
  );
}

String _formatReviewCount(int count) {
  if (count >= 1000) {
    final k = count / 1000;
    return k == k.roundToDouble()
        ? '${k.toInt()}k'
        : '${k.toStringAsFixed(1)}k';
  }
  return count.toString();
}

(Color, Color) _gradientForName(String name) {
  for (final r in DineInData.restaurants) {
    if (r.name.toLowerCase() == name.toLowerCase() ||
        r.id.toLowerCase() == name.toLowerCase()) {
      return (r.gradientStart, r.gradientEnd);
    }
  }
  final base = HomeBrandStyle.forName(name);
  return (base, const Color(0xFF15302B));
}
