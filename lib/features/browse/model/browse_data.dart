import 'package:flutter/material.dart';

import 'package:yjeek_app/core/utils/api_media_url.dart';
import 'package:yjeek_app/l10n/l10n.dart';

class BrowseRestaurant {
  const BrowseRestaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.gradientStart,
    required this.gradientEnd,
    this.badge,
    this.deliveryMin = 25,
    this.freeDelivery = false,
    this.deliveryFee = '0.8',
    this.minOrder = '5',
    this.distance = '2.4 km',
    this.imageUrl,
    this.reviewCount = '___',
    this.reviewCountValue = 0,
    this.hasRating = false,
    this.area,
    this.isOpen = true,
    this.prepTimeMin,
    this.arrivesInMin,
    this.readyInMin,
    this.distanceKm,
    this.latitude,
    this.longitude,
    this.isBookable = false,
    this.dineInAvailableLabel,
    this.dineInTablesAvailable,
    this.categoryLabel,
    this.supportsDelivery = true,
    this.supportsPickup = false,
    this.supportsDineIn = false,
  });

  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final Color gradientStart;
  final Color gradientEnd;
  final String? badge;
  final int deliveryMin;
  final bool freeDelivery;
  final String deliveryFee;
  final String minOrder;
  final String distance;
  final String? imageUrl;
  final String reviewCount;
  final int reviewCountValue;
  /// True only when real customer reviews exist (not a placeholder 0.0).
  final bool hasRating;
  /// Vendor area / city for location-style filters when cuisineTags are empty.
  final String? area;
  final bool isOpen;
  final int? prepTimeMin;
  /// Delivery: prep + delivery leg (minutes).
  final int? arrivesInMin;
  /// Pickup / dine-in prep readiness (minutes).
  final int? readyInMin;
  final double? distanceKm;
  final double? latitude;
  final double? longitude;
  final bool isBookable;
  final String? dineInAvailableLabel;
  final int? dineInTablesAvailable;
  final String? categoryLabel;
  final bool supportsDelivery;
  final bool supportsPickup;
  final bool supportsDineIn;

  BrowseRestaurant copyWith({
    double? distanceKm,
    String? distance,
    bool? supportsDelivery,
    bool? supportsPickup,
    bool? supportsDineIn,
  }) {
    return BrowseRestaurant(
      id: id,
      name: name,
      cuisine: cuisine,
      rating: rating,
      gradientStart: gradientStart,
      gradientEnd: gradientEnd,
      badge: badge,
      deliveryMin: deliveryMin,
      freeDelivery: freeDelivery,
      deliveryFee: deliveryFee,
      minOrder: minOrder,
      distance: distance ?? this.distance,
      imageUrl: imageUrl,
      reviewCount: reviewCount,
      reviewCountValue: reviewCountValue,
      hasRating: hasRating,
      area: area,
      isOpen: isOpen,
      prepTimeMin: prepTimeMin,
      arrivesInMin: arrivesInMin,
      readyInMin: readyInMin,
      distanceKm: distanceKm ?? this.distanceKm,
      latitude: latitude,
      longitude: longitude,
      isBookable: isBookable,
      dineInAvailableLabel: dineInAvailableLabel,
      dineInTablesAvailable: dineInTablesAvailable,
      categoryLabel: categoryLabel,
      supportsDelivery: supportsDelivery ?? this.supportsDelivery,
      supportsPickup: supportsPickup ?? this.supportsPickup,
      supportsDineIn: supportsDineIn ?? this.supportsDineIn,
    );
  }
}

class BrowseMenuItem {
  const BrowseMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.section,
    this.imageUrl,
    this.nameAr,
    this.descriptionAr,
    this.hasModifiers = false,
    this.badges = const [],
  });

  final String id;
  final String name;
  final String? nameAr;
  final String description;
  final String? descriptionAr;
  final String price;
  final String section;
  final String? imageUrl;
  /// True when product has option groups and/or add-ons that must be chosen
  /// on the product details page before adding to cart.
  final bool hasModifiers;
  /// Product restriction / handling badges from API (e.g. HIGH_VALUE, AGE_RESTRICTED).
  final List<String> badges;

  bool get isHighValue =>
      badges.any((b) => b.toUpperCase().replaceAll('-', '_') == 'HIGH_VALUE');

  bool get isAgeRestricted => badges.any(
        (b) => b.toUpperCase().replaceAll('-', '_') == 'AGE_RESTRICTED',
      );

  /// Active-locale product title (AR when set and locale is Arabic).
  String get localizedName {
    if (L10n.isArabic) {
      final ar = nameAr?.trim();
      if (ar != null && ar.isNotEmpty) return ar;
    }
    return name;
  }

  /// Active-locale product description.
  String get localizedDescription {
    if (L10n.isArabic) {
      final ar = descriptionAr?.trim();
      if (ar != null && ar.isNotEmpty) return ar;
    }
    return description;
  }
}

class BrowseSizeOption {
  const BrowseSizeOption({
    required this.label,
    required this.subtitle,
    this.extraPrice,
    this.id,
    this.imageUrl,
    this.isDefault = false,
    this.isAvailable = true,
    this.stockLabel,
  });

  final String? id;
  final String label;
  final String subtitle;
  final String? extraPrice;
  final String? imageUrl;
  final bool isDefault;
  final bool isAvailable;
  /// e.g. In stock / Low stock / Out of stock (list view).
  final String? stockLabel;

  bool get isIncluded =>
      extraPrice == null || (double.tryParse(extraPrice!) ?? 0) <= 0;

  String get priceDisplay {
    if (isIncluded) return 'Free';
    final p = extraPrice;
    if (p == null || p.isEmpty) return 'Free';
    return '+BHD $p';
  }

  /// Solid colour from `color:#RRGGBB` imageUrl (electronics colour swatches).
  Color? get swatchColor {
    final raw = imageUrl?.trim();
    if (raw == null || raw.isEmpty) return null;
    final m = RegExp(r'^color:#?([0-9A-Fa-f]{6})$').firstMatch(raw);
    if (m == null) return null;
    return Color(int.parse('FF${m.group(1)}', radix: 16));
  }

  bool get hasNetworkImage {
    final raw = imageUrl?.trim();
    if (raw == null || raw.isEmpty) return false;
    return swatchColor == null;
  }
}

class BrowseOptionGroup {
  const BrowseOptionGroup({
    required this.name,
    required this.minSelect,
    required this.maxSelect,
    required this.options,
    this.id,
  });

  final String? id;
  final String name;
  final int minSelect;
  final int maxSelect;
  final List<BrowseSizeOption> options;

  bool get allowsMultiple => maxSelect > 1;
  bool get isRequired => minSelect > 0;

  String get selectionHint {
    if (isRequired) {
      if (maxSelect <= 1) return 'Required · Select 1';
      if (minSelect == maxSelect) return 'Required · Select $minSelect';
      return 'Required · Select $minSelect–$maxSelect';
    }
    return 'Optional · Select up to $maxSelect';
  }
}

List<BrowseOptionGroup> browseOptionGroupsFromJson(Object? raw) {
  if (raw is! List) return const [];

  final groups = <BrowseOptionGroup>[];
  for (final group in raw) {
    if (group is! Map<String, dynamic>) continue;
    final optsRaw = group['options'];
    if (optsRaw is! List) continue;

    final options = <BrowseSizeOption>[];
    for (final opt in optsRaw) {
      if (opt is! Map<String, dynamic>) continue;
      final id = opt['id']?.toString();
      final name = opt['name'] as String? ?? 'Option';
      final delta = opt['priceDelta'];
      final deltaNum = delta is num ? delta.toDouble() : 0.0;
      final available = opt['isAvailable'] != false;
      final stockRaw = (opt['stockLabel'] as String?)?.trim();
      options.add(
        BrowseSizeOption(
          id: id,
          label: name,
          subtitle: deltaNum <= 0
              ? 'Free'
              : '+BHD ${deltaNum.toStringAsFixed(3)}',
          extraPrice: deltaNum > 0 ? deltaNum.toStringAsFixed(3) : null,
          imageUrl: resolveApiMediaUrl(opt['imageUrl'] as String?),
          isDefault: opt['isDefault'] == true && available,
          isAvailable: available,
          stockLabel: (stockRaw != null && stockRaw.isNotEmpty)
              ? stockRaw
              : (available ? 'In stock' : 'Out of stock'),
        ),
      );
    }
    if (options.isEmpty) continue;

    final minSelect =
        (group['minSelect'] as num?)?.toInt() ??
        (group['min'] as num?)?.toInt() ??
        0;
    final maxSelect =
        (group['maxSelect'] as num?)?.toInt() ??
        (group['max'] as num?)?.toInt() ??
        1;
    final name = (group['name'] as String?)?.trim();

    groups.add(
      BrowseOptionGroup(
        id: group['id']?.toString(),
        name: (name != null && name.isNotEmpty) ? name : 'Options',
        minSelect: minSelect,
        maxSelect: maxSelect,
        options: options,
      ),
    );
  }
  return groups;
}

Map<int, Set<int>> initialOptionSelections(List<BrowseOptionGroup> groups) {
  final selected = <int, Set<int>>{};
  for (var gi = 0; gi < groups.length; gi++) {
    final picks = <int>{};
    for (var oi = 0; oi < groups[gi].options.length; oi++) {
      if (groups[gi].options[oi].isDefault) picks.add(oi);
    }
    selected[gi] = picks;
  }
  return selected;
}

double optionSelectionsExtraPrice(
  List<BrowseOptionGroup> groups,
  Map<int, Set<int>> selected,
) {
  var total = 0.0;
  for (var gi = 0; gi < groups.length; gi++) {
    for (final oi in selected[gi] ?? const <int>{}) {
      if (oi < 0 || oi >= groups[gi].options.length) continue;
      total +=
          double.tryParse(groups[gi].options[oi].extraPrice ?? '') ?? 0.0;
    }
  }
  return total;
}

List<String> optionSelectionIds(
  List<BrowseOptionGroup> groups,
  Map<int, Set<int>> selected,
) {
  final ids = <String>[];
  for (var gi = 0; gi < groups.length; gi++) {
    for (final oi in selected[gi] ?? const <int>{}) {
      if (oi < 0 || oi >= groups[gi].options.length) continue;
      final id = groups[gi].options[oi].id;
      if (id != null && id.isNotEmpty) ids.add(id);
    }
  }
  return ids;
}

String? validateOptionSelections(
  List<BrowseOptionGroup> groups,
  Map<int, Set<int>> selected,
) {
  for (var gi = 0; gi < groups.length; gi++) {
    final group = groups[gi];
    final count = selected[gi]?.length ?? 0;
    if (count < group.minSelect) {
      return 'Select at least ${group.minSelect} for ${group.name}';
    }
    if (count > group.maxSelect) {
      return 'Select up to ${group.maxSelect} for ${group.name}';
    }
  }
  return null;
}

class BrowseAddonOption {
  const BrowseAddonOption({
    required this.label,
    required this.price,
    this.id,
    this.imageUrl,
  });

  final String? id;
  final String label;
  final String price;
  final String? imageUrl;

  String get priceLabel {
    final n = double.tryParse(price) ?? 0;
    if (n <= 0) return 'Included';
    return '+BHD ${n.toStringAsFixed(3)}';
  }
}

abstract final class BrowseData {
  static String get category => L10n.tr('Food');

  static const cuisineFilters = [
    'All',
    'Burgers',
    'Shawarma',
    'Indian',
    'Sushi',
  ];

  static const menuSections = ['Starters', 'Main Dishes', 'Desserts', 'Drinks'];

  static const orderAgainBrands = [
    ('McDonald\'s', Color(0xFFFFBC0D)),
    ('KFC', Color(0xFFE4002B)),
    ('Starbucks', Color(0xFF00704A)),
    ('Pizza Hut', Color(0xFFEE3124)),
    ('Burger King', Color(0xFFF5A623)),
  ];

  static const recentSearches = ['Burgers', 'Sushi', 'Coffee', 'Flowers'];

  static const restaurants = [
    BrowseRestaurant(
      id: 'green-kitchen',
      name: 'The Green Kitchen',
      cuisine: 'Lebanese · Mediterranean',
      rating: 4.9,
      gradientStart: Color(0xFF2C5A3A),
      gradientEnd: Color(0xFF15302B),
      freeDelivery: true,
      deliveryMin: 25,
      distance: '1.2 km away',
    ),
    BrowseRestaurant(
      id: 'burger-boss',
      name: 'Burger Boss',
      cuisine: 'American · Burgers',
      rating: 4.7,
      gradientStart: Color(0xFF7A4A22),
      gradientEnd: Color(0xFF15302B),
      badge: '25% off',
      deliveryMin: 20,
    ),
    BrowseRestaurant(
      id: 'seoul-kitchen',
      name: 'Seoul Kitchen',
      cuisine: 'Japanese · Sushi',
      rating: 4.8,
      gradientStart: Color(0xFF2E6E5B),
      gradientEnd: Color(0xFF15302B),
      badge: 'Buy 1 Get 1',
      deliveryMin: 30,
    ),
    BrowseRestaurant(
      id: 'pizza-roma',
      name: 'Pizza Roma',
      cuisine: 'Italian · Pizza',
      rating: 4.6,
      gradientStart: Color(0xFF8A3B2A),
      gradientEnd: Color(0xFF15302B),
      badge: '25% off',
      deliveryMin: 28,
    ),
    BrowseRestaurant(
      id: 'arabic-grills',
      name: 'Arabic Grills',
      cuisine: 'Arabic · Grills',
      rating: 4.5,
      gradientStart: Color(0xFF9A5B2A),
      gradientEnd: Color(0xFF15302B),
      freeDelivery: true,
      deliveryMin: 22,
    ),
  ];

  static const greenKitchenMenu = [
    BrowseMenuItem(
      id: 'mezze-platter',
      name: 'Gourmet Mezze Platter',
      description: 'Hummus, mutabal, vine leaves, falafel',
      price: '20.000',
      section: 'Starters',
    ),
    BrowseMenuItem(
      id: 'lamb-ouzi',
      name: 'Lamb Ouzi',
      description: 'Slow-roasted lamb with spiced rice',
      price: '28.000',
      section: 'Main Dishes',
    ),
    BrowseMenuItem(
      id: 'kunafa',
      name: 'Kunafa',
      description: 'Crispy pastry with sweet cheese',
      price: '8.000',
      section: 'Desserts',
    ),
    BrowseMenuItem(
      id: 'fresh-juice',
      name: 'Fresh Juice — Large',
      description: 'Orange, mango or mixed',
      price: '2.000',
      section: 'Drinks',
    ),
  ];

  static const mezzeSizes = [
    BrowseSizeOption(label: 'Regular — for 2', subtitle: 'Included'),
    BrowseSizeOption(
      label: 'Family — for 4',
      subtitle: '+ BHD 8.0',
      extraPrice: '8.0',
    ),
  ];

  static const mezzeAddons = [
    BrowseAddonOption(label: 'Extra pita bread', price: '0.5'),
    BrowseAddonOption(label: 'Garlic sauce', price: '0.3'),
  ];

  static const mezzeLongDescription =
      'A generous sharing platter of hummus, mutabal, stuffed vine leaves, '
      'falafel and warm pita.';

  static const cartItemCount = 3;
  static const cartTotal = '35.000';

  static BrowseRestaurant restaurantById(String id) {
    return restaurants.firstWhere(
      (r) => r.id == id,
      orElse: () => restaurants.first,
    );
  }

  static BrowseMenuItem menuItemById(String itemId) {
    return greenKitchenMenu.firstWhere(
      (item) => item.id == itemId,
      orElse: () => greenKitchenMenu.first,
    );
  }

  static List<BrowseRestaurant> restaurantsForFilter(String filter) {
    if (filter == 'All') return restaurants;
    return restaurants.where((r) {
      final text = '${r.name} ${r.cuisine}'.toLowerCase();
      return text.contains(filter.toLowerCase());
    }).toList();
  }

  static List<BrowseRestaurant> searchResults(String query) {
    final q = query.toLowerCase();
    if (q.isEmpty) return restaurants;
    return restaurants.where((r) {
      return r.name.toLowerCase().contains(q) ||
          r.cuisine.toLowerCase().contains(q) ||
          greenKitchenMenu.any((item) => item.name.toLowerCase().contains(q));
    }).toList();
  }
}
