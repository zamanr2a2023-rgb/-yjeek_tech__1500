import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/l10n/l10n.dart';

enum DineInPrepMode { prepareNow, prepareOnArrival }

enum DineInSeating { indoor, outdoor, any }

class DineInCartItem {
  const DineInCartItem({
    required this.name,
    required this.subtitle,
    required this.price,
    this.originalPrice,
    this.quantity = 1,
    this.isMain = false,
  });

  final String name;
  final String subtitle;
  final String price;
  final String? originalPrice;
  final int quantity;
  final bool isMain;
}

class DineInComboItem {
  const DineInComboItem({
    required this.name,
    required this.price,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final String name;
  final String price;
  final Color gradientStart;
  final Color gradientEnd;
}

abstract final class DineInCartStrings {
  static String get basket => L10n.tr('Dine-in basket');
  static String get checkout => L10n.tr('Dine-in checkout');
  static String get reviewConfirm => L10n.tr('Review & confirm');
  static String get yourItems => L10n.tr('Your items');
  static String get makeItCombo => L10n.tr('Make it a combo');
  static String get promoCode => L10n.tr('Enter promo code');
  static String get dineInPreferences => L10n.tr('Dine-in preferences');
  static String get partySize => L10n.tr('Party size');
  static String get seating => L10n.tr('Seating');
  static String get indoor => L10n.tr('Indoor');
  static String get outdoor => L10n.tr('Outdoor');
  static String get any => L10n.tr('Any');
  static String get specialOccasion => L10n.tr('Special occasion setup');
  static String get specialOccasionHint => L10n.tr('Candles & a little surprise on the table.');
  static String get noteForKitchen => L10n.tr('Note for the kitchen');
  static String get noteForKitchenHint => L10n.tr('Allergies, seating, less spicy…');
  static String get addMore => L10n.tr('Add more');
  static String get checkoutBtn => L10n.tr('Checkout');
  static String get diningOption => L10n.tr('How would you like to dine?');
  static String get prepareNow => L10n.tr('Prepare now');
  static String get prepareNowHint => L10n.tr('Kitchen starts now. Table ready in ~1 hour.');
  static String get prepareOnArrival => L10n.tr('Prepare on arrival');
  static String get prepareOnArrivalHint => L10n.tr('Choose your time. Kitchen starts on check-in.');
  static String get tableReadyLabel => L10n.tr('Table ready');
  static String get tableReadyValue => L10n.tr('in ~1 hour');
  static String get tableReadyIn => L10n.tr('Table ready in ~1 hour');
  static String get prepareNowBanner => L10n.tr('Your table will be ready about 1 hour after you pay.');
  static String get dineInTime => L10n.tr('Dine-in time');
  static String get arrivalBanner => L10n.tr('Arrive within 1 hour of your time, or the order auto-cancels.');
  static String get paymentMethod => L10n.tr('Payment method');
  static String get walletComboNote => L10n.tr('You can pay with any method and use your Yjeek Wallet balance together.');
  static String get walletBalance => L10n.tr('Balance BHD 12.450');
  static String get billSummary => L10n.tr('Bill summary');
  static String get placeOrder => L10n.tr('Place order');
  static String get sendingOrder => L10n.tr('Sending your dine-in order to VEERA');
  static String get autoConfirmHint => L10n.tr('Auto-confirms in 10 seconds. You can still edit or cancel before then.');
  static String get orderSummary => L10n.tr('Order summary');
  static String get editOrder => L10n.tr('Edit order');
  static String get confirmNow => L10n.tr('Confirm now');
  static String get restaurant => L10n.tr('Restaurant');
  static String get items => L10n.tr('Items');
  static String get diningOptionLabel => L10n.tr('Dining option');
  static String get time => L10n.tr('Time');
  static String get payment => L10n.tr('Payment');
  static String get orderTotal => L10n.tr('Order total');
  static String get payPrepNow => L10n.tr('Pay & prep now');
  static String get yjeekWallet => L10n.tr('Yjeek Wallet');
  static String get deliveryDineIn => L10n.tr('Dine-in');
  static String get submit => L10n.tr('Submit');
}

abstract final class DineInCartData {
  static String get vendor => L10n.tr('VEERA');
  static String get location => L10n.tr('Adliya');
  static String get vendorSubtitle => L10n.tr('VEERA · Adliya');
  static String get vendorFull => L10n.tr('VEERA · ADLIYA · DINE-IN');
  static String get orderTotal => L10n.tr('BHD 20.500');
  static String get dineInTime => L10n.tr('Today · 19:30');
  static String get checkoutSubtitle => L10n.tr('VEERA · Adliya · Today 19:30');
  static const int defaultPartySize = 2;
  static const int minPartySize = 1;
  static const int maxPartySize = 12;

  static const List<DineInCartItem> cartItems = [
    DineInCartItem(
      name: 'Mixed Grill Platter',
      subtitle: 'Shish tawook, kofta, lamb · serves 2',
      price: 'BHD 12.000',
      originalPrice: 'BHD 15.000',
      isMain: true,
    ),
    DineInCartItem(
      name: 'Hummus Beiruti',
      subtitle: 'Classic chickpea dip',
      price: 'BHD 3.500',
    ),
    DineInCartItem(
      name: 'Fresh Lemonade',
      subtitle: 'House-made · large',
      price: 'BHD 4.000',
      quantity: 2,
    ),
  ];

  static const List<DineInComboItem> comboItems = [
    DineInComboItem(
      name: 'Baba Ganoush',
      price: 'BHD 1.200',
      gradientStart: Color(0xFF6B8A3A),
      gradientEnd: Color(0xFF15302B),
    ),
    DineInComboItem(
      name: 'Baklava',
      price: 'BHD 2.000',
      gradientStart: Color(0xFF9A6B2A),
      gradientEnd: Color(0xFF15302B),
    ),
    DineInComboItem(
      name: 'Mint Tea',
      price: 'BHD 0.800',
      gradientStart: Color(0xFF3A6B48),
      gradientEnd: Color(0xFF15302B),
    ),
  ];

  static String get cashbackAmount => L10n.tr('+ BHD 0.615');

  static const List<BillLine> billLines = [
    BillLine(label: 'Subtotal', value: 'BHD 23.500'),
    BillLine(label: 'Discount', value: '− BHD 3.000', isDiscount: true),
    BillLine(label: 'Delivery', value: '— Dine-in'),
    BillLine(label: 'Order total', value: 'BHD 20.500', isBold: true),
  ];

  static final List<PaymentOption> paymentOptions = [
    PaymentOption(
      id: 'benefitpay',
      label: 'BenefitPay',
      iconAsset: AppAssets.payBenefitPay,
    ),
    PaymentOption(
      id: 'apple',
      label: 'Apple Pay',
      iconAsset: AppAssets.payApple,
    ),
    PaymentOption(
      id: 'google',
      label: 'Google Pay',
      iconAsset: AppAssets.payGoogle,
    ),
    PaymentOption(
      id: 'benefit',
      label: 'Benefit',
      iconAsset: AppAssets.payBenefit,
    ),
    PaymentOption(
      id: 'new-card',
      label: 'Add new card',
      iconAsset: AppAssets.payAddCard,
    ),
    PaymentOption(
      id: 'wallet',
      label: DineInCartStrings.yjeekWallet,
      subtitle: DineInCartStrings.walletBalance,
      iconAsset: AppAssets.payWallet,
      selected: true,
    ),
  ];
}

class PaymentOption {
  const PaymentOption({
    required this.id,
    required this.label,
    this.subtitle,
    this.icon,
    this.iconAsset,
    this.selected = false,
  });

  final String id;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final String? iconAsset;
  final bool selected;
}
