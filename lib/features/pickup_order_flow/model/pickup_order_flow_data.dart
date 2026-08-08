import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/l10n/l10n.dart';

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
  static String get sentToVendor => L10n.tr('Sent to Brew & Bean');
  static String get waitingSubtitle => L10n.tr('Waiting for the vendor to accept your order…');
  static const String notChargedYet =
      "You won't be charged until the vendor accepts your order.";
  static String get cancelOrder => L10n.tr('Cancel order');
  static String get freeCancelHint => L10n.tr('Free cancellation before the vendor accepts');
  static String get vendorAccepted => L10n.tr('Brew & Bean said yes! 🙌');
  static String get payWithinHint => L10n.tr('Complete payment within 2 minutes. If payment is not completed in time, your order will be cancelled automatically.');
  static String get payWith => L10n.tr('Pay with');
  static String get change => L10n.tr('Change');
  static String get subtotal => L10n.tr('Subtotal');
  static String get pickupDiscount => L10n.tr('Pickup discount (15%)');
  static String get serviceFee => L10n.tr('Service fee');
  static String get deliveryFee => L10n.tr('Delivery fee');
  static String get tip => L10n.tr('Tip');
  static String get totalToPay => L10n.tr('Total to pay');
  static String get pay => L10n.tr('Pay');
  static String get payIn => L10n.tr('PAY IN');
  static String get orderConfirmed => L10n.tr('Order confirmed');
  static String get preparedForPickup => L10n.tr('Your order is being prepared for pickup.');
  static String get trackOrder => L10n.tr('Track order');
  static String get viewReceipt => L10n.tr('View receipt');
  static const String imHere = "I'm here";
  static String get paymentExpired => L10n.tr('Payment window expired. Your order was cancelled.');
  static String get orderStatus => L10n.tr('Order status');
  static const String notifyBanner =
      "We'll notify you the moment your order is ready to collect.";
  static String get preparingBanner => L10n.tr('Preparing · ready in ~8 min');
  static String get statusSection => L10n.tr('STATUS');
  static String get receipt => L10n.tr('Receipt');
  static String get shareReceipt => L10n.tr('Share receipt');
  static String get paidBadge => L10n.tr('PICKUP · PAID');
  static String get collectNote => L10n.tr('Show this receipt at the counter to collect.');
  static String get paidWith => L10n.tr('Paid: Yjeek Wallet');
  static String get orderNumber => L10n.tr('Order #');
  static String get items => L10n.tr('Items');
  static String get pickup => L10n.tr('Pickup');
  static String get payment => L10n.tr('Payment');
  static String get total => L10n.tr('Total');
  static String get orderTotal => L10n.tr('Order total');
  static String get yjeekWallet => L10n.tr('Yjeek Wallet');
}

abstract final class PickupOrderFlowData {
  static String get orderId => L10n.tr('YJK-2026-00091');
  static String get waitingOrderId => L10n.tr('YJK-…00091');
  static String get vendorName => L10n.tr('Brew & Bean');
  static String get statusSubtitle => L10n.tr('Pickup · #$orderId');
  static String get waitingSummary => L10n.tr('4 items · Order $waitingOrderId');
  static String get payTotal => L10n.tr('BHD 5.675');
  static String get paySubtotal => L10n.tr('BHD 6.500');
  static String get payDiscount => L10n.tr('− BHD 0.975');
  static String get payServiceFee => L10n.tr('BHD 0.150');
  static String get confirmedTotal => L10n.tr('BHD 5.675');
  static String get confirmedItems => L10n.tr('Iced Caramel Latte + 3 more');
  static String get confirmedPickup => L10n.tr('Brew & Bean · ready in ~8 min');
  static String get confirmedPayment => L10n.tr('Yjeek Wallet');
  static String get statusItems => L10n.tr('Iced Caramel Latte + 3 more');
  static String get statusPickup => L10n.tr('Brew & Bean · Seef');
  static String get receiptDate => L10n.tr('Order $orderId · Seef');
  static String get walletBalance => L10n.tr('Balance BHD 12.450');

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

  static final List<BillLine> receiptBillLines = [
    BillLine(label: 'Subtotal', value: 'BHD 6.500'),
    BillLine(label: 'Pickup discount (15%)', value: '− BHD 0.975', isDiscount: true),
    BillLine(label: 'Service fee', value: 'BHD 0.150'),
    BillLine(label: 'Total', value: confirmedTotal, isBold: true),
  ];
}
