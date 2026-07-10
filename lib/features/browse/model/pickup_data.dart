import 'package:flutter/material.dart';

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
  static const String homeTitle = 'Pickup';
  static const String searchHint = 'Search pickup spots…';
  static const String browseByCategory = 'Browse by category';
  static const String viewAll = 'View all';
  static const String readyNearYou = 'Ready near you';
  static const String pickUpFromAnyCategory = 'Pick up from any category';
  static const String weeklySpotlight = 'WEEKLY SPOTLIGHT';
  static const String spotlightVendor = 'Green Artisan Bakery';
  static const String orderNow = 'Order Now';

  static const List<PickupCategory> featuredCategories = [
    PickupCategory(
      id: 'food',
      name: 'Food',
      icon: Icons.lunch_dining_outlined,
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
      backgroundColor: Color(0xFFFCE8E4),
    ),
  ];

  static const List<PickupCategory> allCategories = [
    PickupCategory(
      id: 'food',
      name: 'Food',
      icon: Icons.lunch_dining_outlined,
      backgroundColor: Color(0xFFFFE7D6),
    ),
    PickupCategory(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.shopping_basket_outlined,
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
      icon: Icons.sports_soccer_outlined,
      backgroundColor: Color(0xFFE8F4FC),
    ),
    PickupCategory(
      id: 'cosmetics',
      name: 'Cosmetics',
      icon: Icons.face_retouching_natural_outlined,
      backgroundColor: Color(0xFFFBE2EF),
    ),
    PickupCategory(
      id: 'gifts',
      name: 'Gifts',
      icon: Icons.card_giftcard_outlined,
      backgroundColor: Color(0xFFFCE8E4),
    ),
    PickupCategory(
      id: 'fashion',
      name: 'Fashion',
      icon: Icons.checkroom_outlined,
      backgroundColor: Color(0xFFE8E4F8),
    ),
    PickupCategory(
      id: 'electronics',
      name: 'Electronics',
      icon: Icons.devices_outlined,
      backgroundColor: Color(0xFFE2EEFB),
    ),
    PickupCategory(
      id: 'jewelry',
      name: 'Jewelry',
      icon: Icons.diamond_outlined,
      backgroundColor: Color(0xFFFFF0D9),
    ),
    PickupCategory(
      id: 'stationery',
      name: 'Stationery',
      icon: Icons.edit_note_outlined,
      backgroundColor: Color(0xFFE3F5E8),
    ),
    PickupCategory(
      id: 'baby-kids',
      name: 'Baby & Kids',
      icon: Icons.child_care_outlined,
      backgroundColor: Color(0xFFEDE3FA),
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
      imageColor: Color(0xFFE8F5E9),
    ),
    PickupSpot(
      id: 'green-kitchen',
      name: 'The Green Kitchen',
      rating: 4.9,
      categoryLabel: 'Healthy',
      distance: '0.6 km',
      pickupEta: '~12 min',
      imageColor: Color(0xFFE3F2EB),
    ),
    PickupSpot(
      id: 'lulu-express',
      name: 'Lulu Express',
      rating: 4.5,
      categoryLabel: 'Grocery',
      distance: '0.9 km',
      pickupEta: '~15 min',
      imageColor: Color(0xFFE8F4FC),
    ),
    PickupSpot(
      id: 'city-pharmacy',
      name: 'City Pharmacy',
      rating: 4.7,
      categoryLabel: 'Pharmacy',
      distance: '1.1 km',
      pickupEta: '~10 min',
      imageColor: Color(0xFFE2EEFB),
    ),
  ];
}
