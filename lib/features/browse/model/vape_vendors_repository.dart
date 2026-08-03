import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/browse/model/vape_data.dart';

class VapeCartSummary {
  const VapeCartSummary({
    required this.itemCount,
    required this.totalLabel,
    this.vendorId,
  });

  final int itemCount;
  final String totalLabel;
  final String? vendorId;

  static const empty = VapeCartSummary(itemCount: 0, totalLabel: '0.000');
}

class VapeVendorsRepository {
  const VapeVendorsRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /vendors?category=vape&sort=rating&q=
  Future<List<VapeStore>> fetchStores({String? query}) async {
    final params = <String, String>{
      'category': 'vape',
      'sort': 'rating',
    };
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

    final items = <VapeStore>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = vapeStoreFromVendorJson(raw);
      if (mapped != null) items.add(mapped);
    }
    return items;
  }

  /// GET /vendors/:id
  Future<VapeStore> fetchStore(String storeId) async {
    final response = await _apiClient.getJson('/vendors/$storeId');
    final data = response?['data'];
    if (data is Map<String, dynamic>) {
      final mapped = vapeStoreFromVendorJson(data);
      if (mapped != null) return mapped;
    }
    return VapeData.storeById(storeId);
  }

  /// GET /vendors/:id/menu — filter products by category chip (section name).
  Future<List<VapeProduct>> fetchProducts(
    String storeId, {
    required String category,
    String? query,
  }) async {
    final qs = (query != null && query.trim().isNotEmpty)
        ? '?q=${Uri.encodeQueryComponent(query.trim())}'
        : '';
    final response = await _apiClient.getJson('/vendors/$storeId/menu$qs');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return const [];

    final sectionsRaw = data['sections'];
    if (sectionsRaw is! List) return const [];

    final items = <VapeProduct>[];
    for (final section in sectionsRaw) {
      if (section is! Map<String, dynamic>) continue;
      final sectionName = (section['name'] as String?)?.trim() ?? '';
      if (sectionName.isEmpty) continue;
      if (category.isNotEmpty &&
          sectionName.toLowerCase() != category.toLowerCase()) {
        continue;
      }
      final products = section['products'];
      if (products is! List) continue;
      for (final product in products) {
        if (product is! Map<String, dynamic>) continue;
        final mapped = vapeProductFromJson(
          product,
          storeId: storeId,
          category: sectionName,
        );
        if (mapped != null) items.add(mapped);
      }
    }
    return items;
  }

  /// GET /vendors/:id/products/:productId
  Future<VapeProduct> fetchProductDetail({
    required String storeId,
    required String productId,
  }) async {
    final response = await _apiClient.getJson(
      '/vendors/$storeId/products/$productId',
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return VapeData.productById(productId);
    }

    return vapeProductFromJson(
          data,
          storeId: storeId,
          category: data['menuSectionName'] as String? ??
              _categoryFromTags(data) ??
              'Disposables',
          detailed: true,
        ) ??
        VapeData.productById(productId);
  }

  /// GET /cart?type=DELIVERY
  Future<VapeCartSummary> fetchCart() async {
    if (!_storage.hasSession) return VapeCartSummary.empty;

    final response = await _apiClient.getJson(
      '/cart?type=DELIVERY',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return VapeCartSummary.empty;

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

    return VapeCartSummary(
      itemCount: count ?? 0,
      totalLabel: totalNum.toStringAsFixed(3),
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
    if (!_storage.hasSession) {
      return (
        ok: false,
        vendorConflict: false,
        message: 'Please log in to add items to your cart',
      );
    }

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

VapeStore? vapeStoreFromVendorJson(Map<String, dynamic> json) {
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

  final etaMin = json['deliveryTimeMin'] ?? json['pickupEtaMin'];
  final eta = etaMin is num
      ? '~${etaMin.toInt()} min'
      : (json['pickupEtaLabel'] as String? ?? '~30 min');

  final tags = json['cuisineTags'];
  String? subtitle;
  if (tags is List) {
    for (final tag in tags) {
      final t = tag.toString().toLowerCase();
      if (t == 'tobacco') {
        subtitle = 'tobacco';
        break;
      }
    }
  }

  final colors = _gradientForName(name);
  final shortName = name.split(' ').first;

  return VapeStore(
    id: id,
    name: name,
    shortName: shortName.length > 12 ? name.substring(0, 12) : shortName,
    rating: double.parse(rating.toStringAsFixed(1)),
    distance: distance,
    eta: eta,
    subtitle: subtitle,
    gradientStart: colors.$1,
    gradientEnd: colors.$2,
  );
}

VapeProduct? vapeProductFromJson(
  Map<String, dynamic> json, {
  required String storeId,
  required String category,
  bool detailed = false,
}) {
  final id = json['id']?.toString();
  final name = json['name'] as String?;
  if (id == null || id.isEmpty || name == null || name.isEmpty) return null;

  final priceRaw = json['price'];
  final priceNum = priceRaw is num
      ? priceRaw.toDouble()
      : double.tryParse(priceRaw?.toString() ?? '') ?? 0;
  final price = priceNum.toStringAsFixed(3);

  final specs = (json['specs'] as String?)?.trim();
  final detailSpecs = (json['descriptionAr'] as String?)?.trim();

  var nicotineOptions = <String>[];
  var nicotineOptionIds = <String>[];

  if (detailed) {
    final groups = json['optionGroups'];
    if (groups is List) {
      for (final group in groups) {
        if (group is! Map<String, dynamic>) continue;
        final groupName = (group['name'] as String?)?.toLowerCase() ?? '';
        if (!groupName.contains('nicotine')) continue;
        final options = group['options'];
        if (options is! List) continue;
        for (final opt in options) {
          if (opt is! Map<String, dynamic>) continue;
          final label = opt['name']?.toString();
          final optId = opt['id']?.toString();
          if (label == null || label.isEmpty) continue;
          nicotineOptions.add(label);
          if (optId != null) nicotineOptionIds.add(optId);
        }
      }
    }
  }

  // List rows: no option groups — show empty nicotine (chips only on detail).
  // Devices typically have no nicotine; leave empty when detailed and none found.
  if (!detailed) {
    nicotineOptions = const [];
    nicotineOptionIds = const [];
  }

  return VapeProduct(
    id: id,
    storeId: storeId,
    name: name,
    specs: (specs != null && specs.isNotEmpty)
        ? specs
        : (json['description'] as String? ?? ''),
    detailSpecs: (detailSpecs != null && detailSpecs.isNotEmpty)
        ? detailSpecs
        : specs,
    price: price,
    category: category,
    nicotineOptions: nicotineOptions,
    nicotineOptionIds: nicotineOptionIds,
  );
}

String? _categoryFromTags(Map<String, dynamic> json) {
  final tags = json['tags'];
  if (tags is! List) return null;
  for (final tag in tags) {
    final t = tag.toString();
    if (VapeData.categories.any((c) => c.toLowerCase() == t.toLowerCase())) {
      return t;
    }
  }
  return null;
}

(Color, Color) _gradientForName(String name) {
  final key = name.toLowerCase();
  if (key.contains('cloud')) {
    return (const Color(0xFFE3F0FA), const Color(0xFFC8DFF0));
  }
  if (key.contains('smoke')) {
    return (const Color(0xFFF0EDE8), const Color(0xFFE0D8CE));
  }
  return (const Color(0xFFE8ECF5), const Color(0xFFD4DBEB));
}
