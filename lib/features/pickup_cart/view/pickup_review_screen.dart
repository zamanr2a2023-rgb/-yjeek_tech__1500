import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/pickup_cart/model/pickup_cart_data.dart';
import 'package:yjeek_app/features/pickup_cart/view/widgets/pickup_cart_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/pickup_order_flow_routes.dart';

class PickupReviewScreen extends ConsumerStatefulWidget {
  const PickupReviewScreen({
    super.key,
    this.paymentId = 'benefitpay',
    this.tipAmount = 0,
  });

  final String paymentId;
  final double tipAmount;

  @override
  ConsumerState<PickupReviewScreen> createState() => _PickupReviewScreenState();
}

class _PickupReviewScreenState extends ConsumerState<PickupReviewScreen> {
  static const _initialSeconds = 10;
  late int _secondsLeft;
  Timer? _timer;
  CartSnapshot? _cart;
  bool _finishing = false;
  String? _checkoutError;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _initialSeconds;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finishing) return;
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() => _secondsLeft = 0);
        _finishOrder();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  Future<void> _load() async {
    final cart =
        await ref.read(cartRepositoryProvider).fetchCart(CartOrderType.pickup);
    if (!mounted) return;
    setState(() => _cart = cart);
  }

  Future<void> _finishOrder() async {
    if (_finishing) return;
    setState(() {
      _finishing = true;
      _checkoutError = null;
    });
    _timer?.cancel();
    try {
      final order = await ref.read(cartRepositoryProvider).checkout(
            type: CartOrderType.pickup,
            paymentMethod: paymentMethodApiValue(widget.paymentId),
            tipAmount: widget.tipAmount,
          );
      if (!mounted) return;
      final orderId = order?['id']?.toString();
      if (orderId == null || orderId.isEmpty) {
        throw Exception('Checkout failed — try again');
      }
      context.pushReplacement(PickupOrderFlowRoutes.waitingFor(orderId));
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _finishing = false;
        _checkoutError = message;
        _secondsLeft = _initialSeconds;
      });
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFB42318),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;
    final vendor = cart?.vendorName.isNotEmpty == true
        ? cart!.vendorName
        : PickupCartData.vendor;
    final collectAt = cart?.pickup?.address ??
        cart?.pickup?.vendorLabel ??
        PickupCartData.collectAt;
    final total = cart != null
        ? formatCheckoutTotal(cart, widget.tipAmount)
        : PickupCartData.orderTotal;
    final payment = formatPaymentMethod(
      paymentMethodApiValue(widget.paymentId),
    );

    return CartFlowScaffold(
      title: PickupCartStrings.reviewConfirm,
      lightHeader: true,
      bottomNavIndex: 2,
      backgroundColor: const Color(0xFFF2F7F2),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
              children: [
                PickupReviewStatusCard(secondsLeft: _secondsLeft),
                if (_checkoutError != null) ...[
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F0),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFF5C2C0)),
                    ),
                    child: Text(
                      _checkoutError!,
                      style: TextStyle(
                        color: const Color(0xFFB42318),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 14.h),
                PickupReviewSummaryCard(
                  orderTypeLabel: '${vendor.toUpperCase()} · PICKUP',
                  collectAt: collectAt,
                  orderTotal: total,
                  paymentLabel: payment,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
            child: Row(
              children: [
                Expanded(
                  child: CartOutlineButton(
                    label: PickupCartStrings.editOrder,
                    onPressed: _finishing
                        ? () {}
                        : () {
                            _timer?.cancel();
                            context.pop();
                          },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PrimaryGreenButton(
                    label: _finishing ? '…' : PickupCartStrings.sendToVendor,
                    backgroundColor: const Color(0xFF4CAF50),
                    height: 53,
                    onPressed: _finishing ? null : _finishOrder,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
