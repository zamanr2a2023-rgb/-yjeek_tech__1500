import 'package:flutter/material.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/features/home/model/home_data.dart';

/// Maps API category slug/name → existing home icon + color (no design change).
abstract final class HomeCategoryStyle {
  static const _styles = <String, (IconData, Color)>{
    'cosmetics': (Icons.brush_outlined, Color(0xFFFBE2EF)),
    'gifts': (Icons.card_giftcard_outlined, Color(0xFFFCE8E4)),
    'fashion': (Icons.checkroom_outlined, Color(0xFFE8E4F8)),
    'electronics': (Icons.devices_outlined, Color(0xFFE2EEFB)),
    'food': (Icons.restaurant_outlined, Color(0xFFFFF0D9)),
    'dine_in': (Icons.local_dining_outlined, Color(0xFFE3F2EB)),
    'dine-in': (Icons.local_dining_outlined, Color(0xFFE3F2EB)),
    'services': (Icons.spa_outlined, Color(0xFFEDE3FA)),
    'grocery': (Icons.shopping_basket_outlined, Color(0xFFE3F5E8)),
    'groceries': (Icons.shopping_basket_outlined, Color(0xFFE3F5E8)),
    'pickup': (Icons.storefront_outlined, Color(0xFFE8F4FC)),
    'vape': (Icons.cloud_outlined, Color(0xFFE8E4F8)),
    'pharmacy': (Icons.medical_services_outlined, Color(0xFFE2EEFB)),
    'jewelry': (Icons.diamond_outlined, Color(0xFFFFF5E0)),
    'stationery': (Icons.edit_note_outlined, Color(0xFFEAF4FF)),
    'baby-kids': (Icons.child_care_outlined, Color(0xFFFBE8F3)),
    'baby_kids': (Icons.child_care_outlined, Color(0xFFFBE8F3)),
    'sports': (Icons.sports_soccer_outlined, Color(0xFFE4F7EA)),
  };

  static const _fallback = (Icons.category_outlined, Color(0xFFE8F0FE));

  static (IconData, Color) forSlug(String? slug, String name) {
    final key = (slug ?? name).trim().toLowerCase().replaceAll(' ', '_');
    return _styles[key] ??
        _styles[name.trim().toLowerCase()] ??
        _fallback;
  }
}

/// Stable brand circle colors matching the existing Order-again look.
abstract final class HomeBrandStyle {
  static const _palette = <Color>[
    Color(0xFF1A1A1A),
    Color(0xFFE8489A),
    Color(0xFF00704A),
    Color(0xFF0066CC),
    Color(0xFFBC6C25),
    Color(0xFF2D6A4F),
    Color(0xFFC9184A),
    Color(0xFF6F4E37),
  ];

  static Color forName(String name) {
    var hash = 0;
    for (final code in name.codeUnits) {
      hash = 0x1fffffff & (hash + code);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= hash >> 6;
    }
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash ^= hash >> 11;
    return _palette[hash.abs() % _palette.length];
  }
}

abstract final class HomeOfferStyle {
  static const _palette = <Color>[
    Color(0xFFF5F5F5),
    Color(0xFFFCE8EC),
    Color(0xFFE8F0FE),
    Color(0xFFFFF0D9),
    Color(0xFFE3F2EB),
  ];

  static Color forName(String name) {
    var hash = 0;
    for (final code in name.codeUnits) {
      hash = (hash + code) & 0x7fffffff;
    }
    return _palette[hash % _palette.length];
  }

  static String formatPrice(num price) =>
      'BHD ${price.toStringAsFixed(3)}';
}

CategoryItem categoryItemFromApi({
  required String name,
  String? slug,
  String? id,
}) {
  final style = HomeCategoryStyle.forSlug(slug, name);
  return CategoryItem(
    id: id,
    slug: slug,
    name: name,
    icon: style.$1,
    backgroundColor: style.$2,
  );
}

BrandItem brandItemFromApi({
  required String name,
  String? id,
  String? logoUrl,
}) {
  return BrandItem(
    id: id,
    name: name,
    color: HomeBrandStyle.forName(name),
    logoUrl: logoUrl,
  );
}

OfferItem offerItemFromApi({
  required String name,
  required num offerPrice,
  String? imageUrl,
  String? badgeLabel,
}) {
  return OfferItem(
    name: name,
    price: HomeOfferStyle.formatPrice(offerPrice),
    imageColor: HomeOfferStyle.forName(name),
    imageUrl: imageUrl,
    badgeLabel: badgeLabel,
  );
}
