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
import 'package:yjeek_app/features/scheduled_cart/model/scheduled_cart_data.dart';
import 'package:yjeek_app/features/scheduled_cart/scheduled_cart_routes.dart';
import 'package:yjeek_app/features/scheduled_cart/view/widgets/scheduled_cart_widgets.dart';

class ScheduledCheckoutScreen extends ConsumerStatefulWidget {
  const ScheduledCheckoutScreen({
    super.key,
    this.initialDeliveryId = 'same-day',
  });

  final String initialDeliveryId;

  @override
  ConsumerState<ScheduledCheckoutScreen> createState() =>
      _ScheduledCheckoutScreenState();
}

class _ScheduledCheckoutScreenState
    extends ConsumerState<ScheduledCheckoutScreen> {
  late String _deliveryId;
  int _dropOffIndex = 0;
  int _tipIndex = 0;
  String _paymentId = 'cod';
  CartSnapshot? _cart;
  DeliveryAddressSnapshot? _address;
  CheckoutPaymentMethods _payments =
      CheckoutPaymentMethods.fallback(defaultId: 'cod');
  List<ScheduledDeliveryMethod> _deliveryMethods =
      ScheduledCartData.deliveryMethods;
  List<Map<String, dynamic>> _deliveryOptions = const [];
  bool _loading = true;
  bool _placing = false;

  double get _tipAmount =>
      tipAmountFrom(ScheduledCartData.tipOptions, _tipIndex);

  ScheduledDeliveryMethod get _selectedMethod {
    for (final m in _deliveryMethods) {
      if (m.id == _deliveryId) return m;
    }
    return _deliveryMethods.isNotEmpty
        ? _deliveryMethods.first
        : ScheduledCartData.deliveryMethods.first;
  }

  List<BillLine> get _billLines {
    final cart = _cart;
    if (cart == null) return const [];
    final base = billLinesWithTip(cart, _tipAmount);
    final fee = _selectedMethod.priceValue;
    return [
      for (final line in base)
        if (line.label.toLowerCase().contains('delivery'))
          BillLine(label: line.label, value: formatBhdMoney(fee))
        else
          line,
    ];
  }

  String get _totalLabel {
    final cart = _cart;
    if (cart == null) return 'BHD 0.000';
    final baseFee = deliveryFeeFromBillLines(cart.billLines) ?? 0;
    final adjusted = cart.totalAmount - baseFee + _selectedMethod.priceValue;
    return formatBhdMoney(adjusted + _tipAmount);
  }

  @override
  void initState() {
    super.initState();
    _deliveryId = widget.initialDeliveryId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  String formatBhdMoney(num value) =>
      'BHD ${value.toDouble().toStringAsFixed(3)}';

  List<ScheduledDeliveryMethod> _mapOptions(List<Map<String, dynamic>> raw) {
    if (raw.isEmpty) return ScheduledCartData.deliveryMethods;
    return [
      for (final o in raw)
        ScheduledDeliveryMethod(
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
      final detailed =
          await ref.read(cartRepositoryProvider).fetchScheduledCartDetailed();
      final address =
          await ref.read(addressesRepositoryProvider).defaultAddress();
      final payments = await ref
          .read(paymentMethodsRepositoryProvider)
          .fetchCheckoutMethods(
            preferredDefaultId: 'cod',
          );
      if (!mounted) return;
      final methods = _mapOptions(detailed.deliveryOptions);
      var deliveryId = _deliveryId;
      final selected = methods.where((m) => m.id == deliveryId);
      if (selected.isEmpty || !selected.first.available) {
        final firstAvail = methods.where((m) => m.available);
        if (firstAvail.isNotEmpty) deliveryId = firstAvail.first.id;
      }
      setState(() {
        _cart = detailed.cart;
        _address = address;
        _payments = payments;
        _paymentId = payments.defaultId;
        _deliveryMethods = methods;
        _deliveryOptions = detailed.deliveryOptions;
        _deliveryId = deliveryId;
        _dropOffIndex = dropOffIndexFromPrefs(address?.dropOffPreferences);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _placeOrder() async {
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
      final result = await ref.read(cartRepositoryProvider).checkoutScheduled(
            addressId: addressId,
            paymentMethod: paymentMethodApiValue(_paymentId),
            windowStartAt: windowStart,
            deliverySpeed: deliverySpeedApiValue(_deliveryId),
            dropOffPreferences: dropOff == null ? null : [dropOff],
            tipAmount: _tipAmount,
          );
      if (!mounted) return;
      final orders = result?['orders'];
      final ids = <String>[];
      if (orders is List) {
        for (final o in orders) {
          if (o is Map && o['id'] != null) ids.add(o['id'].toString());
        }
      }
      context.pushReplacement(
        ScheduledCartRoutes.reviewFor(
          orderIds: ids,
          deliveryId: _deliveryId,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;
    final vendor = cart?.vendorName.isNotEmpty == true
        ? cart!.vendorName
        : 'Scheduled cart';

    return CartFlowScaffold(
      title: ScheduledCartStrings.checkout,
      subtitle: vendor,
      lightHeader: true,
      backgroundColor: Color(0xFFF2F7F2),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              children: [
                CartSectionTitle(ScheduledCartStrings.deliveryAddress),
                ScheduledAddressCard(
                  address: _address?.label,
                  addressDetail: _address?.subtitle,
                  onChange: () => context.push(CartRoutes.changeAddress),
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(ScheduledCartStrings.deliveryMethod),
                ..._deliveryMethods.map(
                  (method) => ScheduledDeliveryMethodCard(
                    method: method,
                    selected: _deliveryId == method.id,
                    onTap: () => setState(() => _deliveryId = method.id),
                  ),
                ),
                SizedBox(height: 8.h),
                CartDropOffGrid(
                  showTitle: true,
                  options: ScheduledCartData.dropOffOptions,
                  selectedIndex: _dropOffIndex,
                  onSelected: (index) => setState(() => _dropOffIndex = index),
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(ScheduledCartStrings.paymentMethod),
                const ScheduledPaymentNoteBanner(),
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
                  options: ScheduledCartData.tipOptions,
                  selectedIndex: _tipIndex,
                  onSelected: (index) => setState(() => _tipIndex = index),
                ),
                SizedBox(height: 14.h),
                CartZoodPromoBanner(
                  onTap: () => context.push(CartRoutes.zoodWaitingList),
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(ScheduledCartStrings.billSummary),
                BillSummaryCard(lines: _billLines),
                SizedBox(height: 10.h),
                ScheduledCashbackBanner(amount: cart?.cashbackLabel),
              ],
            ),
      bottom: CartStickyFooter(
        total: _totalLabel,
        buttonLabel: _placing ? '…' : ScheduledCartStrings.placeOrder,
        onPressed: _placing || _loading ? () {} : _placeOrder,
      ),
    );
  }
}
