import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/model/payment_methods_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/vape_cart/model/vape_cart_data.dart';
import 'package:yjeek_app/features/vape_cart/vape_cart_routes.dart';
import 'package:yjeek_app/features/vape_cart/view/widgets/vape_cart_widgets.dart';

/// Vape checkout — live DELIVERY cart + age gate; layout unchanged.
class VapeCheckoutScreen extends ConsumerStatefulWidget {
  const VapeCheckoutScreen({
    super.key,
    this.initialDeliveryId = 'same-day',
  });

  final String initialDeliveryId;

  @override
  ConsumerState<VapeCheckoutScreen> createState() => _VapeCheckoutScreenState();
}

class _VapeCheckoutScreenState extends ConsumerState<VapeCheckoutScreen> {
  late String _deliveryId;
  int _dropOffIndex = 0;
  int _tipIndex = 0;
  String _paymentId = 'benefitpay';
  bool _saveDropOff = false;
  CartSnapshot? _cart;
  DeliveryAddressSnapshot? _address;
  CheckoutPaymentMethods _payments = CheckoutPaymentMethods.fallback(
    base: VapeCartData.paymentOptions,
  );
  List<VapeDeliveryMethod> _deliveryMethods = VapeCartData.deliveryMethods;
  List<Map<String, dynamic>> _deliveryOptions = const [];
  String? _phone;
  bool _ageVerified = false;
  bool _loading = true;
  bool _placing = false;

  double get _tipAmount => tipAmountFrom(VapeCartData.tipOptions, _tipIndex);

  VapeDeliveryMethod get _selectedMethod {
    for (final m in _deliveryMethods) {
      if (m.id == _deliveryId) return m;
    }
    return _deliveryMethods.isNotEmpty
        ? _deliveryMethods.first
        : VapeCartData.deliveryMethods.first;
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
    final base = billLinesWithTip(cart, _tipAmount);
    final fee = _selectedMethod.priceValue;
    return [
      for (final line in base)
        if (line.label.toLowerCase().contains('delivery'))
          BillLine(
            label: line.label,
            value: 'BHD ${fee.toStringAsFixed(3)}',
          )
        else
          line,
    ];
  }

  String get _totalLabel {
    final cart = _cart;
    if (cart == null) return 'BHD 0.000';
    final baseFee = deliveryFeeFromBillLines(cart.billLines) ?? 0;
    final adjusted =
        cart.totalAmount - baseFee + _selectedMethod.priceValue;
    return 'BHD ${(adjusted + _tipAmount).toStringAsFixed(3)}';
  }

  @override
  void initState() {
    super.initState();
    _deliveryId = widget.initialDeliveryId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  List<VapeDeliveryMethod> _mapOptions(List<Map<String, dynamic>> raw) {
    if (raw.isEmpty) return VapeCartData.deliveryMethods;
    return [
      for (final o in raw)
        VapeDeliveryMethod(
          id: deliveryUiIdFromApi(o['id']?.toString()),
          label: o['label']?.toString() ?? 'Delivery',
          subtitle: o['windowLabel']?.toString() ??
              o['subtitle']?.toString() ??
              o['note']?.toString(),
          priceValue: (o['fee'] as num?)?.toDouble() ?? 0,
          price:
              'BHD ${((o['fee'] as num?)?.toDouble() ?? 0).toStringAsFixed(3)}',
          available: o['available'] != false,
          unavailableNote: o['note']?.toString() ??
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

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final detailed = await ref
          .read(cartRepositoryProvider)
          .fetchCartDetailed(CartOrderType.delivery);
      final address =
          await ref.read(addressesRepositoryProvider).defaultAddress();
      final payments = await ref
          .read(paymentMethodsRepositoryProvider)
          .fetchCheckoutMethods(
            preferredDefaultId: 'benefitpay',
          );
      final me = await ref.read(userRepositoryProvider).fetchMe();
      if (!mounted) return;
      final methods = _mapOptions(detailed.deliveryOptions);
      var deliveryId = widget.initialDeliveryId;
      final match = methods.where((m) => m.id == deliveryId);
      if (match.isEmpty || !match.first.available) {
        deliveryId = methods
            .firstWhere(
              (m) => m.available,
              orElse: () => methods.first,
            )
            .id;
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
        _dropOffIndex = dropOffIndexFromPrefs(address?.dropOffPreferences);
        _ageVerified = me?.verification.status.toUpperCase() == 'VERIFIED';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _placeOrder() async {
    if (!_ageVerified) {
      context.push(VapeCartRoutes.ageVerify).then((_) {
        if (mounted) _load();
      });
      return;
    }
    if (_placing) return;
    final addressId = _address?.id;
    if (addressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a delivery address first')),
      );
      return;
    }
    if (!_selectedMethod.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected delivery method unavailable')),
      );
      return;
    }
    setState(() => _placing = true);
    try {
      final dropOff = dropOffApiValue(_dropOffIndex);
      final windowStart = _windowForSelected();
      final result = await ref.read(cartRepositoryProvider).checkout(
            type: CartOrderType.delivery,
            paymentMethod: paymentMethodApiValue(_paymentId),
            tipAmount: _tipAmount,
            addressId: addressId,
            dropOffPreferences: dropOff == null ? null : [dropOff],
            saveDropOffPreferences: _saveDropOff,
            fulfillmentType: 'SCHEDULED',
            deliverySpeed: deliverySpeedApiValue(_deliveryId),
            windowStartAt: windowStart,
            scheduledAt: windowStart,
          );
      if (!mounted) return;
      final id = result?['id']?.toString();
      final ids = <String>[
        if (id != null && id.isNotEmpty) id,
      ];
      context.pushReplacement(
        VapeCartRoutes.reviewFor(
          orderIds: ids,
          deliveryId: _deliveryId,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      if (message.toLowerCase().contains('age verification') ||
          message.contains('AGE_VERIFICATION')) {
        context.push(VapeCartRoutes.ageVerify);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;
    final vendor =
        cart?.vendorName.isNotEmpty == true ? cart!.vendorName : 'Vape store';
    final billLines = _billLines;
    final total = _totalLabel;

    return CartFlowScaffold(
      title: VapeCartStrings.checkout,
      subtitle: vendor,
      lightHeader: true,
      backgroundColor: const Color(0xFFF2F7F2),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              children: [
                const CartSectionTitle(VapeCartStrings.deliveryDetails),
                CartDeliveryDetailsCard(
                  address: _address?.label ?? 'Add delivery address',
                  addressDetail: _address?.subtitle,
                  phone: _phone,
                  arrivesLabel: _windowArrivesLabel,
                  onChange: () => context.push(CartRoutes.changeAddress),
                ),
                SizedBox(height: 14.h),
                if (_ageVerified) ...[
                  const VapeIdVerifiedCard(),
                  SizedBox(height: 14.h),
                ],
                const CartSectionTitle(VapeCartStrings.deliveryMethod),
                ..._deliveryMethods.map(
                  (method) => VapeDeliveryMethodCard(
                    method: method,
                    selected: _deliveryId == method.id,
                    onTap: () {
                      if (!method.available) return;
                      setState(() => _deliveryId = method.id);
                    },
                  ),
                ),
                SizedBox(height: 8.h),
                CartDropOffGrid(
                  showTitle: true,
                  options: VapeCartData.dropOffOptions,
                  selectedIndex: _dropOffIndex,
                  onSelected: (index) => setState(() => _dropOffIndex = index),
                  saveForAddress: _saveDropOff,
                  onSaveChanged: (v) => setState(() => _saveDropOff = v),
                ),
                SizedBox(height: 14.h),
                const CartSectionTitle(VapeCartStrings.paymentMethod),
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
                  onSelected: (index) => setState(() => _tipIndex = index),
                ),
                SizedBox(height: 14.h),
                CartZoodPromoBanner(
                  onTap: () => context.push(CartRoutes.zoodWaitingList),
                ),
                SizedBox(height: 14.h),
                const CartSectionTitle(VapeCartStrings.billSummary),
                BillSummaryCard(lines: billLines),
                SizedBox(height: 10.h),
                VapeCashbackBanner(amount: cart?.cashbackLabel),
              ],
            ),
      bottom: CartStickyFooter(
        total: total,
        buttonLabel: _placing ? '…' : VapeCartStrings.placeOrder,
        onPressed: _placing || _loading ? () {} : _placeOrder,
      ),
    );
  }
}
