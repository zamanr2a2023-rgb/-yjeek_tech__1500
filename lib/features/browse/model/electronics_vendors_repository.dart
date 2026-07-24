import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
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

  /// GET /vendors?category=electronics&sort=&freeDelivery=&q=
  Future<List<ElectronicsStore>> fetchStores({
    String sort = 'rating',
    bool freeDelivery = false,
    String? query,
  }) async {
    final params = <String, String>{
      'category': 'electronics',
      'sort': sort,
    };
    if (freeDelivery) params['freeDelivery'] = 'true';
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

    final items = <ElectronicsStore>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = electronicsStoreFromVendorJson(raw);
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
    return ElectronicsData.storeById(storeId);
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
      final fallback = ElectronicsData.productById(productId);
      return ElectronicsProductDetail(
        product: fallback,
        reviewCountLabel: '812',
      );
    }

    final product = electronicsProductFromJson(
          data,
          storeId: storeId,
          detailed: true,
        ) ??
        ElectronicsData.productById(productId);

    return ElectronicsProductDetail(
      product: product,
      reviewCountLabel: '___',
    );
  }

  /// GET /cart?type=DELIVERY (electronics uses delivery/scheduled basket)
  Future<ElectronicsCartSummary> fetchCart() async {
    final response = await _apiClient.getJson(
      '/cart?type=DELIVERY',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return ElectronicsCartSummary.empty;

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

    return ElectronicsCartSummary(
      itemCount: count ?? 0,
      totalLabel: totalNum == totalNum.roundToDouble()
          ? totalNum.toStringAsFixed(0)
          : totalNum.toStringAsFixed(3),
      vendorId: vendorId,
    );
  }

  /// POST /cart/items?type=DELIVERY
  Future<({bool ok, bool vendorConflict, String? message})> addToCart({
    required String productId,
    required int quantity,
    List<String> optionIds = const [],
    bool replaceCart = false,
  }) async {
    final response = await _apiClient.postJson(
      '/cart/items?type=DELIVERY',
      {
        'productId': productId,
        'quantity': quantity,
        'replaceCart': replaceCart,
        'options': {
          if (optionIds.isNotEmpty) 'optionIds': optionIds,
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
}

ElectronicsStore? electronicsStoreFromVendorJson(Map<String, dynamic> json) {
  final id = (json['id'] ?? json['slug'])?.toString();
  final name = json['name'] as String?;
  if (id == null || id.isEmpty || name == null || name.isEmpty) return null;

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

  final tags = json['cuisineTags'];
  final categories = tags is List && tags.isNotEmpty
      ? tags.map((e) => e.toString()).where((e) => e.isNotEmpty).join(' · ')
      : 'Electronics';

  final productCount = (json['productCount'] as num?)?.toInt() ?? 0;
  final colors = _gradientForName(name);

  return ElectronicsStore(
    id: id,
    name: name,
    rating: double.parse(rating.toStringAsFixed(1)),
    reviewCount: reviewCount,
    distance: distance,
    categories: categories,
    productCount: productCount,
    gradientStart: colors.$1,
    gradientEnd: colors.$2,
    freeDelivery: json['freeDelivery'] == true ||
        ((json['deliveryFee'] as num?)?.toDouble() ?? 1) == 0,
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
  for (final s in ElectronicsData.stores) {
    if (s.name.toLowerCase() == name.toLowerCase() ||
        s.id.toLowerCase() == name.toLowerCase()) {
      return (s.gradientStart, s.gradientEnd);
    }
  }
  final base = HomeBrandStyle.forName(name);
  return (Color.lerp(base, Colors.white, 0.85) ?? const Color(0xFFE3F2EB),
      Color.lerp(base, Colors.white, 0.7) ?? const Color(0xFFC8E6D4));
}
