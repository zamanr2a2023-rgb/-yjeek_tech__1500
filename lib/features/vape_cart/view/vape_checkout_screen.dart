import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/model/delivery_quote.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/location/provider/delivery_location_provider.dart';
import 'package:yjeek_app/features/location/utils/checkout_delivery_address.dart';
import 'package:yjeek_app/features/cart/model/payment_methods_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/campaigns/view/on_time_promise_banner.dart';
import 'package:yjeek_app/features/vape_cart/model/vape_cart_data.dart';
import 'package:yjeek_app/features/vape_cart/vape_cart_routes.dart';
import 'package:yjeek_app/features/vape_cart/view/widgets/vape_cart_widgets.dart';

/// Vape checkout — live DELIVERY cart + age gate; layout unchanged.
class VapeCheckoutScreen extends ConsumerStatefulWidget {
  const VapeCheckoutScreen({super.key, this.initialDeliveryId = 'same-day'});

  final String initialDeliveryId;

  @override
  ConsumerState<VapeCheckoutScreen> createState() => _VapeCheckoutScreenState();
}

class _VapeCheckoutScreenState extends ConsumerState<VapeCheckoutScreen> {
  late String _deliveryId;
  Set<int> _dropOffIndices = {0};
  int _tipIndex = -1;
  double _customTipAmount = 0;
  final _customTipController = TextEditingController();
  String _paymentId = 'benefitpay';
  bool _saveDropOff = false;
  CartSnapshot? _cart;
  DeliveryAddressSnapshot? _address;
  CheckoutPaymentMethods _payments = CheckoutPaymentMethods.fallback(
    base: VapeCartData.paymentOptions,
    includeCod: false,
  );
  List<VapeDeliveryMethod> _deliveryMethods = const [];
  List<Map<String, dynamic>> _deliveryOptions = const [];
  String? _phone;
  bool _ageVerified = false;
  bool _loading = true;
  bool _placing = false;

  double get _tipAmount => tipAmountFrom(
    VapeCartData.tipOptions,
    _tipIndex,
    customAmount: _customTipAmount,
  );

  VapeDeliveryMethod get _selectedMethod {
    for (final m in _deliveryMethods) {
      if (m.id == _deliveryId) return m;
    }
    return _deliveryMethods.isNotEmpty
        ? _deliveryMethods.first
        : const VapeDeliveryMethod(
            id: 'same-day',
            label: 'Same Day',
            price: '',
            priceValue: 0,
          );
  }

  String get _windowArrivesLabel {
    final selected = _selectedMethod;
    if (selected.subtitle != null && selected.subtitle!.isNotEmpty) {
      return selected.subtitle!;
    }
    return formatDeliveryWindowLabel(windowStartForDelivery(_deliveryId));
  }

  List<BillLine> get _billLines {
    final cart = _cart;
    if (cart == null) return const [];
    return billLinesWithTip(cart, _tipAmount);
  }

  String get _totalLabel {
    final cart = _cart;
    if (cart == null) return 'BHD 0.000';
    return formatCheckoutTotal(cart, _tipAmount);
  }

  @override
  void initState() {
    super.initState();
    _deliveryId = widget.initialDeliveryId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _customTipController.dispose();
    super.dispose();
  }

  List<VapeDeliveryMethod> _mapOptions(List<Map<String, dynamic>> raw) {
    if (raw.isEmpty) {
      return [
        for (final method in VapeCartData.deliveryMethods)
          VapeDeliveryMethod(
            id: method.id,
            label: method.label,
            subtitle: method.subtitle,
            priceValue: 0,
            price: '',
            available: method.available,
          ),
      ];
    }
    return [
      for (final o in raw)
        VapeDeliveryMethod(
          id: deliveryUiIdFromApi(o['id']?.toString()),
          label: o['label']?.toString() ?? 'Delivery',
          subtitle:
              o['windowLabel']?.toString() ??
              o['subtitle']?.toString() ??
              o['note']?.toString(),
          priceValue: parseApiMoney(o['fee']) ?? 0,
          price: formatBhdAmount(o['fee']),
          available: o['available'] != false,
          unavailableNote:
              o['note']?.toString() ??
              (o['unavailableReason'] == 'CUTOFF_PASSED'
                  ? 'Available until 12 PM only'
                  : null),
        ),
    ];
  }

  DateTime _windowForSelected() {
    final speed = deliverySpeedApiValue(_deliveryId);
    for (final o in _deliveryOptions) {
      if ((o['id']?.toString() ?? '').toUpperCase() != speed) continue;
      final raw = o['earliestWindowStartAt']?.toString();
      final parsed = DateTime.tryParse(raw ?? '');
      if (parsed != null) return parsed.toUtc();
    }
    return windowStartForDelivery(_deliveryId);
  }

  Future<void> _load({bool quoteOnly = false}) async {
    if (!quoteOnly) setState(() => _loading = true);
    try {
      final detailed = await ref
          .read(cartRepositoryProvider)
          .fetchCartDetailed(
            CartOrderType.delivery,
            deliverySpeed: deliverySpeedApiValue(_deliveryId),
          );
      if (!mounted) return;
      final methods = _mapOptions(detailed.deliveryOptions);
      if (quoteOnly) {
        setState(() {
          _cart = detailed.cart;
          _deliveryOptions = detailed.deliveryOptions;
          _deliveryMethods = methods;
        });
        return;
      }
      final deliveryLoc = ref.read(deliveryLocationProvider).valueOrNull;
      final address = checkoutAddressDisplay(deliveryLoc) ??
          await ref.read(addressesRepositoryProvider).defaultAddress();
      final payments = await ref
          .read(paymentMethodsRepositoryProvider)
          .fetchCheckoutMethods(
            fallback: VapeCartData.paymentOptions,
            includeCod: false,
            preferredDefaultId: 'benefitpay',
          );
      final me = await ref.read(userRepositoryProvider).fetchMe();
      final age = await ref
          .read(ageVerificationRepositoryProvider)
          .fetchStatus();
      if (!mounted) return;
      var deliveryId = _deliveryId;
      final match = methods.where((m) => m.id == deliveryId);
      if (match.isEmpty || !match.first.available) {
        deliveryId = methods
            .firstWhere((m) => m.available, orElse: () => methods.first)
            .id;
      }
      if (deliveryId != _deliveryId) {
        _deliveryId = deliveryId;
        return _load();
      }
      setState(() {
        _cart = detailed.cart;
        _deliveryOptions = detailed.deliveryOptions;
        _deliveryMethods = methods;
        _deliveryId = deliveryId;
        _address = address;
        _payments = payments;
        _paymentId = payments.defaultId;
        _phone = address?.phone ?? me?.formattedPhone;
        _dropOffIndices = dropOffIndicesFromPrefs(address?.dropOffPreferences);
        _ageVerified = age.canPurchaseAgeRestricted;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _deliveryMethods = _mapOptions(const []);
        _loading = false;
      });
    }
  }

  Future<bool> _refreshAgePurchase() async {
    final status = await ref
        .read(ageVerificationRepositoryProvider)
        .fetchStatus();
    if (!mounted) return false;
    setState(() => _ageVerified = status.canPurchaseAgeRestricted);
    return status.canPurchaseAgeRestricted;
  }

  Future<void> _placeOrder() async {
    final allowed = await _refreshAgePurchase();
    if (!mounted) return;
    if (!allowed) {
      await context.push(VapeCartRoutes.ageVerify);
      if (mounted) await _load();
      return;
    }
    if (_placing) return;
    var address = _address;
    if (address == null || address.id.isEmpty) {
      final saved = await ensureSavedAddressForCheckout(context, ref);
      if (!mounted) return;
      if (saved == null) return;
      setState(() => _address = saved);
      address = saved;
    }
    final addressId = address.id;
    if (!_selectedMethod.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected delivery method unavailable')),
      );
      return;
    }
    if (_cart?.delivery?.outOfRange == true) {
      await pushOutOfDelivery(
        context,
        address: _address,
        message: kOutOfDeliveryRangeMessage,
      );
      return;
    }
    if (_cart?.delivery?.blocksCheckout == true) return;

    final vendorId = _cart?.vendorId;
    if (vendorId != null && vendorId.isNotEmpty) {
      final range = await checkDeliveryRange(
        addresses: ref.read(addressesRepositoryProvider),
        vendorId: vendorId,
        addressId: addressId,
        failClosed: true,
      );
      if (!mounted) return;
      if (range.isExtraCharge && _cart?.delivery?.waived != true) {
        final proceed = await confirmExtraDeliveryCharge(context, range);
        if (!mounted || !proceed) return;
      }
      if (!range.allowsDelivery) {
        await pushOutOfDelivery(context, address: range.address ?? _address);
        return;
      }
    }

    setState(() => _placing = true);
    try {
      final dropOff = dropOffApiValues(_dropOffIndices);
      final windowStart = _windowForSelected();
      final result = await ref
          .read(cartRepositoryProvider)
          .checkout(
            type: CartOrderType.delivery,
            paymentMethod: paymentMethodApiValue(_paymentId),
            tipAmount: _tipAmount,
            addressId: addressId,
            dropOffPreferences: dropOff.isEmpty ? null : dropOff,
            saveDropOffPreferences: _saveDropOff,
            fulfillmentType: 'SCHEDULED',
            deliverySpeed: deliverySpeedApiValue(_deliveryId),
            windowStartAt: windowStart,
            scheduledAt: windowStart,
          );
      if (!mounted) return;
      final id = result?['id']?.toString();
      final ids = <String>[if (id != null && id.isNotEmpty) id];
      context.pushReplacement(
        VapeCartRoutes.reviewFor(orderIds: ids, deliveryId: _deliveryId),
      );
    } catch (e) {
      if (!mounted) return;
      if (e is OutOfDeliveryRangeException ||
          isOutOfDeliveryRangeMessage(e.toString())) {
        await pushOutOfDelivery(context, address: _address);
        return;
      }
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;
    final vendor = cart?.vendorName.isNotEmpty == true
        ? cart!.vendorName
        : 'Vape store';
    final billLines = _billLines;
    final total = _totalLabel;

    return CartFlowScaffold(
      title: VapeCartStrings.checkout,
      subtitle: vendor,
      lightHeader: true,
      backgroundColor: const Color(0xFFF2F7F2),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              children: [
                const OnTimePromiseBanner(),
                CartSectionTitle(VapeCartStrings.deliveryDetails),
                CartDeliveryDetailsCard(
                  address: _address?.label ?? 'Add delivery address',
                  addressDetail: _address?.subtitle,
                  phone: _phone,
                  arrivesLabel: _windowArrivesLabel,
                  onChange: () => context.push(CartRoutes.changeAddress),
                ),
                SizedBox(height: 14.h),
                if (_ageVerified) ...[
                  VapeIdVerifiedCard(),
                  SizedBox(height: 14.h),
                ],
                CartSectionTitle(VapeCartStrings.deliveryMethod),
                ..._deliveryMethods.map(
                  (method) => VapeDeliveryMethodCard(
                    method: method,
                    selected: _deliveryId == method.id,
                    onTap: () {
                      if (!method.available || method.id == _deliveryId) {
                        return;
                      }
                      setState(() => _deliveryId = method.id);
                      _load(quoteOnly: true);
                    },
                  ),
                ),
                SizedBox(height: 8.h),
                CartDropOffGrid(
                  showTitle: true,
                  options: VapeCartData.dropOffOptions,
                  selectedIndices: _dropOffIndices,
                  onChanged: (next) => setState(() => _dropOffIndices = next),
                  saveForAddress: _saveDropOff,
                  onSaveChanged: (v) => setState(() => _saveDropOff = v),
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(VapeCartStrings.paymentMethod),
                const VapePaymentNoteBanner(),
                SizedBox(height: 12.h),
                CartPaymentMethodList(
                  options: _payments.options,
                  selectedId: _paymentId,
                  onSelected: (id) => setState(() => _paymentId = id),
                  showSecurityNotes: true,
                ),
                SizedBox(height: 14.h),
                CartTipSelector(
                  showHeader: true,
                  options: VapeCartData.tipOptions,
                  selectedIndex: _tipIndex,
                  customController: _customTipController,
                  onSelected: (index) => setState(() => _tipIndex = index),
                  onCustomChanged: (raw) {
                    setState(() {
                      _customTipAmount = parseTipInput(raw) ?? 0;
                    });
                  },
                ),
                SizedBox(height: 14.h),
                CartZoodPromoBanner(
                  onTap: () => context.push(CartRoutes.zoodWaitingList),
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(VapeCartStrings.billSummary),
                BillSummaryCard(lines: billLines),
                deliveryQuoteNotices(cart?.delivery),
                SizedBox(height: 10.h),
                VapeCashbackBanner(amount: cart?.cashbackLabel),
              ],
            ),
      bottom: CartStickyFooter(
        total: total,
        buttonLabel: _placing ? '…' : VapeCartStrings.placeOrder,
        onPressed:
            _placing ||
                _loading ||
                deliveryQuoteBlocksPlaceOrder(cart?.delivery)
            ? null
            : _placeOrder,
      ),
    );
  }
}
