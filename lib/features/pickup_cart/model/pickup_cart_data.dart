import 'package:flutter/material.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

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
    required this.color,
  });

  final String name;
  final String price;
  final Color color;
}

abstract final class PickupCartStrings {
  static const String cart = 'Cart';
  static const String checkout = 'Checkout';
  static const String reviewConfirm = 'Review & confirm';
  static const String yourItems = 'Your items';
  static const String youMightAlsoLike = 'You might also like';
  static const String promoCode = 'Have a promo code?';
  static const String pickupDetails = 'Pickup details';
  static const String pickupTime = 'Pickup time';
  static const String pickupTimeLabel = 'Pickup time ·';
  static const String paymentMethod = 'Payment method';
  static const String billSummary = 'Bill summary';
  static const String placeOrder = 'Place order';
  static const String goToCheckout = 'Go to checkout';
  static const String placingOrder = 'Placing your order';
  static const String autoConfirmHint =
      'Auto-confirms in 10 seconds. You can still edit or cancel before then.';
  static const String orderSummary = 'Order summary';
  static const String editOrder = 'Edit order';
  static const String sendToVendor = 'Send to vendor';
  static const String orderType = 'BREW & BEAN · PICKUP';
  static const String method = 'Method';
  static const String pickupMethod = 'Pickup';
  static const String collectAt = 'Collect at';
  static const String payment = 'Payment';
  static const String orderTotal = 'Order total';
  static const String applePay = 'Apple Pay';
  static const String map = 'Map';
  static const String change = 'Change';
  static const String pickupFrom = 'Pickup from';
  static const String policyWarning =
      'Please collect on time. No-show within 1 hour of the ready time is non-refundable.';
  static const String paymentNote =
      'You can pay with any method and use your Yjeek Wallet balance together.';
  static const String cashbackEarn = 'Earn 3% cashback to your Wallet';
}

abstract final class PickupCartData {
  static const String vendor = 'Brew & Bean';
  static const String vendorLocation = 'Brew & Bean · Seef';
  static const String pickupAddress = 'Seef Blvd, Shop 12 · 0.4 km away';
  static const String readyIn = 'Ready in ~8 min';
  static const String pickupTime = 'Today · 19:30';
  static const String collectAt = 'Apartment · Seef';
  static const String checkoutTotal = 'BHD 4.900';
  static const String orderTotal = 'BHD 6.610';
  static const String cashbackAmount = '+ BHD 0.198';
  static const String walletBalance = 'Balance BHD 12.450';

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
      name: 'Blue Razz',
      price: 'BHD 6.500',
      color: Color(0xFFE8ECF5),
    ),
    PickupUpsellItem(
      name: 'Watermelon Ice',
      price: 'BHD 6.500',
      color: Color(0xFFFFE8EC),
    ),
    PickupUpsellItem(
      name: 'Mint Tobacco',
      price: 'BHD 6.500',
      color: Color(0xFFE3F2EB),
    ),
  ];

  static const List<BillLine> cartBillLines = [
    BillLine(label: 'Subtotal', value: 'BHD 6.500'),
    BillLine(label: 'Discount', value: '− BHD 0.500', isDiscount: true),
    BillLine(label: 'Delivery', value: 'BHD 0.500'),
    BillLine(label: 'Service fee', value: 'BHD 0.110'),
    BillLine(label: 'Order total', value: orderTotal, isBold: true),
  ];

  static List<PaymentOption> get paymentOptions => [
    const PaymentOption(
      id: 'benefitpay',
      label: 'BenefitPay',
      icon: Icons.account_balance_wallet_outlined,
      selected: true,
    ),
    ...CartFlowData.paymentOptions.where((o) => o.id != 'benefitpay' && o.id != 'cod'),
  ];
}
