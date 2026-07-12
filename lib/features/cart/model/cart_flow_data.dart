import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

abstract final class CartFlowStrings {
  static const String checkout = 'Checkout';
  static const String reviewConfirm = 'Review & confirm';
  static const String deliveryDetails = 'Delivery details';
  static const String dropOffPreferences = 'Drop-off preferences';
  static const String tipYourChamp = 'Tip your champ';
  static const String paymentMethod = 'Payment method';
  static const String billSummary = 'Bill summary';
  static const String placeOrder = 'Place order';
  static const String change = 'Change';
  static const String arrivalEstimate = '15–25 mins';
  static const String arrivesIn = 'Arrives in 15–25 mins';
  static const String tipChampSubtitle = '100% goes straight to your champ';
  static const String saveDropOffForAddress = 'Save these for this address';
  static const String pciProtected =
      'Protected by PCI Data Security Standard';
  static const String walletComboNote =
      'You can pay with any method and use your Yjeek Wallet balance together.';
  static const String sendingOrder = 'Sending your order';
  static const String autoConfirmHint =
      'Auto-confirms in 10 seconds. You can still edit or cancel before then.';
  static const String editOrder = 'Edit order';
  static const String confirmNow = 'Confirm now';
  static const String orderSummary = 'Order summary';
  static const String orderTotalLabel = 'Order total';
  static const String deliverToLabel = 'DELIVER TO';
  static const String arrivesInLabel = 'ARRIVES IN';
  static const String paymentLabel = 'PAYMENT';
  static const String edit = 'Edit';
  static const String changeAddress = 'Change address';
  static const String deliveryAddress = 'Delivery address';
  static const String chooseWhereToDeliver = 'Choose where to deliver';
  static const String useCurrentLocation = 'Use current location';
  static const String detectGpsLocation = 'Detect my GPS location';
  static const String savedAddresses = 'Saved addresses';
  static const String addNewAddress = '+ Add new address';
  static const String deliverHere = 'Deliver here';
  static const String startNewCartTitle = 'Start a new cart?';
  static const String startNewCartBody =
      'Your cart has items from The Green Kitchen. Adding from Burger Boss will clear your current cart.';
  static const String startNewCart = 'Start new cart';
  static const String keepCurrentCart = 'Keep current cart';
  static const String setYourLocation = 'Set your location';
  static const String moveMapPin = 'Move the map to drop your pin';
  static const String searchAreaHint = 'Search area, street or landmark...';
  static const String confirmLocation = 'Confirm location';
  static const String detectedLocationLabel = 'DETECTED LOCATION';
  static const String addNewAddressTitle = 'Add new address';
  static const String savePlaceSubtitle = 'Save a place for faster checkout';
  static const String addressLabel = 'Address label';
  static const String areaBlock = 'Area / Block';
  static const String road = 'Road';
  static const String building = 'Building';
  static const String flatFloor = 'Flat / Floor';
  static const String additionalDirections = 'Additional Directions';
  static const String locationPhotos = 'Location photos · Optional';
  static const String locationPhotosHint =
      'Add photos of the entrance, gate or a landmark to help the champ find you.';
  static const String addPhoto = 'Add photo';
  static const String phoneNumber = 'Phone number';
  static const String saveAddress = 'Save address';
  static const String outOfRangeTitle = 'Out of range for this vendor';
  static const String outOfRangeBody =
      "We can't deliver to that location yet. Try another address or check back soon.";
  static const String chooseAnotherAddress = 'Choose another address';
  static const String editAddress = 'Edit address';
  static const String updatePlaceSubtitle = 'Update this saved place';
  static const String deleteAddress = 'Delete address';
  static const String saveChanges = 'Save changes';
  static const String deleteAddressTitle = 'Delete this address?';
  static const String deleteAddressBody =
      "Are you sure you want to delete 'Home · Adliya'? This action can't be undone.";
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String zoodTitle = 'Join the Zood waiting list?';
  static const String zoodSubtitle =
      'Get early access to member discounts, cashback and exclusive offers — before everyone else.';
  static const String zoodJoin = 'Yes, join the list';
  static const String zoodNotNow = 'Not now';
  static const String zoodBanner =
      'Save more on every order with Zood — join the waiting list';
  static const String zoodPromoTitle = 'Join Zood and save on every order';
  static const String zoodPromoHint = 'Be first on the Zood waiting list';
  static const String zoodJoinWaitingList = 'Join waiting list';
  static const String zoodBadge = '✦ Zood';
  static const String cashbackBanner = '2% cashback to your Yjeek Wallet';
  static const String addNewCard = 'Add new card';
  static const String customTip = 'Custom';
  static const String standardDelivery = '15–25 min · Standard';
  static const String cashOnDelivery = 'Cash on delivery';
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
  const ZoodBenefit({required this.emoji, required this.text});

  final String emoji;
  final String text;
}

abstract final class CartFlowData {
  static const String vendor = NavigationData.cartVendor;
  static const String orderTotal = 'BHD 2.110';
  static const String itemName = NavigationData.cartItemName;
  static const String itemPrice = NavigationData.cartItemPrice;
  static const String addonItemName = 'Honey Chocolate Chips';
  static const String addonItemPrice = 'BHD 0.500';
  static const String selectedAddress = 'Apartment · Seef';
  static const String reviewAddressLine = 'Apartment · Seef · Road 6055';
  static const String selectedAddressDetail = 'Road 6000, Bldg 23, Flat 82';
  static const String detectedLocation = 'Seef · Bahrain';
  static const String detectedLocationDetail =
      'Road 6000, Block 428 · near City Centre';
  static const String userPhone = '+973 3558 0000';

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

  static const List<TipOption> tipOptions = [
    TipOption(label: 'BHD 0.300', amount: 0.3),
    TipOption(label: 'BHD 0.600', amount: 0.6),
    TipOption(label: 'BHD 1', amount: 1),
    TipOption(label: CartFlowStrings.customTip),
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
      selected: true,
    ),
  ];

  static const List<String> addressLabels = ['Home', 'Work', 'Apartment', 'Other'];

  static const List<ZoodBenefit> zoodBenefits = [
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
