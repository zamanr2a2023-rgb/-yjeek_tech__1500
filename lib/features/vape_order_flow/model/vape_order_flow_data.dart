import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

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
  static const String sentToVendor = 'Sent to Vapeology';
  static const String waitingSubtitle =
      'Waiting for the vendor to accept your order…';
  static const String notChargedYet =
      "You won't be charged until the vendor accepts your order.";
  static const String cancelOrder = 'Cancel order';
  static const String freeCancelHint = 'Free cancellation before the vendor accepts';
  static const String vendorAccepted = 'Vapeology said yes! 🙌';
  static const String payWithinHint =
      'Complete payment within 5 minutes. If payment is not completed in time, your order will be cancelled automatically.';
  static const String payWith = 'Pay with';
  static const String change = 'Change';
  static const String subtotal = 'Subtotal';
  static const String sameDayDelivery = 'Same Day delivery';
  static const String serviceFee = 'Service fee';
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
  static const String packedBanner =
      '📦 Packed · out for delivery · arrives in 30–45 mins';
  static const String receipt = 'Receipt';
  static const String shareReceipt = 'Share receipt';
  static const String paidBadge = 'PAID';
  static const String ageNote =
      'Age-restricted (18+) · ID checked on delivery.';
  static const String paidWith = 'Paid: BenefitPay';
  static const String orderNumber = 'Order #';
  static const String items = 'Items';
  static const String delivery = 'Delivery';
  static const String payment = 'Payment';
  static const String total = 'Total';
  static const String orderTotal = 'Order total';
  static const String benefitPay = 'BenefitPay';
}

abstract final class VapeOrderFlowData {
  static const String orderId = 'YJK-2026-00061';
  static const String waitingOrderId = 'YJK-…00061';
  static const String vendorName = 'Vapeology';
  static const String receiptVendor = 'Vapeology';
  static const String statusSubtitle = 'Vape · #$orderId';
  static const String waitingSummary = '1 item · Order $waitingOrderId';
  static const String payTotal = 'BHD 6.610';
  static const String paySubtotal = 'BHD 6.000';
  static const String payDelivery = 'BHD 0.500';
  static const String payServiceFee = 'BHD 0.110';
  static const String confirmedTotal = 'BHD 6.610';
  static const String confirmedItems = 'Mango Ice Disposable';
  static const String confirmedDelivery = 'Same Day · Apartment - Seef';
  static const String confirmedPayment = 'BenefitPay';
  static const String statusItems = 'Mango Ice Disposable';
  static const String statusDelivery = 'Same Day · Apartment - Seef';
  static const String receiptDate = 'Order $orderId · Mon 14 Jun';

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

  static const List<BillLine> receiptBillLines = [
    BillLine(label: 'Subtotal', value: 'BHD 6.500'),
    BillLine(label: 'Discount', value: '- BHD 0.500', isDiscount: true),
    BillLine(label: 'Delivery', value: 'BHD 0.500'),
    BillLine(label: 'Service fee', value: 'BHD 0.110'),
    BillLine(label: 'Total', value: confirmedTotal, isBold: true),
  ];
}
