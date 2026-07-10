import 'package:flutter/material.dart';

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
}

class BrowseMenuItem {
  const BrowseMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.section,
  });

  final String id;
  final String name;
  final String description;
  final String price;
  final String section;
}

class BrowseSizeOption {
  const BrowseSizeOption({
    required this.label,
    required this.subtitle,
    this.extraPrice,
  });

  final String label;
  final String subtitle;
  final String? extraPrice;
}

class BrowseAddonOption {
  const BrowseAddonOption({required this.label, required this.price});

  final String label;
  final String price;
}

abstract final class BrowseData {
  static const category = 'Food';

  static const cuisineFilters = ['All', 'Burgers', 'Shawarma', 'Indian', 'Sushi'];

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
      gradientStart: Color(0xFF7A4A22),
      gradientEnd: Color(0xFF15302B),
      freeDelivery: true,
      deliveryMin: 25,
    ),
    BrowseRestaurant(
      id: 'burger-boss',
      name: 'Burger Boss',
      cuisine: 'American · Burgers',
      rating: 4.7,
      gradientStart: Color(0xFF8B4513),
      gradientEnd: Color(0xFF2C1810),
      badge: '25% off',
      deliveryMin: 20,
    ),
    BrowseRestaurant(
      id: 'seoul-kitchen',
      name: 'Seoul Kitchen',
      cuisine: 'Japanese · Sushi',
      rating: 4.8,
      gradientStart: Color(0xFF1A3A5C),
      gradientEnd: Color(0xFF0D1F33),
      badge: 'Buy 1 Get 1',
      deliveryMin: 30,
    ),
    BrowseRestaurant(
      id: 'pizza-roma',
      name: 'Pizza Roma',
      cuisine: 'Italian · Pizza',
      rating: 4.6,
      gradientStart: Color(0xFFB83232),
      gradientEnd: Color(0xFF4A1515),
      badge: '25% off',
      deliveryMin: 28,
    ),
    BrowseRestaurant(
      id: 'arabic-grills',
      name: 'Arabic Grills',
      cuisine: 'Arabic · Grills',
      rating: 4.5,
      gradientStart: Color(0xFF6B4423),
      gradientEnd: Color(0xFF2A1810),
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
    BrowseSizeOption(label: 'Family — for 4', subtitle: '+ BHD 8.0', extraPrice: '8.0'),
  ];

  static const mezzeAddons = [
    BrowseAddonOption(label: 'Extra pita bread', price: '0.5'),
    BrowseAddonOption(label: 'Extra hummus', price: '1.0'),
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
          greenKitchenMenu.any(
            (item) => item.name.toLowerCase().contains(q),
          );
    }).toList();
  }
}
