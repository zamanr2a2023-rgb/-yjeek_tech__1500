import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/l10n/l10n.dart';

abstract final class CartFlowStrings {
  static String get checkout => L10n.tr('Checkout');
  static String get reviewConfirm => L10n.tr('Review & confirm');
  static String get deliveryDetails => L10n.tr('Delivery details');
  static String get dropOffPreferences => L10n.tr('Drop-off preferences');
  static String get tipYourChamp => L10n.tr('Tip your champ');
  static String get paymentMethod => L10n.tr('Payment method');
  static String get billSummary => L10n.tr('Bill summary');
  static String get placeOrder => L10n.tr('Place order');
  static String get change => L10n.tr('Change');
  static String get arrivalEstimate => L10n.tr('15–25 mins');
  static String get arrivesIn => L10n.tr('Arrives in 15–25 mins');
  static String get tipChampSubtitle => L10n.tr('100% goes straight to your champ');
  static String get saveDropOffForAddress => L10n.tr('Save these for this address');
  static String get pciProtected => L10n.tr('Protected by PCI Data Security Standard');
  static String get walletComboNote => L10n.tr('You can pay with any method and use your Yjeek Wallet balance together.');
  static String get sendingOrder => L10n.tr('Sending your order');
  static String get autoConfirmHint => L10n.tr('Auto-confirms in 10 seconds. You can still edit or cancel before then.');
  static String get editOrder => L10n.tr('Edit order');
  static String get confirmNow => L10n.tr('Confirm now');
  static String get orderSummary => L10n.tr('Order summary');
  static String get orderTotalLabel => L10n.tr('Order total');
  static String get deliverToLabel => L10n.tr('DELIVER TO');
  static String get arrivesInLabel => L10n.tr('ARRIVES IN');
  static String get paymentLabel => L10n.tr('PAYMENT');
  static String get edit => L10n.tr('Edit');
  static String get changeAddress => L10n.tr('Change address');
  static String get deliveryAddress => L10n.tr('Delivery address');
  static String get chooseWhereToDeliver => L10n.tr('Choose where to deliver');
  static String get useCurrentLocation => L10n.tr('Use current location');
  static String get detectGpsLocation => L10n.tr('Detect my GPS location');
  static String get savedAddresses => L10n.tr('Saved addresses');
  static String get addNewAddress => L10n.tr('+ Add new address');
  static String get deliverHere => L10n.tr('Deliver here');
  static String get startNewCartTitle => L10n.tr('Start a new cart?');
  static String get startNewCartBody => L10n.tr('Your cart has items from The Green Kitchen. Adding from Burger Boss will clear your current cart.');
  static String get startNewCart => L10n.tr('Start new cart');
  static String get keepCurrentCart => L10n.tr('Keep current cart');
  static String get setYourLocation => L10n.tr('Set your location');
  static String get moveMapPin => L10n.tr('Move the map to drop your pin');
  static String get searchAreaHint => L10n.tr('Search area, street or landmark...');
  static String get confirmLocation => L10n.tr('Confirm location');
  static String get detectedLocationLabel => L10n.tr('DETECTED LOCATION');
  static String get addNewAddressTitle => L10n.tr('Add new address');
  static String get savePlaceSubtitle => L10n.tr('Save a place for faster checkout');
  static String get addressLabel => L10n.tr('Address label');
  static String get areaBlock => L10n.tr('Area / Block');
  static String get road => L10n.tr('Road');
  static String get building => L10n.tr('Building');
  static String get flatFloor => L10n.tr('Flat / Floor');
  static String get additionalDirections => L10n.tr('Additional Directions');
  static String get locationPhotos => L10n.tr('Location photos · Optional');
  static String get locationPhotosHint => L10n.tr('Add photos of the entrance, gate or a landmark to help the champ find you.');
  static String get addPhoto => L10n.tr('Add photo');
  static String get phoneNumber => L10n.tr('Phone number');
  static String get saveAddress => L10n.tr('Save address');
  static String get outOfRangeTitle => L10n.tr('Out of range for this vendor');
  static String get outOfRangeBody => L10n.tr(
        "We can't deliver to that location yet. Try another address or check back soon.",
      );
  static String get chooseAnotherAddress => L10n.tr('Choose another address');
  static String get editAddress => L10n.tr('Edit address');
  static String get updatePlaceSubtitle => L10n.tr('Update this saved place');
  static String get deleteAddress => L10n.tr('Delete address');
  static String get saveChanges => L10n.tr('Save changes');
  static String get deleteAddressTitle => L10n.tr('Delete this address?');
  static String get deleteAddressBody => L10n.tr(
        "Are you sure you want to delete 'Home · Adliya'? This action can't be undone.",
      );
  static String get cancel => L10n.tr('Cancel');
  static String get delete => L10n.tr('Delete');
  static String get zoodTitle => L10n.tr('Join the Zood waiting list?');
  static String get zoodSubtitle => L10n.tr('Get early access to member discounts, cashback and exclusive offers — before everyone else.');
  static String get zoodJoin => L10n.tr('Yes, join the list');
  static String get zoodNotNow => L10n.tr('Not now');
  static String get zoodBanner => L10n.tr('Save more on every order with Zood — join the waiting list');
  static String get zoodPromoTitle => L10n.tr('Join Zood and save on every order');
  static String get zoodPromoHint => L10n.tr('Be first on the Zood waiting list');
  static String get zoodJoinWaitingList => L10n.tr('Join waiting list');
  static String get zoodBadge => L10n.tr('✦ Zood');
  static String get cashbackBanner => L10n.tr('2% cashback to your Yjeek Wallet');
  static String get addNewCard => L10n.tr('Add new card');
  static String get customTip => L10n.tr('Custom');
  static String get standardDelivery => L10n.tr('15–25 min · Standard');
  static String get cashOnDelivery => L10n.tr('Cash on delivery');
}

class CartDeliveryAddress {
  const CartDeliveryAddress({
    required this.id,
    required this.label,
    required this.subtitle,
    this.phone,
    this.icon,
    this.selected = false,
  });

  final String id;
  final String label;
  final String subtitle;
  final String? phone;
  final IconData? icon;
  final bool selected;
}

class DropOffOption {
  const DropOffOption({
    required this.label,
    this.icon,
    this.iconAsset,
    this.selected = false,
  }) : assert(icon != null || iconAsset != null);

  final String label;
  final IconData? icon;
  final String? iconAsset;
  final bool selected;
}

class PaymentOption {
  const PaymentOption({
    required this.id,
    required this.label,
    this.icon,
    this.iconAsset,
    this.selected = false,
  });

  final String id;
  final String label;
  final IconData? icon;
  final String? iconAsset;
  final bool selected;
}

class TipOption {
  const TipOption({required this.label, this.amount});

  final String label;
  final double? amount;
}

class ZoodBenefit {
  ZoodBenefit({required this.emoji, required this.text});

  final String emoji;
  final String text;
}

abstract final class CartFlowData {
  static String vendor = NavigationData.cartVendor;
  static String get orderTotal => L10n.tr('BHD 2.110');
  static String itemName = NavigationData.cartItemName;
  static String itemPrice = NavigationData.cartItemPrice;
  static String get addonItemName => L10n.tr('Honey Chocolate Chips');
  static String get addonItemPrice => L10n.tr('BHD 0.500');
  static String get selectedAddress => L10n.tr('Apartment · Seef');
  static String get reviewAddressLine => L10n.tr('Apartment · Seef · Road 6055');
  static String get selectedAddressDetail => L10n.tr('Road 6000, Bldg 23, Flat 82');
  static String get detectedLocation => L10n.tr('Seef · Bahrain');
  static String get detectedLocationDetail => L10n.tr('Road 6000, Block 428 · near City Centre');
  static String get userPhone => L10n.tr('+973 3558 0000');

  static const List<BillLine> billLines = NavigationData.cartBillLines;

  static const List<CartDeliveryAddress> deliveryAddresses = [
    CartDeliveryAddress(
      id: 'apartment-seef',
      label: 'Apartment · Seef',
      subtitle: 'Road 6000, Bldg 23, Flat 82',
      phone: '+973 3558 0000',
      icon: Icons.apartment_outlined,
      selected: true,
    ),
    CartDeliveryAddress(
      id: 'home-adliya',
      label: 'Home · Adliya',
      subtitle: 'Road 1705, Building 12',
      phone: '+973 3558 0000',
      icon: Icons.home_outlined,
    ),
    CartDeliveryAddress(
      id: 'work-manama',
      label: 'Work · Manama',
      subtitle: 'BFH Tower, Office 412',
      phone: '+973 3558 0000',
      icon: Icons.work_outline,
    ),
  ];

  static const List<DropOffOption> dropOffOptions = [
    DropOffOption(
      label: 'Call on arrival',
      iconAsset: AppAssets.dropOffCall,
      selected: true,
    ),
    DropOffOption(
      label: "Don't ring bell",
      iconAsset: AppAssets.dropOffDontRing,
    ),
    DropOffOption(
      label: 'Leave at reception',
      iconAsset: AppAssets.dropOffReception,
    ),
    DropOffOption(
      label: 'Ring doorbell',
      iconAsset: AppAssets.dropOffRingBell,
    ),
    DropOffOption(
      label: "Don't call on arrival",
      iconAsset: AppAssets.dropOffDontCall,
    ),
    DropOffOption(
      label: 'Ring bell',
      iconAsset: AppAssets.dropOffRingBell,
    ),
    DropOffOption(
      label: 'Message on arrival',
      iconAsset: AppAssets.dropOffMessage,
    ),
    DropOffOption(
      label: 'Leave at my door',
      iconAsset: AppAssets.dropOffLeaveAtDoor,
    ),
  ];

  static final List<TipOption> tipOptions = [
    TipOption(label: 'BHD 0.300', amount: 0.3),
    TipOption(label: 'BHD 0.600', amount: 0.6),
    TipOption(label: 'BHD 1', amount: 1),
    TipOption(label: CartFlowStrings.customTip),
  ];

  static final List<PaymentOption> paymentOptions = [
    PaymentOption(
      id: 'benefitpay',
      label: 'BenefitPay',
      iconAsset: AppAssets.payBenefitPay,
      selected: true,
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
      label: CartFlowStrings.addNewCard,
      iconAsset: AppAssets.payAddCard,
    ),
    PaymentOption(
      id: 'wallet',
      label: 'Yjeek Wallet',
      iconAsset: AppAssets.payWallet,
    ),
    PaymentOption(
      id: 'cod',
      label: CartFlowStrings.cashOnDelivery,
      iconAsset: AppAssets.payCash,
    ),
  ];

  static final List<String> addressLabels = ['Home', 'Work', 'Apartment', 'Other'];

  static final List<ZoodBenefit> zoodBenefits = [
    ZoodBenefit(emoji: '🏷️', text: 'Up to 25% off every order'),
    ZoodBenefit(emoji: '💰', text: '5% cashback to your Wallet'),
    ZoodBenefit(emoji: '✨', text: 'Members-only offers & deals'),
    ZoodBenefit(emoji: '⏱️', text: 'Priority access when Zood launches'),
  ];

  static const List<String> zoodPromoChips = [
    'Up to 25% off',
    '5% cashback',
    'Offers',
  ];

  static const Color zoodRed = Color(0xFF9B111E);
}
