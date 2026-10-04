import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/food_vendors_repository.dart';

void main() {
  group('browseRestaurantFromVendorJson', () {
    test('uses API cuisine as primary label and parses cuisineTags', () {
      final restaurant = browseRestaurantFromVendorJson({
        'id': 'v1',
        'name': 'Test Kitchen',
        'cuisine': 'Fast food',
        'cuisineTags': ['Burger', 'Fast food'],
        'area': 'Manama',
      });

      expect(restaurant, isNotNull);
      expect(restaurant!.cuisine, 'Fast food');
      expect(restaurant.cuisineTags, ['Burger', 'Fast food']);
    });

    test('falls back to first tag when cuisine missing', () {
      final restaurant = browseRestaurantFromVendorJson({
        'id': 'v2',
        'name': 'Grill House',
        'cuisineTags': ['Indian', 'Grills'],
      });

      expect(restaurant!.cuisine, 'Indian');
      expect(restaurant.cuisineTags, ['Indian', 'Grills']);
    });
  });

  group('buildVendorListQueryParams', () {
    test('joins multiple cuisines for OR filter', () {
      final params = <String, String>{'category': 'food'};
      buildVendorListQueryParams(
        params,
        cuisines: ['Burgers', 'Indian'],
      );
      expect(params['cuisine'], 'Burgers,Indian');
    });

    test('dedupes and skips All', () {
      final params = <String, String>{};
      buildVendorListQueryParams(
        params,
        cuisines: ['Burger', 'burger', 'All', ''],
      );
      expect(params['cuisine'], 'Burger');
    });
  });

  group('vendorMatchesCuisineQuery', () {
    test('matches primary cuisine or tags case-insensitively', () {
      final restaurant = BrowseRestaurant(
        id: '1',
        name: 'X',
        cuisine: 'Fast food',
        cuisineTags: const ['Burger'],
        rating: 4,
        gradientStart: const Color(0xFF000000),
        gradientEnd: const Color(0xFFFFFFFF),
      );

      expect(vendorMatchesCuisineQuery(restaurant, ['burger']), isTrue);
      expect(vendorMatchesCuisineQuery(restaurant, ['fast food']), isTrue);
      expect(vendorMatchesCuisineQuery(restaurant, ['Sushi']), isFalse);
    });
  });

  group('browseRestaurantLocationSubtitle', () {
    test('shows cuisine and area when both differ', () {
      final restaurant = BrowseRestaurant(
        id: '1',
        name: 'X',
        cuisine: 'Fast food',
        area: 'Manama',
        rating: 4,
        gradientStart: const Color(0xFF000000),
        gradientEnd: const Color(0xFFFFFFFF),
      );
      expect(
        browseRestaurantLocationSubtitle(restaurant),
        'Fast food · Manama',
      );
    });
  });
}
