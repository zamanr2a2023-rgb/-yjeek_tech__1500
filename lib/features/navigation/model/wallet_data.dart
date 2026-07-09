import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';

class WalletTransaction {
  const WalletTransaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.positive,
    this.expiryNote,
    this.iconBg = const Color(0xFFE8F4FC),
    this.iconAsset,
    this.icon = Icons.refresh,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool positive;
  final String? expiryNote;
  final Color iconBg;
  final String? iconAsset;
  final IconData icon;
}

class SavedAddress {
  const SavedAddress({
    required this.label,
    required this.address,
    this.isDefault = false,
    this.iconAsset,
    this.icon,
  }) : assert(iconAsset != null || icon != null);

  final String label;
  final String address;
  final bool isDefault;
  final String? iconAsset;
  final IconData? icon;
}

class PolicySection {
  const PolicySection({required this.title, required this.body});

  final String title;
  final String body;
}

class CountryOption {
  const CountryOption({
    required this.name,
    this.selected = false,
  });

  final String name;
  final bool selected;
}

abstract final class WalletData {
  static const String cashBackBalance = 'BHD 7.214';
  static const String refundsCreditsBalance = 'BHD 12.450';
  static const String cashbackScreenBalance = 'BHD 5.200';
  static const String withdrawableBalance = 'BHD 18.400';
  static const String withdrawReceive = 'BHD 12.880';
  static const String withdrawFee = 'BHD 5.520';
  static const String accountCashbackBalance = 'BHD 8.000';

  static const String userEmail = 'asmaa@email.com';
  static const String userDob = '12 Jun 1996';
  static const String userGender = 'Female';
  static const String memberSince = 'March 2025';

  static const List<WalletTransaction> refundTransactions = [
    WalletTransaction(
      title: 'Refund · Lamb Ouzi',
      subtitle: 'Today · 14:20',
      amount: '+ BHD 5.000',
      positive: true,
      expiryNote: '⏳ 183 days to expire',
      iconBg: Color(0xFFE6F1FB),
      iconAsset: AppAssets.walletRefundHistory,
    ),
    WalletTransaction(
      title: 'Late delivery credit',
      subtitle: 'Yesterday',
      amount: '+ BHD 1.000',
      positive: true,
      expiryNote: '⏳ 182 days to expire',
      iconBg: Color(0xFFE6F1FB),
      iconAsset: AppAssets.walletGiftCredit,
    ),
  ];

  static const List<WalletTransaction> cashbackTransactions = [
    WalletTransaction(
      title: 'Cashback · The Green Kitchen',
      subtitle: 'Today · 13:40',
      amount: '+ BHD 0.864',
      positive: true,
      expiryNote: '⏳ 183 days to expire',
      iconBg: Color(0xFFF4EBD0),
      iconAsset: AppAssets.walletCashBack,
    ),
    WalletTransaction(
      title: 'Cash-out to BenefitPay',
      subtitle: '5 Jun',
      amount: '- BHD 4.000',
      positive: false,
      iconBg: Color(0xFFDCE7D4),
      iconAsset: AppAssets.walletCashOut,
    ),
  ];

  static const List<SavedAddress> savedAddresses = [
    SavedAddress(
      label: 'Home',
      address: 'Building 2732, Road 3649, Block 436, Al Seef',
      isDefault: true,
      icon: Icons.home_outlined,
    ),
    SavedAddress(
      label: 'Work',
      address: 'Office 412, Bahrain Financial Harbour, Manama',
      iconAsset: AppAssets.addressWork,
    ),
    SavedAddress(
      label: "Mum's place",
      address: 'Villa 18, Road 2805, Riffa',
      iconAsset: AppAssets.accountLocation,
    ),
  ];

  static const List<CountryOption> countries = [
    CountryOption(name: 'Kuwait'),
    CountryOption(name: 'KSA'),
    CountryOption(name: 'Bahrain', selected: true),
    CountryOption(name: 'UAE'),
    CountryOption(name: 'Oman'),
    CountryOption(name: 'Qatar'),
    CountryOption(name: 'Jordan'),
    CountryOption(name: 'Egypt'),
    CountryOption(name: 'Iraq'),
  ];

  static const termsIntro =
      'Reference YTW-TC-2026-EN · By using Yjeek you agree to these Terms. '
      'Operator: Yjeek Technologies W.L.L (CR 110111-3).';

  static const List<PolicySection> termsSections = [
    PolicySection(
      title: '1 · About Yjeek',
      body:
          'Yjeek is a multi-category on-demand delivery and lifestyle platform. '
          'The platform includes the customer app, www.yjeektech.com, Yjeek Wallet '
          'and Yjeek Discover. Governed by the laws of the Kingdom of Bahrain.',
    ),
    PolicySection(
      title: '2 · Eligibility & registration',
      body:
          'You must be 18+, able to enter contracts, and a resident or visitor in Bahrain. '
          'You are responsible for the security of your account credentials.',
    ),
    PolicySection(
      title: '3 · Orders, categories & pricing',
      body:
          'Yjeek is a technology intermediary; vendors are solely responsible for their '
          'products. In-app prices must equal or be lower than in-store prices. '
          'Yjeek serves 29 categories.',
    ),
    PolicySection(
      title: '4 · Payment',
      body:
          'Accepted: Visa/Mastercard (credit & debit), BenefitPay and Yjeek Wallet credits. '
          'Payments are processed via PCI-DSS compliant gateways; full card numbers are '
          'never stored. Prices in BHD; VAT 10% where applicable.',
    ),
    PolicySection(
      title: '5 · Yjeek Wallet',
      body:
          'A digital cashback balance managed by Yjeek. Earn cashback on eligible orders; '
          'balance can be redeemed in-app or withdrawn to a verified bank account (IBAN).',
    ),
  ];

  static const privacyIntro =
      'Document YTW-PP-2026-EN · Yjeek protects your personal data per '
      'Bahrain PDPL (Decree No. 30 of 2018).';

  static const List<PolicySection> privacySections = [
    PolicySection(
      title: '1 · Data controller',
      body:
          'Yjeek Technologies W.L.L (CR 110111-3), Al Seef, Kingdom of Bahrain. '
          'Data contact: privacy@yjeektech.com · Authority: Personal Data Protection '
          'Authority (pdp.gov.bh).',
    ),
    PolicySection(
      title: '2 · What we collect & why',
      body:
          'Account (name, email, mobile) for sign-in; Order data for fulfilment & disputes; '
          'Payment data (type, last 4, token) for processing & fraud prevention; '
          'Location/GPS (with consent, active orders only) for delivery; Wallet data for cashback.',
    ),
    PolicySection(
      title: '3 · Legal basis',
      body:
          'We process data under consent, contract, legal obligation and legitimate interest '
          'as applicable to each category.',
    ),
    PolicySection(
      title: '4 · Your rights',
      body:
          'Access, correct, delete and port your data, and withdraw consent at any time. '
          'Contact privacy@yjeektech.com to exercise your rights.',
    ),
  ];

  static const refundIntro =
      'Reference YTW-RRP-2026-EN · Under Bahrain Consumer Protection Law No. 35 of 2012.';

  static const List<PolicySection> refundSections = [
    PolicySection(
      title: '1 · Cancellation',
      body:
          'Before vendor acceptance: free, full automatic refund. After acceptance, before pickup: '
          'a fee up to 50% may apply. After pickup: not normally possible. If the vendor cancels: '
          'full refund + goodwill Wallet credit. Delay over 15 min: automatic goodwill credit.',
    ),
    PolicySection(
      title: 'Order did not arrive',
      body:
          '100% to original payment method · request within 1 hour of ETA · '
          'Card 5–10 days, Wallet immediate.',
    ),
    PolicySection(
      title: 'Completely wrong order',
      body: '100% or free re-delivery · within 30 min of delivery.',
    ),
    PolicySection(
      title: 'Missing items',
      body: 'Pro-rata refund for missing items · within 30 min · Wallet immediate.',
    ),
    PolicySection(
      title: 'Damaged / spilled (with photo)',
      body: '100% or re-delivery · within 30 min · Wallet immediate.',
    ),
    PolicySection(
      title: 'Refund methods',
      body:
          'Wallet credits are immediate; card refunds take 5–10 business days to the '
          'original payment method.',
    ),
  ];
}
