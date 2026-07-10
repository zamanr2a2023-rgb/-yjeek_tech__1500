import 'package:flutter/material.dart';

class VapeStore {
  const VapeStore({
    required this.id,
    required this.name,
    required this.shortName,
    required this.rating,
    required this.distance,
    required this.eta,
    this.subtitle,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final String id;
  final String name;
  final String shortName;
  final double rating;
  final String distance;
  final String eta;
  final String? subtitle;
  final Color gradientStart;
  final Color gradientEnd;
}

class VapeProduct {
  const VapeProduct({
    required this.id,
    required this.storeId,
    required this.name,
    required this.specs,
    required this.price,
    required this.category,
    this.detailSpecs,
    this.nicotineOptions = const ['20mg', '35mg', '50mg'],
    this.ageWarningDetail =
        '18+ only. Your CPR will be checked & photographed on delivery to confirm age and name.',
  });

  final String id;
  final String storeId;
  final String name;
  final String specs;
  final String price;
  final String category;
  final String? detailSpecs;
  final List<String> nicotineOptions;
  final String ageWarningDetail;
}

abstract final class VapeData {
  static const homeTitle = 'Vape';
  static const searchHint = 'Search vape stores & products…';
  static const storesSectionTitle = 'Stores near you';
  static const ageBannerShort = '18+ only · your ID is checked on delivery';
  static const nicotineStrengthLabel = 'Nicotine strength';

  static const categories = [
    'Disposables',
    'E-liquids',
    'Pods',
    'Devices',
  ];

  static const stores = <VapeStore>[
    VapeStore(
      id: 'vapeology-bahrain',
      name: 'Vapeology Bahrain',
      shortName: 'Vapeology',
      rating: 4.8,
      distance: '0.8 km',
      eta: '~25 min',
      gradientStart: Color(0xFFE8ECF5),
      gradientEnd: Color(0xFFD4DBEB),
    ),
    VapeStore(
      id: 'cloud9-vape-lounge',
      name: 'Cloud9 Vape Lounge',
      shortName: 'Cloud9',
      rating: 4.6,
      distance: '1.2 km',
      eta: '~30 min',
      gradientStart: Color(0xFFE3F0FA),
      gradientEnd: Color(0xFFC8DFF0),
    ),
    VapeStore(
      id: 'smoke-and-co',
      name: 'Smoke & Co.',
      shortName: 'Smoke & Co.',
      rating: 4.5,
      distance: '1.6 km',
      eta: '~35 min',
      subtitle: 'tobacco',
      gradientStart: Color(0xFFF0EDE8),
      gradientEnd: Color(0xFFE0D8CE),
    ),
  ];

  static const products = <VapeProduct>[
    VapeProduct(
      id: 'mango-ice-disposable',
      storeId: 'vapeology-bahrain',
      name: 'Mango Ice Disposable',
      specs: '2500 puffs · 20mg',
      detailSpecs: '2500 puffs · 20mg nicotine',
      price: '6.500',
      category: 'Disposables',
    ),
    VapeProduct(
      id: 'blue-razz-disposable',
      storeId: 'vapeology-bahrain',
      name: 'Blue Razz Disposable',
      specs: '2500 puffs · 20mg',
      detailSpecs: '2500 puffs · 20mg nicotine',
      price: '6.500',
      category: 'Disposables',
    ),
    VapeProduct(
      id: 'salt-nic-e-liquid',
      storeId: 'vapeology-bahrain',
      name: 'Salt Nic E-liquid 30ml',
      specs: '35mg · assorted',
      detailSpecs: '35mg · assorted flavours',
      price: '4.000',
      category: 'E-liquids',
      nicotineOptions: ['20mg', '35mg', '50mg'],
    ),
    VapeProduct(
      id: 'refill-pod-pack',
      storeId: 'vapeology-bahrain',
      name: 'Refill Pod Pack',
      specs: '2 pods · 18mg',
      price: '5.500',
      category: 'Pods',
    ),
    VapeProduct(
      id: 'starter-kit',
      storeId: 'vapeology-bahrain',
      name: 'Starter Kit Pro',
      specs: 'Device + charger',
      price: '18.000',
      category: 'Devices',
      nicotineOptions: [],
    ),
  ];

  static VapeStore storeById(String id) {
    return stores.firstWhere((store) => store.id == id);
  }

  static VapeProduct productById(String id) {
    return products.firstWhere((product) => product.id == id);
  }

  static List<VapeProduct> productsForStore(String storeId, String category) {
    return products
        .where((product) => product.storeId == storeId && product.category == category)
        .toList();
  }
}
