import 'package:flutter/material.dart';
import 'package:yjeek_app/l10n/l10n.dart';

class CategoryItem {
  const CategoryItem({
    required this.name,
    required this.icon,
    required this.backgroundColor,
    this.id,
    this.slug,
  });

  final String? id;
  final String? slug;
  final String name;
  final IconData icon;
  final Color backgroundColor;

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
}

