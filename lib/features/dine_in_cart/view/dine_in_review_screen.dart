import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/model/pending_checkout.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/dine_in_cart/dine_in_cart_routes.dart';
import 'package:yjeek_app/features/dine_in_cart/model/dine_in_cart_data.dart';
import 'package:yjeek_app/features/dine_in_cart/view/widgets/dine_in_cart_widgets.dart';
import 'package:yjeek_app/features/dine_in_order_flow/dine_in_order_flow_routes.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';

class DineInReviewScreen extends ConsumerStatefulWidget {
  const DineInReviewScreen({
    super.key,
    this.prepMode = DineInPrepMode.prepareNow,
  });

  final DineInPrepMode prepMode;

  @override
  ConsumerState<DineInReviewScreen> createState() => _DineInReviewScreenState();
}

class _DineInReviewScreenState extends ConsumerState<DineInReviewScreen> {
  static const _initialSeconds = 10;
  late int _secondsLeft;
  Timer? _timer;
  bool _finishing = false;
  bool _placing = false;
  bool _loading = true;

  String _vendor = DineInCartData.vendorFull;
  String _items = 'Mixed Grill Platter + 2 more';
  String _time = DineInCartData.dineInTime;
  String _payment = DineInCartStrings.yjeekWallet;
  String _total = DineInCartData.orderTotal;
  List<BillLine> _bill = DineInCartData.billLines;
  late DineInPrepMode _prepMode;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _initialSeconds;
    _prepMode = widget.prepMode;
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
    final pending = ref.read(pendingDineInCheckoutProvider);
    if (pending != null) _prepMode = pending.prepMode;

    final cart =
        await ref.read(cartRepositoryProvider).fetchCart(CartOrderType.dineIn);
    if (!mounted) return;

    final paymentId = pending?.paymentId ?? 'wallet';
    final itemLabel = cart.items.isEmpty
        ? _items
        : (cart.items.length == 1
            ? cart.items.first.name
            : '${cart.items.first.name} + ${cart.items.length - 1} more');
    final readyLabel = formatDineInReadyLabel(
      dineIn: cart.dineIn,
      eta: cart.deliveryEta,
      fallback: DineInCartData.dineInTime,
    );
    final timeLabel = _prepMode == DineInPrepMode.prepareOnArrival
        ? formatPickupTimeLabel(
            cart.scheduledDineInAt ?? cart.dineIn?.scheduledAt,
            readyLabel: readyLabel,
          )
        : readyLabel;

    setState(() {
      if (cart.vendorName.isNotEmpty) _vendor = cart.vendorName;
      _items = itemLabel;
      _time = timeLabel;
      _payment = formatPaymentMethod(paymentMethodApiValue(paymentId));
      _total = cart.totalLabel;
      _bill = cart.billLines;
      _loading = false;
    });
  }

  Future<void> _confirmAndPlace() async {
    if (_finishing || _placing) return;
    _timer?.cancel();

    final pending = ref.read(pendingDineInCheckoutProvider);
    final paymentId = pending?.paymentId ?? 'wallet';
    final prepMode = pending?.prepMode ?? _prepMode;

    setState(() => _placing = true);
    try {
      final isArrival = prepMode == DineInPrepMode.prepareOnArrival;
      final cart =
          await ref.read(cartRepositoryProvider).fetchCart(CartOrderType.dineIn);
      await ref.read(cartRepositoryProvider).updatePreferences(
            type: CartOrderType.dineIn,
            dineInPrepMode:
                isArrival ? 'PREPARE_ON_ARRIVAL' : 'PREPARE_NOW',
            scheduledDineInAt: isArrival ? cart.scheduledDineInAt : null,
            clearScheduledDineInAt: !isArrival,
          );
      final order = await ref.read(cartRepositoryProvider).checkout(
            type: CartOrderType.dineIn,
            paymentMethod: paymentMethodApiValue(paymentId),
          );
      if (!mounted) return;
      _finishing = true;
      ref.read(pendingDineInCheckoutProvider.notifier).state = null;
      final orderId = order?['id']?.toString();
      context.pushReplacement(DineInOrderFlowRoutes.waitingFor(orderId));
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

  /// Same destination as editing checkout (prep / payment / time).
  void _editOrder() {
    if (_finishing || _placing) return;
    _timer?.cancel();
    _finishing = true;
    ref.read(pendingDineInCheckoutProvider.notifier).state = null;
    context.go(DineInCartRoutes.checkoutWithMode(_prepMode));
  }

  @override
  Widget build(BuildContext context) {
    final busy = _finishing || _placing;
    return CartFlowScaffold(
      title: DineInCartStrings.reviewConfirm,
      lightHeader: true,
      onBack: busy ? null : _editOrder,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              children: [
                DineInReviewStatusCard(
                  secondsLeft: _secondsLeft,
                  totalSeconds: _initialSeconds,
                ),
                SizedBox(height: 14.h),
                _DineInLiveSummaryCard(
                  prepMode: _prepMode,
                  vendor: _vendor,
                  items: _items,
                  time: _time,
                  payment: _payment,
                  total: _total,
                ),
                SizedBox(height: 14.h),
                Text(
                  DineInCartStrings.billSummary,
                  style:
                      AppTextStyles.labelMedium(color: AppColors.textPrimary)
                          .copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                BillSummaryCard(
                  lines: _bill,
                  cashbackAmount: null,
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
                  label: DineInCartStrings.editOrder,
                  onPressed: busy ? () {} : _editOrder,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryGreenButton(
                  label: _placing ? '…' : DineInCartStrings.confirmNow,
                  onPressed: busy ? null : _confirmAndPlace,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DineInLiveSummaryCard extends StatelessWidget {
  const _DineInLiveSummaryCard({
    required this.prepMode,
    required this.vendor,
    required this.items,
    required this.time,
    required this.payment,
    required this.total,
  });

  final DineInPrepMode prepMode;
  final String vendor;
  final String items;
  final String time;
  final String payment;
  final String total;

  @override
  Widget build(BuildContext context) {
    final diningOption = prepMode == DineInPrepMode.prepareNow
        ? DineInCartStrings.payPrepNow
        : 'Prepare on arrival';

    return CartFlowCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DineInCartStrings.orderSummary,
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                .copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 12.h),
          _row(DineInCartStrings.restaurant, vendor),
          _row(DineInCartStrings.items, items),
          _row(DineInCartStrings.diningOptionLabel, diningOption),
          _row(DineInCartStrings.time, time),
          _row(DineInCartStrings.payment, payment),
          Divider(height: 20.h, color: const Color(0xFFE2E8DD)),
          _row(DineInCartStrings.orderTotal, total, bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall(color: const Color(0xFF6B7B6E))
                .copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
              height: 1.3,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                  .copyWith(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                fontSize: bold ? 15.sp : 13.sp,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
