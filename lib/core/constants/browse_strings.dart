import 'package:yjeek_app/l10n/l10n.dart';

abstract final class BrowseStrings {
  static String get freeDelivery => L10n.tr('Free delivery');
  static String get orderAgain => L10n.tr('Order again');
  static String get seeAll => L10n.tr('See all');
  static String get cancel => L10n.tr('Cancel');
  static String get recentSearches => L10n.tr('Recent searches');
  static String get topRated => L10n.tr('Top rated');
  static String get mostPopular => L10n.tr('Most Popular');
  static String get fastestDelivery => L10n.tr('Fastest Delivery');
  static String get nameSort => L10n.tr('Name');
  static String get sort => L10n.tr('Sort');
  static String get bookable => L10n.tr('Bookable');
  static String get offers => L10n.tr('Offers');
  static String get bookAgain => L10n.tr('Book again');

  static String sortWith(String label) =>
      L10n.trParams('Sort: {label}', {'label': label});

  static String get searchInFood => L10n.tr('Search in Food…');
  static String get searchInDineIn => L10n.tr('Search in Dine In…');
  static String get searchDineInRestaurants =>
      L10n.tr('Search dine-in restaurants…');
  static String get enableLocationFood => L10n.tr(
        'Enable location to see restaurants that deliver to you.',
      );
  static String get noRestaurantsNearby => L10n.tr(
        'No restaurants deliver to your current location. Showing all Food vendors.',
      );
  static String get noPickupSpots => L10n.tr('No pickup spots found');
  static String get recentDineInVisits => L10n.tr('Your recent dine-in visits');
  static String get searchThisMenu => L10n.tr('Search this menu…');
  static String get searchServices => L10n.tr('Search services…');
  static String get searchQuestions => L10n.tr('Search questions…');
}
