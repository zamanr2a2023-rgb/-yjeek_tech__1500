import 'package:yjeek_app/l10n/l10n.dart';
abstract final class HomeStrings {
  static String get hello => L10n.tr('Hello 👋');
  static String get deliverTo => L10n.tr('Deliver to');
  static String get chooseLocation => L10n.tr('Choose location');
  static String get searchHome => L10n.tr('Search for restaurants, groceries…');
  static String get searchCategories => L10n.tr('Search categories & vendors…');
  static String get preparingOrder => L10n.tr('Preparing your order');
  static String get orderSubtitle => L10n.tr('The Green Kitchen · arrives 15–25 min');
  static String get track => L10n.tr('Track');
  static String get categories => L10n.tr('Categories');
  static String get seeAll => L10n.tr('See all');
  static String get orderAgain => L10n.tr('Order again');
  static String get exclusiveOffers => L10n.tr('Super Exclusive offers');
  static String get weeklySpotlight => L10n.tr('WEEKLY SPOTLIGHT');
  static String get spotlightTitle => L10n.tr('Green Artisan Bakery');
  static String get orderNow => L10n.tr('Order Now');
  static String get allCategories => L10n.tr('All categories');
  static String get deliverToLabel => L10n.tr('DELIVER TO');

  static String get navHome => L10n.tr('Home');
  static String get navOrders => L10n.tr('Orders');
  static String get navCart => L10n.tr('Cart');
  static String get navWallet => L10n.tr('Wallet');
  static String get navAccount => L10n.tr('Account');
}
