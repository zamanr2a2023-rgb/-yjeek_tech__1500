import 'package:flutter/material.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/l10n/l10n.dart';

class ScheduledCartItem {
  const ScheduledCartItem({
    required this.name,
    required this.subtitle,
    required this.price,
    this.quantity = 1,
    this.color = const Color(0xFFE3F2EB),
  });

  final String name;
  final String subtitle;
  final String price;
  final int quantity;
  final Color color;
}

class ScheduledAddMoreItem {
  const ScheduledAddMoreItem({
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

class ScheduledDeliveryMethod {
  const ScheduledDeliveryMethod({
    required this.id,
    required this.label,
    required this.price,
    required this.priceValue,
    this.subtitle,
    this.freeAfterNoon = false,
    this.available = true,
    this.unavailableNote,
  });

  final String id;
  final String label;
  final String price;
  final double priceValue;
  final String? subtitle;
  final bool freeAfterNoon;
  final bool available;
  final String? unavailableNote;
}

abstract final class ScheduledCartStrings {
  static String get cart => L10n.tr('Cart');
  static String get checkout => L10n.tr('Checkout');
  static String get reviewConfirm => L10n.tr('Review & confirm');
  static String get addMorePrompt => L10n.tr('Add more ... ?');
  static String get promoCode => L10n.tr('Have a promo code?');
  static String get deliveryAddress => L10n.tr('Delivery address');
  static String get deliveryMethod => L10n.tr('Delivery method');
  static String get dropOffPreferences => L10n.tr('Drop-off preferences');
  static String get paymentMethod => L10n.tr('Payment method');
  static String get tipYourChamp => L10n.tr('Tip your champ');
  static String get billSummary => L10n.tr('Bill summary');
  static String get placeOrder => L10n.tr('Place order');
  static String get addMore => L10n.tr('Add more');
  static String get checkoutBtn => L10n.tr('Checkout');
  static String get placingOrder => L10n.tr('Placing your order');
  static String get autoConfirmHint => L10n.tr('Auto-confirms in 10 seconds. You can still edit or cancel before then.');
  static String get orderSummary => L10n.tr('Order summary');
  static String get editOrder => L10n.tr('Edit order');
  static String get sendToVendor => L10n.tr('Send to vendor');
  static String get vendorNote => L10n.tr('scheduled cart: user can add items from different vendors, MAX 3');
  static const String paymentNote =
      "You won't be charged now. Once the vendor accepts, you'll have 5 minutes to pay";
  static String get walletNote => L10n.tr('You can pay with any method and use your Yjeek Wallet balance together.');
  static String get cashbackEarn => L10n.tr('Earn 3% cashback to your Wallet');
  static String get orderType => L10n.tr('TECHHUB ELECTRONICS · SCHEDULED DELIVERY');
  static String get method => L10n.tr('Method');
  static String get deliverTo => L10n.tr('Deliver to');
  static String get payment => L10n.tr('Payment');
  static String get orderTotal => L10n.tr('Order total');
  static String get cashOnDelivery => L10n.tr('Cash on delivery');
  static String get customTip => L10n.tr('Custom');
}

abstract final class ScheduledCartData {
  static String get vendor => L10n.tr('TechHub Electronics');
  static String get selectedAddress => L10n.tr('Apartment - Seef');
  static String get selectedAddressDetail => L10n.tr('Road 6000, Bldg 23, Flat 82');
  static String get walletBalance => L10n.tr('Balance BHD 12.450');
  static String get cartTotal => L10n.tr('BHD 154.300');
  static String get checkoutTotal => L10n.tr('BHD 154.300');
  static String get reviewTotal => L10n.tr('BHD 154.300');
  static String get cashbackAmount => L10n.tr('+ BHD 1.260');

  static const List<ScheduledCartItem> cartItems = [
    ScheduledCartItem(
      name: 'Nova 12 smartphone',
      subtitle: '128GB · Graphite',
      price: 'BHD 119.000',
    ),
    ScheduledCartItem(
      name: 'Pulse Buds Pro',
      subtitle: 'Wireless earbuds',
      price: 'BHD 28.900',
    ),
    ScheduledCartItem(
      name: 'Fast charger 33W',
      subtitle: 'USB-C',
      price: 'BHD 6.000',
    ),
  ];

  static const List<ScheduledAddMoreItem> addMoreItems = [
    ScheduledAddMoreItem(
      name: 'Airpods Case',
      price: 'BHD 0.500',
      gradientStart: Color(0xFF6B4A2A),
      gradientEnd: Color(0xFF15302B),
    ),
    ScheduledAddMoreItem(
      name: 'iPhone Cases',
      price: 'BHD 0.600',
      gradientStart: Color(0xFF8A5B2A),
      gradientEnd: Color(0xFF15302B),
    ),
    ScheduledAddMoreItem(
      name: 'Screen Guard',
      price: 'BHD 0.400',
      gradientStart: Color(0xFF5A4030),
      gradientEnd: Color(0xFF1A2E28),
    ),
  ];

  static final List<BillLine> cartBillLines = [
    BillLine(label: 'Subtotal', value: 'BHD 153.000'),
    BillLine(label: 'Delivery', value: 'BHD 1.000'),
    BillLine(label: 'Service fee', value: 'BHD 0.300'),
    BillLine(label: 'Total', value: cartTotal, isBold: true),
  ];

  static const List<ScheduledDeliveryMethod> deliveryMethods = [
    ScheduledDeliveryMethod(
      id: 'same-day',
      label: 'Same Day',
      price: 'BHD 2.000',
      priceValue: 2.0,
    ),
    ScheduledDeliveryMethod(
      id: 'next-day',
      label: 'Next Day',
      price: 'BHD 1.500',
      priceValue: 1.5,
      freeAfterNoon: true,
    ),
    ScheduledDeliveryMethod(
      id: 'standard',
      label: 'Standard',
      subtitle: '1–3 days',
      price: 'BHD 1.000',
      priceValue: 1.0,
    ),
    ScheduledDeliveryMethod(
      id: 'economy',
      label: 'Economy',
      subtitle: '5–7 days',
      price: 'BHD 0.500',
      priceValue: 0.5,
    ),
  ];

  static final List<TipOption> tipOptions = [
    TipOption(label: 'BHD 0.300', amount: 0.3),
    TipOption(label: 'BHD 0.500', amount: 0.5),
    TipOption(label: 'BHD 1', amount: 1),
    TipOption(label: ScheduledCartStrings.customTip),
  ];

  static List<BillLine> checkoutBillLines({
    required ScheduledDeliveryMethod method,
    bool nextDayFree = false,
    double tip = 0.3,
  }) {
    final deliveryValue = method.id == 'next-day' && nextDayFree ? 0.0 : method.priceValue;
    final deliveryLabel = method.id == 'same-day'
        ? 'Same Day delivery'
        : method.id == 'next-day'
            ? 'Next Day delivery'
            : 'Delivery';
    final deliveryDisplay = deliveryValue == 0
        ? 'BHD 0.000'
        : 'BHD ${deliveryValue.toStringAsFixed(3)}';
    final total = 153.0 + deliveryValue + 0.3 + tip;

    return [
      const BillLine(label: 'Subtotal', value: 'BHD 153.000'),
      BillLine(label: deliveryLabel, value: deliveryDisplay),
      const BillLine(label: 'Service fee', value: 'BHD 0.300'),
      if (tip > 0) BillLine(label: 'Tip', value: 'BHD ${tip.toStringAsFixed(3)}'),
      BillLine(
        label: 'Order total',
        value: 'BHD ${total.toStringAsFixed(3)}',
        isBold: true,
      ),
    ];
  }

  static String checkoutTotalFor({
    required ScheduledDeliveryMethod method,
    bool nextDayFree = false,
    double tip = 0.3,
  }) {
    final deliveryValue = method.id == 'next-day' && nextDayFree ? 0.0 : method.priceValue;
    final total = 153.0 + deliveryValue + 0.3 + tip;
    return 'BHD ${total.toStringAsFixed(3)}';
  }

  static List<DropOffOption> get dropOffOptions => CartFlowData.dropOffOptions;

  static List<PaymentOption> get paymentOptions => CartFlowData.paymentOptions;
}
