import 'package:flutter/material.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

class BookingDateOption {
  const BookingDateOption({required this.day, required this.date});

  final String day;
  final int date;
}

class BookingUpsellItem {
  const BookingUpsellItem({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.emoji,
    this.selected = false,
  });

  final String id;
  final String name;
  final String duration;
  final String price;
  final String emoji;
  final bool selected;
}

class ServicesPaymentOption {
  const ServicesPaymentOption({
    required this.id,
    required this.label,
    this.subtitle,
    this.icon,
  });

  final String id;
  final String label;
  final String? subtitle;
  final IconData? icon;
}

abstract final class ServicesBookingStrings {
  static const String booking = 'Booking';
  static const String checkout = 'Checkout';
  static const String reviewConfirm = 'Review & confirm';
  static const String provider = 'Glow Beauty Lounge';
  static const String yourService = 'Your service';
  static const String where = 'Where';
  static const String atVenue = 'At venue';
  static const String atHome = 'At home';
  static const String date = 'Date';
  static const String time = 'Time';
  static const String addTheseToo = 'Add these too?';
  static const String popularWith = 'Popular with Haircut & styling';
  static const String promoCode = 'Have a promo code?';
  static const String promoApplied = '✓ WELCOME10 applied';
  static const String billSummary = 'Bill summary';
  static const String addMore = 'Add more';
  static const String checkoutBtn = 'Checkout';
  static const String serviceLocation = 'Service location';
  static const String venueAddress = 'Building 210, Road 2810, Adliya';
  static const String venueLocationLabel = 'At venue · Glow Beauty Lounge';
  static const String appointment = 'Appointment';
  static const String service = 'Service';
  static const String when = 'When';
  static const String specialist = 'Specialist';
  static const String people = 'People';
  static const String tipSpecialist = 'Tip the specialist (optional)';
  static const String paymentMethod = 'Payment method';
  static const String placeBooking = 'Place booking';
  static const String sendingBooking = 'Sending your booking to Glow Beauty Lounge';
  static const String autoConfirmHint =
      'Auto-confirms in 10 seconds. You can still edit or cancel before then.';
  static const String bookingSummary = 'Booking summary';
  static const String providerLabel = 'Provider';
  static const String location = 'Location';
  static const String confirmBooking = 'Confirm booking';
  static const String apply = 'Apply';
  static const String customTip = 'Custom';
}

abstract final class ServicesBookingData {
  static const String mainService = 'Haircut & styling';
  static const String mainServiceDuration = '🕒 45 min';
  static const String mainServicePrice = 'BHD 8.000';
  static const String appointmentWhen = 'Wed 14 · 1:00 PM';
  static const String specialistName = 'Sara';
  static const String peopleCount = '1 person';
  static const String bookingTotal = 'BHD 17.380';
  static const String checkoutTotal = 'BHD 14.355';
  static const String reviewTotal = 'BHD 9.350';

  static const List<BookingDateOption> dates = [
    BookingDateOption(day: 'Mon', date: 12),
    BookingDateOption(day: 'Tue', date: 13),
    BookingDateOption(day: 'Wed', date: 14),
    BookingDateOption(day: 'Thu', date: 15),
    BookingDateOption(day: 'Fri', date: 16),
  ];

  static const List<String> timeSlots = [
    '10:00',
    '11:30',
    '1:00 PM',
    '3:00 PM',
    '4:30 PM',
  ];

  static const List<BookingUpsellItem> upsells = [
    BookingUpsellItem(
      id: 'blow-dry',
      name: 'Blow dry & style',
      duration: '30 min',
      price: '6.000',
      emoji: '💨',
      selected: true,
    ),
    BookingUpsellItem(
      id: 'hair-mask',
      name: 'Hair treatment mask',
      duration: '20 min',
      price: '5.000',
      emoji: '🧴',
    ),
    BookingUpsellItem(
      id: 'scalp-massage',
      name: 'Scalp massage',
      duration: '10 min',
      price: '2.000',
      emoji: '💆',
    ),
  ];

  static const List<BillLine> bookingBillLines = [
    BillLine(label: 'Glam Day Package (combo)', value: 'BHD 15.000'),
    BillLine(label: 'Scalp massage', value: 'BHD 2.000'),
    BillLine(label: 'Service fee', value: 'BHD 0.500'),
    BillLine(label: 'Promo (WELCOME10)', value: '− BHD 1.700', isDiscount: true),
    BillLine(label: 'VAT (10%)', value: 'BHD 1.580'),
    BillLine(label: 'Total', value: 'BHD 17.380', isBold: true),
  ];

  static const List<BillLine> checkoutBillLines = [
    BillLine(label: 'Service', value: 'BHD 8.000'),
    BillLine(label: 'Blow dry & style', value: 'BHD 6.000'),
    BillLine(label: 'Service fee', value: 'BHD 0.500'),
    BillLine(label: 'Promo (WELCOME10)', value: '− BHD 1.450', isDiscount: true),
    BillLine(label: 'VAT (10%)', value: 'BHD 1.305'),
    BillLine(label: 'Total', value: 'BHD 14.355', isBold: true),
  ];

  static const List<BillLine> reviewBillLines = [
    BillLine(label: 'Service', value: 'BHD 8.000'),
    BillLine(label: 'Service fee', value: 'BHD 0.500'),
    BillLine(label: 'VAT (10%)', value: 'BHD 0.850'),
    BillLine(label: 'Total', value: 'BHD 9.350', isBold: true),
  ];

  static const List<TipOption> tipOptions = [
    TipOption(label: 'BHD 0.500', amount: 0.5),
    TipOption(label: 'BHD 1', amount: 1),
    TipOption(label: 'BHD 2', amount: 2),
    TipOption(label: ServicesBookingStrings.customTip),
  ];

  static const List<ServicesPaymentOption> paymentOptions = [
    ServicesPaymentOption(
      id: 'benefitpay',
      label: 'BenefitPay',
      subtitle: 'Forwarded to BenefitPay',
      icon: Icons.account_balance_wallet_outlined,
    ),
    ServicesPaymentOption(
      id: 'apple',
      label: 'Apple Pay',
      icon: Icons.apple,
    ),
    ServicesPaymentOption(
      id: 'google',
      label: 'Google Pay',
      icon: Icons.g_mobiledata,
    ),
    ServicesPaymentOption(
      id: 'benefit',
      label: 'Benefit',
      subtitle: 'Forwarded to Benefit',
      icon: Icons.credit_card_outlined,
    ),
    ServicesPaymentOption(
      id: 'new-card',
      label: 'Add new card',
      icon: Icons.add_card_outlined,
    ),
  ];
}
