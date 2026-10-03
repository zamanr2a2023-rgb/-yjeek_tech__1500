import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/voucher_evaluate_key.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/location/provider/delivery_location_provider.dart';
import 'package:yjeek_app/features/location/utils/checkout_delivery_address.dart';
import 'package:yjeek_app/features/cart/model/payment_methods_repository.dart';
import 'package:yjeek_app/features/cart/model/pending_checkout.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/model/user_me.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/ui_content/view/ui_banner_widgets.dart';
import 'package:yjeek_app/features/vouchers/widgets/checkout_vouchers_section.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  Set<int> _dropOffIndices = {0};
  int _tipIndex = -1;
  double _customTipAmount = 0;
  final _customTipController = TextEditingController();
  /// Deferred charge: online default so vendor accept → pay-now screen.
  String _paymentId = 'benefitpay';
  bool _saveDropOff = false;
  CartSnapshot? _cart;
  DeliveryAddressSnapshot? _address;
  CheckoutPaymentMethods _payments =
      CheckoutPaymentMethods.fallback(defaultId: 'benefitpay');
  String? _phone;
  bool _loading = true;
  bool _submitting = false;
  String? _selectedVoucherId;
  bool _useWalletBalance = false;
  bool _applyReferralCredit = false;
  DeliveryRangeCheck? _liveRange;

  double get _tipAmount => tipAmountFrom(
        CartFlowData.tipOptions,
        _tipIndex,
        customAmount: _customTipAmount,
      );

  bool get _voucherSelected =>
      _selectedVoucherId != null && _selectedVoucherId!.isNotEmpty;

  List<PaymentOption> get _paymentOptions {
    if (!_voucherSelected) return _payments.options;
    return _payments.options.where((o) => o.id != 'wallet').toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _customTipController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cart = await ref
          .read(cartRepositoryProvider)
          .fetchCart(CartOrderType.delivery);
      final deliveryLoc = ref.read(deliveryLocationProvider).valueOrNull;
      final address = checkoutAddressDisplay(deliveryLoc) ??
          await ref.read(addressesRepositoryProvider).defaultAddress();
      final allowCod = allowsCashOnDelivery(cart);
      final payments = await ref
          .read(paymentMethodsRepositoryProvider)
          .fetchCheckoutMethods(
            includeCod: allowCod,
            preferredDefaultId: 'benefitpay',
          );
      final UserMe? me = await ref.read(userRepositoryProvider).fetchMe();
      if (!mounted) return;
      if (!cart.hasItems) {
        leaveCheckoutIfCartEmpty(context, cart: cart);
        return;
      }
      DeliveryRangeCheck? liveRange;
      final vendorId = cart.vendorId;
      if (vendorId != null && vendorId.isNotEmpty) {
        liveRange = await checkDeliveryRange(
          addresses: ref.read(addressesRepositoryProvider),
          vendorId: vendorId,
          addressId: address?.id,
          failClosed: false,
        );
      }
      if (!mounted) return;
      final previousPaymentId = _paymentId;
      setState(() {
        _cart = cart;
        _address = address;
        _liveRange = liveRange;
        _payments = payments;
        _paymentId = payments.options.any((o) => o.id == previousPaymentId)
            ? previousPaymentId
            : payments.defaultId;
        if (_voucherSelected && _paymentId == 'wallet') {
          _paymentId = payments.options
              .firstWhere(
                (o) => o.id != 'wallet',
                orElse: () => payments.options.first,
              )
              .id;
        }
        _phone = address?.phone ?? me?.formattedPhone;
        _dropOffIndices = dropOffIndicesFromPrefs(address?.dropOffPreferences);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _onVoucherSelected(String? voucherId) async {
    setState(() {
      _selectedVoucherId = voucherId;
      if (voucherId != null &&
          voucherId.isNotEmpty &&
          _paymentId == 'wallet') {
        final next = _payments.options.where((o) => o.id != 'wallet');
        if (next.isNotEmpty) _paymentId = next.first.id;
      }
    });
    // Refresh cart so cashbackPreview recalculates after voucher context.
    try {
      final cart = await ref
          .read(cartRepositoryProvider)
          .fetchCart(CartOrderType.delivery);
      if (!mounted) return;
      setState(() => _cart = cart);
    } catch (_) {}
  }

  Future<void> _goToReview() async {
    if (_submitting) return;
    final cart = _cart;
    if (cart == null || !cart.hasItems) {
      showEmptyCartSnackBar(context);
      return;
    }
    if (cart.delivery?.blocksCheckout == true) return;
    var address = _address;
    if (address == null || address.id.isEmpty) {
      final saved = await ensureSavedAddressForCheckout(context, ref);
      if (!mounted) return;
      if (saved == null) return;
      setState(() => _address = saved);
      address = saved;
    }
    final addressId = address.id;
    if (_voucherSelected && _paymentId == 'wallet') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet balance cannot be used with a voucher'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final vendorId = cart.vendorId;
      if (vendorId != null && vendorId.isNotEmpty) {
        final range = await checkDeliveryRange(
          addresses: ref.read(addressesRepositoryProvider),
          vendorId: vendorId,
          addressId: addressId,
          failClosed: true,
        );
        if (!mounted) return;
        if (range.isExtraCharge && cart.delivery?.waived != true) {
          final proceed = await confirmExtraDeliveryCharge(context, range);
          if (!mounted || !proceed) return;
        }
        if (!range.allowsDelivery) {
          await pushOutOfDelivery(
            context,
            address: range.address ?? _address,
          );
          return;
        }
      }

      // Order is placed on Review & confirm (Confirm now / auto-timer), not here.
      final cartSnapshot = _cart;
      double? walletAmount;
      if (_useWalletBalance &&
          !_voucherSelected &&
          _paymentId != 'wallet' &&
          _payments.walletBalance > 0) {
        final payable = cartSnapshot?.grandTotal ?? cartSnapshot?.totalAmount ?? 0;
        walletAmount = payable < _payments.walletBalance
            ? payable
            : _payments.walletBalance;
      }
      double? referralAmount;
      if (_applyReferralCredit && !_voucherSelected) {
        final credit = cartSnapshot?.referralCredit;
        referralAmount = credit?.maxApplicable ?? credit?.available;
      }
      ref.read(pendingCheckoutProvider.notifier).state = PendingCheckout(
        paymentId: _paymentId,
        tipAmount: _tipAmount,
        addressId: addressId,
        dropOffIndices: _dropOffIndices,
        saveDropOff: _saveDropOff,
        voucherId: _selectedVoucherId,
        walletAmount: walletAmount,
        referralCreditAmount: referralAmount,
      );
      if (!mounted) return;
      context.pushReplacement(CartRoutes.review);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;
    final vendor =
        cart?.vendorName.isNotEmpty == true ? cart!.vendorName : 'Checkout';
    final billLines =
        cart != null ? billLinesWithTip(cart, _tipAmount) : const <BillLine>[];
    final total =
        cart != null ? formatCheckoutTotal(cart, _tipAmount) : 'BHD 0.000';
    final paymentOptions = _paymentOptions;
    final selectedPayment = paymentOptions.any((o) => o.id == _paymentId)
        ? _paymentId
        : (paymentOptions.isNotEmpty
            ? paymentOptions.first.id
            : _paymentId);

    return CartFlowScaffold(
      title: CartFlowStrings.checkout,
      subtitle: vendor,
      lightHeader: true,
      onBack: _submitting
          ? () {}
          : () {
              if (context.canPop()) {
                context.pop();
              }
            },
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              children: [
                CartSectionTitle(CartFlowStrings.deliveryDetails),
                CartDeliveryDetailsCard(
                  address: _address?.label ?? 'Add delivery address',
                  addressDetail: _address?.subtitle,
                  phone: _phone,
                  arrivesLabel: formatArrivesLabel(cart?.deliveryEta),
                  latitude: _address?.latitude,
                  longitude: _address?.longitude,
                  onChange: () async {
                    await context.push(CartRoutes.changeAddress);
                    if (mounted) await _load();
                  },
                ),
                SizedBox(height: 18.h),
                CartDropOffGrid(
                  options: CartFlowData.dropOffOptions,
                  selectedIndices: _dropOffIndices,
                  onChanged: (next) => setState(() => _dropOffIndices = next),
                  saveForAddress: _saveDropOff,
                  onSaveChanged: (value) =>
                      setState(() => _saveDropOff = value),
                  showTitle: true,
                ),
                SizedBox(height: 18.h),
                CartTipSelector(
                  options: CartFlowData.tipOptions,
                  selectedIndex: _tipIndex,
                  customController: _customTipController,
                  onSelected: (index) => setState(() => _tipIndex = index),
                  onCustomChanged: (raw) {
                    setState(() {
                      _customTipAmount = parseTipInput(raw) ?? 0;
                    });
                  },
                  showHeader: true,
                ),
                SizedBox(height: 18.h),
                CheckoutVouchersSection(
                  orderType: CartOrderType.delivery.apiValue,
                  selectedVoucherId: _selectedVoucherId,
                  onSelected: _onVoucherSelected,
                  cartId: cart?.cartId,
                  evaluateKey: voucherEvaluateKey(cart),
                ),
                if (cart?.referralCredit?.hasAvailable == true &&
                    !_voucherSelected) ...[
                  SizedBox(height: 12.h),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Apply referral credit (up to BHD ${cart!.referralCredit!.maxApplicable?.toStringAsFixed(3) ?? cart.referralCredit!.available?.toStringAsFixed(3) ?? '0.000'})',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    value: _applyReferralCredit,
                    onChanged: (v) => setState(() => _applyReferralCredit = v),
                  ),
                ],
                if (_payments.walletBalance > 0 && !_voucherSelected) ...[
                  SizedBox(height: 8.h),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Use wallet balance (BHD ${_payments.walletBalance.toStringAsFixed(3)})',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    value: _useWalletBalance,
                    onChanged: (v) => setState(() => _useWalletBalance = v),
                  ),
                ],
                SizedBox(height: 18.h),
                CartSectionTitle(CartFlowStrings.paymentMethod),
                if (_voucherSelected)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Text(
                      'Wallet payment is disabled while a voucher is selected',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B756E),
                      ),
                    ),
                  ),
                CartPaymentMethodList(
                  options: paymentOptions,
                  selectedId: selectedPayment,
                  onSelected: (id) => setState(() => _paymentId = id),
                  showSecurityNotes: true,
                ),
                SizedBox(height: 18.h),
                CartSectionTitle(CartFlowStrings.billSummary),
                UiPlacementBanner(
                  placementKey: 'checkout_banner',
                ),
                SizedBox(height: 12.h),
                BillSummaryCard(
                  lines: billLines,
                  showCashback: true,
                  cashbackAmount: cart?.cashbackPreview?.amountLabel ??
                      cart?.cashbackLabel,
                  cashbackMessage: cart?.cashbackPreview?.message,
                ),
                deliveryQuoteNotices(
                  cart?.delivery,
                  liveRange: _liveRange,
                ),
              ],
            ),
      bottom: CartStickyFooter(
        total: total,
        buttonLabel: CartFlowStrings.placeOrder,
        loading: _loading || _submitting,
        onPressed: checkoutPlaceOrderBlocked(
              cart?.delivery,
              liveRange: _liveRange,
            )
            ? null
            : _goToReview,
      ),
    );
  }
}
