import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

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
  static const String sentToProvider = 'Sent to Glow Beauty Lounge';
  static const String waitingSubtitle =
      'Waiting for the provider to accept your booking…';
  static const String notChargedYet =
      "You won't be charged until the vendor accepts your order.";
  static const String cancelBooking = 'Cancel booking';
  static const String freeCancelHint = 'Free cancellation before the provider accepts';
  static const String providerAccepted = 'Glow Beauty Lounge accepted! 🙌';
  static const String payWithinHint =
      'Complete payment within 5 minutes. If payment is not completed in time, your order will be cancelled automatically.';
  static const String payWith = 'Pay with';
  static const String change = 'Change';
  static const String subtotal = 'Subtotal';
  static const String serviceFee = 'Service fee';
  static const String totalToPay = 'Total to pay';
  static const String pay = 'Pay';
  static const String payIn = 'PAY IN';
  static const String bookingConfirmed = 'Booking confirmed!';
  static const String appointmentBooked = 'Your appointment is booked · Ref #SV-4821';
  static const String trackBooking = 'Track booking';
  static const String addToCalendar = 'Add to calendar';
  static const String yourBooking = 'Your booking';
  static const String statusConfirmed = '✅ Confirmed · Wed 14 · 1:00 PM';
  static const String statusLabel = 'STATUS';
  static const String service = 'Service';
  static const String provider = 'Provider';
  static const String when = 'When';
  static const String location = 'Location';
  static const String paid = 'Paid';
  static const String viewReceipt = 'View receipt';
  static const String getDirections = 'Get directions';
  static const String contactVenue = 'Contact venue';
  static const String serviceComplete = 'Service complete!';
  static const String thankYouVisit =
      'Hope you enjoyed your visit to Glow Beauty Lounge.';
  static const String rateProvider = 'Rate the provider';
  static const String rateService = 'Rate the service';
  static const String tipSpecialist = 'Tip the specialist (optional)';
  static const String customTip = 'Custom';
  static const String submit = 'Submit';
  static const String bookAgain = 'Book again';
  static const String receipt = 'Receipt';
  static const String servicePaid = '✓ SERVICE · PAID';
  static const String print = 'Print';
  static const String shareReceipt = 'Share receipt';
  static const String paymentCard = 'Card · ending 4421';
}

abstract final class ServicesOrderFlowData {
  static const String bookingId = 'SV-4821';
  static const String providerName = 'Glow Beauty Lounge';
  static const String serviceName = 'Haircut & styling';
  static const String bookingSummary = 'Haircut & styling · Booking $bookingId';
  static const String payTotal = 'BHD 14.355';
  static const String subtotalAmount = 'BHD 13.855';
  static const String serviceFeeAmount = 'BHD 0.500';
  static const String walletBalance = 'BHD 12.450';
  static const String confirmedPaid = 'BHD 9.350 · Card';
  static const String appointmentWhen = 'Wed 14 Jun · 1:00 PM';
  static const String appointmentWhenShort = 'Wed 14 · 1:00 PM';
  static const String locationLabel = 'At venue · Adliya';
  static const String venueAddress = 'Salon & Beauty · Adliya · CR 67890';
  static const String venueReceipt = 'Glow Beauty Lounge';

  static const List<ServicesOrderTimelineStep> statusTimeline = [
    ServicesOrderTimelineStep(label: 'Requested', time: 'Mon 12', completed: true),
    ServicesOrderTimelineStep(label: 'Confirmed', time: 'Mon 12', completed: true),
    ServicesOrderTimelineStep(label: 'In progress', time: '--'),
    ServicesOrderTimelineStep(label: 'Completed', time: '--'),
  ];

  static const List<BillLine> receiptBillLines = [
    BillLine(label: 'Service', value: 'BHD 8.000'),
    BillLine(label: 'Service fee', value: 'BHD 0.500'),
    BillLine(label: 'VAT (10%)', value: 'BHD 0.850'),
    BillLine(label: 'Total', value: 'BHD 9.350', isBold: true),
  ];

  static const List<String> tipOptions = ['BHD 0.500', 'BHD 1', 'BHD 2', ServicesOrderFlowStrings.customTip];
}
