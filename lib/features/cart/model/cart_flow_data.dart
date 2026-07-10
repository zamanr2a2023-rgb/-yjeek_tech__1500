import 'package:flutter/material.dart';
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
  static const String sendingOrder = 'Sending your order';
  static const String autoConfirmHint =
      'Auto-confirms in 10 seconds. You can still edit or cancel before then.';
  static const String editOrder = 'Edit order';
  static const String confirmNow = 'Confirm now';
  static const String orderSummary = 'Order summary';
  static const String changeAddress = 'Change address';
  static const String deliveryAddress = 'Delivery address';
  static const String chooseWhereToDeliver = 'Choose where to deliver';
  static const String useCurrentLocation = 'Use current location';
  static const String addNewAddress = '+ Add new address';
  static const String deliverHere = 'Deliver here';
  static const String startNewCartTitle = 'Start a new cart?';
  static const String startNewCartBody =
      'Your cart has items from The Green Kitchen. Adding from Burger Boss will clear your current cart.';
  static const String startNewCart = 'Start new cart';
  static const String setYourLocation = 'Set your location';
  static const String moveMapPin = 'Move the map to drop your pin';
  static const String searchAreaHint = 'Search area, street or landmark...';
  static const String confirmLocation = 'Confirm location';
  static const String addNewAddressTitle = 'Add new address';
  static const String savePlaceSubtitle = 'Save a place for faster checkout';
  static const String addressLabel = 'Address label';
  static const String areaBlock = 'Area / Block';
  static const String road = 'Road';
  static const String building = 'Building';
  static const String flatFloor = 'Flat / Floor';
  static const String additionalDirections = 'Additional Directions';
  static const String locationPhotos = 'Location photos';
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
      "Are you sure you want to delete 'Home - Adliya'? This action can't be undone.";
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String zoodTitle = 'Join the Zood waiting list?';
  static const String zoodSubtitle =
      'Get early access to member discounts, cashback and exclusive offers — before everyone else.';
  static const String zoodJoin = 'Yes, join the list';
  static const String zoodNotNow = 'Not now';
  static const String zoodBanner =
      'Save more on every order with Zood — join the waiting list';
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
    this.selected = false,
  });

  final String id;
  final String label;
  final String subtitle;
  final bool selected;
}

class DropOffOption {
  const DropOffOption({
    required this.label,
    required this.icon,
    this.selected = false,
  });

  final String label;
  final IconData icon;
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
  const ZoodBenefit({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

abstract final class CartFlowData {
  static const String vendor = NavigationData.cartVendor;
  static const String orderTotal = 'BHD 2.110';
  static const String selectedAddress = 'Apartment - Seef';
  static const String selectedAddressDetail = 'Seef - Block 428, Road 6000, Bldg 23';
  static const String detectedLocation = 'Seef - Bahrain';
  static const String userPhone = '+973 3558 0000';

  static const List<BillLine> billLines = NavigationData.cartBillLines;

  static const List<CartDeliveryAddress> deliveryAddresses = [
    CartDeliveryAddress(
      id: 'apartment-seef',
      label: 'Apartment - Seef',
      subtitle: 'Block 428, Road 6000, Bldg 23',
      selected: true,
    ),
    CartDeliveryAddress(
      id: 'home-adliya',
      label: 'Home - Adliya',
      subtitle: 'Road 1705, Building 12',
    ),
    CartDeliveryAddress(
      id: 'work-manama',
      label: 'Work - Manama',
      subtitle: 'BFH Tower, Office 412',
    ),
  ];

  static const List<DropOffOption> dropOffOptions = [
    DropOffOption(label: 'Call on arrival', icon: Icons.phone_outlined, selected: true),
    DropOffOption(label: "Don't ring bell", icon: Icons.notifications_off_outlined),
    DropOffOption(label: 'Leave at reception', icon: Icons.desk_outlined),
    DropOffOption(label: 'Meet outside', icon: Icons.door_front_door_outlined),
    DropOffOption(label: 'Leave at door', icon: Icons.door_sliding_outlined),
    DropOffOption(label: 'Hand to me', icon: Icons.back_hand_outlined),
    DropOffOption(label: 'Pet at home', icon: Icons.pets_outlined),
    DropOffOption(label: 'Other', icon: Icons.more_horiz),
  ];

  static const List<TipOption> tipOptions = [
    TipOption(label: 'BHD 0.300', amount: 0.3),
    TipOption(label: 'BHD 0.600', amount: 0.6),
    TipOption(label: 'BHD 1', amount: 1),
    TipOption(label: CartFlowStrings.customTip),
  ];

  static const List<PaymentOption> paymentOptions = [
    PaymentOption(id: 'benefitpay', label: 'BenefitPay', icon: Icons.account_balance_wallet_outlined),
    PaymentOption(id: 'apple', label: 'Apple Pay', icon: Icons.apple),
    PaymentOption(id: 'google', label: 'Google Pay', icon: Icons.g_mobiledata),
    PaymentOption(id: 'benefit', label: 'Benefit', icon: Icons.credit_card_outlined),
    PaymentOption(id: 'new-card', label: CartFlowStrings.addNewCard, icon: Icons.add_card_outlined),
    PaymentOption(id: 'wallet', label: 'Yjeek Wallet', icon: Icons.account_balance_wallet),
    PaymentOption(
      id: 'cod',
      label: CartFlowStrings.cashOnDelivery,
      icon: Icons.payments_outlined,
      selected: true,
    ),
  ];

  static const List<String> addressLabels = ['Home', 'Work', 'Apartment', 'Other'];

  static const List<ZoodBenefit> zoodBenefits = [
    ZoodBenefit(icon: Icons.local_pizza_outlined, text: 'Up to 25% off every order'),
    ZoodBenefit(icon: Icons.savings_outlined, text: '5% cashback to your Wallet'),
    ZoodBenefit(icon: Icons.star_outline, text: 'Members-only offers & deals'),
    ZoodBenefit(icon: Icons.schedule_outlined, text: 'Priority access when Zood launches'),
  ];

  static const Color zoodRed = Color(0xFFA51D24);
}
