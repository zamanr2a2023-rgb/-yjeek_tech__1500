import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';

/// Shared home + Categories screen routing (no UI change).
void openHomeCategory(BuildContext context, CategoryItem category) {
  final key = (category.slug ?? category.name).toLowerCase().trim();
  final slug = (category.slug ?? '').toLowerCase().trim();

  if (key.contains('food') && !key.contains('baby')) {
    context.push(BrowseRoutes.foodBrowse());
    return;
  }
  if (key.contains('dine')) {
    context.push(BrowseRoutes.dineInBrowse());
    return;
  }
  if (key.contains('service')) {
    context.push(BrowseRoutes.servicesBrowse());
    return;
  }
  if (key.contains('electronic')) {
    context.push(BrowseRoutes.electronicsBrowse());
    return;
  }
  if (key.contains('vape')) {
    context.push(BrowseRoutes.vapeBrowse());
    return;
  }
  if (key.contains('pickup')) {
    context.push(BrowseRoutes.pickupBrowse());
    return;
  }

  // Scheduled / retail categories — reuse browse layout with category filter.
  final scheduledSlug = switch (slug) {
    'grocery' || 'groceries' => 'grocery',
    'fashion' => 'fashion',
    'prosthetics' || 'prosthetic' => 'prosthetics',
    'pharmacy' => 'pharmacy',
    'cosmetics' => 'cosmetics',
    'gifts' || 'gift' => 'gifts',
    'jewelry' || 'jewellery' => 'jewelry',
    'stationery' => 'stationery',
    'baby-kids' || 'baby_kids' || 'baby' => 'baby-kids',
    'sports' || 'sport' => 'sports',
    _ => null,
  };

  if (scheduledSlug != null) {
    context.push(BrowseRoutes.electronicsBrowse(category: scheduledSlug));
    return;
  }

  // Name-based fallback when slug is missing/odd.
  if (key.contains('grocery') || key.contains('grocer')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'grocery'));
  } else if (key.contains('fashion')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'fashion'));
  } else if (key.contains('prosthetic')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'prosthetics'));
  } else if (key.contains('pharmacy')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'pharmacy'));
  } else if (key.contains('cosmetic')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'cosmetics'));
  } else if (key.contains('gift')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'gifts'));
  } else if (key.contains('jewel')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'jewelry'));
  } else if (key.contains('station')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'stationery'));
  } else if (key.contains('baby') || key.contains('kid')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'baby-kids'));
  } else if (key.contains('sport')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'sports'));
  }
}
