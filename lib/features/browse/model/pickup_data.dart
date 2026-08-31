import 'package:flutter/material.dart';
import 'package:yjeek_app/l10n/l10n.dart';

class PickupCategory {
  const PickupCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.backgroundColor,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color backgroundColor;
}

class PickupSpot {
  const PickupSpot({
    required this.id,
    required this.name,
    required this.rating,
    required this.categoryLabel,
    required this.distance,
    required this.pickupEta,
    this.promoLabel,
    this.imageColor = const Color(0xFFE3F2EB),
  });

  final String id;
  final String name;
  final double rating;
  final String categoryLabel;
  final String distance;
  final String pickupEta;
  final String? promoLabel;
  final Color imageColor;
}

abstract final class PickupData {
  static String get homeTitle => L10n.tr('Pickup');
  static String get searchHint => L10n.tr('Search pickup spots…');
  static String get browseByCategory => L10n.tr('Browse by category');
  static String get viewAll => L10n.tr('View all');
  static String get readyNearYou => L10n.tr('Ready near you');
  static String get pickUpFromAnyCategory => L10n.tr('Pick up from any category');
  static String get weeklySpotlight => L10n.tr('WEEKLY SPOTLIGHT');
  static String get spotlightVendor => L10n.tr('Green Artisan Bakery');
  static String get orderNow => L10n.tr('Order Now');

  static const List<PickupCategory> featuredCategories = [
    PickupCategory(
      id: 'food',
      name: 'Food',
      icon: Icons.lunch_dining,
      backgroundColor: Color(0xFFFFE7D6),
    ),
    PickupCategory(
      id: 'grocery',
      name: 'Grocery',
      icon: Icons.shopping_bag_outlined,
      backgroundColor: Color(0xFFD6F0EA),
    ),
    PickupCategory(
      id: 'pharmacy',
      name: 'Pharmacy',
      icon: Icons.medication_outlined,
      backgroundColor: Color(0xFFE2EEFB),
    ),
    PickupCategory(
      id: 'beauty',
      name: 'Beauty',
      icon: Icons.brush_outlined,
      backgroundColor: Color(0xFFFBE2EF),
    ),
    PickupCategory(
      id: 'gifts',
      name: 'Gifts',
      icon: Icons.card_giftcard_outlined,
      backgroundColor: Color(0xFFFBE1E3),
    ),
  ];

  // Figma PK6 tile fills (authoritative).
  static const List<PickupCategory> allCategories = [
    PickupCategory(
      id: 'food',
      name: 'Food',
      icon: Icons.lunch_dining,
      backgroundColor: Color(0xFFFFE7D6),
    ),
    PickupCategory(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.shopping_bag_outlined,
      backgroundColor: Color(0xFFD6F0EA),
    ),
    PickupCategory(
      id: 'pharmacy',
      name: 'Pharmacy',
      icon: Icons.medication_outlined,
      backgroundColor: Color(0xFFE2EEFB),
    ),
    PickupCategory(
      id: 'sports',
      name: 'Sports',
      icon: Icons.sports_tennis,
      backgroundColor: Color(0xFFE7F2D4),
    ),
    PickupCategory(
      id: 'cosmetics',
      name: 'Cosmetics',
      icon: Icons.brush_outlined,
      backgroundColor: Color(0xFFFBE2EF),
    ),
    PickupCategory(
      id: 'gifts',
      name: 'Gifts',
      icon: Icons.card_giftcard_outlined,
      backgroundColor: Color(0xFFFBE1E3),
    ),
    PickupCategory(
      id: 'fashion',
      name: 'Fashion',
      icon: Icons.checkroom_outlined,
      backgroundColor: Color(0xFFECE6FB),
    ),
    PickupCategory(
      id: 'electronics',
      name: 'Electronics',
      icon: Icons.headphones_outlined,
      backgroundColor: Color(0xFFE6E9F2),
    ),
    PickupCategory(
      id: 'jewelry',
      name: 'Jewelry',
      icon: Icons.diamond_outlined,
      backgroundColor: Color(0xFFE6F3FA),
    ),
    PickupCategory(
      id: 'stationery',
      name: 'Stationery',
      icon: Icons.edit_outlined,
      backgroundColor: Color(0xFFFBEFD0),
    ),
    PickupCategory(
      id: 'baby-kids',
      name: 'Baby & Kids',
      icon: Icons.toys_outlined,
      backgroundColor: Color(0xFFFCE8E0),
    ),
  ];

  static const List<PickupSpot> nearbySpots = [
    PickupSpot(
      id: 'brew-bean',
      name: 'Brew & Bean',
      rating: 4.8,
      categoryLabel: 'Coffee',
      distance: '0.4 km',
      pickupEta: '~8 min',
      promoLabel: '15% off pickup',
      imageColor: Color(0xFFEAF3DE),
    ),
    PickupSpot(
      id: 'green-kitchen',
      name: 'The Green Kitchen',
      rating: 4.9,
      categoryLabel: 'Healthy',
      distance: '0.6 km',
      pickupEta: '~12 min',
      imageColor: Color(0xFFEAF3DE),
    ),
    PickupSpot(
      id: 'lulu-express',
      name: 'Lulu Express',
      rating: 4.5,
      categoryLabel: 'Grocery',
      distance: '0.9 km',
      pickupEta: '~15 min',
      imageColor: Color(0xFFEAF3DE),
    ),
    PickupSpot(
      id: 'city-pharmacy',
      name: 'City Pharmacy',
      rating: 4.7,
      categoryLabel: 'Pharmacy',
      distance: '1.1 km',
      pickupEta: '~10 min',
      imageColor: Color(0xFFEAF3DE),
    ),
  ];
}
