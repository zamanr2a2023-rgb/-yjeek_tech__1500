import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/browse/model/pickup_data.dart';
import 'package:yjeek_app/features/home/model/home_feed.dart';

/// Default Manama center used when device location is unavailable.
const double kPickupDefaultLat = 26.2285;
const double kPickupDefaultLng = 50.586;

/// Phase-1 pickup: hot food only (grocery/pharmacy/etc disabled).
const _featuredSlugOrder = [
  'food',
];

/// Phase-1 pickup category grid — food only.
const _allPickupSlugOrder = [
  'food',
];

/// "Ready near you" — food only in phase 1.
const _nearYouCategorySlugs = {'food'};

class PickupSpotlight {
  const PickupSpotlight({
    required this.title,
    this.vendorId,
    this.ctaLabel,
  });

  final String title;
  final String? vendorId;
  final String? ctaLabel;
}

class PickupVendorsRepository {
  const PickupVendorsRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  /// GET /categories → map to PK1 featured chips.
  Future<List<PickupCategory>> fetchFeaturedCategories() async {
    final all = await _fetchCategoryMaps();
    final bySlug = {for (final c in all) c.slug: c};
    final items = <PickupCategory>[];
    for (final slug in _featuredSlugOrder) {
      final raw = bySlug[slug];
      if (raw == null) continue;
      items.add(_mapCategory(raw, featured: true));
    }
    return items;
  }

  /// GET /categories → map to PK6 grid (excludes hub tiles like pickup/dine_in/services).
  Future<List<PickupCategory>> fetchAllPickupCategories() async {
    final all = await _fetchCategoryMaps();
    final bySlug = {for (final c in all) c.slug: c};
    final items = <PickupCategory>[];
    for (final slug in _allPickupSlugOrder) {
      final raw = bySlug[slug];
      if (raw == null) continue;
      items.add(_mapCategory(raw, featured: false));
    }
    return items;
  }

  /// GET /vendors?supportsPickup=true&sort=distance&latitude&longitude&q=&category=
  Future<List<PickupSpot>> fetchNearbySpots({
    String? query,
    String? categorySlug,
    double latitude = kPickupDefaultLat,
    double longitude = kPickupDefaultLng,
    int limit = 12,
  }) async {
    final params = <String, String>{
      'supportsPickup': 'true',
      'sort': 'distance',
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    if (categorySlug != null && categorySlug.trim().isNotEmpty) {
      params['category'] = categorySlug.trim();
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

    final spots = <PickupSpot>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = pickupSpotFromVendorJson(raw);
      if (mapped == null) continue;

      if (categorySlug == null || categorySlug.isEmpty) {
        final slugs = _categorySlugs(raw);
        if (slugs.isNotEmpty &&
            slugs.intersection(_nearYouCategorySlugs).isEmpty) {
          continue;
        }
      }
      spots.add(mapped);
      if (spots.length >= limit) break;
    }
    return spots;
  }

  /// GET /home → spotlight (Weekly Spotlight banner).
  Future<PickupSpotlight?> fetchSpotlight() async {
    final response = await _apiClient.getJson(
      '/home',
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;
    final spotlightRaw = data['spotlight'];
    if (spotlightRaw is! Map<String, dynamic>) return null;
    final spotlight = HomeSpotlight.fromJson(spotlightRaw);
    if (spotlight.title.trim().isEmpty) return null;
    return PickupSpotlight(
      title: spotlight.title,
      vendorId: spotlight.vendorId,
      ctaLabel: spotlight.ctaLabel,
    );
  }

  Future<List<({String id, String name, String slug})>> _fetchCategoryMaps() async {
    final response = await _apiClient.getJson('/categories');
    final data = response?['data'];
    if (data is! List) return const [];

    final items = <({String id, String name, String slug})>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final slug = (raw['slug'] as String?)?.trim() ?? '';
      final name = (raw['name'] as String?)?.trim() ?? '';
      final id = raw['id']?.toString() ?? slug;
      if (slug.isEmpty || name.isEmpty) continue;
      items.add((id: id, name: name, slug: slug));
    }
    return items;
  }
}

PickupCategory _mapCategory(
  ({String id, String name, String slug}) raw, {
  required bool featured,
}) {
  final style = _styleForSlug(raw.slug);
  // PK1 Figma labels: Grocery / Beauty (API: Groceries / Cosmetics).
  final name = featured
      ? switch (raw.slug) {
          'grocery' => 'Grocery',
          'cosmetics' => 'Beauty',
          _ => raw.name,
        }
      : raw.name;

  return PickupCategory(
    id: raw.slug,
    name: name,
    icon: style.icon,
    backgroundColor: style.color,
  );
}

({IconData icon, Color color}) _styleForSlug(String slug) {
  for (final c in PickupData.allCategories) {
    if (c.id == slug) {
      return (icon: c.icon, color: c.backgroundColor);
    }
  }
  // PK1 beauty id vs cosmetics slug.
  if (slug == 'cosmetics') {
    return (
      icon: Icons.brush_outlined,
      color: const Color(0xFFFBE2EF),
    );
  }
  if (slug == 'grocery') {
    return (
      icon: Icons.shopping_bag_outlined,
      color: const Color(0xFFD6F0EA),
    );
  }
  return (
    icon: Icons.storefront_outlined,
    color: const Color(0xFFE8F4FC),
  );
}

Set<String> _categorySlugs(Map<String, dynamic> json) {
  final slugs = <String>{};
  final categories = json['categories'];
  if (categories is List) {
    for (final c in categories) {
      if (c is Map<String, dynamic>) {
        final slug = c['slug']?.toString();
        if (slug != null && slug.isNotEmpty) slugs.add(slug);
      }
    }
  }
  return slugs;
}

PickupSpot? pickupSpotFromVendorJson(Map<String, dynamic> json) {
  final id = (json['id'] ?? json['slug'])?.toString();
  final name = json['name'] as String?;
  if (id == null || id.isEmpty || name == null || name.isEmpty) return null;

  final ratingRaw = json['rating'];
  final rating = ratingRaw is num
      ? ratingRaw.toDouble()
      : double.tryParse(ratingRaw?.toString() ?? '') ?? 0;

  final distanceKm = json['distanceKm'];
  final distance = distanceKm is num
      ? '${distanceKm.toStringAsFixed(1)} km'
      : (json['area'] as String? ?? 'Nearby');

  final eta = (json['pickupEtaLabel'] as String?) ??
      (json['pickupEtaMin'] is num
          ? '~${(json['pickupEtaMin'] as num).toInt()} min'
          : '~15 min');

  final promo = json['pickupOfferBadge'] as String?;

  String categoryLabel = 'Pickup';
  final tags = json['cuisineTags'];
  if (tags is List && tags.isNotEmpty) {
    categoryLabel = tags.first.toString();
  } else {
    final categories = json['categories'];
    if (categories is List && categories.isNotEmpty) {
      final first = categories.first;
      if (first is Map<String, dynamic>) {
        categoryLabel = first['name']?.toString() ?? categoryLabel;
      }
    } else if (json['categoryLabel'] is String &&
        (json['categoryLabel'] as String).isNotEmpty) {
      categoryLabel = json['categoryLabel'] as String;
    }
  }

  return PickupSpot(
    id: id,
    name: name,
    rating: double.parse(rating.toStringAsFixed(1)),
    categoryLabel: categoryLabel,
    distance: distance,
    pickupEta: eta,
    promoLabel: (promo != null && promo.trim().isNotEmpty) ? promo : null,
    imageColor: const Color(0xFFEAF3DE),
  );
}
