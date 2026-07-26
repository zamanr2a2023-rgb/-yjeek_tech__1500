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
import 'package:yjeek_app/features/scheduled_cart/view/widgets/scheduled_cart_widgets.dart';
import 'package:yjeek_app/features/scheduled_order_flow/scheduled_order_flow_routes.dart';

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
  bool _loading = true;
  bool _placing = false;

  double get _tipAmount =>
      tipAmountFrom(ScheduledCartData.tipOptions, _tipIndex);

  List<ScheduledDeliveryMethod> get _deliveryMethods {
    final fee = _cart != null
        ? (deliveryFeeFromBillLines(_cart!.billLines) ?? 1.0)
        : 1.0;
    final price = 'BHD ${fee.toStringAsFixed(3)}';
    return ScheduledCartData.deliveryMethods
        .map(
          (m) => ScheduledDeliveryMethod(
            id: m.id,
            label: m.label,
            subtitle: m.subtitle,
            price: price,
            priceValue: fee,
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _deliveryId = widget.initialDeliveryId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cart = await ref.read(cartRepositoryProvider).fetchScheduledCart();
      final address =
          await ref.read(addressesRepositoryProvider).defaultAddress();
      final payments = await ref
          .read(paymentMethodsRepositoryProvider)
          .fetchCheckoutMethods(
            preferredDefaultId: 'cod',
          );
      if (!mounted) return;
      setState(() {
        _cart = cart;
        _address = address;
        _payments = payments;
        _paymentId = payments.defaultId;
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
    setState(() => _placing = true);
    try {
      final dropOff = dropOffApiValue(_dropOffIndex);
      final windowStart = windowStartForDelivery(_deliveryId);
      await ref.read(cartRepositoryProvider).checkoutScheduled(
            addressId: addressId,
            paymentMethod: paymentMethodApiValue(_paymentId),
            windowStartAt: windowStart,
            deliverySpeed: deliverySpeedApiValue(_deliveryId),
            dropOffPreferences: dropOff == null ? null : [dropOff],
            tipAmount: _tipAmount,
          );
      if (!mounted) return;
      context.pushReplacement(ScheduledOrderFlowRoutes.waiting);
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
    final billLines = cart != null
        ? billLinesWithTip(cart, _tipAmount)
        : const <BillLine>[];
    final total = cart != null
        ? formatCheckoutTotal(cart, _tipAmount)
        : 'BHD 0.000';

    return CartFlowScaffold(
      title: ScheduledCartStrings.checkout,
      subtitle: vendor,
      lightHeader: true,
      backgroundColor: const Color(0xFFF2F7F2),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              children: [
                const CartSectionTitle(ScheduledCartStrings.deliveryAddress),
                ScheduledAddressCard(
                  address: _address?.label,
                  addressDetail: _address?.subtitle,
                  onChange: () => context.push(CartRoutes.changeAddress),
                ),
                SizedBox(height: 14.h),
                const CartSectionTitle(ScheduledCartStrings.deliveryMethod),
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
                const CartSectionTitle(ScheduledCartStrings.paymentMethod),
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
                const CartSectionTitle(ScheduledCartStrings.billSummary),
                BillSummaryCard(lines: billLines),
                SizedBox(height: 10.h),
                ScheduledCashbackBanner(amount: cart?.cashbackLabel),
              ],
            ),
      bottom: CartStickyFooter(
        total: total,
        buttonLabel: _placing ? '…' : ScheduledCartStrings.placeOrder,
        onPressed: _placing || _loading ? () {} : _placeOrder,
      ),
    );
  }
}
