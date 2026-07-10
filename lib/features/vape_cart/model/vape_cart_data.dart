import 'package:flutter/material.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

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
    required this.color,
  });

  final String name;
  final String price;
  final Color color;
}

class VapeDeliveryMethod {
  const VapeDeliveryMethod({
    required this.id,
    required this.label,
    required this.price,
    required this.priceValue,
    this.subtitle,
  });

  final String id;
  final String label;
  final String price;
  final double priceValue;
  final String? subtitle;
}

abstract final class VapeCartStrings {
  static const String cart = 'Cart';
  static const String checkout = 'Checkout';
  static const String reviewConfirm = 'Review & confirm';
  static const String yourItems = 'Your items';
  static const String youMightAlsoLike = 'You might also like';
  static const String promoCode = 'Have a promo code?';
  static const String edit = 'Edit';
  static const String deliveryDetails = 'Delivery details';
  static const String deliveryMethod = 'Delivery method';
  static const String dropOffPreferences = 'Drop-off preferences';
  static const String tipYourChamp = 'Tip your champ';
  static const String paymentMethod = 'Payment method';
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
  static const String orderType = 'VAPEOLOGY · VAPE DELIVERY';
  static const String method = 'Method';
  static const String deliverTo = 'Deliver to';
  static const String payment = 'Payment';
  static const String orderTotal = 'Order total';
  static const String cashOnDelivery = 'Cash on delivery';
  static const String customTip = 'Custom';
  static const String verified = 'VERIFIED ✓';
  static const String verifiedNote =
      'Your CPR is verified by Yjeek. The champ still checks your ID (18+) on delivery.';
  static const String arrivesIn = 'Arrives in 30–45 mins';
  static const String verifyTitle = 'Verify your age first';
  static const String verifyBody =
      'This is an age-restricted (18+) order. You need to upload your CPR and documents and get verified before you can place this order.';
  static const String goToVerification = 'Go to verification';
  static const String notNow = 'Not now';
  static const String cashbackEarn = 'Earn 2% cashback to your Wallet';
}

abstract final class VapeCartData {
  static const String vendor = 'Vapeology';
  static const String selectedAddress = 'Apartment - Seef';
  static const String selectedAddressDetail = 'Seef - Block 428, Road 6000, Bldg 23';
  static const String orderTotal = 'BHD 6.610';
  static const String cashbackAmount = '+ BHD 0.130';

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
      color: Color(0xFFE8ECF5),
    ),
    VapeUpsellItem(
      name: 'Watermelon Ice',
      price: 'BHD 6.500',
      color: Color(0xFFFFE8EC),
    ),
    VapeUpsellItem(
      name: 'Mint Tobacco',
      price: 'BHD 6.500',
      color: Color(0xFFE3F2EB),
    ),
  ];

  static const List<BillLine> cartBillLines = [
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
      subtitle: '1–2 days',
      price: 'BHD 1.000',
      priceValue: 1.0,
    ),
    VapeDeliveryMethod(
      id: 'economy',
      label: 'Economy',
      subtitle: '3–7 days',
      price: 'BHD 0.500',
      priceValue: 0.5,
    ),
  ];

  static const List<TipOption> tipOptions = [
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
      const BillLine(label: 'Service fee', value: 'BHD 0.110'),
      if (tip > 0) BillLine(label: 'Tip', value: 'BHD ${tip.toStringAsFixed(3)}'),
      const BillLine(label: 'Order total', value: orderTotal, isBold: true),
    ];
  }

  static String checkoutTotalFor({
    required VapeDeliveryMethod method,
    double tip = 0,
  }) =>
      orderTotal;
}
