import 'package:flutter/material.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

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
  });

  final String id;
  final String label;
  final String price;
  final double priceValue;
  final String? subtitle;
  final bool freeAfterNoon;
}

abstract final class ScheduledCartStrings {
  static const String cart = 'Cart';
  static const String checkout = 'Checkout';
  static const String reviewConfirm = 'Review & confirm';
  static const String addMorePrompt = 'Add more ... ?';
  static const String promoCode = 'Have a promo code?';
  static const String deliveryAddress = 'Delivery address';
  static const String deliveryMethod = 'Delivery method';
  static const String dropOffPreferences = 'Drop-off preferences';
  static const String paymentMethod = 'Payment method';
  static const String tipYourChamp = 'Tip your champ';
  static const String billSummary = 'Bill summary';
  static const String placeOrder = 'Place order';
  static const String addMore = 'Add more';
  static const String checkoutBtn = 'Checkout';
  static const String placingOrder = 'Placing your order';
  static const String autoConfirmHint =
      'Auto-confirms in 10 seconds. You can still edit or cancel before then.';
  static const String orderSummary = 'Order summary';
  static const String editOrder = 'Edit order';
  static const String sendToVendor = 'Send to vendor';
  static const String vendorNote =
      'scheduled cart: user can add items from different vendors, MAX 3';
  static const String paymentNote =
      "You won't be charged now. Once the vendor accepts, you'll have 5 minutes to pay";
  static const String walletNote =
      'You can pay with any method and use your Yjeek Wallet balance together.';
  static const String cashbackEarn = 'Earn 3% cashback to your Wallet';
  static const String orderType = 'TECHHUB ELECTRONICS · SCHEDULED DELIVERY';
  static const String method = 'Method';
  static const String deliverTo = 'Deliver to';
  static const String payment = 'Payment';
  static const String orderTotal = 'Order total';
  static const String cashOnDelivery = 'Cash on delivery';
  static const String customTip = 'Custom';
}

abstract final class ScheduledCartData {
  static const String vendor = 'TechHub Electronics';
  static const String selectedAddress = 'Apartment - Seef';
  static const String selectedAddressDetail = 'Road 6000, Bldg 23, Flat 82';
  static const String walletBalance = 'Balance BHD 12.450';
  static const String cartTotal = 'BHD 154.300';
  static const String checkoutTotal = 'BHD 154.300';
  static const String reviewTotal = 'BHD 154.300';
  static const String cashbackAmount = '+ BHD 1.260';

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

  static const List<BillLine> cartBillLines = [
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

  static const List<TipOption> tipOptions = [
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
