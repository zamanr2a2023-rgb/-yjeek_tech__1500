import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/l10n/l10n.dart';

class ServicesOrderTimelineStep {
  const ServicesOrderTimelineStep({
    required this.label,
    this.time,
    this.completed = false,
  });

  final String label;
  final String? time;
  final bool completed;
}

abstract final class ServicesOrderFlowStrings {
  static String get sentToProvider => L10n.tr('Sent to Glow Beauty Lounge');
  static String get waitingSubtitle => L10n.tr('Waiting for the provider to accept your booking…');
  static const String notChargedYet =
      "You won't be charged until the vendor accepts your order.";
  static String get cancelBooking => L10n.tr('Cancel booking');
  static String get freeCancelHint => L10n.tr('Free cancellation before the provider accepts.');
  static String get providerAccepted => L10n.tr('Glow Beauty Lounge accepted! 🙌');
  static String get payWithinTitle => L10n.tr('Complete payment within 5 minutes');
  static String get payWithinBody => L10n.tr('If payment is not completed in time, your order will be cancelled automatically.');
  static String get payWithinHint => L10n.tr('Complete payment within 5 minutes. If payment is not completed in time, your order will be cancelled automatically.');
  static String get payWith => L10n.tr('Pay with');
  static String get yjeekWallet => L10n.tr('Yjeek Wallet');
  static String get change => L10n.tr('Change');
  static String get subtotal => L10n.tr('Subtotal');
  static String get serviceFee => L10n.tr('Service fee');
  static String get totalToPay => L10n.tr('Total to pay');
  static String get pay => L10n.tr('Pay');
  static String get payIn => L10n.tr('PAY IN');
  static String get bookingConfirmed => L10n.tr('Booking confirmed!');
  static String get appointmentBooked => L10n.tr('Your appointment is booked · Ref #SV-4821');
  static String get trackBooking => L10n.tr('Track booking');
  static String get addToCalendar => L10n.tr('Add to calendar');
  static String get yourBooking => L10n.tr('Your booking');
  static String get statusConfirmed => L10n.tr('✅ Confirmed · Wed 14 · 1:00 PM');
  static String get statusLabel => L10n.tr('STATUS');
  static String get service => L10n.tr('Service');
  static String get provider => L10n.tr('Provider');
  static String get when => L10n.tr('When');
  static String get location => L10n.tr('Location');
  static String get paid => L10n.tr('Paid');
  static String get viewReceipt => L10n.tr('View receipt');
  static String get getDirections => L10n.tr('Get directions');
  static String get contactVenue => L10n.tr('Contact venue');
  static String get serviceComplete => L10n.tr('Service complete!');
  static String get thankYouVisit => L10n.tr('Hope you enjoyed your visit to Glow Beauty Lounge.');
  static String get rateProvider => L10n.tr('Rate the provider');
  static String get rateService => L10n.tr('Rate the service');
  static String get tipSpecialist => L10n.tr('Tip the specialist (optional)');
  static String get customTip => L10n.tr('Custom');
  static String get submit => L10n.tr('Submit');
  static String get bookAgain => L10n.tr('Book again');
  static String get receipt => L10n.tr('Receipt');
  static String get servicePaid => L10n.tr('✓ SERVICE · PAID');
  static String get print => L10n.tr('Print');
  static String get shareReceipt => L10n.tr('Share receipt');
  static String get paymentCard => L10n.tr('Card · ending 4421');
}

abstract final class ServicesOrderFlowData {
  static String get bookingId => L10n.tr('SV-4821');
  static String get providerName => L10n.tr('Glow Beauty Lounge');
  static String get serviceName => L10n.tr('Haircut & styling');
  static String get bookingSummary => L10n.tr('Haircut & styling · Booking $bookingId');
  static String get payTotal => L10n.tr('BHD 14.355');
  static String get subtotalAmount => L10n.tr('BHD 13.855');
  static String get serviceFeeAmount => L10n.tr('BHD 0.500');
  static String get walletBalance => L10n.tr('BHD 12.450');
  static String get confirmedPaid => L10n.tr('BHD 9.350 · Card');
  static String get appointmentWhen => L10n.tr('Wed 14 Jun · 1:00 PM');
  static String get appointmentWhenShort => L10n.tr('Wed 14 · 1:00 PM');
  static String get locationLabel => L10n.tr('At venue · Adliya');
  static String get venueAddress => L10n.tr('Salon & Beauty · Adliya · CR 67890');
  static String get venueReceipt => L10n.tr('Glow Beauty Lounge');

  static const List<ServicesOrderTimelineStep> statusTimeline = [
    ServicesOrderTimelineStep(label: 'Requested', time: 'Mon 12', completed: true),
    ServicesOrderTimelineStep(label: 'Confirmed', time: 'Mon 12', completed: true),
    ServicesOrderTimelineStep(label: 'In progress', time: '—'),
    ServicesOrderTimelineStep(label: 'Completed', time: '—'),
  ];

  static final List<BillLine> receiptBillLines = [
    BillLine(label: 'Service', value: 'BHD 8.000'),
    BillLine(label: 'Service fee', value: 'BHD 0.500'),
    BillLine(label: 'VAT (10%)', value: 'BHD 0.850'),
    BillLine(label: 'Total', value: 'BHD 9.350', isBold: true),
  ];

  static List<String> tipOptions = ['BHD 0.500', 'BHD 1', 'BHD 2', ServicesOrderFlowStrings.customTip];
}
