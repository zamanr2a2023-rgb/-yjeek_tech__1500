import 'package:flutter/material.dart';

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
}
