import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/l10n/l10n.dart';

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

abstract final class ServicesBookingStrings {
  static String get booking => L10n.tr('Booking');
  static String get checkout => L10n.tr('Checkout');
  static String get reviewConfirm => L10n.tr('Review & confirm');
  static String get provider => L10n.tr('Glow Beauty Lounge');
  static String get yourService => L10n.tr('Your service');
  static String get where => L10n.tr('Where');
  static String get atVenue => L10n.tr('At venue');
  static String get atHome => L10n.tr('At home');
  static String get date => L10n.tr('Date');
  static String get time => L10n.tr('Time');
  static String get addTheseToo => L10n.tr('Add these too?');
  static String get popularWith => L10n.tr('Popular with Haircut & styling');
  static String get promoCode => L10n.tr('Promo code');
  static String get enterPromoCode => L10n.tr('Enter promo code');
  static String get promoApplied => L10n.tr('✓ WELCOME10 applied');
  static String get billSummary => L10n.tr('Bill summary');
  static String get addMore => L10n.tr('Add more');
  static String get checkoutBtn => L10n.tr('Checkout');
  static String get serviceLocation => L10n.tr('Service location');
  static String get venueLocationLabel => L10n.tr('At venue · Glow Beauty Lounge');
  static String get venueLocationShort => L10n.tr('At venue · Adliya');
  static String get venueAddress => L10n.tr('Building 210, Road 2810, Adliya');
  static String get appointment => L10n.tr('Appointment');
  static String get service => L10n.tr('Service');
  static String get when => L10n.tr('When');
  static String get specialist => L10n.tr('Specialist');
  static String get people => L10n.tr('People');
  static String get tipSpecialist => L10n.tr('Tip the specialist (optional)');
  static String get paymentMethod => L10n.tr('Payment method');
  static String get placeBooking => L10n.tr('Place booking');
  static String get sendingBooking => L10n.tr('Sending your booking to Glow Beauty Lounge');
  static String get autoConfirmHint => L10n.tr('Auto-confirms in 10 seconds. You can still edit or cancel before then.');
  static String get bookingSummary => L10n.tr('Booking summary');
  static String get providerLabel => L10n.tr('Provider');
  static String get location => L10n.tr('Location');
  static String get confirmBooking => L10n.tr('Confirm booking');
  static String get editOrder => L10n.tr('Edit order');
  static String get apply => L10n.tr('Apply');
  static String get customTip => L10n.tr('Custom');
}

abstract final class ServicesBookingData {
  static String get mainService => L10n.tr('Haircut & styling');
  static String get mainServiceDuration => L10n.tr('🕒 45 min');
  static String get mainServicePrice => L10n.tr('BHD 8.000');
  static String get appointmentWhen => L10n.tr('Wed 14 · 1:00 PM');
  static String get specialistName => L10n.tr('Sara');
  static String get peopleCount => L10n.tr('1 person');
  static String get bookingTotal => L10n.tr('BHD 17.380');
  static String get checkoutTotal => L10n.tr('BHD 14.355');
  static String get reviewTotal => L10n.tr('BHD 9.350');

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
    BookingUpsellItem(
      id: 'gloss-shine',
      name: 'Gloss & shine',
      duration: '45 min',
      price: '12.000',
      emoji: '✨',
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

  static final List<TipOption> tipOptions = [
    TipOption(label: 'BHD 0.500', amount: 0.5),
    TipOption(label: 'BHD 1', amount: 1),
    TipOption(label: 'BHD 2', amount: 2),
    TipOption(label: ServicesBookingStrings.customTip),
  ];

  static const List<PaymentOption> paymentOptions = [
    PaymentOption(
      id: 'benefitpay',
      label: 'BenefitPay',
      iconAsset: AppAssets.payBenefitPay,
    ),
    PaymentOption(
      id: 'apple',
      label: 'Apple Pay',
      iconAsset: AppAssets.payApple,
    ),
    PaymentOption(
      id: 'google',
      label: 'Google Pay',
      iconAsset: AppAssets.payGoogle,
    ),
    PaymentOption(
      id: 'benefit',
      label: 'Benefit',
      iconAsset: AppAssets.payBenefit,
    ),
    PaymentOption(
      id: 'new-card',
      label: 'Add new card',
      iconAsset: AppAssets.payAddCard,
    ),
  ];
}
