import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/core/utils/api_media_url.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';

class ElectronicsProductDetail {
  const ElectronicsProductDetail({
    required this.product,
    required this.reviewCountLabel,
  });

  final ElectronicsProduct product;
  final String reviewCountLabel;
}

class ElectronicsCartSummary {
  const ElectronicsCartSummary({
    required this.itemCount,
    required this.totalLabel,
    this.vendorId,
  });

  final int itemCount;
  final String totalLabel;
  final String? vendorId;

  static const empty = ElectronicsCartSummary(itemCount: 0, totalLabel: '0');
}

class ElectronicsVendorsRepository {
  const ElectronicsVendorsRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /vendors?category=&sort=&freeDelivery=&hasOffers=&q=&subcategory=
  Future<List<ElectronicsStore>> fetchStores({
    String category = 'electronics',
    String sort = 'rating',
    bool freeDelivery = false,
    bool hasOffers = false,
    String? query,
    String? subcategory,
  }) async {
    final params = <String, String>{
      'category': category,
      'sort': sort,
    };
    if (freeDelivery) params['freeDelivery'] = 'true';
    if (hasOffers) params['hasOffers'] = 'true';
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    if (subcategory != null && subcategory.trim().isNotEmpty) {
      params['subcategory'] = subcategory.trim();
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
    final list = data is List
        ? data
        : (data is Map<String, dynamic> ? data['items'] : null);
    if (list is! List) return const [];

    final items = <ElectronicsStore>[];
    for (final raw in list) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = electronicsStoreFromVendorJson(
        raw,
        categoryFallback: ElectronicsData.categoryFallbackLabel(category),
      );
      if (mapped != null) items.add(mapped);
    }
    return items;
  }

  /// GET /vendors/:id
  Future<ElectronicsStore> fetchStore(String storeId) async {
    final response = await _apiClient.getJson('/vendors/$storeId');
    final data = response?['data'];
    if (data is Map<String, dynamic>) {
      final mapped = electronicsStoreFromVendorJson(data);
      if (mapped != null) return mapped;
    }
    throw StateError('Electronics store not found: $storeId');
  }

  /// GET /vendors/:id/products?q=&maxPrice=&has5G=&inStock=
  Future<List<ElectronicsProduct>> fetchProducts(
    String storeId, {
    String? query,
    String? filter,
  }) async {
    final params = <String, String>{};
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    final f = (filter ?? 'All').toLowerCase();
    if (f == 'under bhd 100') {
      params['maxPrice'] = '100';
    } else if (f == '5g') {
      params['has5G'] = 'true';
    } else if (f == 'in stock') {
      params['inStock'] = 'true';
    }

    final qs = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

    final response =
        await _apiClient.getJson('/vendors/$storeId/products$qs');
    final data = response?['data'];
    if (data is! List) return const [];

    final items = <ElectronicsProduct>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = electronicsProductFromJson(raw, storeId: storeId);
      if (mapped != null) items.add(mapped);
    }
    return items;
  }

  /// GET /vendors/:id/products/:productId
  Future<ElectronicsProductDetail> fetchProductDetail({
    required String storeId,
    required String productId,
  }) async {
    final response = await _apiClient.getJson(
      '/vendors/$storeId/products/$productId',
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Electronics product not found: $productId');
    }

    final product = electronicsProductFromJson(
      data,
      storeId: storeId,
      detailed: true,
    );
    if (product == null) {
      throw StateError('Electronics product not found: $productId');
    }

    final reviewRaw = data['reviewCount'] ??
        data['reviewsCount'] ??
        data['review_count'];
    final reviewCountLabel = reviewRaw is num
        ? _formatReviewCount(reviewRaw.toInt())
        : (reviewRaw?.toString().trim().isNotEmpty == true
            ? reviewRaw.toString().trim()
            : '0');

    return ElectronicsProductDetail(
      product: product,
      reviewCountLabel: reviewCountLabel,
    );
  }

  /// GET /cart/scheduled (electronics scheduled basket)
  Future<ElectronicsCartSummary> fetchCart() async {
    if (!_storage.hasSession) return ElectronicsCartSummary.empty;

    final response = await _apiClient.getJson(
      '/cart/scheduled',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return ElectronicsCartSummary.empty;

    final itemCount = (data['itemCount'] as num?)?.toInt() ?? 0;
    final summary = data['summary'];
    final total = summary is Map<String, dynamic>
        ? (summary['grandTotal'] ?? summary['totalAmount'])
        : null;
    final totalNum = total is num ? total.toDouble() : 0.0;
    final groups = data['groups'];
    String? vendorId;
    if (groups is List && groups.isNotEmpty) {
      final first = groups.first;
      if (first is Map<String, dynamic>) {
        vendorId = first['vendorId']?.toString();
        final vendor = first['vendor'];
        if (vendor is Map<String, dynamic>) {
          vendorId = vendor['id']?.toString() ?? vendorId;
        }
      }
    }

    return ElectronicsCartSummary(
      itemCount: itemCount,
      totalLabel: totalNum == totalNum.roundToDouble()
          ? totalNum.toStringAsFixed(0)
          : totalNum.toStringAsFixed(3),
      vendorId: vendorId,
    );
  }

  /// POST /cart/scheduled/items
  Future<({bool ok, bool vendorConflict, String? message})> addToCart({
    required String productId,
    required int quantity,
    List<String> optionIds = const [],
    List<String> addonIds = const [],
    bool replaceCart = false,
  }) async {
    final response = await _apiClient.postJson(
      '/cart/scheduled/items',
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
    final message = response.message ?? 'Could not add to cart';
    final conflict = response.statusCode == 409 ||
        code == 'VENDOR_CART_CONFLICT' ||
        detailCode == 'VENDOR_CART_CONFLICT' ||
        detailCode == 'SCHEDULED_VENDOR_LIMIT' ||
        code == 'SCHEDULED_VENDOR_LIMIT' ||
        code == 'CONFLICT' ||
        message.toLowerCase().contains('up to 3 vendors');
    return (
      ok: false,
      vendorConflict: conflict,
      message: message,
    );
  }
}

ElectronicsStore? electronicsStoreFromVendorJson(
  Map<String, dynamic> json, {
  String categoryFallback = 'Electronics',
}) {
  final id = (json['id'] ?? json['slug'])?.toString();
  final name = json['name'] as String?;
  if (id == null || id.isEmpty || name == null || name.isEmpty) return null;

  final ratingRaw = json['rating'];
  final ratingParsed = ratingRaw is num
      ? ratingRaw.toDouble()
      : double.tryParse(ratingRaw?.toString() ?? '') ?? 0;

  final reviewCountRaw = json['reviewCount'];
  final reviewCountValue = reviewCountRaw is num ? reviewCountRaw.toInt() : 0;
  final hasRating = json['hasRating'] == true ||
      (reviewCountValue > 0 && ratingParsed > 0);
  final rating = hasRating ? ratingParsed : 0.0;
  final reviewCount =
      reviewCountValue > 0 ? _formatReviewCount(reviewCountValue) : '0';

  final distanceKm = json['distanceKm'];
  final distance = distanceKm is num
      ? '${distanceKm.toStringAsFixed(1)} km'
      : (json['area'] as String? ?? 'Nearby');

  final storeType = json['storeType'];
  final storeTypeName = storeType is Map
      ? storeType['name']?.toString()
      : null;
  final storeTypeSlug = storeType is Map
      ? storeType['slug']?.toString().toLowerCase()
      : null;
  final linked = json['categories'];
  String? linkedLabel;
  if (linked is List) {
    for (final raw in linked) {
      if (raw is! Map) continue;
      final slug = raw['slug']?.toString().toLowerCase();
      final name = raw['name']?.toString();
      if (name == null || name.isEmpty) continue;
      if (slug == categoryFallback.toLowerCase() ||
          name.toLowerCase() == categoryFallback.toLowerCase()) {
        linkedLabel = name;
        break;
      }
      linkedLabel ??= name;
    }
  }
  final tags = json['cuisineTags'];
  final fromTags = tags is List && tags.isNotEmpty
      ? tags.map((e) => e.toString()).where((e) => e.isNotEmpty).join(' · ')
      : null;
  final fallbackSlug = categoryFallback.toLowerCase();
  final storeTypeMatches = storeTypeSlug != null &&
      (storeTypeSlug == fallbackSlug ||
          storeTypeName?.toLowerCase() == fallbackSlug);
  final categories = linkedLabel ??
      (storeTypeMatches ? storeTypeName : null) ??
      (fromTags != null && fromTags.isNotEmpty ? fromTags : null) ??
      categoryFallback;

  final productCount = (json['productCount'] as num?)?.toInt() ?? 0;
  final colors = _gradientForName(name);
  final area = (json['area'] as String?)?.trim();
  final offer = json['offerBadge'] ?? json['badgeLabel'] ?? json['promoBadge'];
  final offerBadge = offer?.toString().trim();
  final logoUrl = resolveApiMediaUrl(json['logoUrl'] as String?);
  final imageUrl = resolveApiMediaUrl(json['coverUrl'] as String?) ??
      logoUrl ??
      resolveApiMediaUrlFromList(json['imageUrls']);
  final categoryLabelRaw = (json['categoryLabel'] as String?)?.trim();
  final minOrderRaw = json['minOrderAmount'];
  final minOrderAmount = minOrderRaw is num
      ? minOrderRaw.toDouble()
      : double.tryParse(minOrderRaw?.toString() ?? '');

  final deliveryFeeRaw = json['deliveryFee'];
  final deliveryFee = deliveryFeeRaw is num
      ? deliveryFeeRaw.toDouble()
      : double.tryParse(deliveryFeeRaw?.toString() ?? '');
  final deliveryTimeMin = (json['deliveryTimeMin'] as num?)?.toInt() ??
      (json['arrivesInMin'] as num?)?.toInt();
  final deliveryRadiusKm = (json['deliveryRadiusKm'] as num?)?.toDouble();
  final distKm = distanceKm is num ? distanceKm.toDouble() : null;
  final lat = (json['latitude'] as num?)?.toDouble();
  final lng = (json['longitude'] as num?)?.toDouble();
  final isPharmacyLabel = [
    categoryLabelRaw,
    categories,
    storeTypeSlug,
    storeTypeName,
  ].whereType<String>().any((s) => s.toLowerCase().contains('pharm'));

  return ElectronicsStore(
    id: id,
    name: name,
    rating: hasRating ? double.parse(rating.toStringAsFixed(1)) : 0,
    reviewCount: reviewCount,
    distance: distance,
    categories: categories,
    productCount: productCount,
    gradientStart: colors.$1,
    gradientEnd: colors.$2,
    freeDelivery: json['freeDelivery'] == true ||
        ((json['deliveryFee'] as num?)?.toDouble() ?? 1) == 0,
    hasRating: hasRating,
    area: (area != null && area.isNotEmpty) ? area : null,
    imageUrl: imageUrl,
    logoUrl: logoUrl,
    offerBadge: (offerBadge != null && offerBadge.isNotEmpty) ? offerBadge : null,
    categoryLabel: (categoryLabelRaw != null && categoryLabelRaw.isNotEmpty)
        ? categoryLabelRaw
        : (isPharmacyLabel ? 'Pharmacy' : null),
    minOrderAmount: minOrderAmount,
    supportsDelivery: json['supportsDelivery'] == true,
    supportsScheduled: json['supportsScheduled'] == true,
    deliveryFee: deliveryFee,
    deliveryTimeMin: deliveryTimeMin,
    deliveryRadiusKm: deliveryRadiusKm,
    distanceKm: distKm,
    latitude: lat,
    longitude: lng,
    scheduledDeliveryFee: isPharmacyLabel ? (deliveryFee != null ? 1.0 : 1.0) : null,
    scheduledMinOrderAmount: isPharmacyLabel ? 5.0 : null,
  );
}

ElectronicsProduct? electronicsProductFromJson(
  Map<String, dynamic> json, {
  required String storeId,
  bool detailed = false,
}) {
  final id = json['id']?.toString();
  final name = json['name'] as String?;
  if (id == null || id.isEmpty || name == null || name.isEmpty) return null;

  final priceRaw = json['price'];
  final priceNum = priceRaw is num
      ? priceRaw.toDouble()
      : double.tryParse(priceRaw?.toString() ?? '') ?? 0;
  final price = priceNum == priceNum.roundToDouble()
      ? priceNum.toStringAsFixed(0)
      : priceNum.toStringAsFixed(3);

  final compareRaw = json['compareAtPrice'];
  String? originalPrice;
  if (compareRaw is num) {
    originalPrice = compareRaw == compareRaw.roundToDouble()
        ? compareRaw.toStringAsFixed(0)
        : compareRaw.toStringAsFixed(3);
  }

  final specs = (json['specs'] as String?)?.trim().isNotEmpty == true
      ? (json['specs'] as String).trim()
      : ((json['description'] as String?)?.trim().isNotEmpty == true
          ? (json['description'] as String).trim()
          : '___');

  final tags = json['tags'];
  final has5G = json['has5G'] == true ||
      (tags is List &&
          tags.any((t) => t.toString().toLowerCase() == '5g'));

  final inStock = json['inStock'] == true || json['isAvailable'] == true;

  final highlights = <String>[];
  final highlightsRaw = json['highlights'];
  if (highlightsRaw is List) {
    for (final h in highlightsRaw) {
      final s = h.toString().trim();
      if (s.isNotEmpty) highlights.add(s);
    }
  }

  final storageOptions = <ElectronicsStorageOption>[];
  final colorOptions = <ElectronicsColorOption>[];
  if (detailed) {
    final groups = json['optionGroups'];
    if (groups is List) {
      for (final group in groups) {
        if (group is! Map<String, dynamic>) continue;
        final groupName = (group['name'] as String?)?.toLowerCase() ?? '';
        final opts = group['options'];
        if (opts is! List) continue;
        for (final opt in opts) {
          if (opt is! Map<String, dynamic>) continue;
          final optId = opt['id']?.toString();
          final optName = opt['name'] as String? ?? '';
          final delta = (opt['priceDelta'] as num?)?.toDouble() ?? 0;
          if (groupName.contains('color')) {
            final color = _parseColor(optName) ??
                _parseColor(opt['imageUrl']?.toString()) ??
                const Color(0xFF1F2129);
            colorOptions.add(
              ElectronicsColorOption(
                id: optId,
                color: color,
                selectedBorder: opt['isDefault'] == true,
              ),
            );
          } else {
            storageOptions.add(
              ElectronicsStorageOption(
                id: optId,
                label: optName,
                extraPrice: delta.round(),
              ),
            );
          }
        }
      }
    }
  }

  final detailTitle =
      (json['description'] as String?)?.trim().isNotEmpty == true &&
              detailed
          ? (json['description'] as String).trim()
          : null;

  return ElectronicsProduct(
    id: id,
    storeId: storeId,
    name: name,
    specs: specs,
    rating: 4.5,
    price: price,
    originalPrice: originalPrice,
    inStock: inStock,
    has5G: has5G,
    detailTitle: detailTitle,
    detailSubtitle: detailed ? '★ 4.5 · $specs' : null,
    highlights: highlights,
    storageOptions: storageOptions,
    colorOptions: colorOptions,
  );
}

Color? _parseColor(String? raw) {
  if (raw == null) return null;
  var s = raw.trim();
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) {
    final value = int.tryParse(s, radix: 16);
    if (value != null) return Color(0xFF000000 | value);
  }
  return null;
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
  final base = HomeBrandStyle.forName(name);
  return (Color.lerp(base, Colors.white, 0.85) ?? const Color(0xFFE3F2EB),
      Color.lerp(base, Colors.white, 0.7) ?? const Color(0xFFC8E6D4));
}
