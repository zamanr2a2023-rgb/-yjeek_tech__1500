import 'package:flutter/material.dart';
import 'package:yjeek_app/l10n/l10n.dart';

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
    this.hasRating = false,
    this.area,
    this.imageUrl,
    this.logoUrl,
    this.offerBadge,
    this.categoryLabel,
    this.minOrderAmount,
    this.supportsDelivery = false,
    this.supportsScheduled = false,
    this.deliveryFee,
    this.deliveryTimeMin,
    this.deliveryRadiusKm,
    this.distanceKm,
    this.latitude,
    this.longitude,
    this.scheduledDeliveryFee,
    this.scheduledMinOrderAmount,
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
  /// True only when backend has real customer reviews.
  final bool hasRating;
  final String? area;
  final String? imageUrl;
  final String? logoUrl;
  final String? offerBadge;
  /// Store type / category label from backend (e.g. Fashion).
  final String? categoryLabel;
  /// Branch min order; null/0 → "No minimum order".
  final double? minOrderAmount;
  final bool supportsDelivery;
  final bool supportsScheduled;
  final double? deliveryFee;
  final int? deliveryTimeMin;
  final double? deliveryRadiusKm;
  final double? distanceKm;
  final double? latitude;
  final double? longitude;
  /// Scheduled shipping fee (pharmacy Figma); falls back to [deliveryFee].
  final double? scheduledDeliveryFee;
  final double? scheduledMinOrderAmount;

  bool get isPharmacy {
    final c = '${categoryLabel ?? ''} $categories'.toLowerCase();
    return c.contains('pharm');
  }

  /// Dual Deliver Now + Scheduled (pharmacy.md).
  bool get hasPharmacyDeliveryModes => isPharmacy;

  /// Inside on-demand radius when distance unknown → treat as available.
  bool get onDemandInRadius {
    if (!supportsDelivery && !isPharmacy) return false;
    final dist = distanceKm;
    final radius = deliveryRadiusKm ?? 10;
    if (dist == null) return true;
    return dist <= radius;
  }

  /// Branch area from vendor settings (no distance fallback).
  String get areaLabel {
    final a = area?.trim();
    return (a != null && a.isNotEmpty) ? a : '';
  }

  String get locationLabel {
    final a = areaLabel;
    if (a.isNotEmpty) return a;
    return distance;
  }

  String get typeAreaLabel {
    final type = (categoryLabel ?? categories).trim();
    final a = areaLabel;
    if (type.isNotEmpty && a.isNotEmpty) return '$type · $a';
    if (type.isNotEmpty) return type;
    return a;
  }

  String get minOrderDisplay {
    final v = minOrderAmount;
    if (v == null || v <= 0) return 'No minimum order';
    final label = v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(3);
    return 'BHD $label';
  }

  bool get hasMinOrder {
    final v = minOrderAmount;
    return v != null && v > 0;
  }

  ElectronicsStore copyWith({
    String? categoryLabel,
    double? distanceKm,
    double? minOrderAmount,
  }) {
    return ElectronicsStore(
      id: id,
      name: name,
      rating: rating,
      reviewCount: reviewCount,
      distance: distance,
      categories: categories,
      productCount: productCount,
      gradientStart: gradientStart,
      gradientEnd: gradientEnd,
      freeDelivery: freeDelivery,
      hasRating: hasRating,
      area: area,
      imageUrl: imageUrl,
      logoUrl: logoUrl,
      offerBadge: offerBadge,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      supportsDelivery: supportsDelivery,
      supportsScheduled: supportsScheduled,
      deliveryFee: deliveryFee,
      deliveryTimeMin: deliveryTimeMin,
      deliveryRadiusKm: deliveryRadiusKm,
      distanceKm: distanceKm ?? this.distanceKm,
      latitude: latitude,
      longitude: longitude,
      scheduledDeliveryFee: scheduledDeliveryFee,
      scheduledMinOrderAmount: scheduledMinOrderAmount,
    );
  }
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
    this.id,
  });

  final String? id;
  final String label;
  final int extraPrice;
}

class ElectronicsColorOption {
  const ElectronicsColorOption({
    required this.color,
    this.selectedBorder = false,
    this.id,
  });

  final String? id;
  final Color color;
  final bool selectedBorder;
}

abstract final class ElectronicsData {
  static String get homeTitle => L10n.tr('Electronics');
  static String get searchHint => L10n.tr('Search devices, brands…');
  static String get storesSectionTitle => L10n.tr('Stores near you');

  static String titleForCategory(String category) {
    return L10n.tr(switch (category.toLowerCase()) {
      'fashion' => 'Fashion',
      'flowers' || 'florist' => 'Flowers',
      'grocery' || 'groceries' => 'Groceries',
      'prosthetics' => 'Prosthetics',
      'pharmacy' => 'Pharmacy',
      'cosmetics' => 'Cosmetics',
      'gifts' || 'gift' => 'Gifts',
      'jewelry' || 'jewellery' => 'Jewelry',
      'stationery' => 'Stationery',
      'baby-kids' || 'baby_kids' => 'Baby & Kids',
      'sports' || 'sport' => 'Sports',
      _ => 'Electronics',
    });
  }

  static String searchHintForCategory(String category) {
    return L10n.tr(switch (category.toLowerCase()) {
      'fashion' => 'Search categories & vendors…',
      'flowers' || 'florist' => 'Search categories & vendors…',
      'grocery' || 'groceries' => 'Search groceries, stores…',
      'prosthetics' => 'Search products, brands…',
      'pharmacy' => 'Search categories & vendors…',
      'cosmetics' => 'Search beauty, brands…',
      'gifts' || 'gift' => 'Search categories & vendors…',
      'jewelry' || 'jewellery' => 'Search jewelry, brands…',
      'stationery' => 'Search stationery, stores…',
      'baby-kids' || 'baby_kids' => 'Search baby & kids…',
      'sports' || 'sport' => 'Search sports, brands…',
      _ => 'Search devices, brands…',
    });
  }

  static String categoryFallbackLabel(String category) {
    return titleForCategory(category);
  }

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
