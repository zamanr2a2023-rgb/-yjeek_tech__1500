import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

class DineInOrderTimelineStep {
  const DineInOrderTimelineStep({
    required this.label,
    this.subtitle,
    this.time,
    this.completed = false,
    this.active = false,
  });

  final String label;
  final String? subtitle;
  final String? time;
  final bool completed;
  final bool active;
}

class DineInReceiptItem {
  const DineInReceiptItem({required this.name, required this.price});

  final String name;
  final String price;
}

abstract final class DineInOrderFlowStrings {
  static const String sentToVendor = 'Sent to VEERA';
  static const String waitingSubtitle =
      'Waiting for the vendor to accept your dine-in order…';
  static const String notChargedYet =
      "You won't be charged until the vendor accepts your order.";
  static const String cancelOrder = 'Cancel order';
  static const String freeCancelHint =
      'Free cancellation before the vendor accepts.';
  static const String vendorAccepted = 'VEERA accepted ✨';
  static const String payWithinTitle = 'Complete payment within 5 minutes';
  static const String payWithinSubtitle =
      'If payment is not completed in time, your order will be cancelled automatically.';
  static const String payWithinHint =
      'Complete payment within 5 minutes. If payment is not completed in time, your order will be cancelled automatically.';
  static const String payWith = 'Pay with';
  static const String change = 'Change';
  static const String subtotal = 'Subtotal';
  static const String serviceFee = 'Service fee';
  static const String totalToPay = 'Total to pay';
  static const String pay = 'Pay';
  static const String payIn = 'PAY IN';
  static const String youreAllSet = "You're all set";
  static const String showCodeHint =
      'Show this number to the vendor when you arrive at VEERA.';
  static const String arrivalCodeLabel = 'ARRIVAL CODE';
  static const String showAtCounter = 'SHOW THIS AT THE COUNTER';
  static const String viewOrderStatus = 'View order status';
  static const String dineInOrder = 'Dine-in order';
  static const String orderHeaderSubtitle = 'VEERA · #YJK-3920';
  static const String preparingPill = '👨‍🍳 Preparing · table ready ~1 hr';
  static const String kitchenOnIt = "The kitchen's on it 🔥";
  static const String enjoyYourMeal = 'Enjoy your meal';
  static const String venue = 'Venue';
  static const String table = 'Table';
  static const String time = 'Time';
  static const String track = 'Track';
  static const String status = 'Status';
  static const String viewReceipt = 'View receipt';
  static const String getDirections = 'Get directions';
  static const String contactVenue = 'Contact venue';
  static const String visitComplete = 'Visit complete!';
  static const String thankYouVisit = 'Thanks for dining at VEERA · Adliya.';
  static const String rateExperience = 'Rate your experience';
  static const String rateFood = 'Rate the food';
  static const String tipStaff = 'Tip the staff (optional)';
  static const String customTip = 'Custom';
  static const String reviewHint = 'Write a review… (optional)';
  static const String submit = 'Submit';
  static const String bookAgain = 'Book again';
  static const String receipt = 'Receipt';
  static const String shareReceipt = 'Share receipt';
  static const String dineInPaid = '✓ DINE-IN · PAID';
  static const String typeDineIn = 'Dine-in';
  static const String paid = 'Paid';
  static const String itemColumn = 'ITEM';
  static const String priceColumn = 'PRICE';
  static const String vat = 'VAT (10%)';
  static const String total = 'Total';
  static const String discount = 'Discount';
}

abstract final class DineInOrderFlowData {
  static const String orderId = 'YJK-2026-00042';
  static const String orderIdShort = 'YJK-…00042';
  static const String receiptOrderId = 'YJK-3920';
  static const String receiptHeaderSubtitle = '#YJK-3920';
  static const String arrivalCode = 'YJK-2026-00042';
  static const String vendor = 'VEERA';
  static const String venue = 'VEERA - Adliya';
  static const String venueReceipt = 'VEERA — Adliya';
  static const String venueAddress = 'Block 338, Road 2801, Adliya';
  static const String crNumber = 'CR 54321';
  static const String dineInTime = 'Today · 19:30';
  static const String tableLabel = 'Table for 2';
  static const String itemSummary = '3 items · Order $orderIdShort';
  static const String orderTotal = 'BHD 20.500';
  static const String subtotalAmount = 'BHD 20.000';
  static const String serviceFeeAmount = 'BHD 0.500';
  static const String walletBalance = 'BHD 12.450';
  static const String prepTrack = 'Start preparing now';
  static const String statusPreparing = 'Preparing · Paid $orderTotal';

  static const List<DineInOrderTimelineStep> statusTimeline = [
    DineInOrderTimelineStep(label: 'Placed & paid', time: 'Today · 19:05', completed: true),
    DineInOrderTimelineStep(label: 'Vendor confirmed', time: 'Today · 19:08', completed: true),
    DineInOrderTimelineStep(
      label: 'Preparing',
      subtitle: DineInOrderFlowStrings.kitchenOnIt,
      completed: true,
      active: true,
    ),
    DineInOrderTimelineStep(label: 'Ready for you'),
    DineInOrderTimelineStep(label: 'You arrived'),
    DineInOrderTimelineStep(
      label: 'Completed',
      subtitle: DineInOrderFlowStrings.enjoyYourMeal,
    ),
  ];

  static const List<DineInReceiptItem> receiptItems = [
    DineInReceiptItem(name: '1× Gourmet Mezze Platter', price: 'BHD 20.000'),
    DineInReceiptItem(name: '1× Lamb Ouzi', price: 'BHD 5.000'),
    DineInReceiptItem(name: '2× Fresh Juice', price: 'BHD 4.000'),
  ];

  static const List<BillLine> receiptBillLines = [
    BillLine(label: 'Subtotal', value: 'BHD 29.000'),
    BillLine(label: 'Discount', value: '− BHD 8.500'),
    BillLine(label: 'VAT (10%)', value: 'BHD 0.000'),
    BillLine(label: 'Total', value: 'BHD 20.500', isBold: true),
  ];

  static const List<String> tipOptions = ['BHD 0.500', 'BHD 1', 'BHD 2', DineInOrderFlowStrings.customTip];
}
