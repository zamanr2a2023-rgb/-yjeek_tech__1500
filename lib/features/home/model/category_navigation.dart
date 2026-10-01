import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Shared home + Categories screen routing (no UI change).
void openHomeCategory(BuildContext context, CategoryItem category) {
  final key = (category.slug ?? category.name).toLowerCase().trim();
  final slug = (category.slug ?? '').toLowerCase().trim();

  if (slug == 'marketing-offers' ||
      key == 'offers' ||
      (key.contains('offer') && !key.contains('exclusive'))) {
    context.push(RouteNames.marketingOffers);
    return;
  }

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

  // Scheduled / retail categories — sub-category landing (Fashion design).
  final scheduledSlug = switch (slug) {
    'grocery' || 'groceries' => 'grocery',
    'fashion' => 'fashion',
    'flowers' || 'florist' => 'flowers',
    'prosthetics' || 'prosthetic' => 'prosthetics',
    'pharmacy' => 'pharmacy',
    'cosmetics' => 'cosmetics',
    'gifts' || 'gift' => 'gifts',
    'jewelry' || 'jewellery' => 'jewelry',
    'stationery' => 'stationery',
    'baby-kids' || 'baby_kids' || 'baby' => 'baby-kids',
    'sports' || 'sport' => 'sports',
    'health-wellness' ||
    'health_wellness' ||
    'health' ||
    'wellness' =>
      'health-wellness',
    'pets' || 'pet' => 'pets',
    'fragrance' || 'fragrances' => 'fragrance',
    _ => null,
  };

  if (scheduledSlug != null) {
    // Vendor list first (no empty sub-category landing).
    if (scheduledSlug == 'flowers' ||
        scheduledSlug == 'fashion' ||
        scheduledSlug == 'health-wellness' ||
        scheduledSlug == 'pets' ||
        scheduledSlug == 'fragrance') {
      context.push(
        BrowseRoutes.electronicsBrowse(
          category: scheduledSlug,
          title: _vendorListTitle(scheduledSlug, category.name),
        ),
      );
      return;
    }
    // Pharmacy / Gifts: sub-category grid when configured in admin.
    if (scheduledSlug == 'pharmacy' || scheduledSlug == 'gifts') {
      context.push(BrowseRoutes.retailCategory(slug: scheduledSlug));
      return;
    }
    context.push(BrowseRoutes.electronicsBrowse(category: scheduledSlug));
    return;
  }

  // Name-based fallback when slug is missing/odd.
  if (key.contains('grocery') || key.contains('grocer')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'grocery'));
  } else if (key.contains('flower') || key.contains('florist')) {
    context.push(
      BrowseRoutes.electronicsBrowse(
        category: 'flowers',
        title: 'Flowers',
      ),
    );
  } else if (key.contains('fashion')) {
    context.push(
      BrowseRoutes.electronicsBrowse(category: 'fashion', title: 'Fashion'),
    );
  } else if (key.contains('health') || key.contains('wellness')) {
    context.push(
      BrowseRoutes.electronicsBrowse(
        category: 'health-wellness',
        title: 'Health & Wellness',
      ),
    );
  } else if (key.contains('fragrance')) {
    context.push(
      BrowseRoutes.electronicsBrowse(
        category: 'fragrance',
        title: 'Fragrance',
      ),
    );
  } else if (key.contains('pet')) {
    context.push(
      BrowseRoutes.electronicsBrowse(category: 'pets', title: 'Pets'),
    );
  } else if (key.contains('prosthetic')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'prosthetics'));
  } else if (key.contains('pharmacy')) {
    context.push(BrowseRoutes.retailCategory(slug: 'pharmacy'));
  } else if (key.contains('cosmetic')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'cosmetics'));
  } else if (key.contains('gift')) {
    context.push(BrowseRoutes.retailCategory(slug: 'gifts'));
  } else if (key.contains('jewel')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'jewelry'));
  } else if (key.contains('station')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'stationery'));
  } else if (key.contains('baby') || key.contains('kid')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'baby-kids'));
  } else if (key.contains('sport')) {
    context.push(BrowseRoutes.electronicsBrowse(category: 'sports'));
  } else if (slug.isNotEmpty) {
    context.push(
      BrowseRoutes.electronicsBrowse(
        category: slug,
        title: category.name,
      ),
    );
  }
}

String _vendorListTitle(String slug, String fallbackName) {
  return switch (slug) {
    'fashion' => 'Fashion',
    'flowers' => 'Flowers',
    'health-wellness' => 'Health & Wellness',
    'pets' => 'Pets',
    'fragrance' => 'Fragrance',
    _ => fallbackName,
  };
}
