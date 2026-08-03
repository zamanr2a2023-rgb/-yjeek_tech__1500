import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/l10n/l10n.dart';

class VapeOrderTimelineStep {
  const VapeOrderTimelineStep({
    required this.label,
    this.time,
    this.completed = false,
  });

  final String label;
  final String? time;
  final bool completed;
}

class VapeReceiptLine {
  const VapeReceiptLine({
    required this.name,
    required this.price,
  });

  final String name;
  final String price;
}

abstract final class VapeOrderFlowStrings {
  static String get sentToVendor => L10n.tr('Sent to Vapeology');
  static String get waitingSubtitle => L10n.tr('Waiting for the vendor to accept your order…');
  static const String notChargedYet =
      "You won't be charged until the vendor accepts your order.";
  static String get cancelOrder => L10n.tr('Cancel order');
  static String get freeCancelHint => L10n.tr('Free cancellation before the vendor accepts');
  static String get vendorAccepted => L10n.tr('Vapeology said yes! 🙌');
  static String get payWithinTitle => L10n.tr('Complete payment within 5 minutes');
  static String get payWithinSubtitle => L10n.tr('If payment is not completed in time, your order will be cancelled automatically.');
  static String get payWithinHint => L10n.tr('Complete payment within 5 minutes. If payment is not completed in time, your order will be cancelled automatically.');
  static String get payWith => L10n.tr('Pay with');
  static String get tapPayToComplete => L10n.tr('Tap pay to complete');
  static String get change => L10n.tr('Change');
  static String get subtotal => L10n.tr('Subtotal');
  static String get sameDayDelivery => L10n.tr('Same Day delivery');
  static String get serviceFee => L10n.tr('Service fee');
  static String get totalToPay => L10n.tr('Total to pay');
  static String get pay => L10n.tr('Pay');
  static String get payIn => L10n.tr('PAY IN');
  static String get orderConfirmed => L10n.tr('Order confirmed');
  static String get preparedForDelivery => L10n.tr('Your order is being prepared for delivery.');
  static String get trackOrder => L10n.tr('Track order');
  static String get viewReceipt => L10n.tr('View receipt');
  static String get orderStatus => L10n.tr('Order status');
  static String get liveMapHint => L10n.tr('Live map tracking starts when the champ picks up your order.');
  static String get packedBanner => L10n.tr('📦 Packed · out for delivery · arrives in 30–45 mins');
  static String get receipt => L10n.tr('Receipt');
  static String get shareReceipt => L10n.tr('Share receipt');
  static String get paidBadge => L10n.tr('PAID');
  static String get ageNote => L10n.tr('Age-restricted (18+) · ID checked on delivery.');
  /// Receipt footer note (vape-specific; electronics uses warranty).
  static String warrantyNote = ageNote;
  static String get paidWith => L10n.tr('Paid: BenefitPay');
  static String get orderNumber => L10n.tr('Order #');
  static String get items => L10n.tr('Items');
  static String get delivery => L10n.tr('Delivery');
  static String get payment => L10n.tr('Payment');
  static String get total => L10n.tr('Total');
  static String get orderTotal => L10n.tr('Order total');
  static String get benefitPay => L10n.tr('BenefitPay');
  static String get applePay => L10n.tr('BenefitPay');
}

abstract final class VapeOrderFlowData {
  static String get orderId => L10n.tr('YJK-2026-00061');
  static String get waitingOrderId => L10n.tr('YJK-…00061');
  static String get vendorName => L10n.tr('Vapeology');
  static String get receiptVendor => L10n.tr('Vapeology');
  static String get statusSubtitle => L10n.tr('Vape · #$orderId');
  static String get waitingSummary => L10n.tr('1 item · Order $waitingOrderId');
  static String get payTotal => L10n.tr('BHD 6.610');
  static String get paySubtotal => L10n.tr('BHD 6.000');
  static String get payDelivery => L10n.tr('BHD 0.500');
  static String get payServiceFee => L10n.tr('BHD 0.110');
  static String get confirmedTotal => L10n.tr('BHD 6.610');
  static String get confirmedItems => L10n.tr('Mango Ice Disposable');
  static String get confirmedDelivery => L10n.tr('Same Day · Apartment - Seef');
  static String get confirmedPayment => L10n.tr('BenefitPay');
  static String get statusItems => L10n.tr('Mango Ice Disposable');
  static String get statusDelivery => L10n.tr('Same Day · Apartment - Seef');
  static String get receiptDate => L10n.tr('Order $orderId · Mon 14 Jun');

  static const List<VapeOrderTimelineStep> statusTimeline = [
    VapeOrderTimelineStep(label: 'Order confirmed', time: '9:41', completed: true),
    VapeOrderTimelineStep(label: 'Vendor accepted', time: '9:42', completed: true),
    VapeOrderTimelineStep(label: 'Preparing', time: '9:43', completed: true),
    VapeOrderTimelineStep(label: 'Picked up', time: '--'),
    VapeOrderTimelineStep(label: 'On the way', time: '--'),
    VapeOrderTimelineStep(label: 'Delivered', time: '--'),
  ];

  static const List<VapeReceiptLine> receiptItems = [
    VapeReceiptLine(name: 'Mango Ice Disposable ×1', price: 'BHD 6.500'),
  ];

  static final List<BillLine> receiptBillLines = [
    BillLine(label: 'Subtotal', value: 'BHD 6.500'),
    BillLine(label: 'Discount', value: '- BHD 0.500', isDiscount: true),
    BillLine(label: 'Delivery', value: 'BHD 0.500'),
    BillLine(label: 'Service fee', value: 'BHD 0.110'),
    BillLine(label: 'Total', value: confirmedTotal, isBold: true),
  ];
}
