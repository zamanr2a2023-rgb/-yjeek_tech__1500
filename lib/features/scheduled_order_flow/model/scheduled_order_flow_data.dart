import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

class ScheduledOrderTimelineStep {
  const ScheduledOrderTimelineStep({
    required this.label,
    this.time,
    this.completed = false,
  });

  final String label;
  final String? time;
  final bool completed;
}

class ScheduledReceiptLine {
  const ScheduledReceiptLine({
    required this.name,
    required this.price,
  });

  final String name;
  final String price;
}

abstract final class ScheduledOrderFlowStrings {
  static const String sentToVendor = 'Sent to TechHub Electronics';
  static const String waitingSubtitle =
      'Waiting for the vendor to accept your order…';
  static const String notChargedYet =
      "You won't be charged until the vendor accepts your order.";
  static const String cancelOrder = 'Cancel order';
  static const String freeCancelHint =
      'Free cancellation before the vendor accepts.';
  static const String vendorAccepted = 'TechHub Electronics said yes! 🙌';
  static const String payWithinTitle = 'Complete payment within 5 minutes';
  static const String payWithinSubtitle =
      'If payment is not completed in time, your order will be cancelled automatically.';
  static const String payWithinHint =
      'Complete payment within 5 minutes. If payment is not completed in time, your order will be cancelled automatically.';
  static const String payWith = 'Pay with';
  static const String tapPayToComplete = 'Tap pay to complete';
  static const String change = 'Change';
  static const String subtotal = 'Subtotal';
  static const String sameDayDelivery = 'Same Day delivery';
  static const String totalToPay = 'Total to pay';
  static const String pay = 'Pay';
  static const String payIn = 'PAY IN';
  static const String orderConfirmed = 'Order confirmed';
  static const String preparedForDelivery =
      'Your order is being prepared for delivery.';
  static const String trackOrder = 'Track order';
  static const String viewReceipt = 'View receipt';
  static const String orderStatus = 'Order status';
  static const String liveMapHint =
      'Live map tracking starts when the champ picks up your order.';
  static const String packedBanner = '📦 Packed · ships today · arrives tomorrow';
  static const String receipt = 'Receipt';
  static const String shareReceipt = 'Share receipt';
  static const String paidBadge = 'PAID';
  static const String warrantyNote = '1-year warranty included on all devices.';
  static const String paidWith = 'Paid: Yjeek Wallet';
  static const String orderNumber = 'Order #';
  static const String items = 'Items';
  static const String delivery = 'Delivery';
  static const String payment = 'Payment';
  static const String total = 'Total';
  static const String orderTotal = 'Order total';
  static const String applePay = 'Apple Pay';
}

abstract final class ScheduledOrderFlowData {
  static const String orderId = 'YJK-2026-00061';
  static const String waitingOrderId = 'YJK-…00043';
  static const String vendorName = 'TechHub Electronics';
  static const String receiptVendor = 'Yjeek Electronics';
  static const String statusSubtitle = 'Electronics · #$orderId';
  static const String waitingSummary = '1 item · Order $waitingOrderId';
  static const String payTotal = 'BHD 43.310';
  static const String paySubtotal = 'BHD 42.000';
  static const String payDelivery = 'BHD 1.310';
  static const String confirmedTotal = 'BHD 154.300';
  static const String confirmedItems = 'Nova 12 + 2 more';
  static const String confirmedDelivery = 'Tomorrow · 10am–2pm';
  static const String confirmedPayment = 'Yjeek Wallet';
  static const String statusItems = 'Nova 12 + 2 more';
  static const String statusDelivery = 'Tomorrow · 10am–2pm';
  static const String receiptDate = 'Order $orderId · Mon 14 Jun';

  static const List<ScheduledOrderTimelineStep> statusTimeline = [
    ScheduledOrderTimelineStep(label: 'Order confirmed', time: '9:41', completed: true),
    ScheduledOrderTimelineStep(label: 'Vendor accepted', time: '9:42', completed: true),
    ScheduledOrderTimelineStep(label: 'Preparing', time: '9:43', completed: true),
    ScheduledOrderTimelineStep(label: 'Picked up', time: '—'),
    ScheduledOrderTimelineStep(label: 'On the way', time: '—'),
    ScheduledOrderTimelineStep(label: 'Delivered', time: '—'),
  ];

  static const List<ScheduledReceiptLine> receiptItems = [
    ScheduledReceiptLine(name: 'Nova 12 smartphone ×1', price: 'BHD 119.000'),
    ScheduledReceiptLine(name: 'Pulse Buds Pro ×1', price: 'BHD 28.000'),
    ScheduledReceiptLine(name: 'Fast charger 33W ×1', price: 'BHD 6.000'),
  ];

  static const List<BillLine> receiptBillLines = [
    BillLine(label: 'Subtotal', value: 'BHD 153.000'),
    BillLine(label: 'Delivery', value: 'BHD 1.000'),
    BillLine(label: 'Service fee', value: 'BHD 0.300'),
    BillLine(label: 'Total', value: confirmedTotal, isBold: true),
  ];
}
