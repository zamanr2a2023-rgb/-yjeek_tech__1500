import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';

class ServicesVendorMenu {
  const ServicesVendorMenu({
    required this.provider,
    required this.sections,
    required this.items,
  });

  final ServiceProvider provider;
  final List<String> sections;
  final List<ServiceMenuItem> items;
}

class ServicesProductDetail {
  const ServicesProductDetail({
    required this.item,
    required this.description,
    required this.options,
    required this.addons,
    required this.specialists,
    required this.specialistIds,
  });

  final ServiceMenuItem item;
  final String description;
  final List<ServiceOption> options;
  final List<ServiceAddon> addons;
  final List<String> specialists;
  /// Parallel to [specialists]; null means "Any".
  final List<String?> specialistIds;
}

class ServicesCartSummary {
  const ServicesCartSummary({
    required this.itemCount,
    required this.totalLabel,
    this.vendorId,
  });

  final int itemCount;
  final String totalLabel;
  final String? vendorId;

  static const empty = ServicesCartSummary(itemCount: 0, totalLabel: '0.000');
}

class ServicesVendorsRepository {
  const ServicesVendorsRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /categories/services — menuCategories for the home grid.
  Future<List<ServiceCategoryItem>> fetchServiceCategories() async {
    final response = await _apiClient.getJson('/categories/services');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return ServicesData.categories;

    final list = data['menuCategories'];
    if (list is! List || list.isEmpty) return ServicesData.categories;

    final items = <ServiceCategoryItem>[];
    for (final raw in list) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = serviceCategoryFromMenuJson(raw);
      if (mapped != null) items.add(mapped);
    }
    return items.isNotEmpty ? items : ServicesData.categories;
  }

  Future<ServiceCategoryItem> fetchCategoryById(String categoryId) async {
    final categories = await fetchServiceCategories();
    for (final c in categories) {
      if (c.id == categoryId ||
          c.id.toLowerCase() == categoryId.toLowerCase() ||
          c.name.toLowerCase() == categoryId.toLowerCase()) {
        return c;
      }
    }
    return ServicesData.categoryById(categoryId);
  }

  /// GET /vendors?category=services&isBookable=true&sort=&subcategory=&q=&hasOffers=
  Future<List<ServiceProvider>> fetchProviders({
    String sort = 'popular',
    String? subcategory,
    String? query,
    String? venueFilter,
    bool offersOnly = false,
  }) async {
    final params = <String, String>{
      'category': 'services',
      'isBookable': 'true',
      'sort': sort,
    };
    if (subcategory != null &&
        subcategory.isNotEmpty &&
        subcategory.toLowerCase() != 'all') {
      params['subcategory'] = subcategory;
    }
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    if (offersOnly) params['hasOffers'] = 'true';

    final venue = venueFilter?.toLowerCase();
    if (venue == 'at home') {
      params['supportsDelivery'] = 'true';
    } else if (venue == 'at venue') {
      params['supportsPickup'] = 'true';
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

    final items = <ServiceProvider>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = serviceProviderFromVendorJson(raw);
      if (mapped == null) continue;
      if (!_matchesVenue(mapped, venueFilter)) continue;
      items.add(mapped);
    }
    return items;
  }

  Future<List<ServiceProvider>> fetchPopularProviders({
    String sort = 'popular',
    String? query,
  }) {
    return fetchProviders(sort: sort, query: query);
  }

  /// GET /vendors/:id
  Future<ServiceProvider> fetchProvider(String providerId) async {
    final response = await _apiClient.getJson('/vendors/$providerId');
    final data = response?['data'];
    if (data is Map<String, dynamic>) {
      final mapped = serviceProviderFromVendorJson(data);
      if (mapped != null) return mapped;
    }
    return ServicesData.providerById(providerId);
  }

  /// GET /vendors/:id/menu?q=
  Future<ServicesVendorMenu> fetchProviderMenu(
    String providerId, {
    String? query,
  }) async {
    final qs = (query != null && query.trim().isNotEmpty)
        ? '?q=${Uri.encodeQueryComponent(query.trim())}'
        : '';
    final response = await _apiClient.getJson('/vendors/$providerId/menu$qs');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return ServicesVendorMenu(
        provider: await fetchProvider(providerId),
        sections: const [],
        items: const [],
      );
    }

    final vendorRaw = data['vendor'];
    final provider = vendorRaw is Map<String, dynamic>
        ? (serviceProviderFromVendorJson({
              ...vendorRaw,
              'id': vendorRaw['id'] ?? providerId,
              'slug': vendorRaw['slug'] ?? providerId,
            }) ??
            await fetchProvider(providerId))
        : await fetchProvider(providerId);

    final sectionsRaw = data['sections'];
    final sections = <String>[];
    final items = <ServiceMenuItem>[];
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
          final mapped = serviceMenuItemFromProductJson(
            product,
            section: sectionName,
          );
          if (mapped != null) items.add(mapped);
        }
      }
    }

    return ServicesVendorMenu(
      provider: provider,
      sections: sections,
      items: items,
    );
  }

  /// GET /vendors/:id/products/:productId + /staff
  Future<ServicesProductDetail> fetchProductDetail({
    required String providerId,
    required String itemId,
  }) async {
    Map<String, dynamic>? product;
    try {
      final response = await _apiClient.getJson(
        '/vendors/$providerId/products/$itemId',
      );
      final data = response?['data'];
      if (data is Map<String, dynamic>) product = data;
    } catch (_) {}

    var specialists = <String>['Any'];
    var specialistIds = <String?>[null];
    try {
      final staffResponse = await _apiClient.getJson(
        '/vendors/$providerId/staff',
      );
      final staffData = staffResponse?['data'];
      final staffList = staffData is Map<String, dynamic>
          ? staffData['staff']
          : null;
      if (staffList is List && staffList.isNotEmpty) {
        specialists = <String>['Any'];
        specialistIds = <String?>[null];
        for (final member in staffList) {
          if (member is! Map<String, dynamic>) continue;
          final name = member['name'] as String?;
          final id = member['id']?.toString();
          if (name == null || name.isEmpty) continue;
          specialists.add(name);
          specialistIds.add(id);
        }
      }
    } catch (_) {}

    if (specialists.length == 1) {
      specialists = List<String>.from(ServicesData.specialists);
      specialistIds = List<String?>.filled(specialists.length, null);
    }

    if (product == null) {
      final fallback = ServicesData.menuItemById(itemId);
      return ServicesProductDetail(
        item: fallback,
        description: ServicesData.haircutDescription,
        options: ServicesData.haircutOptions,
        addons: ServicesData.haircutAddons,
        specialists: specialists,
        specialistIds: specialistIds,
      );
    }

    final item =
        serviceMenuItemFromProductJson(product, section: 'Services') ??
        ServicesData.menuItemById(itemId);

    final description =
        (product['description'] as String?)?.trim().isNotEmpty == true
        ? (product['description'] as String).trim()
        : item.description;

    final options = <ServiceOption>[];
    final optionGroups = product['optionGroups'];
    if (optionGroups is List) {
      for (final group in optionGroups) {
        if (group is! Map<String, dynamic>) continue;
        final opts = group['options'];
        if (opts is! List) continue;
        for (final opt in opts) {
          if (opt is! Map<String, dynamic>) continue;
          final name = opt['name'] as String?;
          if (name == null || name.isEmpty) continue;
          final delta = (opt['priceDelta'] as num?)?.toDouble() ?? 0;
          options.add(
            ServiceOption(
              id: opt['id']?.toString(),
              name: name,
              subtitle: delta <= 0
                  ? 'Included'
                  : '+ BHD ${_formatMoney(delta)}',
              extraPrice: delta > 0 ? _formatMoney(delta) : null,
            ),
          );
        }
      }
    }
    if (options.isEmpty) options.addAll(ServicesData.haircutOptions);

    final addons = <ServiceAddon>[];
    final addonsRaw = product['addons'];
    if (addonsRaw is List) {
      for (final addon in addonsRaw) {
        if (addon is! Map<String, dynamic>) continue;
        final name = addon['name'] as String?;
        if (name == null || name.isEmpty) continue;
        final price = (addon['price'] as num?)?.toDouble() ?? 0;
        addons.add(
          ServiceAddon(
            id: addon['id']?.toString(),
            name: name,
            price: _formatMoney(price),
          ),
        );
      }
    }
    if (addons.isEmpty) addons.addAll(ServicesData.haircutAddons);

    return ServicesProductDetail(
      item: item,
      description: description,
      options: options,
      addons: addons,
      specialists: specialists,
      specialistIds: specialistIds,
    );
  }

  /// GET /cart?type=SERVICE
  Future<ServicesCartSummary> fetchServiceCart() async {
    final response = await _apiClient.getJson(
      '/cart?type=SERVICE',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return ServicesCartSummary.empty;

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

    return ServicesCartSummary(
      itemCount: count ?? 0,
      totalLabel: totalNum.toStringAsFixed(3),
      vendorId: vendorId,
    );
  }

  /// POST /cart/items?type=SERVICE
  Future<({bool ok, bool vendorConflict, String? message})> addToCart({
    required String productId,
    required int quantity,
    List<String> optionIds = const [],
    List<String> addonIds = const [],
    bool replaceCart = false,
  }) async {
    final response = await _apiClient.postJson(
      '/cart/items?type=SERVICE',
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
      message: response.message ?? 'Could not add to booking',
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
      return const ['Glow Beauty', 'Spa', 'Haircut', 'Home cleaning'];
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
        : const ['Glow Beauty', 'Spa', 'Haircut', 'Home cleaning'];
  }
}

ServiceCategoryItem? serviceCategoryFromMenuJson(Map<String, dynamic> json) {
  final name = (json['name'] as String?)?.trim();
  if (name == null || name.isEmpty) return null;

  final known = _knownServiceCategory(name);
  final apiId = json['id']?.toString();
  return ServiceCategoryItem(
    id: known?.id ?? _slugify(name) ?? apiId ?? name,
    name: name,
    emoji: known?.emoji ?? '✂',
    iconBackground: known?.iconBackground ?? const Color(0xFFE3F2EB),
  );
}

ServiceProvider? serviceProviderFromVendorJson(Map<String, dynamic> json) {
  final id = (json['id'] ?? json['slug'])?.toString();
  final name = json['name'] as String?;
  if (id == null || id.isEmpty || name == null || name.isEmpty) return null;

  final serviceCategory =
      (json['serviceCategory'] as String?) ??
      (json['categoryLabel'] as String?) ??
      _firstCategoryName(json) ??
      'Services';

  final knownCat = _knownServiceCategory(serviceCategory);
  final categoryId =
      knownCat?.id ??
      (json['serviceCategoryId']?.toString()) ??
      'services';

  final ratingRaw = json['rating'];
  final rating = ratingRaw is num
      ? ratingRaw.toDouble()
      : double.tryParse(ratingRaw?.toString() ?? '') ?? 0;

  final reviewCount = (json['reviewCount'] as num?)?.toInt() ?? 0;

  final fromRaw = json['fromPrice'];
  final fromPrice = fromRaw is num
      ? _formatPrice(fromRaw.toDouble())
      : (fromRaw?.toString() ?? '0');

  final distanceKm = json['distanceKm'];
  final distance = distanceKm is num
      ? '${distanceKm.toStringAsFixed(1)} km'
      : (json['area'] as String? ?? 'Nearby');

  final tagsList = json['cuisineTags'];
  final tags = tagsList is List && tagsList.isNotEmpty
      ? tagsList.map((e) => e.toString()).where((e) => e.isNotEmpty).join(' · ')
      : serviceCategory;

  final colors = _gradientForName(name);
  final emoji = knownCat?.emoji ?? '💇‍♀';

  final openHoursTitle =
      (json['openHoursTitle'] as String?)?.trim().isNotEmpty == true
          ? (json['openHoursTitle'] as String).trim()
          : 'Open · 9–9';
  final openHoursSubtitle =
      (json['openHoursSubtitle'] as String?)?.trim().isNotEmpty == true
          ? (json['openHoursSubtitle'] as String).trim()
          : 'Today';
  final bookingModeLabel =
      (json['bookingModeLabel'] as String?)?.trim().isNotEmpty == true
          ? (json['bookingModeLabel'] as String).trim()
          : 'Walk-in / book';

  return ServiceProvider(
    id: id,
    name: name,
    category: serviceCategory,
    categoryId: categoryId,
    rating: double.parse(rating.toStringAsFixed(1)),
    reviewCount: reviewCount,
    distance: distance,
    tags: tags,
    priceFrom: fromPrice,
    atVenue: json['atVenue'] == true ||
        json['supportsDineIn'] == true ||
        json['supportsPickup'] == true,
    atHome: json['atHome'] == true ||
        (json['isBookable'] == true && json['supportsDelivery'] == true),
    gradientStart: colors.$1,
    gradientEnd: colors.$2,
    emoji: emoji,
    openHoursTitle: openHoursTitle,
    openHoursSubtitle: openHoursSubtitle,
    bookingModeLabel: bookingModeLabel,
  );
}

ServiceMenuItem? serviceMenuItemFromProductJson(
  Map<String, dynamic> json, {
  required String section,
}) {
  final id = json['id']?.toString();
  final name = json['name'] as String?;
  if (id == null || id.isEmpty || name == null || name.isEmpty) return null;

  final priceRaw = json['price'];
  final price = priceRaw is num
      ? _formatMoney(priceRaw.toDouble())
      : (priceRaw?.toString() ?? '0.000');

  final prep = (json['prepTimeMin'] as num?)?.toInt();
  final duration = prep != null ? '$prep min' : '45 min';
  final description =
      (json['description'] as String?)?.trim().isNotEmpty == true
      ? (json['description'] as String).trim()
      : '$name · $duration';

  return ServiceMenuItem(
    id: id,
    name: name,
    description: description,
    price: price,
    section: section,
    duration: duration,
  );
}

bool _matchesVenue(ServiceProvider provider, String? venueFilter) {
  if (venueFilter == null) return true;
  switch (venueFilter.toLowerCase()) {
    case 'at venue':
      return provider.atVenue;
    case 'at home':
      return provider.atHome;
    default:
      return true;
  }
}

ServiceCategoryItem? _knownServiceCategory(String name) {
  final lower = name.toLowerCase();
  for (final c in ServicesData.categories) {
    if (c.name.toLowerCase() == lower ||
        c.id.toLowerCase() == lower ||
        lower.contains(c.id.replaceAll('-', ' '))) {
      return c;
    }
  }
  if (lower.contains('salon') || lower.contains('beauty')) {
    return ServicesData.categories[0];
  }
  if (lower.contains('spa') || lower.contains('massage')) {
    return ServicesData.categories[1];
  }
  if (lower.contains('photo')) return ServicesData.categories[2];
  if (lower.contains('home')) return ServicesData.categories[3];
  return null;
}

String? _slugify(String name) {
  final slug = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return slug.isEmpty ? null : slug;
}

String? _firstCategoryName(Map<String, dynamic> json) {
  final cats = json['categories'];
  if (cats is! List || cats.isEmpty) return null;
  final first = cats.first;
  if (first is Map<String, dynamic>) return first['name'] as String?;
  return null;
}

String _formatPrice(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}

String _formatMoney(double value) => value.toStringAsFixed(3);

(Color, Color) _gradientForName(String name) {
  for (final p in [
    ...ServicesData.popularProviders,
    ...ServicesData.salonBeautyProviders,
  ]) {
    if (p.name.toLowerCase() == name.toLowerCase()) {
      return (p.gradientStart, p.gradientEnd);
    }
  }
  final base = HomeBrandStyle.forName(name);
  return (base, const Color(0xFF15302B));
}
