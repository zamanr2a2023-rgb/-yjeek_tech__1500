import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Where a home / categories tile should navigate (testable without [BuildContext]).
enum HomeCategoryDestination {
  marketingOffers,
  foodBrowse,
  dineInBrowse,
  servicesBrowse,
  electronicsBrowse,
  vapeBrowse,
  pickupBrowse,
  retailCategory,
  none,
}

/// Resolved navigation for [CategoryItem] — slug is passed through from admin/catalog.
class HomeCategoryRoute {
  const HomeCategoryRoute(
    this.destination, {
    this.categorySlug,
    this.title,
    this.foodCategorySlug,
  });

  final HomeCategoryDestination destination;

  /// Store-type slug for vendor list / retail category (`GET /vendors?category=`).
  final String? categorySlug;

  /// Screen title (usually API / home-entry display name).
  final String? title;

  /// Optional food browse store-type slug (null = default food directory).
  final String? foodCategorySlug;

  static const none = HomeCategoryRoute(HomeCategoryDestination.none);
}

String _normalizeToken(String value) =>
    value.trim().toLowerCase().replaceAll('-', '_');

bool _slugIs(String slug, Set<String> options) {
  if (slug.isEmpty) return false;
  final normalized = _normalizeToken(slug);
  return options.contains(normalized) ||
      options.contains(slug.trim().toLowerCase());
}

/// Store types that use the retail sub-category landing (admin menu / sub-types).
const _retailLandingSlugs = {'pharmacy', 'gifts'};

/// Resolves browse destination from catalog fields — no substring remapping of slugs.
HomeCategoryRoute resolveHomeCategoryRoute(CategoryItem category) {
  final slugRaw = category.slug?.trim() ?? '';
  final slug = slugRaw.toLowerCase();
  final key = _normalizeToken(category.slug ?? category.name);

  if (slug == 'marketing-offers' ||
      key == 'offers' ||
      (key.contains('offer') && !key.contains('exclusive'))) {
    return const HomeCategoryRoute(HomeCategoryDestination.marketingOffers);
  }

  final kind = category.kind?.trim().toUpperCase();
  if (kind == 'ORDER_MODE' ||
      isOrderModeCategory(kind: category.kind, slug: category.slug, name: category.name)) {
    if (_slugIs(slug, {'pickup'})) {
      return const HomeCategoryRoute(HomeCategoryDestination.pickupBrowse);
    }
    if (_slugIs(slug, {'dine_in', 'dine-in'})) {
      return const HomeCategoryRoute(HomeCategoryDestination.dineInBrowse);
    }
    if (_slugIs(slug, {'delivery'})) {
      return const HomeCategoryRoute(HomeCategoryDestination.foodBrowse);
    }
  }

  if (_slugIs(slug, {'food'}) || (slug.isEmpty && key == 'food')) {
    final foodSlug = slug.isNotEmpty ? slug : 'food';
    return HomeCategoryRoute(
      HomeCategoryDestination.foodBrowse,
      foodCategorySlug: foodSlug == 'food' ? null : foodSlug,
    );
  }
  if (_slugIs(slug, {'dine_in', 'dine-in'}) || (slug.isEmpty && key.contains('dine'))) {
    return const HomeCategoryRoute(HomeCategoryDestination.dineInBrowse);
  }
  if (_slugIs(slug, {'services'}) ||
      (slug.isEmpty && key == 'services')) {
    return HomeCategoryRoute(
      HomeCategoryDestination.servicesBrowse,
      categorySlug: slug.isNotEmpty ? slug : null,
    );
  }
  if (_slugIs(slug, {'electronics'}) ||
      (slug.isEmpty && key.contains('electronic'))) {
    return const HomeCategoryRoute(
      HomeCategoryDestination.electronicsBrowse,
      categorySlug: 'electronics',
    );
  }
  if (_slugIs(slug, {'vape'}) || (slug.isEmpty && key.contains('vape'))) {
    return const HomeCategoryRoute(HomeCategoryDestination.vapeBrowse);
  }
  if (_slugIs(slug, {'pickup'}) || (slug.isEmpty && key.contains('pickup'))) {
    return const HomeCategoryRoute(HomeCategoryDestination.pickupBrowse);
  }

  if (category.twoLevel && slug.isNotEmpty) {
    return HomeCategoryRoute(
      HomeCategoryDestination.retailCategory,
      categorySlug: slugRaw,
      title: category.displayName,
    );
  }

  if (slug.isNotEmpty) {
    if (_retailLandingSlugs.contains(slug)) {
      return HomeCategoryRoute(
        HomeCategoryDestination.retailCategory,
        categorySlug: slugRaw,
        title: category.displayName,
      );
    }
    return HomeCategoryRoute(
      HomeCategoryDestination.electronicsBrowse,
      categorySlug: slugRaw,
      title: category.displayName,
    );
  }

  // Legacy tiles with name only (no slug) — map to catalog slugs without guessing combined types.
  final legacySlug = _legacySlugForNameKey(key);
  if (legacySlug != null) {
    if (_retailLandingSlugs.contains(legacySlug)) {
      return HomeCategoryRoute(
        HomeCategoryDestination.retailCategory,
        categorySlug: legacySlug,
        title: category.displayName,
      );
    }
    return HomeCategoryRoute(
      HomeCategoryDestination.electronicsBrowse,
      categorySlug: legacySlug,
      title: category.displayName,
    );
  }

  return HomeCategoryRoute.none;
}

String? _legacySlugForNameKey(String key) {
  return switch (key) {
    'groceries' || 'grocery' => 'grocery',
    'fashion' => 'fashion',
    'flowers' || 'florist' => 'flowers',
    'prosthetics' || 'prosthetic' => 'prosthetics',
    'pharmacy' => 'pharmacy',
    'cosmetics' => 'cosmetics',
    'gifts' || 'gift' => 'gifts',
    'gifts_flowers' ||
    'gifts_&_flowers' ||
    'gifts_and_flowers' =>
      'gifts_flowers',
    'jewelry' || 'jewellery' => 'jewelry',
    'stationery' => 'stationery',
    'baby_kids' || 'baby_kid' || 'baby' => 'baby-kids',
    'sports' || 'sport' => 'sports',
    'health_wellness' ||
    'health_&_wellness' ||
    'health' ||
    'wellness' =>
      'health-wellness',
    'pets' || 'pet' => 'pets',
    'fragrance' || 'fragrances' => 'fragrance',
    _ => null,
  };
}

/// Shared home + Categories screen routing.
void openHomeCategory(BuildContext context, CategoryItem category) {
  final route = resolveHomeCategoryRoute(category);
  switch (route.destination) {
    case HomeCategoryDestination.marketingOffers:
      context.push(RouteNames.marketingOffers);
    case HomeCategoryDestination.foodBrowse:
      context.push(BrowseRoutes.foodBrowse(category: route.foodCategorySlug));
    case HomeCategoryDestination.dineInBrowse:
      context.push(BrowseRoutes.dineInBrowse());
    case HomeCategoryDestination.servicesBrowse:
      context.push(BrowseRoutes.servicesBrowse(slug: route.categorySlug));
    case HomeCategoryDestination.electronicsBrowse:
      context.push(
        BrowseRoutes.electronicsBrowse(
          category: route.categorySlug ?? 'electronics',
          title: route.title,
        ),
      );
    case HomeCategoryDestination.vapeBrowse:
      context.push(BrowseRoutes.vapeBrowse());
    case HomeCategoryDestination.pickupBrowse:
      context.push(BrowseRoutes.pickupBrowse());
    case HomeCategoryDestination.retailCategory:
      final slug = route.categorySlug;
      if (slug != null && slug.isNotEmpty) {
        context.push(BrowseRoutes.retailCategory(slug: slug));
      }
    case HomeCategoryDestination.none:
      return;
  }
}
