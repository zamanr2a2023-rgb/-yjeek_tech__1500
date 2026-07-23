import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';

class FoodVendorsRepository {
  const FoodVendorsRepository(this._apiClient);

  final ApiClient _apiClient;

  /// GET /vendors/cuisines?category=food — chip labels (plus "All").
  Future<List<String>> fetchCuisineFilters() async {
    final response = await _apiClient.getJson(
      '/vendors/cuisines?category=food',
    );
    final data = response?['data'];
    final list = data is Map<String, dynamic> ? data['cuisines'] : null;
    if (list is! List || list.isEmpty) {
      return BrowseData.cuisineFilters;
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
    return names.length > 1 ? names : BrowseData.cuisineFilters;
  }

  /// GET /vendors?category=food&sort=&cuisine=&freeDelivery=&q=
  Future<List<BrowseRestaurant>> fetchVendors({
    String? cuisine,
    bool freeDelivery = false,
    String sort = 'rating',
    String? query,
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

    final qs = params.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}='
            '${Uri.encodeQueryComponent(e.value)}')
        .join('&');

    final response = await _apiClient.getJson('/vendors?$qs');
    final data = response?['data'];
    if (data is! List) return BrowseData.restaurants;

    final items = <BrowseRestaurant>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = browseRestaurantFromVendorJson(raw);
      if (mapped != null) items.add(mapped);
    }
    return items.isNotEmpty ? items : BrowseData.restaurants;
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
  );
}

(Color, Color) _gradientForName(String name) {
  final base = HomeBrandStyle.forName(name);
  return (base, const Color(0xFF15302B));
}
