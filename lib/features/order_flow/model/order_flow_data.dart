import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/l10n/l10n.dart';

abstract final class OrderFlowStrings {
  static String get orderConfirmed => L10n.tr('Order confirmed!');
  static String get trackOrder => L10n.tr('Track order');
  static String get viewReceipt => L10n.tr('View receipt');
  static String get estimatedArrival => L10n.tr('Estimated arrival');
  static String get preparingOrder => L10n.tr('Preparing your order');
  static String get statusLabel => L10n.tr('STATUS');
  static String get orderTotal => L10n.tr('Order total');
  static String get items => L10n.tr('Items');
  static String get deliverTo => L10n.tr('Deliver to');
  static String get arrivesIn => L10n.tr('Arrives in');
  static String get call => L10n.tr('Call');
  static String get chat => L10n.tr('Chat');
  static String get change => L10n.tr('Change');
  static String get contactSupport => L10n.tr('Contact support');
  static String get delivered => L10n.tr('Delivered!');
  static String get deliveredSubtitle => L10n.tr('Hope you enjoyed your order from The Green Kitchen.');
  static String get rateYourOrder => L10n.tr('Rate your order');
  static String get rateYourChamp => L10n.tr('Rate your champ');
  static String get reviewHint => L10n.tr('Write a short review (optional)');
  static String get submitAndDone => L10n.tr('Submit & done');
  static String get receipt => L10n.tr('Receipt');
  static String get receiptSubtitle => L10n.tr('Order #YJK-3920');
  static String get shareReceipt => L10n.tr('Share receipt');
  static String get orderConfirmedBadge => L10n.tr('✓ ORDER CONFIRMED');
  static String get typeDelivery => L10n.tr('Delivery');
  static String get paid => L10n.tr('Paid');
  static String get itemColumn => L10n.tr('ITEM');
  static String get priceColumn => L10n.tr('PRICE');
  static String get messageAhmed => L10n.tr('Message Ahmed…');
  static String get onlineChamp => L10n.tr('● Online · your champ');
  static String get yourChamp => L10n.tr('your champ');
  static String get sentToVendor => L10n.tr('Sent to vendor');
  static String get waitingSubtitle => L10n.tr('Waiting for the vendor to accept your order…');
  static const String notChargedYet =
      "You won't be charged until the vendor accepts your order.";
  static String get cancelOrder => L10n.tr('Cancel order');
  static String get freeCancelHint => L10n.tr('Free cancellation before the vendor accepts');
  static String get payWithinHint => L10n.tr('Complete payment within 5 minutes. If payment is not completed in time, your order will be cancelled automatically.');
  static String get pay => L10n.tr('Pay');
  static String get payIn => L10n.tr('PAY IN');
}

class OrderTimelineStep {
  const OrderTimelineStep({
    required this.label,
    this.time,
    this.completed = false,
    this.active = false,
  });

  final String label;
  final String? time;
  final bool completed;
  final bool active;
}

class OrderReceiptItem {
  const OrderReceiptItem({required this.name, required this.price});

  final String name;
  final String price;
}

class DriverChatMessage {
  const DriverChatMessage({
    required this.text,
    required this.isUser,
    this.quickReplies = const [],
  });

  final String text;
  final bool isUser;
  final List<String> quickReplies;
}

abstract final class OrderFlowData {
  static String get orderId => L10n.tr('YJK-3920');
  static String get orderIdDisplay => L10n.tr('#YJK-3920');
  /// Figma order-status header: "Order #YJK-3920".
  static String get orderStatusTitle => L10n.tr('Order #YJK-3920');
  static String get vendor => L10n.tr('The Green Kitchen');
  static String get vendorLocation => L10n.tr('The Green Kitchen — Seef');
  static String get vendorAddress => L10n.tr('Block 338, Road 3801, Seef · CR 12345');
  static String get deliveryAddress => L10n.tr('Apartment · Seef');
  static String get arrivalWindow => L10n.tr('15–25 min');
  static String get orderTotal => L10n.tr('BHD 2.110');
  static String get itemCount => L10n.tr('2 items');
  static String get orderDate => L10n.tr('17 Jun 2026 · 9:41');
  static String get paymentMethod => L10n.tr('Cash on delivery');
  static String get driverName => L10n.tr('Ahmed K.');
  static String get driverSubtitle => L10n.tr('Ahmed K. · your champ');
  static String get driverMeta => L10n.tr('★ 4.9 · Motorcycle · M 1234');
  static String get driverPlate => L10n.tr('M 1234');

  static const List<OrderTimelineStep> timelineSteps = [
    OrderTimelineStep(label: 'Order confirmed', time: '9:41', completed: true),
    OrderTimelineStep(label: 'Vendor accepted', time: '9:42', completed: true),
    OrderTimelineStep(label: 'Preparing', time: '9:43', completed: true, active: true),
    OrderTimelineStep(label: 'Picked up'),
    OrderTimelineStep(label: 'On the way'),
    OrderTimelineStep(label: 'Delivered'),
  ];

  static const List<OrderReceiptItem> receiptItems = [
    OrderReceiptItem(name: '1× Iced Americano + Choc Muffin', price: 'BHD 2.000'),
    OrderReceiptItem(name: '1× Honey Chocolate Chips', price: 'BHD 0.500'),
  ];

  static const List<BillLine> receiptBillLines = [
    BillLine(label: 'Subtotal', value: 'BHD 2.500'),
    BillLine(label: 'Discount', value: '− BHD 0.500', isDiscount: true),
    BillLine(label: 'Delivery', value: 'Free'),
    BillLine(label: 'Service fee', value: 'BHD 0.110'),
    BillLine(label: 'Total', value: 'BHD 2.110', isBold: true),
  ];

  static const List<DriverChatMessage> driverMessages = [
    DriverChatMessage(
      text: "Hi! I've picked up your order and I'm on my way",
      isUser: false,
    ),
    DriverChatMessage(
      text: 'Great, thank you! Please call when you arrive',
      isUser: true,
    ),
    DriverChatMessage(
      text: "Sure, I'll be there in about 8 minutes.",
      isUser: false,
    ),
    DriverChatMessage(
      text: "I'll come down. The gate is on Road 6055.",
      isUser: true,
    ),
  ];

  static const List<String> chatQuickReplies = [
    "I'm coming down",
    'Leave at door',
    'Call me',
  ];

  static String confirmedSubtitle() =>
      'Order $orderIdDisplay · sent to $vendor.';
}
