import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem({
    required this.name,
    required this.icon,
    required this.backgroundColor,
  });

  final String name;
  final IconData icon;
  final Color backgroundColor;
}
