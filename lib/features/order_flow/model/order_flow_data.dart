import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

abstract final class OrderFlowStrings {
  static const String orderConfirmed = 'Order confirmed!';
  static const String trackOrder = 'Track order';
  static const String viewReceipt = 'View receipt';
  static const String estimatedArrival = 'Estimated arrival';
  static const String preparingOrder = 'Preparing your order';
  static const String statusLabel = 'STATUS';
  static const String orderTotal = 'Order total';
  static const String items = 'Items';
  static const String deliverTo = 'Deliver to';
  static const String arrivesIn = 'Arrives in';
  static const String call = 'Call';
  static const String chat = 'Chat';
  static const String change = 'Change';
  static const String contactSupport = 'Contact support';
  static const String delivered = 'Delivered!';
  static const String deliveredSubtitle =
      'Hope you enjoyed your order from The Green Kitchen.';
  static const String rateYourOrder = 'Rate your order';
  static const String rateYourChamp = 'Rate your champ';
  static const String submitAndDone = 'Submit & done';
  static const String receipt = 'Receipt';
  static const String receiptSubtitle = 'Order #YJK-3920';
  static const String shareReceipt = 'Share receipt';
  static const String orderConfirmedBadge = '✓ ORDER CONFIRMED';
  static const String typeDelivery = 'Delivery';
  static const String paid = 'Paid';
  static const String itemColumn = 'ITEM';
  static const String priceColumn = 'PRICE';
  static const String messageAhmed = 'Message Ahmed…';
  static const String onlineChamp = '● Online · your champ';
  static const String yourChamp = 'your champ';
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
  static const String orderId = 'YJK-3920';
  static const String orderIdDisplay = '#YJK-3920';
  /// Figma order-status header: "Order #YJK-3920".
  static const String orderStatusTitle = 'Order #YJK-3920';
  static const String vendor = 'The Green Kitchen';
  static const String vendorLocation = 'The Green Kitchen — Seef';
  static const String vendorAddress = 'Block 338, Road 3801, Seef · CR 12345';
  static const String deliveryAddress = 'Apartment · Seef';
  static const String arrivalWindow = '15–25 min';
  static const String orderTotal = 'BHD 2.110';
  static const String itemCount = '2 items';
  static const String orderDate = '17 Jun 2026 · 9:41';
  static const String paymentMethod = 'Cash on delivery';
  static const String driverName = 'Ahmed K.';
  static const String driverSubtitle = 'Ahmed K. · your champ';
  static const String driverMeta = '★ 4.9 · Motorcycle · M 1234';
  static const String driverPlate = 'M 1234';

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
