import 'package:flutter/material.dart';

enum HelpChatVariant { support, payment, serviceNoShow }

extension HelpChatVariantX on HelpChatVariant {
  static HelpChatVariant fromQuery(String? value) => switch (value) {
        'payment' => HelpChatVariant.payment,
        'service' => HelpChatVariant.serviceNoShow,
        _ => HelpChatVariant.support,
      };

  String get routeValue => switch (this) {
        HelpChatVariant.support => 'support',
        HelpChatVariant.payment => 'payment',
        HelpChatVariant.serviceNoShow => 'service',
      };
}

enum HelpFlowType {
  scheduledCancelFree,
  scheduledCancelOutside,
  scheduledCancelConfirmed,
  modifyAwaiting,
  modifyCannotAccommodate,
}

extension HelpFlowTypeX on HelpFlowType {
  static HelpFlowType fromQuery(String? value) => switch (value) {
        'sc3' => HelpFlowType.scheduledCancelOutside,
        'sc2' => HelpFlowType.scheduledCancelConfirmed,
        'mod2' => HelpFlowType.modifyAwaiting,
        'mod3' => HelpFlowType.modifyCannotAccommodate,
        _ => HelpFlowType.scheduledCancelFree,
      };

  String get routeValue => switch (this) {
        HelpFlowType.scheduledCancelFree => 'sc1',
        HelpFlowType.scheduledCancelOutside => 'sc3',
        HelpFlowType.scheduledCancelConfirmed => 'sc2',
        HelpFlowType.modifyAwaiting => 'mod2',
        HelpFlowType.modifyCannotAccommodate => 'mod3',
      };
}

class HelpChatMessage {
  const HelpChatMessage({
    required this.text,
    this.isUser = false,
    this.isSystem = false,
    this.isAgentJoin = false,
    this.avatarLabel = 'Y',
    this.quickReplies = const [],
  });

  final String text;
  final bool isUser;
  final bool isSystem;
  /// Purple “agent joined” system pill (support / payment chats).
  final bool isAgentJoin;
  /// Agent avatar letter — `Y` (bot) or `M` (Maryam).
  final String avatarLabel;
  final List<String> quickReplies;

  bool get isAgentMaryam => avatarLabel == 'M';
}

class HelpFaqItem {
  const HelpFaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });

  final String question;
  final String answer;
  final String category;
}

class HelpPolicyLegalItem {
  const HelpPolicyLegalItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.policyType,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? policyType;
}

class HelpDetailLine {
  const HelpDetailLine({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;
}

abstract final class HelpPhase2Data {
  static const faqCategories = [
    'Wallet',
    'Payments',
    'Delivery',
    'Refunds',
    'Account',
  ];

  static const faqItems = [
    HelpFaqItem(
      category: 'Wallet',
      question: 'Can I withdraw my Wallet balance to my bank?',
      answer:
          'Yes — once your Wallet reaches BHD 10. You receive 70% by bank transfer; '
          '30% is a processing fee. KYC (IBAN certificate + CPR front/back, names matching) '
          'is required. Review ≤ 2 working days, transfer 3–7 working days.',
    ),
    HelpFaqItem(
      category: 'Wallet',
      question: 'Is there a fee for withdrawing?',
      answer:
          'Yes. A 30% processing fee applies to cash-out. You receive 70% of your '
          'balance by bank transfer.',
    ),
    HelpFaqItem(
      category: 'Wallet',
      question: 'Do Wallet credits expire?',
      answer:
          'Wallet cashback and refund credits do not expire. Promotional credits may '
          'have an expiry date shown in Wallet.',
    ),
    HelpFaqItem(
      category: 'Payments',
      question: 'What payment methods are accepted?',
      answer: 'BenefitPay, debit/credit cards, and Yjeek Wallet are accepted at checkout.',
    ),
    HelpFaqItem(
      category: 'Delivery',
      question: 'How long does delivery take?',
      answer:
          'Delivery time depends on the vendor and distance. Estimated time is shown '
          'before you place your order.',
    ),
    HelpFaqItem(
      category: 'Delivery',
      question: 'What if my order is delayed?',
      answer:
          'If your order is 15+ minutes late, open Help → Order is late for an instant '
          'wallet credit.',
    ),
    HelpFaqItem(
      category: 'Refunds',
      question: 'How do I request a refund?',
      answer:
          'Open Help with your order, choose the issue type, and submit photos where '
          'required.',
    ),
  ];

  static const policiesLegal = [
    HelpPolicyLegalItem(
      title: 'Refund & Return Policy',
      subtitle: 'Consumer Protection Law 35/2012',
      icon: Icons.replay_outlined,
      policyType: 'refund',
    ),
    HelpPolicyLegalItem(
      title: 'Terms & Conditions',
      subtitle: 'YTW-TC-2026',
      icon: Icons.description_outlined,
      policyType: 'terms',
    ),
    HelpPolicyLegalItem(
      title: 'Privacy Policy',
      subtitle: 'PDPL Decree 30 of 2018',
      icon: Icons.lock_outline,
      policyType: 'privacy',
    ),
    HelpPolicyLegalItem(
      title: 'Wallet Terms',
      subtitle: 'Cashback · refunds · cash-out',
      icon: Icons.account_balance_wallet_outlined,
    ),
    HelpPolicyLegalItem(
      title: 'Consumer Protection',
      subtitle: 'Your rights in Bahrain',
      icon: Icons.verified_user_outlined,
    ),
  ];

  static const policiesFooter =
      'Perishables, opened personal care, and custom items are non-refundable once delivered.';

  static const champIssues = ['Rude', 'Unsafe driving', 'Inappropriate', 'Unprofessional'];

  static const paymentIssues = [
    'Double charge',
    'Wrong amount',
    'BenefitPay charged — no order',
    'VAT overcharge (10%)',
    'In-app price higher than store',
  ];

  static const serviceQualityIssues = [
    'Incomplete work',
    'Below standard',
    'Not as listed',
    'Incorrect repair',
    'Poor workmanship',
  ];

  static const serviceQualityListed =
      'Full AC service — clean filters, gas top-up, full system check.';

  static const serviceQualityInfoMessage =
      'Report within 24 hours of the service. Photos and video are strongly encouraged.';

  static const serviceQualityFooter =
      'The provider is notified and has 24 hours to respond with their account. '
      'A partial or full refund is applied based on the assessment.';

  static const dineInBillIssues = [
    (
      label: 'Bill higher than Yjeek price',
      subtitle:
          'Difference refunded same day. Vendor must correct the price within 2 hrs (VPA Article 3). VPI pricing compliance updated.',
    ),
    (
      label: 'Food quality complaint',
      subtitle:
          'Reviewed with the restaurant. Partial or full compensation based on severity.',
    ),
    (
      label: 'Food safety concern (felt unwell)',
      subtitle:
          'Treated urgently. GPCC referral considered, full refund + compensation, and the restaurant is flagged for an urgent quality audit.',
    ),
  ];

  static const dineInBillOrder = (
    vendor: 'The Green Kitchen',
    detail: 'Dine-in · #YJK-DIN-2026-00112 · Table for 4',
    badgeLead: '🍴 Dine-in',
    badgeTrail: 'Visited · Today 20:00',
  );

  static const pickUpNotReadyOrder = (
    vendor: 'TechHub Electronics',
    detail: 'Pick-up · #YJK-PK-2026-00203 · BHD 12.500',
    badgeLead: '🛒 Pick-up',
    badgeTrail: 'Ready by 13:00',
  );

  static const pickUpNotReadyAlert =
      'Tap “I am here” when you arrive. A 15-minute wait timer starts and the vendor is pinged instantly.';

  static const pickUpNotReadyMilestones = [
    (
      icon: '⏱',
      title: 'At 10:00',
      subtitle:
          'Dispatcher is alerted if the vendor hasn’t confirmed the order is ready.',
    ),
    (
      icon: '🎁',
      title: 'At 15:00',
      subtitle: 'Compensation is credited to your Wallet if it’s still not ready.',
    ),
  ];

  static const pickUpNotReadyFooter =
      'If you wait more than 15 minutes, a compensation credit is added to your Wallet. '
      'You can also cancel for a full refund.';

  static const cashOutIssues = [
    (
      label: 'Delay beyond 7 working days',
      subtitle: null,
    ),
    (
      label: 'Wrong bank details (my mistake)',
      subtitle:
          'Update your IBAN and we reprocess at the same 70%. No compensation, as it’s a customer error.',
    ),
  ];

  static const scheduledCancelReasons = [
    'Changed my mind',
    'Ordered by mistake',
    'Wrong address',
    'Taking too long',
    'Other',
  ];

  static const supportChatMessages = [
    HelpChatMessage(
      text:
          'Hi Sara 👋 I’m the Yjeek Assistant. What can I help with on order #YJK-…41?',
      quickReplies: ['Missing items', 'Refund', 'Wallet'],
    ),
    HelpChatMessage(text: 'My order is missing the juice', isUser: true),
    HelpChatMessage(
      text:
          'Got it — I’ve credited BHD 2.350 to your Wallet for the missing juice. Anything else?',
    ),
    HelpChatMessage(
      text: 'Connecting a live agent — Maryam joined',
      isSystem: true,
      isAgentJoin: true,
    ),
  ];

  static const paymentChatMessages = [
    HelpChatMessage(
      text: 'Hi — I see a BenefitPay double charge on order #YJK-…41. I’m checking now.',
    ),
    HelpChatMessage(text: 'Yes, I was charged twice for BHD 35.800', isUser: true),
    HelpChatMessage(
      text:
          'Confirmed. The duplicate BHD 35.800 has been reversed to your BenefitPay card. '
          'It may take 1–3 working days to appear.',
    ),
    HelpChatMessage(text: 'No, that’s perfect. Thank you!', isUser: true),
  ];

  static const serviceNoShowChatMessages = [
    HelpChatMessage(text: 'Today', isSystem: true),
    HelpChatMessage(
      text:
          'Hi 👋 I’ve logged that Cool Air AC Services hasn’t arrived for your '
          '14:00 appointment (#YJK-SV-2026-00087). A dispatcher is calling the '
          'provider now.',
      quickReplies: ['Full refund', 'Reschedule', 'Talk to agent'],
    ),
    HelpChatMessage(
      text: 'Dispatcher calling provider — attempt 1 of 3',
      isSystem: true,
    ),
    HelpChatMessage(
      text:
          'No answer on attempt 1. We try again every 2 minutes, up to 3 '
          'attempts, before a no-show can be declared.',
    ),
    HelpChatMessage(
      text: 'I already tried calling them too — no answer.',
      isUser: true,
    ),
    HelpChatMessage(
      text: 'Thanks, noted. Attempts 2 and 3 also went unanswered.',
    ),
    HelpChatMessage(
      text: 'No-show declared · Ops notified',
      isSystem: true,
    ),
    HelpChatMessage(
      text:
          'This is Maryam from Yjeek Care. Confirmed as a provider no-show. '
          'You’ll get a full refund of BHD 18.000 plus a compensation credit, '
          'and the provider is under SPPA review. Reference SV-2026-10577.',
      avatarLabel: 'M',
    ),
    HelpChatMessage(text: 'That’s great, thank you!', isUser: true),
  ];

  static List<HelpChatMessage> messagesFor(HelpChatVariant variant) => switch (variant) {
        HelpChatVariant.payment => paymentChatMessages,
        HelpChatVariant.serviceNoShow => serviceNoShowChatMessages,
        HelpChatVariant.support => supportChatMessages,
      };

  static String chatTitleFor(HelpChatVariant variant) => switch (variant) {
        HelpChatVariant.payment => 'Payments',
        HelpChatVariant.serviceNoShow => 'Support chat',
        HelpChatVariant.support => 'Support chat',
      };

  /// Status line shown in the chat body (not the green header).
  static String chatStatusFor(HelpChatVariant variant) => switch (variant) {
        HelpChatVariant.payment =>
          'Payments · Live agent · replies in ~45 sec',
        HelpChatVariant.serviceNoShow =>
          'Services · Live agent · replies in ~45 sec',
        HelpChatVariant.support =>
          'Tier 2 · Live agent · replies in ~45 sec',
      };

  static const serviceOrder = (
    vendor: 'Cool Air AC Services',
    orderId: '#YJK-SV-2026-00087',
    serviceLabel: 'AC maintenance',
    subtitle: 'Service booking · Appointment — Today 14:00',
    price: 'BHD 18.000',
    status: 'Service booking',
    statusDetail: 'Appointment · Today 14:00',
  );

  static const serviceNoShowAlert =
      'Report it at your appointment time and we’ll act immediately. '
      'Live chat connects in ≤ 45 seconds.';

  static const propertyDamageAlert =
      'Property-damage reports skip the standard queue. An Ops Manager is alerted '
      'directly by SMS and in-app — not a regular dispatcher.';

  static const dineInReservationOrder = (
    vendor: 'The Green Kitchen',
    detail: 'Dine-in · #YJK-DIN-2026-00112 · Table for 4',
    badgeLead: '🍴 Dine-in',
    badgeTrail: 'Reserved · Today 20:00',
  );

  static const dineInReservationAlert =
      'At the restaurant with a confirmed Yjeek reservation but told no table is available? '
      'Contact us now — live chat connects in ≤ 45 seconds.';

  static const dineInReservationFooter =
      'A confirmed reservation that isn’t honored is a VPA breach. You receive mandatory '
      'compensation funded by the vendor — we’ll help seat you elsewhere or compensate you fully.';

  static const dineInReservationSteps = [
    (
      title: 'Pull your reservation details',
      subtitle:
          'We open your confirmed reservation and confirm the date, time and party size.',
    ),
    (
      title: 'Verify the restaurant was notified',
      subtitle:
          'We check that the restaurant was properly notified through the Yjeek vendor system.',
    ),
  ];

  static const paymentOrderDetails = [
    HelpDetailLine(label: 'Order ID', value: '#YJK-2026-00041'),
    HelpDetailLine(label: 'Amount charged', value: 'BHD 35.800'),
    HelpDetailLine(label: 'Payment method', value: 'BenefitPay'),
    HelpDetailLine(label: 'Charged', value: 'today 13:20'),
  ];

  static const paymentDetailsFooter =
      'Pulled automatically from your transaction records — no need to type it in.';

  static const cashbackDetails = [
    HelpDetailLine(label: 'Order ID', value: '#YJK-2026-00041'),
    HelpDetailLine(label: 'Order date', value: 'Today 13:48'),
    HelpDetailLine(label: 'Order value', value: 'BHD 35.800'),
    HelpDetailLine(
      label: 'Expected cashback (min 3%)',
      value: 'BHD 1.074',
      valueColor: Color(0xFF1D8A3E),
    ),
    HelpDetailLine(
      label: 'Wallet credit history',
      value: 'None yet',
      valueColor: Color(0xFFC62828),
    ),
  ];

  static const cashbackAutomaticChecks = [
    (
      label: 'Order status = Delivered / Completed (not cancelled)',
      passed: true,
    ),
    (
      label: 'Cashback engine triggered for this order — not fired',
      passed: false,
    ),
  ];

  static const cashbackInfoMessage =
      'Cashback (minimum 3%) is credited within 24 hours of a completed order.';

  static const cashbackFooter =
      'If the cashback engine didn’t fire, we credit the correct amount (minimum 3%) '
      'to your Wallet — usually the same day.';

  static const cashOutDetails = [
    HelpDetailLine(label: 'Requested', value: 'BHD 20.000'),
    HelpDetailLine(
      label: 'You receive (70%)',
      value: 'BHD 14.000',
      valueColor: Color(0xFF1D8A3E),
    ),
    HelpDetailLine(label: 'Processing fee (30%)', value: 'BHD 6.000'),
    HelpDetailLine(label: 'Bank / IBAN on file', value: 'BH•• •••• 4821'),
    HelpDetailLine(
      label: 'Status',
      value: 'Processing · Day 8',
      valueColor: Color(0xFFC24B00),
    ),
  ];

  static const scheduledGroceryOrder = (
    vendor: 'Fresh Basket Grocery',
    orderId: '#YJK-2026-00051',
    subtitle: '6 items · BHD 24.600',
    total: 'BHD 24.600',
  );
}
