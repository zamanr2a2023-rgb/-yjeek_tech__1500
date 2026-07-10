import 'package:flutter/material.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';

class BrandItem {
  const BrandItem({required this.name, required this.color});

  final String name;
  final Color color;
}

class OfferItem {
  const OfferItem({
    required this.name,
    required this.price,
    required this.imageColor,
  });

  final String name;
  final String price;
  final Color imageColor;
}

abstract final class HomeData {
  static const String userName = 'Asmaa';
  static const String deliveryLocation = 'Seef, Manama';

  static const List<CategoryItem> homeCategories = [
    CategoryItem(
      name: 'Cosmetics',
      icon: Icons.brush_outlined,
      backgroundColor: Color(0xFFFBE2EF),
    ),
    CategoryItem(
      name: 'Gifts',
      icon: Icons.card_giftcard_outlined,
      backgroundColor: Color(0xFFFCE8E4),
    ),
    CategoryItem(
      name: 'Fashion',
      icon: Icons.checkroom_outlined,
      backgroundColor: Color(0xFFE8E4F8),
    ),
    CategoryItem(
      name: 'Electronics',
      icon: Icons.devices_outlined,
      backgroundColor: Color(0xFFE2EEFB),
    ),
    CategoryItem(
      name: 'Food',
      icon: Icons.restaurant_outlined,
      backgroundColor: Color(0xFFFFF0D9),
    ),
    CategoryItem(
      name: 'Dine In',
      icon: Icons.local_dining_outlined,
      backgroundColor: Color(0xFFE3F2EB),
    ),
    CategoryItem(
      name: 'Services',
      icon: Icons.spa_outlined,
      backgroundColor: Color(0xFFEDE3FA),
    ),
    CategoryItem(
      name: 'Groceries',
      icon: Icons.shopping_basket_outlined,
      backgroundColor: Color(0xFFE3F5E8),
    ),
    CategoryItem(
      name: 'Pickup',
      icon: Icons.storefront_outlined,
      backgroundColor: Color(0xFFE8F4FC),
    ),
  ];

  static const List<CategoryItem> allCategories = [
    CategoryItem(
      name: 'Groceries',
      icon: Icons.shopping_basket_outlined,
      backgroundColor: Color(0xFFE3F5E8),
    ),
    CategoryItem(
      name: 'Pharmacy',
      icon: Icons.medical_services_outlined,
      backgroundColor: Color(0xFFE2EEFB),
    ),
    CategoryItem(
      name: 'Cosmetics',
      icon: Icons.brush_outlined,
      backgroundColor: Color(0xFFFBE2EF),
    ),
    CategoryItem(
      name: 'Vape',
      icon: Icons.cloud_outlined,
      backgroundColor: Color(0xFFE8E4F8),
    ),
    CategoryItem(
      name: 'Food',
      icon: Icons.restaurant_outlined,
      backgroundColor: Color(0xFFFFF0D9),
    ),
    CategoryItem(
      name: 'Dine In',
      icon: Icons.local_dining_outlined,
      backgroundColor: Color(0xFFE3F2EB),
    ),
    CategoryItem(
      name: 'Services',
      icon: Icons.spa_outlined,
      backgroundColor: Color(0xFFEDE3FA),
    ),
    CategoryItem(
      name: 'Pickup',
      icon: Icons.storefront_outlined,
      backgroundColor: Color(0xFFE8F4FC),
    ),
    CategoryItem(
      name: 'Gifts',
      icon: Icons.card_giftcard_outlined,
      backgroundColor: Color(0xFFFCE8E4),
    ),
    CategoryItem(
      name: 'Fashion',
      icon: Icons.checkroom_outlined,
      backgroundColor: Color(0xFFE8E4F8),
    ),
    CategoryItem(
      name: 'Electronics',
      icon: Icons.devices_outlined,
      backgroundColor: Color(0xFFE2EEFB),
    ),
    CategoryItem(
      name: 'Jewelry',
      icon: Icons.diamond_outlined,
      backgroundColor: Color(0xFFFFF5E0),
    ),
    CategoryItem(
      name: 'Stationery',
      icon: Icons.edit_note_outlined,
      backgroundColor: Color(0xFFEAF4FF),
    ),
    CategoryItem(
      name: 'Baby & Kids',
      icon: Icons.child_care_outlined,
      backgroundColor: Color(0xFFFBE8F3),
    ),
    CategoryItem(
      name: 'Sports',
      icon: Icons.sports_soccer_outlined,
      backgroundColor: Color(0xFFE4F7EA),
    ),
  ];

  static const List<BrandItem> orderAgainBrands = [
    BrandItem(name: '1002 Collection', color: Color(0xFF1A1A1A)),
    BrandItem(name: 'Floward', color: Color(0xFFE8489A)),
    BrandItem(name: 'Starbucks', color: Color(0xFF00704A)),
    BrandItem(name: 'Sharaf DG', color: Color(0xFF0066CC)),
  ];

  static const List<OfferItem> exclusiveOffers = [
    OfferItem(
      name: 'Apple AirPods Gen5',
      price: 'BHD 50.000',
      imageColor: Color(0xFFF5F5F5),
    ),
    OfferItem(
      name: 'Red Roses Bouquet',
      price: 'BHD 12.500',
      imageColor: Color(0xFFFCE8EC),
    ),
    OfferItem(
      name: 'Nike Air Max',
      price: 'BHD 89.000',
      imageColor: Color(0xFFE8F0FE),
    ),
  ];
}
