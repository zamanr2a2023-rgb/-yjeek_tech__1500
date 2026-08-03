import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/model/payment_methods_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/model/user_me.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _dropOffIndex = 0;
  int _tipIndex = 0;
  String _paymentId = 'cod';
  bool _saveDropOff = false;
  CartSnapshot? _cart;
  DeliveryAddressSnapshot? _address;
  CheckoutPaymentMethods _payments =
      CheckoutPaymentMethods.fallback(defaultId: 'cod');
  String? _phone;
  bool _loading = true;
  bool _placing = false;

  double get _tipAmount => tipAmountFrom(CartFlowData.tipOptions, _tipIndex);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cart = await ref
          .read(cartRepositoryProvider)
          .fetchCart(CartOrderType.delivery);
      final address =
          await ref.read(addressesRepositoryProvider).defaultAddress();
      final payments = await ref
          .read(paymentMethodsRepositoryProvider)
          .fetchCheckoutMethods(preferredDefaultId: 'cod');
      final UserMe? me = await ref.read(userRepositoryProvider).fetchMe();
      if (!mounted) return;
      setState(() {
        _cart = cart;
        _address = address;
        _payments = payments;
        _paymentId = payments.defaultId;
        _phone = address?.phone ?? me?.formattedPhone;
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
      final order = await ref.read(cartRepositoryProvider).checkout(
            type: CartOrderType.delivery,
            paymentMethod: paymentMethodApiValue(_paymentId),
            tipAmount: _tipAmount,
            addressId: addressId,
            dropOffPreferences: dropOff == null ? null : [dropOff],
            saveDropOffPreferences: _saveDropOff,
          );
      if (!mounted) return;
      final orderId = order?['id']?.toString();
      context.pushReplacement(CartRoutes.reviewFor(orderId));
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
    final vendor =
        cart?.vendorName.isNotEmpty == true ? cart!.vendorName : 'Checkout';
    final billLines =
        cart != null ? billLinesWithTip(cart, _tipAmount) : const <BillLine>[];
    final total =
        cart != null ? formatCheckoutTotal(cart, _tipAmount) : 'BHD 0.000';

    return CartFlowScaffold(
      title: CartFlowStrings.checkout,
      subtitle: vendor,
      lightHeader: true,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        }
      },
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
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
                  selectedIndex: _dropOffIndex,
                  onSelected: (index) => setState(() => _dropOffIndex = index),
                  saveForAddress: _saveDropOff,
                  onSaveChanged: (value) =>
                      setState(() => _saveDropOff = value),
                  showTitle: true,
                ),
                SizedBox(height: 18.h),
                CartTipSelector(
                  options: CartFlowData.tipOptions,
                  selectedIndex: _tipIndex,
                  onSelected: (index) => setState(() => _tipIndex = index),
                  showHeader: true,
                ),
                SizedBox(height: 18.h),
                CartSectionTitle(CartFlowStrings.paymentMethod),
                CartPaymentMethodList(
                  options: _payments.options,
                  selectedId: _paymentId,
                  onSelected: (id) => setState(() => _paymentId = id),
                  showSecurityNotes: true,
                ),
                SizedBox(height: 18.h),
                CartSectionTitle(CartFlowStrings.billSummary),
                CartZoodPromoBanner(
                  onTap: () => context.push(CartRoutes.zoodWaitingList),
                ),
                SizedBox(height: 12.h),
                BillSummaryCard(
                  lines: billLines,
                  showCashback: true,
                  cashbackAmount: cart?.cashbackLabel,
                ),
              ],
            ),
      bottom: CartStickyFooter(
        total: total,
        buttonLabel: _placing ? '…' : CartFlowStrings.placeOrder,
        onPressed: _placing || _loading ? () {} : _placeOrder,
      ),
    );
  }
}
