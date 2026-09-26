import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/core/utils/api_media_url.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
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
    required this.optionGroups,
    required this.addons,
    required this.specialists,
    required this.specialistIds,
    this.imageUrl,
    this.quantityLabel = 'Sessions',
    this.categoryLabel,
  });

  final ServiceMenuItem item;
  final String description;
  final List<BrowseOptionGroup> optionGroups;
  final List<BrowseAddonOption> addons;
  final List<String> specialists;
  /// Parallel to [specialists]; null means "Any".
  final List<String?> specialistIds;
  final String? imageUrl;
  /// Cleaning → Visits; Beauty & others → Sessions (chekc.md / help 2.md).
  final String quantityLabel;
  final String? categoryLabel;
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

class ServiceBookingSlot {
  const ServiceBookingSlot({
    required this.id,
    required this.startAt,
    required this.label,
    required this.available,
  });

  final String id;
  final DateTime startAt;
  final String label;
  final bool available;
}

class ServicesVendorsRepository {
  const ServicesVendorsRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /categories/services — menuCategories (preferred) or subTypes.
  Future<List<ServiceCategoryItem>> fetchServiceCategories() async {
    final response = await _apiClient.getJson('/categories/services');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return const [];

    final items = <ServiceCategoryItem>[];

    void addFromList(Object? list) {
      if (list is! List) return;
      for (final raw in list) {
        if (raw is! Map<String, dynamic>) continue;
        final mapped = serviceCategoryFromMenuJson(raw);
        if (mapped != null) items.add(mapped);
      }
    }

    addFromList(data['menuCategories']);
    if (items.isEmpty) addFromList(data['subTypes']);
    if (items.isEmpty) addFromList(data['children']);
    return items;
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
    throw StateError('Service category not found: $categoryId');
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
      // Fully booked can be hidden when sorting by availability (default).
      if (sort != 'rating' && mapped.fullyBooked) continue;
      items.add(mapped);
    }

    // Availability first (open / slots soon), then rating as tie-break.
    if (sort != 'rating' && sort != 'name') {
      items.sort((a, b) {
        final byAvail = b.availabilityRank.compareTo(a.availabilityRank);
        if (byAvail != 0) return byAvail;
        return b.rating.compareTo(a.rating);
      });
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
    throw StateError('Service provider not found: $providerId');
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

    String? providerCategory;
    try {
      final provider = await fetchProvider(providerId);
      providerCategory = provider.category;
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

    if (product == null) {
      throw StateError('Service product not found: $itemId');
    }

    final item = serviceMenuItemFromProductJson(product, section: 'Services');
    if (item == null) {
      throw StateError('Service product not found: $itemId');
    }

    final description =
        (product['description'] as String?)?.trim().isNotEmpty == true
        ? (product['description'] as String).trim()
        : item.description;

    final optionGroups = browseOptionGroupsFromJson(product['optionGroups']);

    // Help 2.md list view: cleaner count under duration (not stock status).
    final patchedGroups = [
      for (final group in optionGroups)
        BrowseOptionGroup(
          id: group.id,
          name: group.name,
          minSelect: group.minSelect,
          maxSelect: group.maxSelect,
          options: [
            for (final opt in group.options)
              BrowseSizeOption(
                id: opt.id,
                label: opt.label,
                subtitle: opt.isIncluded
                    ? 'Included'
                    : '+BHD ${opt.extraPrice}',
                extraPrice: opt.extraPrice,
                imageUrl: opt.imageUrl,
                isDefault: opt.isDefault,
                isAvailable: opt.isAvailable,
                stockLabel: _serviceOptionHint(opt.label),
              ),
          ],
        ),
    ];

    final addons = <BrowseAddonOption>[];
    final addonsRaw = product['addons'];
    if (addonsRaw is List) {
      for (final addon in addonsRaw) {
        if (addon is! Map<String, dynamic>) continue;
        final name = addon['name'] as String?;
        if (name == null || name.isEmpty) continue;
        final price = (addon['price'] as num?)?.toDouble() ?? 0;
        addons.add(
          BrowseAddonOption(
            id: addon['id']?.toString(),
            label: name,
            price: _formatMoney(price),
            imageUrl: resolveApiMediaUrl(addon['imageUrl'] as String?),
          ),
        );
      }
    }

    final category = providerCategory ??
        product['serviceCategory'] as String? ??
        product['categoryLabel'] as String?;

    return ServicesProductDetail(
      item: item,
      description: description,
      optionGroups: patchedGroups,
      addons: addons,
      specialists: specialists,
      specialistIds: specialistIds,
      imageUrl: resolveApiMediaUrl(product['imageUrl'] as String?),
      quantityLabel: serviceQuantityLabel(category),
      categoryLabel: category,
    );
  }

  /// GET /cart?type=SERVICE
  Future<ServicesCartSummary> fetchServiceCart() async {
    if (!_storage.hasSession) return ServicesCartSummary.empty;

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

  /// GET /vendors/:id/booking-slots?date=YYYY-MM-DD
  Future<List<ServiceBookingSlot>> fetchBookingSlots({
    required String vendorId,
    required DateTime date,
    String? staffId,
  }) async {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final qs = StringBuffer('date=$y-$m-$d');
    if (staffId != null && staffId.isNotEmpty) {
      qs.write('&staffId=$staffId');
    }
    final response = await _apiClient.getJson(
      '/vendors/$vendorId/booking-slots?$qs',
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return const [];
    final raw = data['slots'];
    if (raw is! List) return const [];
    final out = <ServiceBookingSlot>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final startAt = DateTime.tryParse(item['startAt']?.toString() ?? '');
      if (startAt == null) continue;
      final label = item['label']?.toString();
      out.add(
        ServiceBookingSlot(
          id: item['id']?.toString() ?? startAt.toIso8601String(),
          startAt: startAt.toLocal(),
          label: (label != null && label.isNotEmpty)
              ? label
              : _formatSlotLabel(startAt.toLocal()),
          available: item['available'] == true,
        ),
      );
    }
    return out;
  }

  static String _formatSlotLabel(DateTime start) {
    final h = start.hour;
    final min = start.minute;
    final mm = min.toString().padLeft(2, '0');
    if (h < 12) return '$h:$mm';
    if (h == 12) return min == 0 ? '12:00 PM' : '12:$mm PM';
    return min == 0 ? '${h - 12}:00 PM' : '${h - 12}:$mm PM';
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
      return const [];
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
    return queries;
  }
}

ServiceCategoryItem? serviceCategoryFromMenuJson(Map<String, dynamic> json) {
  final name = (json['name'] as String?)?.trim();
  if (name == null || name.isEmpty) return null;

  final apiId = json['id']?.toString();
  final slug = json['slug']?.toString();
  return ServiceCategoryItem(
    id: apiId ?? slug ?? _slugify(name) ?? name,
    name: name,
    emoji: (json['emoji'] as String?)?.trim().isNotEmpty == true
        ? (json['emoji'] as String).trim()
        : _emojiForServiceName(name),
    iconBackground: const Color(0xFFE8F5E9),
  );
}

String _emojiForServiceName(String name) {
  final n = name.toLowerCase();
  if (n.contains('clean')) return '🧹';
  if (n.contains('plumb') || n.contains('ac') || n.contains('a/c')) return '🔧';
  if (n.contains('beauty') || n.contains('salon') || n.contains('hair')) {
    return '✂️';
  }
  if (n.contains('car') || n.contains('auto')) return '🚗';
  if (n.contains('photo')) return '📷';
  if (n.contains('spa') || n.contains('massage')) return '🧘';
  return '🛠️';
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

  final categoryId =
      (json['serviceCategoryId']?.toString()) ??
      _slugify(serviceCategory) ??
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
  final emoji = (json['emoji'] as String?)?.trim().isNotEmpty == true
      ? (json['emoji'] as String).trim()
      : '💇‍♀';

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

  final offer = json['offerBadge'] ?? json['badgeLabel'] ?? json['promoBadge'];
  final offerBadge = offer?.toString().trim();
  final area = (json['area'] as String?)?.trim();
  final imageUrl = resolveApiMediaUrl(json['logoUrl'] as String?) ??
      resolveApiMediaUrl(json['coverUrl'] as String?);
  final openStatus = (json['openStatus'] as String?)?.toUpperCase() ?? 'UNKNOWN';
  final hasRating = json['hasRating'] == true || (reviewCount > 0 && rating > 0);
  final fullyBooked = json['fullyBooked'] == true ||
      (json['bookingModeLabel'] as String?)?.toLowerCase().contains('full') ==
          true;

  return ServiceProvider(
    id: id,
    name: name,
    category: serviceCategory,
    categoryId: categoryId,
    rating: hasRating ? double.parse(rating.toStringAsFixed(1)) : 0,
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
    offerBadge:
        (offerBadge != null && offerBadge.isNotEmpty) ? offerBadge : null,
    area: (area != null && area.isNotEmpty) ? area : null,
    imageUrl: imageUrl,
    hasRating: hasRating,
    openStatus: openStatus,
    fullyBooked: fullyBooked,
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

  final mods = json['modifiers'];
  final optionGroups = json['optionGroups'];
  final count = json['_count'];
  final optionCount = optionGroups is List
      ? optionGroups.length
      : (count is Map
          ? (count['optionGroups'] as num?)?.toInt() ?? 0
          : 0);
  final addonCount = count is Map
      ? (count['addons'] as num?)?.toInt() ?? 0
      : (json['addons'] is List ? (json['addons'] as List).length : 0);
  final hasModifiers = json['hasModifiers'] == true ||
      (mods is List && mods.isNotEmpty) ||
      optionCount > 0 ||
      addonCount > 0;

  return ServiceMenuItem(
    id: id,
    name: name,
    description: description,
    price: price,
    section: section,
    duration: duration,
    hasModifiers: hasModifiers,
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

String? _serviceOptionHint(String label) {
  final n = label.toLowerCase().trim();
  if (n == '2 hours') return '1 cleaner';
  if (n == '3 hours' || n == '4 hours' || n == '6 hours') return '2 cleaners';
  return null;
}

/// Quantity row label: Cleaning → Visits; Beauty & other services → Sessions.
String serviceQuantityLabel(String? category) {
  final c = (category ?? '').toLowerCase();
  if (c.contains('clean')) return 'Visits';
  return 'Sessions';
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
  final base = HomeBrandStyle.forName(name);
  return (base, const Color(0xFF15302B));
}
