import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/voucher_evaluate_key.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/model/delivery_quote.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/location/provider/delivery_location_provider.dart';
import 'package:yjeek_app/features/location/utils/checkout_delivery_address.dart';
import 'package:yjeek_app/features/cart/model/payment_methods_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/scheduled_cart/model/scheduled_cart_data.dart';
import 'package:yjeek_app/features/scheduled_cart/scheduled_cart_routes.dart';
import 'package:yjeek_app/features/scheduled_cart/view/widgets/scheduled_cart_widgets.dart';
import 'package:yjeek_app/features/vouchers/widgets/checkout_vouchers_section.dart';

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
  Set<int> _dropOffIndices = {0};
  int _tipIndex = -1;
  double _customTipAmount = 0;
  final _customTipController = TextEditingController();
  String _paymentId = 'cod';
  CartSnapshot? _cart;
  DeliveryAddressSnapshot? _address;
  CheckoutPaymentMethods _payments =
      CheckoutPaymentMethods.fallback(defaultId: 'cod');
  List<ScheduledDeliveryMethod> _deliveryMethods = const [];
  List<Map<String, dynamic>> _deliveryOptions = const [];
  bool _loading = true;
  bool _placing = false;
  String? _selectedVoucherId;

  double get _tipAmount => tipAmountFrom(
        ScheduledCartData.tipOptions,
        _tipIndex,
        customAmount: _customTipAmount,
      );

  ScheduledDeliveryMethod get _selectedMethod {
    for (final m in _deliveryMethods) {
      if (m.id == _deliveryId) return m;
    }
    return _deliveryMethods.isNotEmpty
        ? _deliveryMethods.first
        : const ScheduledDeliveryMethod(
            id: 'same-day',
            label: 'Same Day',
            price: '',
            priceValue: 0,
          );
  }

  List<BillLine> get _billLines {
    final cart = _cart;
    if (cart == null) return const [];
    return billLinesWithTip(cart, _tipAmount, totalLabel: 'Total');
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

  String formatBhdMoney(num value) =>
      'BHD ${value.toDouble().toStringAsFixed(3)}';

  List<ScheduledDeliveryMethod> _mapOptions(List<Map<String, dynamic>> raw) {
    if (raw.isEmpty) {
      return [
        for (final method in ScheduledCartData.deliveryMethods)
          ScheduledDeliveryMethod(
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
        ScheduledDeliveryMethod(
          id: deliveryUiIdFromApi(o['id']?.toString()),
          label: o['label']?.toString() ?? 'Delivery',
          subtitle: o['windowLabel']?.toString() ??
              o['subtitle']?.toString() ??
              o['note']?.toString(),
          priceValue: parseApiMoney(o['fee']) ?? 0,
          price: formatBhdAmount(o['fee']),
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

  Future<void> _load({bool quoteOnly = false}) async {
    if (!quoteOnly) setState(() => _loading = true);
    try {
      final detailed = await ref
          .read(cartRepositoryProvider)
          .fetchScheduledCartDetailed(
            deliverySpeed: deliverySpeedApiValue(_deliveryId),
          );
      if (!mounted) return;
      final methods = _mapOptions(detailed.deliveryOptions);
      if (quoteOnly) {
        setState(() {
          _cart = detailed.cart;
          _deliveryMethods = methods;
          _deliveryOptions = detailed.deliveryOptions;
        });
        return;
      }
      final deliveryLoc = ref.read(deliveryLocationProvider).valueOrNull;
      final address = checkoutAddressDisplay(deliveryLoc) ??
          await ref.read(addressesRepositoryProvider).defaultAddress();
      final payments = await ref
          .read(paymentMethodsRepositoryProvider)
          .fetchCheckoutMethods(
            preferredDefaultId: 'cod',
          );
      if (!mounted) return;
      var deliveryId = _deliveryId;
      final selected = methods.where((m) => m.id == deliveryId);
      if (selected.isEmpty || !selected.first.available) {
        final firstAvail = methods.where((m) => m.available);
        if (firstAvail.isNotEmpty) deliveryId = firstAvail.first.id;
      }
      if (deliveryId != _deliveryId) {
        _deliveryId = deliveryId;
        return _load();
      }
      setState(() {
        _cart = detailed.cart;
        _address = address;
        _payments = payments;
        _paymentId = payments.defaultId;
        _deliveryMethods = methods;
        _deliveryOptions = detailed.deliveryOptions;
        _deliveryId = deliveryId;
        _dropOffIndices = dropOffIndicesFromPrefs(address?.dropOffPreferences);
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

  Future<void> _placeOrder() async {
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
      if (!range.allowsDelivery) {
        await pushOutOfDelivery(
          context,
          address: range.address ?? _address,
        );
        return;
      }
    }

    setState(() => _placing = true);
    try {
      final dropOff = dropOffApiValues(_dropOffIndices);
      final windowStart = _windowForSelected();
      final result = await ref.read(cartRepositoryProvider).checkoutScheduled(
            addressId: addressId,
            paymentMethod: paymentMethodApiValue(_paymentId),
            windowStartAt: windowStart,
            deliverySpeed: deliverySpeedApiValue(_deliveryId),
            dropOffPreferences: dropOff.isEmpty ? null : dropOff,
            tipAmount: _tipAmount,
            voucherId: _selectedVoucherId,
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
      if (e is OutOfDeliveryRangeException ||
          isOutOfDeliveryRangeMessage(e.toString())) {
        await pushOutOfDelivery(context, address: _address);
        return;
      }
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
                  options: ScheduledCartData.dropOffOptions,
                  selectedIndices: _dropOffIndices,
                  onChanged: (next) => setState(() => _dropOffIndices = next),
                ),
                SizedBox(height: 14.h),
                CheckoutVouchersSection(
                  orderType: 'DELIVERY',
                  selectedVoucherId: _selectedVoucherId,
                  cartId: _cart?.cartId,
                  evaluateKey: voucherEvaluateKey(_cart),
                  onSelected: (id) async {
                    setState(() {
                      _selectedVoucherId = id;
                      if (id != null &&
                          id.isNotEmpty &&
                          _paymentId == 'wallet') {
                        final next =
                            _payments.options.where((o) => o.id != 'wallet');
                        if (next.isNotEmpty) _paymentId = next.first.id;
                      }
                    });
                    try {
                      final cart = await ref
                          .read(cartRepositoryProvider)
                          .fetchScheduledCart();
                      if (!mounted) return;
                      setState(() => _cart = cart);
                    } catch (_) {}
                  },
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(ScheduledCartStrings.paymentMethod),
                const ScheduledPaymentNoteBanner(),
                SizedBox(height: 12.h),
                CartPaymentMethodList(
                  options: (_selectedVoucherId != null &&
                          _selectedVoucherId!.isNotEmpty)
                      ? _payments.options
                          .where((o) => o.id != 'wallet')
                          .toList()
                      : _payments.options,
                  selectedId: _paymentId,
                  onSelected: (id) => setState(() => _paymentId = id),
                  showSecurityNotes: true,
                ),
                SizedBox(height: 14.h),
                CartTipSelector(
                  showHeader: true,
                  options: ScheduledCartData.tipOptions,
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
                CartSectionTitle(ScheduledCartStrings.billSummary),
                BillSummaryCard(
                  lines: _billLines,
                  showCashback: true,
                  cashbackAmount: cart?.cashbackPreview?.amountLabel ??
                      cart?.cashbackLabel,
                  cashbackMessage: cart?.cashbackPreview?.message,
                ),
                deliveryQuoteNotices(cart?.delivery),
              ],
            ),
      bottom: CartStickyFooter(
        total: _totalLabel,
        buttonLabel: _placing ? '…' : ScheduledCartStrings.placeOrder,
        onPressed: _placing ||
                _loading ||
                deliveryQuoteBlocksPlaceOrder(cart?.delivery)
            ? null
            : _placeOrder,
      ),
    );
  }
}
