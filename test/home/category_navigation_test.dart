import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/features/home/model/category_navigation.dart';

CategoryItem _item({
  String? slug,
  String name = 'Category',
  String? structure,
  String? kind,
}) {
  return CategoryItem(
    name: name,
    slug: slug,
    structure: structure,
    kind: kind,
    icon: Icons.category_outlined,
    backgroundColor: const Color(0xFFE8F0FE),
  );
}

void main() {
  test('uses admin slug for gifts_flowers — not remapped to flowers', () {
    final route = resolveHomeCategoryRoute(
      _item(slug: 'gifts_flowers', name: 'Gifts & Flowers'),
    );
    expect(route.destination, HomeCategoryDestination.electronicsBrowse);
    expect(route.categorySlug, 'gifts_flowers');
    expect(route.title, isNotNull);
  });

  test('flowers slug stays flowers', () {
    final route = resolveHomeCategoryRoute(
      _item(slug: 'flowers', name: 'Flowers'),
    );
    expect(route.destination, HomeCategoryDestination.electronicsBrowse);
    expect(route.categorySlug, 'flowers');
  });

  test('gifts slug uses retail landing', () {
    final route = resolveHomeCategoryRoute(_item(slug: 'gifts', name: 'Gifts'));
    expect(route.destination, HomeCategoryDestination.retailCategory);
    expect(route.categorySlug, 'gifts');
  });

  test('two-level store type opens retail category with exact slug', () {
    final route = resolveHomeCategoryRoute(
      _item(slug: 'services', name: 'Services', structure: 'TWO_LEVEL'),
    );
    expect(route.destination, HomeCategoryDestination.servicesBrowse);
  });

  test('two-level non-services uses retail category', () {
    final route = resolveHomeCategoryRoute(
      _item(slug: 'custom-retail', name: 'Custom', structure: 'TWO_LEVEL'),
    );
    expect(route.destination, HomeCategoryDestination.retailCategory);
    expect(route.categorySlug, 'custom-retail');
  });

  test('food uses food browse', () {
    final route = resolveHomeCategoryRoute(_item(slug: 'food', name: 'Food'));
    expect(route.destination, HomeCategoryDestination.foodBrowse);
  });

  test('order mode pickup is not confused with store slug', () {
    final route = resolveHomeCategoryRoute(
      _item(slug: 'pickup', name: 'Pickup', kind: 'ORDER_MODE'),
    );
    expect(route.destination, HomeCategoryDestination.pickupBrowse);
  });
}
