import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/model/pending_checkout.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/routes/app_router.dart';

/// Food: 10s window after checkout to edit or confirm (auto-places order).
class ReviewConfirmScreen extends ConsumerStatefulWidget {
  const ReviewConfirmScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<ReviewConfirmScreen> createState() =>
      _ReviewConfirmScreenState();
}

class _ReviewConfirmScreenState extends ConsumerState<ReviewConfirmScreen> {
  static const _initialSeconds = 10;
  late int _secondsLeft;
  Timer? _timer;
  bool _finishing = false;
  bool _loading = true;
  bool _placing = false;

  String _vendor = CartFlowData.vendor;
  List<({String qty, String name, String price})> _items = const [];
  String _deliverTo = CartFlowData.reviewAddressLine;
  String _arrives = CartFlowStrings.standardDelivery;
  String _payment = CartFlowStrings.cashOnDelivery;
  String _total = CartFlowData.orderTotal;

  bool get _hasExistingOrder =>
      widget.orderId != null && widget.orderId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _initialSeconds;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _hydrate();
      if (!mounted) return;
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finishing || _placing) return;
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() => _secondsLeft = 0);
        _confirmAndPlace();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  Future<void> _hydrate() async {
    if (_hasExistingOrder) {
      await _hydrateFromOrder(widget.orderId!);
      return;
    }
    await _hydrateFromCart();
  }

  Future<void> _hydrateFromOrder(String orderId) async {
    final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
    if (!mounted) return;
    if (order == null) {
      setState(() => _loading = false);
      return;
    }

    final vendor = order['vendor'];
    final vendorName = vendor is Map
        ? vendor['name']?.toString() ?? _vendor
        : _vendor;

    final rawItems = order['items'];
    final lines = reviewLinesFromApi(rawItems is List ? rawItems : null);

    final etaMin = order['estimatedArrivalMin'] ?? order['etaMin'];
    final etaMax = order['estimatedArrivalMax'] ?? order['etaMax'];
    final etaLabel = order['etaLabel']?.toString();
    final arrives = etaLabel != null && etaLabel.isNotEmpty
        ? (etaLabel.toLowerCase().contains('standard')
            ? etaLabel
            : '$etaLabel · Standard')
        : (etaMin != null
            ? '$etaMin–${etaMax ?? etaMin} min · Standard'
            : CartFlowStrings.standardDelivery);

    setState(() {
      _vendor = vendorName;
      _items = lines;
      _deliverTo =
          deliverToFromOrderApi(order) ?? CartFlowData.reviewAddressLine;
      _arrives = arrives;
      _payment = formatPaymentMethod(order['paymentMethod']?.toString());
      _total = formatBhd(order['totalAmount']);
      _loading = false;
    });
  }

  Future<void> _hydrateFromCart() async {
    final pending = ref.read(pendingCheckoutProvider);
    final cart = await ref
        .read(cartRepositoryProvider)
        .fetchCart(CartOrderType.delivery);
    final address =
        await ref.read(addressesRepositoryProvider).defaultAddress();
    if (!mounted) return;

    if (!cart.hasItems) {
      ref.read(pendingCheckoutProvider.notifier).state = null;
      showEmptyCartSnackBar(context);
      context.goHome(tab: 2, emptyCart: true);
      return;
    }

    final tip = pending?.tipAmount ?? 0;
    final paymentId = pending?.paymentId ?? 'benefitpay';
    final lines = cart.items
        .map(
          (item) => (
            qty: '${item.quantity}×',
            name: item.name,
            price: item.unitPriceLabel,
          ),
        )
        .toList();

    final eta = cart.deliveryEta;
    final arrives = eta != null && eta.etaMin > 0
        ? '${eta.etaMin}–${eta.etaMax > 0 ? eta.etaMax : eta.etaMin} min · Standard'
        : CartFlowStrings.standardDelivery;

    final deliverTo = address == null
        ? CartFlowData.reviewAddressLine
        : [
            if (address.label.trim().isNotEmpty) address.label.trim(),
            if (address.subtitle.trim().isNotEmpty) address.subtitle.trim(),
          ].join(' · ');

    setState(() {
      _vendor = cart.vendorName.isNotEmpty ? cart.vendorName : _vendor;
      _items = lines;
      _deliverTo = deliverTo.isEmpty ? CartFlowData.reviewAddressLine : deliverTo;
      _arrives = arrives;
      _payment = formatPaymentMethod(paymentMethodApiValue(paymentId));
      _total = formatCheckoutTotal(cart, tip);
      _loading = false;
    });
  }

  Future<void> _confirmAndPlace() async {
    if (_finishing || _placing) return;
    _timer?.cancel();

    // Legacy path: order already created at checkout.
    if (_hasExistingOrder) {
      _finishing = true;
      if (mounted) {
        context.pushReplacement(OrderFlowRoutes.waitingFor(widget.orderId));
      }
      return;
    }

    final pending = ref.read(pendingCheckoutProvider);
    if (pending == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout session expired. Try again.')),
      );
      context.go(CartRoutes.checkout);
      return;
    }

    setState(() => _placing = true);
    try {
      final cart = await ref
          .read(cartRepositoryProvider)
          .fetchCart(CartOrderType.delivery);
      if (!mounted) return;
      if (!cart.hasItems) {
        ref.read(pendingCheckoutProvider.notifier).state = null;
        setState(() {
          _placing = false;
          _secondsLeft = _initialSeconds;
        });
        showEmptyCartSnackBar(context);
        context.goHome(tab: 2, emptyCart: true);
        return;
      }
      final dropOff = dropOffApiValue(pending.dropOffIndex);
      final order = await ref.read(cartRepositoryProvider).checkout(
            type: CartOrderType.delivery,
            paymentMethod: paymentMethodApiValue(pending.paymentId),
            tipAmount: pending.tipAmount,
            addressId: pending.addressId,
            dropOffPreferences: dropOff == null ? null : [dropOff],
            saveDropOffPreferences: pending.saveDropOff,
          );
      if (!mounted) return;
      _finishing = true;
      ref.read(pendingCheckoutProvider.notifier).state = null;
      final orderId = order?['id']?.toString();
      context.pushReplacement(OrderFlowRoutes.waitingFor(orderId));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _placing = false;
        _secondsLeft = _initialSeconds;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      _startTimer();
    }
  }

  /// Same route as the address "Edit" link.
  Future<void> _editAddress() async {
    if (_finishing || _placing) return;
    _timer?.cancel();

    if (_hasExistingOrder) {
      final orderId = widget.orderId!;
      await ref.read(ordersRepositoryProvider).cancel(
            orderId,
            reason: 'Changed address before confirm',
          );
    }

    if (!mounted) return;
    _finishing = true;
    await context.push(CartRoutes.changeAddress);
    if (!mounted) return;
    context.go(CartRoutes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    final busy = _finishing || _placing;
    return CartFlowScaffold(
      title: CartFlowStrings.reviewConfirm,
      lightHeader: true,
      onBack: busy ? null : _editAddress,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              children: [
                CartReviewStatusCard(
                  secondsLeft: _secondsLeft,
                  totalSeconds: _initialSeconds,
                ),
                SizedBox(height: 14.h),
                Text(
                  CartFlowStrings.orderSummary,
                  style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                      .copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                CartReviewSummaryCard(
                  vendorName: _vendor,
                  items: _items,
                  deliverTo: _deliverTo,
                  arrivesIn: _arrives,
                  paymentMethod: _payment,
                  orderTotal: _total,
                  onEditAddress: busy ? null : _editAddress,
                ),
              ],
            ),
      bottom: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: CartOutlineButton(
                  label: CartFlowStrings.editOrder,
                  onPressed: busy ? () {} : _editAddress,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryGreenButton(
                  label: _placing ? '…' : CartFlowStrings.confirmNow,
                  height: 53,
                  enabled: !busy,
                  onPressed: _confirmAndPlace,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
