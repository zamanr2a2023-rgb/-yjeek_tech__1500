import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

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
  static const String basket = 'Dine-in basket';
  static const String checkout = 'Dine-in checkout';
  static const String reviewConfirm = 'Review & confirm';
  static const String yourItems = 'Your items';
  static const String makeItCombo = 'Make it a combo';
  static const String promoCode = 'Enter promo code';
  static const String dineInPreferences = 'Dine-in preferences';
  static const String partySize = 'Party size';
  static const String seating = 'Seating';
  static const String indoor = 'Indoor';
  static const String outdoor = 'Outdoor';
  static const String any = 'Any';
  static const String specialOccasion = 'Special occasion setup';
  static const String specialOccasionHint =
      'Candles & a little surprise on the table.';
  static const String noteForKitchen = 'Note for the kitchen';
  static const String noteForKitchenHint = 'Allergies, seating, less spicy…';
  static const String addMore = 'Add more';
  static const String checkoutBtn = 'Checkout';
  static const String diningOption = 'How would you like to dine?';
  static const String prepareNow = 'Prepare now';
  static const String prepareNowHint = 'Kitchen starts now. Table ready in ~1 hour.';
  static const String prepareOnArrival = 'Prepare on arrival';
  static const String prepareOnArrivalHint =
      'Choose your time. Kitchen starts on check-in.';
  static const String tableReadyLabel = 'Table ready';
  static const String tableReadyValue = 'in ~1 hour';
  static const String tableReadyIn = 'Table ready in ~1 hour';
  static const String prepareNowBanner =
      'Your table will be ready about 1 hour after you pay.';
  static const String dineInTime = 'Dine-in time';
  static const String arrivalBanner =
      'Arrive within 1 hour of your time, or the order auto-cancels.';
  static const String paymentMethod = 'Payment method';
  static const String walletComboNote =
      'You can pay with any method and use your Yjeek Wallet balance together.';
  static const String walletBalance = 'Balance BHD 12.450';
  static const String billSummary = 'Bill summary';
  static const String placeOrder = 'Place order';
  static const String sendingOrder = 'Sending your dine-in order to VEERA';
  static const String autoConfirmHint =
      'Auto-confirms in 10 seconds. You can still edit or cancel before then.';
  static const String orderSummary = 'Order summary';
  static const String editOrder = 'Edit order';
  static const String confirmNow = 'Confirm now';
  static const String restaurant = 'Restaurant';
  static const String items = 'Items';
  static const String diningOptionLabel = 'Dining option';
  static const String time = 'Time';
  static const String payment = 'Payment';
  static const String orderTotal = 'Order total';
  static const String payPrepNow = 'Pay & prep now';
  static const String yjeekWallet = 'Yjeek Wallet';
  static const String deliveryDineIn = 'Dine-in';
  static const String submit = 'Submit';
}

abstract final class DineInCartData {
  static const String vendor = 'VEERA';
  static const String location = 'Adliya';
  static const String vendorSubtitle = 'VEERA · Adliya';
  static const String vendorFull = 'VEERA · ADLIYA · DINE-IN';
  static const String orderTotal = 'BHD 20.500';
  static const String dineInTime = 'Today · 19:30';
  static const String checkoutSubtitle = 'VEERA · Adliya · Today 19:30';
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

  static const String cashbackAmount = '+ BHD 0.615';

  static const List<BillLine> billLines = [
    BillLine(label: 'Subtotal', value: 'BHD 23.500'),
    BillLine(label: 'Discount', value: '− BHD 3.000', isDiscount: true),
    BillLine(label: 'Delivery', value: '— Dine-in'),
    BillLine(label: 'Order total', value: 'BHD 20.500', isBold: true),
  ];

  static const List<PaymentOption> paymentOptions = [
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
