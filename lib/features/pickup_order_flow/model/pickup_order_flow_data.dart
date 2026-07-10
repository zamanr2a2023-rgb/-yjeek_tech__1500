import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

class PickupOrderTimelineStep {
  const PickupOrderTimelineStep({
    required this.label,
    this.time,
    this.completed = false,
  });

  final String label;
  final String? time;
  final bool completed;
}

class PickupReceiptLine {
  const PickupReceiptLine({
    required this.name,
    required this.price,
  });

  final String name;
  final String price;
}

abstract final class PickupOrderFlowStrings {
  static const String sentToVendor = 'Sent to Brew & Bean';
  static const String waitingSubtitle =
      'Waiting for the vendor to accept your order…';
  static const String notChargedYet =
      "You won't be charged until the vendor accepts your order.";
  static const String cancelOrder = 'Cancel order';
  static const String freeCancelHint = 'Free cancellation before the vendor accepts';
  static const String vendorAccepted = 'Brew & Bean said yes! 🙌';
  static const String payWithinHint =
      'Complete payment within 2 minutes. If payment is not completed in time, your order will be cancelled automatically.';
  static const String payWith = 'Pay with';
  static const String change = 'Change';
  static const String subtotal = 'Subtotal';
  static const String pickupDiscount = 'Pickup discount (15%)';
  static const String serviceFee = 'Service fee';
  static const String totalToPay = 'Total to pay';
  static const String pay = 'Pay';
  static const String payIn = 'PAY IN';
  static const String orderConfirmed = 'Order confirmed';
  static const String preparedForPickup =
      'Your order is being prepared for pickup.';
  static const String trackOrder = 'Track order';
  static const String viewReceipt = 'View receipt';
  static const String orderStatus = 'Order status';
  static const String notifyBanner =
      "We'll notify you the moment your order is ready to collect.";
  static const String preparingBanner = 'Preparing · ready in ~8 min';
  static const String statusSection = 'STATUS';
  static const String receipt = 'Receipt';
  static const String shareReceipt = 'Share receipt';
  static const String paidBadge = 'PICKUP · PAID';
  static const String collectNote = 'Show this receipt at the counter to collect.';
  static const String paidWith = 'Paid: Yjeek Wallet';
  static const String orderNumber = 'Order #';
  static const String items = 'Items';
  static const String pickup = 'Pickup';
  static const String payment = 'Payment';
  static const String total = 'Total';
  static const String orderTotal = 'Order total';
  static const String yjeekWallet = 'Yjeek Wallet';
}

abstract final class PickupOrderFlowData {
  static const String orderId = 'YJK-2026-00091';
  static const String waitingOrderId = 'YJK-…00091';
  static const String vendorName = 'Brew & Bean';
  static const String statusSubtitle = 'Pickup · #$orderId';
  static const String waitingSummary = '4 items · Order $waitingOrderId';
  static const String payTotal = 'BHD 5.675';
  static const String paySubtotal = 'BHD 6.500';
  static const String payDiscount = '− BHD 0.975';
  static const String payServiceFee = 'BHD 0.150';
  static const String confirmedTotal = 'BHD 5.675';
  static const String confirmedItems = 'Iced Caramel Latte + 3 more';
  static const String confirmedPickup = 'Brew & Bean · ready in ~8 min';
  static const String confirmedPayment = 'Yjeek Wallet';
  static const String statusItems = 'Iced Caramel Latte + 3 more';
  static const String statusPickup = 'Brew & Bean · Seef';
  static const String receiptDate = 'Order $orderId · Seef';
  static const String walletBalance = 'Balance BHD 12.450';

  static const List<PickupOrderTimelineStep> statusTimeline = [
    PickupOrderTimelineStep(label: 'Order placed', time: '14:02', completed: true),
    PickupOrderTimelineStep(label: 'Vendor accepted', time: '14:03', completed: true),
    PickupOrderTimelineStep(label: 'Preparing', time: '14:05', completed: true),
    PickupOrderTimelineStep(label: 'Ready for pickup', time: '--'),
    PickupOrderTimelineStep(label: 'Collected', time: '--'),
  ];

  static const List<PickupReceiptLine> receiptItems = [
    PickupReceiptLine(name: 'Iced Caramel Latte ×1', price: 'BHD 2.100'),
    PickupReceiptLine(name: 'Butter Croissant ×1', price: 'BHD 1.200'),
    PickupReceiptLine(name: 'Choc Chip Cookie ×1', price: 'BHD 1.600'),
    PickupReceiptLine(name: 'Flat White ×1', price: 'BHD 1.600'),
  ];

  static const List<BillLine> receiptBillLines = [
    BillLine(label: 'Subtotal', value: 'BHD 6.500'),
    BillLine(label: 'Pickup discount (15%)', value: '− BHD 0.975', isDiscount: true),
    BillLine(label: 'Service fee', value: 'BHD 0.150'),
    BillLine(label: 'Total', value: confirmedTotal, isBold: true),
  ];
}
