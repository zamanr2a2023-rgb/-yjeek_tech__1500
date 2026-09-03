import 'package:flutter/material.dart';

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
  });

  final String id;
  final String name;
  final String? nameAr;
  final String description;
  final String? descriptionAr;
  final String price;
  final String section;
  final String? imageUrl;

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
    this.isDefault = false,
  });

  final String? id;
  final String label;
  final String subtitle;
  final String? extraPrice;
  final bool isDefault;
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
      options.add(
        BrowseSizeOption(
          id: id,
          label: name,
          subtitle: deltaNum <= 0
              ? 'Included'
              : '+ BHD ${deltaNum.toStringAsFixed(1)}',
          extraPrice: deltaNum > 0 ? deltaNum.toStringAsFixed(3) : null,
          isDefault: opt['isDefault'] == true,
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
  });

  final String? id;
  final String label;
  final String price;
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
