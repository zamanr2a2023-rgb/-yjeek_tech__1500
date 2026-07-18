import 'package:flutter/material.dart';

class ElectronicsStore {
  const ElectronicsStore({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.categories,
    required this.productCount,
    required this.gradientStart,
    required this.gradientEnd,
    this.freeDelivery = false,
  });

  final String id;
  final String name;
  final double rating;
  final String reviewCount;
  final String distance;
  final String categories;
  final int productCount;
  final Color gradientStart;
  final Color gradientEnd;
  final bool freeDelivery;
}

class ElectronicsProduct {
  const ElectronicsProduct({
    required this.id,
    required this.storeId,
    required this.name,
    required this.specs,
    required this.rating,
    required this.price,
    this.originalPrice,
    this.inStock = true,
    this.has5G = false,
    this.detailTitle,
    this.detailSubtitle,
    this.highlights = const [],
    this.storageOptions = const [],
    this.colorOptions = const [],
  });

  final String id;
  final String storeId;
  final String name;
  final String specs;
  final double rating;
  final String price;
  final String? originalPrice;
  final bool inStock;
  final bool has5G;
  final String? detailTitle;
  final String? detailSubtitle;
  final List<String> highlights;
  final List<ElectronicsStorageOption> storageOptions;
  final List<ElectronicsColorOption> colorOptions;
}

class ElectronicsStorageOption {
  const ElectronicsStorageOption({
    required this.label,
    this.extraPrice = 0,
  });

  final String label;
  final int extraPrice;
}

class ElectronicsColorOption {
  const ElectronicsColorOption({
    required this.color,
    this.selectedBorder = false,
  });

  final Color color;
  final bool selectedBorder;
}

abstract final class ElectronicsData {
  static const homeTitle = 'Electronics';
  static const searchHint = 'Search devices, brands…';
  static const storesSectionTitle = 'Stores near you';

  static const productFilters = [
    'All',
    'Under BHD 100',
    '5G',
    'In stock',
  ];

  static const stores = <ElectronicsStore>[
    ElectronicsStore(
      id: 'techhub-electronics',
      name: 'TechHub Electronics',
      rating: 4.8,
      reviewCount: '1.2k',
      distance: '1.4 km',
      categories: 'Phones · Laptops · Audio',
      productCount: 24,
      gradientStart: Color(0xFFE3F2EB),
      gradientEnd: Color(0xFFC8E6D4),
      freeDelivery: true,
    ),
    ElectronicsStore(
      id: 'gadget-galaxy',
      name: 'Gadget Galaxy',
      rating: 4.7,
      reviewCount: '860',
      distance: '2.1 km',
      categories: 'Phones · Wearables · Accessories',
      productCount: 18,
      gradientStart: Color(0xFFE8F0FA),
      gradientEnd: Color(0xFFD0E0F5),
    ),
    ElectronicsStore(
      id: 'gamezone',
      name: 'GameZone',
      rating: 4.9,
      reviewCount: '540',
      distance: '2.8 km',
      categories: 'Gaming · Consoles · Accessories',
      productCount: 15,
      gradientStart: Color(0xFFF3E8FF),
      gradientEnd: Color(0xFFE0D4F5),
    ),
  ];

  static const products = <ElectronicsProduct>[
    ElectronicsProduct(
      id: 'nova-12',
      storeId: 'techhub-electronics',
      name: 'Nova 12',
      specs: '6.5" · 128GB · 5G',
      rating: 4.7,
      price: '119',
      originalPrice: '149',
      has5G: true,
      detailTitle: 'Nova 12 smartphone',
      detailSubtitle: '★ 4.7 (812) · 6.5" AMOLED · 5G · 50MP camera',
      storageOptions: [
        ElectronicsStorageOption(label: '128GB · included'),
        ElectronicsStorageOption(label: '256GB · +BHD 30', extraPrice: 30),
      ],
      colorOptions: [
        ElectronicsColorOption(color: Color(0xFF1F2129), selectedBorder: true),
        ElectronicsColorOption(color: Color(0xFFCCD1DB)),
        ElectronicsColorOption(color: Color(0xFF33598C)),
      ],
      highlights: [
        '6.5" 120Hz AMOLED display',
        '5000mAh battery · 33W fast charge',
        'Triple 50MP camera system',
        '1-year Yjeek warranty included',
      ],
    ),
    ElectronicsProduct(
      id: 'aero-lite',
      storeId: 'techhub-electronics',
      name: 'Aero Lite',
      specs: '6.1" · 64GB',
      rating: 4.4,
      price: '69',
    ),
    ElectronicsProduct(
      id: 'pulse-buds-pro',
      storeId: 'techhub-electronics',
      name: 'Pulse Buds Pro',
      specs: 'Wireless · ANC',
      rating: 4.6,
      price: '28',
      originalPrice: '39',
    ),
    ElectronicsProduct(
      id: 'fitband-5',
      storeId: 'techhub-electronics',
      name: 'FitBand 5',
      specs: 'Smartwatch · GPS',
      rating: 4.5,
      price: '34',
    ),
    ElectronicsProduct(
      id: 'soundwave-mini',
      storeId: 'techhub-electronics',
      name: 'SoundWave mini',
      specs: 'BT speaker',
      rating: 4.6,
      price: '22',
    ),
  ];

  static ElectronicsStore storeById(String id) {
    return stores.firstWhere((store) => store.id == id);
  }

  static ElectronicsProduct productById(String id) {
    return products.firstWhere((product) => product.id == id);
  }

  static List<ElectronicsProduct> productsForStore(String storeId) {
    return products.where((product) => product.storeId == storeId).toList();
  }

  static List<ElectronicsProduct> productsForFilter(
    String storeId,
    String filter,
  ) {
    final items = productsForStore(storeId);
    return switch (filter) {
      'Under BHD 100' => items.where((item) {
          final price = int.tryParse(item.price) ?? 0;
          return price < 100;
        }).toList(),
      '5G' => items.where((item) => item.has5G).toList(),
      'In stock' => items.where((item) => item.inStock).toList(),
      _ => items,
    };
  }
}
