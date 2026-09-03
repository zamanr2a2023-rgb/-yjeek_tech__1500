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
  });

  final String? id;
  final String? slug;
  final String name;
  final IconData icon;
  final Color backgroundColor;
  final String? iconUrl;

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

