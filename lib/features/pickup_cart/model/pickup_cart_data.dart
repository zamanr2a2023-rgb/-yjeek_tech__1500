import 'package:flutter/material.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/l10n/l10n.dart';

class PickupCartItem {
  const PickupCartItem({
    required this.name,
    required this.price,
    this.subtitle,
    this.quantity = 1,
  });

  final String name;
  final String price;
  final String? subtitle;
  final int quantity;
}

class PickupUpsellItem {
  const PickupUpsellItem({
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

abstract final class PickupCartStrings {
  static String get cart => L10n.tr('Cart');
  static String get checkout => L10n.tr('Checkout');
  static String get reviewConfirm => L10n.tr('Review & confirm');
  static String get yourItems => L10n.tr('Your items');
  static String get youMightAlsoLike => L10n.tr('You might also like');
  static String get promoCode => L10n.tr('Have a promo code?');
  static String get pickupDetails => L10n.tr('Pickup details');
  static String get pickupTime => L10n.tr('Pickup time');
  static String get pickupTimeLabel => L10n.tr('Pickup time ·');
  static String get paymentMethod => L10n.tr('Payment method');
  static String get billSummary => L10n.tr('Bill summary');
  static String get placeOrder => L10n.tr('Place order');
  static String get goToCheckout => L10n.tr('Go to checkout');
  static String get placingOrder => L10n.tr('Placing your order');
  static String get autoConfirmHint => L10n.tr('Auto-confirms in 10 seconds. You can still edit or cancel before then.');
  static String get orderSummary => L10n.tr('Order summary');
  static String get editOrder => L10n.tr('Edit order');
  static String get sendToVendor => L10n.tr('Send to vendor');
  static String get orderType => L10n.tr('BREW & BEAN · PICKUP');
  static String get method => L10n.tr('Method');
  static String get pickupMethod => L10n.tr('Pickup');
  static String get collectAt => L10n.tr('Collect at');
  static String get payment => L10n.tr('Payment');
  static String get orderTotal => L10n.tr('Order total');
  static String get applePay => L10n.tr('Apple Pay');
  static String get map => L10n.tr('Map');
  static String get change => L10n.tr('Change');
  static String get pickupFrom => L10n.tr('Pickup from');
  static String get tip => L10n.tr('Tip');
  static String get customTip => L10n.tr('Custom');
  static String get policyWarning => L10n.tr('Please collect on time. No-show within 1 hour of the ready time is non-refundable.');
  static String get paymentNote => L10n.tr('You can pay with any method and use your Yjeek Wallet balance together.');
  static String get cashbackEarn => L10n.tr('Earn 3% cashback to your Wallet');
}

abstract final class PickupCartData {
  static String get vendor => L10n.tr('Brew & Bean');
  static String get vendorLocation => L10n.tr('Brew & Bean · Seef');
  static String get pickupAddress => L10n.tr('Seef Blvd, Shop 12 · 0.4 km away');
  static String get checkoutAddress => L10n.tr('Shop 12, Seef Blvd · 0.4 km');
  static String get readyIn => L10n.tr('Ready in ~8 min');
  static String get pickupTime => L10n.tr('Today · 19:30');
  static String get collectAt => L10n.tr('Apartment · Seef');
  static String get checkoutTotal => L10n.tr('BHD 4.290');
  static String get orderTotal => L10n.tr('BHD 4.290');
  static String get cashbackAmount => L10n.tr('+ BHD 0.129');
  static String get walletBalance => L10n.tr('Balance BHD 12.450');
  static String get pickupBadge => L10n.tr('PICKUP');

  static const List<PickupCartItem> cartItems = [
    PickupCartItem(
      name: 'Iced Caramel Latte',
      subtitle: 'Large · oat milk',
      price: 'BHD 2.100',
    ),
    PickupCartItem(
      name: 'Butter Croissant',
      price: 'BHD 1.200',
    ),
    PickupCartItem(
      name: 'Choc Chip Cookie',
      quantity: 2,
      price: 'BHD 1.600',
    ),
  ];

  static const List<PickupUpsellItem> upsellItems = [
    PickupUpsellItem(
      name: 'Flat White',
      price: 'BHD 1.800',
      gradientStart: Color(0xFF6B4A2A),
      gradientEnd: Color(0xFF15302B),
    ),
    PickupUpsellItem(
      name: 'Blueberry Muffin',
      price: 'BHD 1.400',
      gradientStart: Color(0xFF8A5B2A),
      gradientEnd: Color(0xFF15302B),
    ),
    PickupUpsellItem(
      name: 'Banana Bread',
      price: 'BHD 1.500',
      gradientStart: Color(0xFF7A4A22),
      gradientEnd: Color(0xFF15302B),
    ),
  ];

  static final List<BillLine> cartBillLines = [
    BillLine(label: 'Subtotal', value: 'BHD 4.900'),
    BillLine(label: 'Discount', value: '− BHD 0.735', isDiscount: true),
    BillLine(label: 'Delivery', value: 'BHD 0.450'),
    BillLine(label: 'Service fee', value: 'BHD 0.125'),
    BillLine(label: 'Order total', value: orderTotal, isBold: true),
  ];

  /// Same tip chips as Electronics scheduled checkout.
  static final List<TipOption> tipOptions = [
    TipOption(label: 'BHD 0.300', amount: 0.3),
    TipOption(label: 'BHD 0.500', amount: 0.5),
    TipOption(label: 'BHD 1', amount: 1),
    TipOption(label: PickupCartStrings.customTip),
  ];

  static List<BillLine> checkoutBillLines({double tip = 0.3}) {
    const subtotal = 6.0;
    const service = 0.11;
    final total = subtotal + service + tip;
    return [
      const BillLine(label: 'Subtotal', value: 'BHD 6.000'),
      const BillLine(label: 'Service fee', value: 'BHD 0.110'),
      if (tip > 0)
        BillLine(label: PickupCartStrings.tip, value: 'BHD ${tip.toStringAsFixed(3)}'),
      BillLine(
        label: 'Order total',
        value: 'BHD ${total.toStringAsFixed(3)}',
        isBold: true,
      ),
    ];
  }

  static String checkoutTotalFor({double tip = 0.3}) {
    final total = 6.0 + 0.11 + tip;
    return 'BHD ${total.toStringAsFixed(3)}';
  }

  /// Same payment list chrome as Electronics scheduled checkout.
  static List<PaymentOption> get paymentOptions => CartFlowData.paymentOptions;
}
