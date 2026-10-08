import 'package:flutter/material.dart';
import 'package:yjeek_app/l10n/l10n.dart';

class CategoryItem {
  const CategoryItem({
    required this.name,
    required this.icon,
    required this.backgroundColor,
    this.id,
    this.slug,
    this.iconUrl,
    this.structure,
    this.kind,
  });

  final String? id;
  final String? slug;
  final String name;
  final IconData icon;
  final Color backgroundColor;
  final String? iconUrl;

  /// Store Management catalog structure: SINGLE or TWO_LEVEL.
  final String? structure;

  /// Taxonomy kind from admin (`STORE_TYPE`, `ORDER_MODE`, …).
  final String? kind;

  bool get twoLevel => structure?.trim().toUpperCase() == 'TWO_LEVEL';

  bool get hasNetworkIcon => iconUrl != null && iconUrl!.trim().isNotEmpty;

  /// Category label in the active app language.
  String get localizedName {
    switch (name.trim().toLowerCase()) {
      case 'dine in':
      case 'dine-in':
        return L10n.tr('Dine-in');
      default:
        return L10n.tr(name);
    }
  }

  /// Label for compact tiles — short aliases where needed, else [localizedName].
  String get displayName {
    final key = (slug ?? name)
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    switch (key) {
      case 'technology':
      case 'technologies':
        return L10n.tr('Tech');
      case 'electronics':
        return L10n.tr('Electronics');
      case 'cosmetics':
        return L10n.tr('Cosmetics');
      case 'gifts_flowers':
      case 'gifts_&_flowers':
      case 'gifts_and_flowers':
        return L10n.tr('Gifts & Flowers');
      case 'health_wellness':
      case 'health_&_wellness':
        return L10n.tr('Health & Wellness');
      case 'jewelry_watches':
      case 'jewelry_&_watches':
        return L10n.tr('Jewelry & Watches');
      case 'prosthetics':
        return L10n.tr('Prosthetics');
      case 'stationery':
        return L10n.tr('Stationery');
      case 'baby_kids':
      case 'baby_kid':
        return L10n.tr('Baby & Kids');
      default:
        return localizedName;
    }
  }
}

