import 'package:flutter/material.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/l10n/l10n.dart';

class VapeCartItem {
  const VapeCartItem({
    required this.name,
    required this.subtitle,
    required this.price,
    this.originalPrice,
    this.quantity = 1,
  });

  final String name;
  final String subtitle;
  final String price;
  final String? originalPrice;
  final int quantity;
}

class VapeUpsellItem {
  const VapeUpsellItem({
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

class VapeDeliveryMethod {
  const VapeDeliveryMethod({
    required this.id,
    required this.label,
    required this.price,
    required this.priceValue,
    this.subtitle,
    this.available = true,
    this.unavailableNote,
  });

  final String id;
  final String label;
  final String price;
  final double priceValue;
  final String? subtitle;
  final bool available;
  final String? unavailableNote;
}

abstract final class VapeCartStrings {
  static String get cart => L10n.tr('Cart');
  static String get checkout => L10n.tr('Checkout');
  static String get reviewConfirm => L10n.tr('Review & confirm');
  static String get yourItems => L10n.tr('Your items');
  static String get youMightAlsoLike => L10n.tr('You might also like');
  static String get promoCode => L10n.tr('Have a promo code?');
  static String get edit => L10n.tr('Edit');
  static String get deliveryDetails => L10n.tr('Delivery details');
  static String get deliveryMethod => L10n.tr('Delivery method');
  static String get dropOffPreferences => L10n.tr('Drop-off preferences');
  static String get tipYourChamp => L10n.tr('Tip your champ');
  static String get paymentMethod => L10n.tr('Payment method');
  static String get billSummary => L10n.tr('Bill summary');
  static String get placeOrder => L10n.tr('Place order');
  static String get addMore => L10n.tr('Add more');
  static String get checkoutBtn => L10n.tr('Checkout');
  static String get placingOrder => L10n.tr('Placing your order');
  static String get autoConfirmHint => L10n.tr('Auto-confirms in 10 seconds. You can still edit or cancel before then.');
  static String get orderSummary => L10n.tr('Order summary');
  static String get editOrder => L10n.tr('Edit order');
  static String get sendToVendor => L10n.tr('Send to vendor');
  static String get orderType => L10n.tr('VAPEOLOGY · VAPE DELIVERY');
  static String get method => L10n.tr('Method');
  static String get deliverTo => L10n.tr('Deliver to');
  static String get payment => L10n.tr('Payment');
  static String get orderTotal => L10n.tr('Order total');
  static String get cashOnDelivery => L10n.tr('Cash on delivery');
  static String get customTip => L10n.tr('Custom');
  static String get idVerification => L10n.tr('ID verification');
  static String get verified => L10n.tr('VERIFIED ✓');
  static String get verifiedNote => L10n.tr('Your CPR is verified by Yjeek. The champ still checks your ID (18+) on delivery.');
  static String get arrivesIn => L10n.tr('Scheduled delivery');
  static String get phone => L10n.tr('+973 3558 0000');
  static const String paymentNote =
      "You won't be charged now. Once the vendor accepts, you'll have 5 minutes to pay";
  static String get verifyTitle => L10n.tr('Verify your age first');
  static String get verifyBody => L10n.tr('This is an age-restricted (18+) order. You need to upload your CPR and documents and get verified before you can place this order.');
  static String get goToVerification => L10n.tr('Go to verification');
  static String get notNow => L10n.tr('Not now');
  static String get cashbackEarn => L10n.tr('Earn 3% cashback to your Wallet');
  static String get enterPromoCode => L10n.tr('Enter promo code');
  static String get submit => L10n.tr('Submit');
}

abstract final class VapeCartData {
  static String get vendor => L10n.tr('Vapeology');
  static String get selectedAddress => L10n.tr('Apartment · Seef');
  static String get selectedAddressDetail => L10n.tr('Road 6000, Bldg 23, Flat 82');
  static String get orderTotal => L10n.tr('BHD 6.610');
  static String get cashbackAmount => L10n.tr('+ BHD 0.198');

  static const List<VapeCartItem> cartItems = [
    VapeCartItem(
      name: 'Mango Ice Disposable',
      subtitle: '2500 puffs · 20mg nicotine',
      price: 'BHD 6.500',
      originalPrice: 'BHD 7.000',
    ),
  ];

  static const List<VapeUpsellItem> upsellItems = [
    VapeUpsellItem(
      name: 'Blue Razz',
      price: 'BHD 6.500',
      gradientStart: Color(0xFF6B4A2A),
      gradientEnd: Color(0xFF15302B),
    ),
    VapeUpsellItem(
      name: 'Watermelon Ice',
      price: 'BHD 6.500',
      gradientStart: Color(0xFF8A5B2A),
      gradientEnd: Color(0xFF15302B),
    ),
    VapeUpsellItem(
      name: 'Mint Tobacco',
      price: 'BHD 6.500',
      gradientStart: Color(0xFF7A4A22),
      gradientEnd: Color(0xFF15302B),
    ),
  ];

  static final List<BillLine> cartBillLines = [
    BillLine(label: 'Subtotal', value: 'BHD 6.500'),
    BillLine(label: 'Discount', value: '- BHD 0.500', isDiscount: true),
    BillLine(label: 'Delivery', value: 'BHD 0.500'),
    BillLine(label: 'Service fee', value: 'BHD 0.110'),
    BillLine(label: 'Order total', value: orderTotal, isBold: true),
  ];

  static const List<VapeDeliveryMethod> deliveryMethods = [
    VapeDeliveryMethod(
      id: 'same-day',
      label: 'Same Day',
      price: 'BHD 2.000',
      priceValue: 2.0,
    ),
    VapeDeliveryMethod(
      id: 'next-day',
      label: 'Next Day',
      price: 'BHD 1.500',
      priceValue: 1.5,
    ),
    VapeDeliveryMethod(
      id: 'standard',
      label: 'Standard',
      subtitle: '1–3 days',
      price: 'BHD 1.000',
      priceValue: 1.0,
    ),
    VapeDeliveryMethod(
      id: 'economy',
      label: 'Economy',
      subtitle: '5–7 days',
      price: 'BHD 0.500',
      priceValue: 0.5,
    ),
  ];

  static final List<TipOption> tipOptions = [
    TipOption(label: 'BHD 0.200', amount: 0.2),
    TipOption(label: 'BHD 0.500', amount: 0.5),
    TipOption(label: 'BHD 1', amount: 1),
    TipOption(label: VapeCartStrings.customTip),
  ];

  static List<DropOffOption> get dropOffOptions => CartFlowData.dropOffOptions;

  static List<PaymentOption> get paymentOptions => [
    const PaymentOption(
      id: 'benefitpay',
      label: 'BenefitPay',
      icon: Icons.account_balance_wallet_outlined,
      selected: true,
    ),
    ...CartFlowData.paymentOptions.where((o) => o.id != 'benefitpay'),
  ];

  static const bool isAgeVerified = true;

  static List<BillLine> checkoutBillLines({
    required VapeDeliveryMethod method,
    double tip = 0,
  }) {
    return [
      const BillLine(label: 'Subtotal', value: 'BHD 6.500'),
      const BillLine(label: 'Discount', value: '- BHD 0.500', isDiscount: true),
      BillLine(label: method.label, value: method.price),
      BillLine(label: 'Service fee', value: 'BHD 0.110'),
      if (tip > 0) BillLine(label: 'Tip', value: 'BHD ${tip.toStringAsFixed(3)}'),
      BillLine(label: 'Order total', value: orderTotal, isBold: true),
    ];
  }

  static String checkoutTotalFor({
    required VapeDeliveryMethod method,
    double tip = 0,
  }) =>
      orderTotal;
}
