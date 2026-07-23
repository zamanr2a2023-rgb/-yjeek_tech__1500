import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';

class ServicesProviderMenu {
  const ServicesProviderMenu({
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
  });

  final ServiceMenuItem item;
  final String description;
  final List<ServiceOption> options;
  final List<ServiceAddon> addons;
  final List<String> specialists;
}

class ServicesVendorsRepository {
  const ServicesVendorsRepository(this._apiClient);

  final ApiClient _apiClient;

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

  /// GET /vendors?category=services&isBookable=true&sort=
  Future<List<ServiceProvider>> fetchProviders({
    String sort = 'popular',
    String? query,
    String? categoryId,
    String? venueFilter,
  }) async {
    final params = <String, String>{
      'category': 'services',
      'isBookable': 'true',
      'sort': sort,
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
    if (data is! List) {
      return _fallbackProviders(categoryId: categoryId, venueFilter: venueFilter);
    }

    var items = <ServiceProvider>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = serviceProviderFromVendorJson(raw);
      if (mapped != null) items.add(mapped);
    }

    if (items.isEmpty) {
      return _fallbackProviders(categoryId: categoryId, venueFilter: venueFilter);
    }

    if (categoryId != null &&
        categoryId.isNotEmpty &&
        categoryId.toLowerCase() != 'all') {
      final known = ServicesData.categoryById(categoryId);
      items = items
          .where(
            (p) =>
                p.categoryId == categoryId ||
                p.category.toLowerCase() == known.name.toLowerCase(),
          )
          .toList();
    }

    if (venueFilter == 'At venue') {
      items = items.where((p) => p.atVenue).toList();
    } else if (venueFilter == 'At home') {
      items = items.where((p) => p.atHome).toList();
    }

    if (items.isEmpty) {
      return _fallbackProviders(categoryId: categoryId, venueFilter: venueFilter);
    }
    return items;
  }

  Future<List<ServiceProvider>> fetchPopularProviders({
    String sort = 'popular',
    String? query,
  }) {
    return fetchProviders(sort: sort, query: query);
  }

  /// Resolves slug or cuid to vendor cuid using existing list/detail endpoints.
  Future<String> resolveVendorId(String idOrSlug) async {
    final direct = await _apiClient.getJson('/vendors/$idOrSlug');
    final data = direct?['data'];
    if (data is Map<String, dynamic>) {
      final id = data['id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    }

    final providers = await fetchProviders();
    for (final provider in providers) {
      if (provider.id == idOrSlug) return provider.id;
    }

    // Mock / legacy slug fallback: match by name-ish slug against list again via raw
    final response = await _apiClient.getJson(
      '/vendors?category=services&isBookable=true',
    );
    final list = response?['data'];
    if (list is List) {
      for (final raw in list) {
        if (raw is! Map<String, dynamic>) continue;
        final slug = raw['slug']?.toString();
        final id = raw['id']?.toString();
        if (id != null && (slug == idOrSlug || id == idOrSlug)) return id;
      }
    }
    return idOrSlug;
  }

  /// GET /vendors/:id
  Future<ServiceProvider?> fetchProvider(String idOrSlug) async {
    final vendorId = await resolveVendorId(idOrSlug);
    final response = await _apiClient.getJson('/vendors/$vendorId');
    final data = response?['data'];
    if (data is Map<String, dynamic>) {
      return serviceProviderFromVendorJson(data);
    }
    try {
      return ServicesData.providerById(idOrSlug);
    } catch (_) {
      return null;
    }
  }

  /// GET /vendors/:id/menu
  Future<ServicesProviderMenu?> fetchProviderMenu(String idOrSlug) async {
    final vendorId = await resolveVendorId(idOrSlug);
    final provider =
        await fetchProvider(vendorId) ?? ServicesData.providerById(idOrSlug);

    final response = await _apiClient.getJson('/vendors/$vendorId/menu');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return ServicesProviderMenu(
        provider: provider,
        sections: ServicesData.glowBeautySections,
        items: ServicesData.glowBeautyMenu,
      );
    }

    final sectionsRaw = data['sections'];
    final sections = <String>[];
    final items = <ServiceMenuItem>[];

    if (sectionsRaw is List) {
      for (final section in sectionsRaw) {
        if (section is! Map<String, dynamic>) continue;
        final sectionName = (section['name'] as String?)?.trim();
        if (sectionName == null || sectionName.isEmpty) continue;
        final displaySection =
            sectionName.toLowerCase() == 'other' ? 'Services' : sectionName;
        if (!sections.contains(displaySection)) sections.add(displaySection);

        final products = section['products'];
        if (products is! List) continue;
        for (final product in products) {
          if (product is! Map<String, dynamic>) continue;
          final item = serviceMenuItemFromProductJson(
            product,
            section: displaySection,
          );
          if (item != null) items.add(item);
        }
      }
    }

    if (items.isEmpty) {
      return ServicesProviderMenu(
        provider: provider,
        sections: ServicesData.glowBeautySections,
        items: ServicesData.glowBeautyMenu,
      );
    }

    return ServicesProviderMenu(
      provider: provider,
      sections: sections.isNotEmpty ? sections : ['Services'],
      items: items,
    );
  }

  /// GET /vendors/:id/products/:productId + GET /vendors/:id/staff
  Future<ServicesProductDetail?> fetchProductDetail({
    required String providerId,
    required String itemId,
  }) async {
    final vendorId = await resolveVendorId(providerId);

    final productResponse = await _apiClient.getJson(
      '/vendors/$vendorId/products/$itemId',
    );
    final productData = productResponse?['data'];

    ServiceMenuItem? item;
    var description = '';
    var options = <ServiceOption>[];
    var addons = <ServiceAddon>[];

    if (productData is Map<String, dynamic>) {
      item = serviceMenuItemFromProductJson(productData, section: 'Services');
      description =
          (productData['description'] as String?)?.trim().isNotEmpty == true
          ? productData['description'] as String
          : (item?.description ?? '');

      final optionGroups = productData['optionGroups'];
      if (optionGroups is List) {
        for (final group in optionGroups) {
          if (group is! Map<String, dynamic>) continue;
          final groupOptions = group['options'];
          if (groupOptions is! List) continue;
          for (final opt in groupOptions) {
            if (opt is! Map<String, dynamic>) continue;
            final name = opt['name'] as String?;
            if (name == null || name.isEmpty) continue;
            final delta = (opt['priceDelta'] as num?)?.toDouble() ?? 0;
            options.add(
              ServiceOption(
                name: name,
                subtitle: delta > 0
                    ? '+ BHD ${delta.toStringAsFixed(3)}'
                    : 'Included',
                extraPrice: delta > 0 ? delta.toStringAsFixed(3) : null,
              ),
            );
          }
        }
      }

      final addonsRaw = productData['addons'];
      if (addonsRaw is List) {
        for (final addon in addonsRaw) {
          if (addon is! Map<String, dynamic>) continue;
          final name = addon['name'] as String?;
          if (name == null || name.isEmpty) continue;
          final price = (addon['price'] as num?)?.toDouble() ?? 0;
          addons.add(
            ServiceAddon(name: name, price: price.toStringAsFixed(3)),
          );
        }
      }
    }

    item ??= await _menuItemFromProviderMenu(vendorId, itemId);

    if (item == null) {
      final fallback = ServicesData.menuItemById(itemId);
      return ServicesProductDetail(
        item: fallback,
        description: ServicesData.haircutDescription,
        options: ServicesData.haircutOptions,
        addons: ServicesData.haircutAddons,
        specialists: await fetchSpecialists(vendorId),
      );
    }

    if (description.isEmpty) {
      description = item.description.isNotEmpty
          ? item.description
          : '${item.name} · ${item.duration}';
    }

    final specialists = await fetchSpecialists(vendorId);

    return ServicesProductDetail(
      item: item,
      description: description,
      options: options,
      addons: addons,
      specialists: specialists,
    );
  }

  Future<List<String>> fetchSpecialists(String idOrSlug) async {
    final vendorId = await resolveVendorId(idOrSlug);
    final response = await _apiClient.getJson('/vendors/$vendorId/staff');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return const ['Any'];

    final staff = data['staff'];
    final names = <String>['Any'];
    if (staff is List) {
      for (final member in staff) {
        if (member is! Map<String, dynamic>) continue;
        final name = member['name'] as String?;
        if (name != null && name.isNotEmpty) names.add(name);
      }
    }
    return names.length > 1 ? names : const ['Any'];
  }

  Future<ServiceMenuItem?> _menuItemFromProviderMenu(
    String vendorId,
    String itemId,
  ) async {
    final menu = await fetchProviderMenu(vendorId);
    if (menu == null) return null;
    for (final item in menu.items) {
      if (item.id == itemId) return item;
    }
    return null;
  }

  List<ServiceProvider> _fallbackProviders({
    String? categoryId,
    String? venueFilter,
  }) {
    if (categoryId != null && categoryId.isNotEmpty) {
      return ServicesData.providersForCategory(
        categoryId,
        venueFilter: venueFilter,
      );
    }
    return ServicesData.popularProviders;
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
  // Prefer cuid so GET /vendors/:id works without API changes.
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

  final atVenue = json['atVenue'] == true ||
      json['supportsDineIn'] == true ||
      json['supportsPickup'] == true;
  final atHome = json['atHome'] == true ||
      (json['isBookable'] == true && json['supportsDelivery'] == true);

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
    atVenue: atVenue,
    atHome: atHome,
    gradientStart: colors.$1,
    gradientEnd: colors.$2,
    emoji: emoji,
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
      ? priceRaw.toDouble().toStringAsFixed(3)
      : (priceRaw?.toString() ?? '0.000');

  final prep = (json['prepTimeMin'] as num?)?.toInt();
  final duration = prep != null ? '$prep min' : '45 min';
  final description = (json['description'] as String?)?.trim();
  final desc = (description != null && description.isNotEmpty)
      ? description
      : '$name · $duration';

  return ServiceMenuItem(
    id: id,
    name: name,
    description: desc,
    price: price,
    section: section,
    duration: duration,
  );
}

ServiceCategoryItem? _knownServiceCategory(String name) {
  final needle = name.toLowerCase();
  for (final category in ServicesData.categories) {
    if (category.name.toLowerCase() == needle) return category;
  }
  return null;
}

String? _firstCategoryName(Map<String, dynamic> json) {
  final categories = json['categories'];
  if (categories is! List || categories.isEmpty) return null;
  final first = categories.first;
  if (first is Map<String, dynamic>) {
    return first['name'] as String?;
  }
  return null;
}

String _formatPrice(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String? _slugify(String name) {
  final slug = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return slug.isEmpty ? null : slug;
}

(Color, Color) _gradientForName(String name) {
  final base = HomeBrandStyle.forName(name);
  return (base, const Color(0xFF15302B));
}
