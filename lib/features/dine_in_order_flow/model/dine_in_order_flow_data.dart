import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/l10n/l10n.dart';

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
  static String get sentToVendor => L10n.tr('Sent to VEERA');
  static String get waitingSubtitle => L10n.tr('Waiting for the vendor to accept your dine-in order…');
  static const String notChargedYet =
      "You won't be charged until the vendor accepts your order.";
  static String get cancelOrder => L10n.tr('Cancel order');
  static String get freeCancelHint => L10n.tr('Free cancellation before the vendor accepts.');
  static String get vendorAccepted => L10n.tr('VEERA accepted ✨');
  static String get payWithinTitle => L10n.tr('Complete payment within 5 minutes');
  static String get payWithinSubtitle => L10n.tr('If payment is not completed in time, your order will be cancelled automatically.');
  static String get payWithinHint => L10n.tr('Complete payment within 5 minutes. If payment is not completed in time, your order will be cancelled automatically.');
  static String get payWith => L10n.tr('Pay with');
  static String get change => L10n.tr('Change');
  static String get subtotal => L10n.tr('Subtotal');
  static String get serviceFee => L10n.tr('Service fee');
  static String get totalToPay => L10n.tr('Total to pay');
  static String get pay => L10n.tr('Pay');
  static String get payIn => L10n.tr('PAY IN');
  static const String youreAllSet = "You're all set";
  static String get showCodeHint => L10n.tr('Show this number to the vendor when you arrive at VEERA.');
  static String get arrivalCodeLabel => L10n.tr('ARRIVAL CODE');
  static String get showAtCounter => L10n.tr('SHOW THIS AT THE COUNTER');
  static String get viewOrderStatus => L10n.tr('View order status');
  static String get dineInOrder => L10n.tr('Dine-in order');
  static String get orderHeaderSubtitle => L10n.tr('VEERA · #YJK-3920');
  static String get preparingPill => L10n.tr('👨‍🍳 Preparing · table ready ~1 hr');
  static const String kitchenOnIt = "The kitchen's on it 🔥";
  static String get enjoyYourMeal => L10n.tr('Enjoy your meal');
  static String get venue => L10n.tr('Venue');
  static String get table => L10n.tr('Table');
  static String get time => L10n.tr('Time');
  static String get track => L10n.tr('Track');
  static String get status => L10n.tr('Status');
  static String get viewReceipt => L10n.tr('View receipt');
  static String get getDirections => L10n.tr('Get directions');
  static String get contactVenue => L10n.tr('Contact venue');
  static String get visitComplete => L10n.tr('Visit complete!');
  static String get thankYouVisit => L10n.tr('Thanks for dining at VEERA · Adliya.');
  static String get rateExperience => L10n.tr('Rate your experience');
  static String get rateFood => L10n.tr('Rate the food');
  static String get tipStaff => L10n.tr('Tip the staff (optional)');
  static String get customTip => L10n.tr('Custom');
  static String get reviewHint => L10n.tr('Write a review… (optional)');
  static String get submit => L10n.tr('Submit');
  static String get bookAgain => L10n.tr('Book again');
  static String get receipt => L10n.tr('Receipt');
  static String get shareReceipt => L10n.tr('Share receipt');
  static String get dineInPaid => L10n.tr('✓ DINE-IN · PAID');
  static String get typeDineIn => L10n.tr('Dine-in');
  static String get paid => L10n.tr('Paid');
  static String get itemColumn => L10n.tr('ITEM');
  static String get priceColumn => L10n.tr('PRICE');
  static String get vat => L10n.tr('VAT (10%)');
  static String get total => L10n.tr('Total');
  static String get discount => L10n.tr('Discount');
}

abstract final class DineInOrderFlowData {
  static String get orderId => L10n.tr('YJK-2026-00042');
  static String get orderIdShort => L10n.tr('YJK-…00042');
  static String get receiptOrderId => L10n.tr('YJK-3920');
  static String get receiptHeaderSubtitle => L10n.tr('#YJK-3920');
  static String get arrivalCode => L10n.tr('YJK-2026-00042');
  static String get vendor => L10n.tr('VEERA');
  static String get venue => L10n.tr('VEERA - Adliya');
  static String get venueReceipt => L10n.tr('VEERA — Adliya');
  static String get venueAddress => L10n.tr('Block 338, Road 2801, Adliya');
  static String get crNumber => L10n.tr('CR 54321');
  static String get dineInTime => L10n.tr('Today · 19:30');
  static String get tableLabel => L10n.tr('Table for 2');
  static String get itemSummary => L10n.tr('3 items · Order $orderIdShort');
  static String get orderTotal => L10n.tr('BHD 20.500');
  static String get subtotalAmount => L10n.tr('BHD 20.000');
  static String get serviceFeeAmount => L10n.tr('BHD 0.500');
  static String get walletBalance => L10n.tr('BHD 12.450');
  static String get prepTrack => L10n.tr('Start preparing now');
  static String get statusPreparing => L10n.tr('Preparing · Paid $orderTotal');

  static final List<DineInOrderTimelineStep> statusTimeline = [
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

  static final List<BillLine> receiptBillLines = [
    BillLine(label: 'Subtotal', value: 'BHD 29.000'),
    BillLine(label: 'Discount', value: '− BHD 8.500'),
    BillLine(label: 'VAT (10%)', value: 'BHD 0.000'),
    BillLine(label: 'Total', value: 'BHD 20.500', isBold: true),
  ];

  static List<String> tipOptions = ['BHD 0.500', 'BHD 1', 'BHD 2', DineInOrderFlowStrings.customTip];
}
