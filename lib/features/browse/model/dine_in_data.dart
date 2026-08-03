import 'package:flutter/material.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';

enum DineInVenueStatus { open, closed, bookable }

class DineInRestaurant {
  const DineInRestaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.gradientStart,
    required this.gradientEnd,
    this.badge,
    this.distance = '1.2 km',
    this.status = DineInVenueStatus.open,
    this.subtitle,
    this.reviewCount = '2.5k',
    this.tableMin = 2,
    this.statusLabel = 'Open now',
    this.modeLabel = 'Dine-in',
    this.entryLabel = 'Walk-in',
    this.imageUrl,
  });

  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final Color gradientStart;
  final Color gradientEnd;
  final String? badge;
  final String distance;
  final DineInVenueStatus status;
  final String? subtitle;
  final String reviewCount;
  final int tableMin;
  final String statusLabel;
  final String modeLabel;
  final String entryLabel;
  final String? imageUrl;
}

class DineInVisit {
  const DineInVisit({
    required this.restaurantId,
    required this.restaurantName,
    required this.itemsSummary,
    required this.visitMeta,
    required this.total,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final String restaurantId;
  final String restaurantName;
  final String itemsSummary;
  final String visitMeta;
  final String total;
  final Color gradientStart;
  final Color gradientEnd;
}

abstract final class DineInData {
  static const category = 'Dine-in';

  static const cuisineFilters = ['All', 'Lebanese', 'Grills', 'Seafood', 'Italian'];

  static const orderAgainFilters = ['All', 'Lunch', 'Dinner', 'Cafes'];

  static const menuSections = ['Starters', 'Main Dishes', 'Desserts', 'Drinks'];

  static const defaultRestaurantId = 'veera';

  static const restaurants = [
    DineInRestaurant(
      id: 'veera',
      name: 'VEERA',
      cuisine: 'Lebanese',
      rating: 4.9,
      gradientStart: Color(0xFF2E5E4A),
      gradientEnd: Color(0xFF15302B),
      badge: '15% off',
      distance: '1.2 km',
      subtitle: 'Lebanese · Mediterranean',
      reviewCount: '2.5k',
    ),
    DineInRestaurant(
      id: 'olea-terrace',
      name: 'Olea Terrace',
      cuisine: 'Lebanese',
      rating: 4.6,
      gradientStart: Color(0xFF3A5A2C),
      gradientEnd: Color(0xFF15302B),
      badge: 'Bookable',
      distance: '1.5 km',
      status: DineInVenueStatus.bookable,
      subtitle: 'Lebanese · Terrace',
    ),
    DineInRestaurant(
      id: 'sakura-house',
      name: 'Sakura House',
      cuisine: 'Japanese',
      rating: 4.8,
      gradientStart: Color(0xFF5A2A3A),
      gradientEnd: Color(0xFF15302B),
      badge: '20% off',
      distance: '2.4 km',
      subtitle: 'Japanese · Sushi',
    ),
    DineInRestaurant(
      id: 'cedar-lounge',
      name: 'Cedar Lounge',
      cuisine: 'Lebanese',
      rating: 4.7,
      gradientStart: Color(0xFF2C5A3A),
      gradientEnd: Color(0xFF15302B),
      badge: 'Happy hour',
      distance: '1.8 km',
      subtitle: 'Lebanese · Lounge',
    ),
    DineInRestaurant(
      id: 'marine-co',
      name: 'Marine & Co',
      cuisine: 'Seafood',
      rating: 4.8,
      gradientStart: Color(0xFF7A4A22),
      gradientEnd: Color(0xFF15302B),
      badge: '15% off',
      distance: '2.1 km',
      status: DineInVenueStatus.bookable,
      subtitle: 'Seafood · Grill',
    ),
    DineInRestaurant(
      id: 'sushi-yama',
      name: 'Sushi Yama',
      cuisine: 'Japanese',
      rating: 4.7,
      gradientStart: Color(0xFF4A2040),
      gradientEnd: Color(0xFF1A0A18),
      badge: 'Free dessert',
      distance: '3.4 km',
      subtitle: 'Japanese · Sushi',
    ),
    DineInRestaurant(
      id: 'roma-trattoria',
      name: 'Roma Trattoria',
      cuisine: 'Italian',
      rating: 4.6,
      gradientStart: Color(0xFF8B3030),
      gradientEnd: Color(0xFF3A1010),
      badge: '15% off',
      distance: '1.8 km',
      subtitle: 'Italian · Casual',
    ),
    DineInRestaurant(
      id: 'grill-house',
      name: 'Grill House',
      cuisine: 'Grills',
      rating: 4.5,
      gradientStart: Color(0xFF5C3A1E),
      gradientEnd: Color(0xFF2A1810),
      distance: '4.0 km',
      status: DineInVenueStatus.closed,
      subtitle: 'Grills · BBQ',
    ),
  ];

  static const veeraMenu = [
    BrowseMenuItem(
      id: 'mezze-platter',
      name: 'Gourmet Mezze Platter',
      description: 'Hummus, mutabal, vine leaves, falafel',
      price: '20.000',
      section: 'Starters',
    ),
    BrowseMenuItem(
      id: 'lamb-chops',
      name: 'Grilled Lamb Chops',
      description: 'Charcoal grilled with herbs and garlic',
      price: '24.000',
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
      id: 'mint-lemonade',
      name: 'Fresh Mint Lemonade',
      description: 'House-made, large',
      price: '3.000',
      section: 'Drinks',
    ),
  ];

  static const mezzeSizes = [
    BrowseSizeOption(label: 'Regular — for 2', subtitle: 'Included'),
    BrowseSizeOption(label: 'Family — for 4', subtitle: '+ BHD 8.0', extraPrice: '8.0'),
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

  static const recentVisits = [
    DineInVisit(
      restaurantId: 'green-kitchen',
      restaurantName: 'The Green Kitchen',
      itemsSummary: 'Mezze Platter • Mixed Grill',
      visitMeta: 'Table for 2 · 2 days ago',
      total: 'BHD 22.000',
      gradientStart: Color(0xFF3D6B4F),
      gradientEnd: Color(0xFF1A3028),
    ),
    DineInVisit(
      restaurantId: 'veera',
      restaurantName: 'VEERA',
      itemsSummary: 'Gourmet Mezze • Lamb Chops',
      visitMeta: 'Table for 3 · last week',
      total: 'BHD 38.000',
      gradientStart: Color(0xFF2E5E4A),
      gradientEnd: Color(0xFF15302B),
    ),
    DineInVisit(
      restaurantId: 'sushi-yama',
      restaurantName: 'Sushi Yama',
      itemsSummary: 'Sushi Platter • Miso Soup',
      visitMeta: 'Table for 2 · last week',
      total: 'BHD 24.500',
      gradientStart: Color(0xFF4A2040),
      gradientEnd: Color(0xFF1A0A18),
    ),
    DineInVisit(
      restaurantId: 'marine-co',
      restaurantName: 'Marine & Co',
      itemsSummary: 'Grilled Fish • Seafood Rice',
      visitMeta: 'Table for 4 · 2 weeks ago',
      total: 'BHD 56.000',
      gradientStart: Color(0xFF1A4A6E),
      gradientEnd: Color(0xFF0D2840),
    ),
    DineInVisit(
      restaurantId: 'brew-bean',
      restaurantName: 'Brew & Bean',
      itemsSummary: 'Avocado Toast • Flat White',
      visitMeta: 'Table for 2 · 3 weeks ago',
      total: 'BHD 9.500',
      gradientStart: Color(0xFF6B4423),
      gradientEnd: Color(0xFF2E1A0E),
    ),
  ];

  static DineInRestaurant restaurantById(String id) {
    return restaurants.firstWhere(
      (r) => r.id == id,
      orElse: () => restaurants.first,
    );
  }

  static BrowseMenuItem menuItemById(String itemId) {
    return veeraMenu.firstWhere(
      (item) => item.id == itemId,
      orElse: () => veeraMenu.first,
    );
  }

  static List<DineInRestaurant> restaurantsForFilter(String filter) {
    if (filter == 'All') return restaurants;
    return restaurants.where((r) {
      return r.cuisine.toLowerCase().contains(filter.toLowerCase()) ||
          (r.subtitle?.toLowerCase().contains(filter.toLowerCase()) ?? false);
    }).toList();
  }

  static List<DineInVisit> visitsForFilter(String filter) {
    if (filter == 'All') return recentVisits;
    if (filter == 'Cafes') {
      return recentVisits.where((v) => v.restaurantName == 'Brew & Bean').toList();
    }
    return recentVisits;
  }
}
