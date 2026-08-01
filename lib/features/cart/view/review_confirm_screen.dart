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
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Food: 10s window after place-order to edit or confirm (auto-confirms).
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

  String _vendor = CartFlowData.vendor;
  List<({String qty, String name, String price})> _items = const [];
  String _deliverTo = CartFlowData.reviewAddressLine;
  String _arrives = CartFlowStrings.standardDelivery;
  String _payment = CartFlowStrings.cashOnDelivery;
  String _total = CartFlowData.orderTotal;

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
      if (!mounted || _finishing) return;
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() => _secondsLeft = 0);
        _goWaiting();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  Future<void> _hydrate() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
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

  void _goWaiting() {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();
    final orderId = widget.orderId;
    context.pushReplacement(OrderFlowRoutes.waitingFor(orderId));
  }

  Future<void> _cancelAndLeave(String route) async {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();
    final orderId = widget.orderId;
    if (orderId != null && orderId.isNotEmpty) {
      await ref.read(ordersRepositoryProvider).cancel(
            orderId,
            reason: 'Edited before confirm',
          );
    }
    if (!mounted) return;
    context.go(route);
  }

  Future<void> _editOrder() =>
      _cancelAndLeave('${RouteNames.home}?tab=2&cart=1');

  Future<void> _editAddress() async {
    if (_finishing) return;
    // Pause countdown while choosing address; cancel order so checkout can re-run.
    _timer?.cancel();
    final orderId = widget.orderId;
    if (orderId != null && orderId.isNotEmpty) {
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
    return CartFlowScaffold(
      title: CartFlowStrings.reviewConfirm,
      lightHeader: true,
      onBack: _finishing ? null : _editOrder,
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
                  onEditAddress: _finishing ? null : _editAddress,
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
                  onPressed: _finishing ? () {} : _editOrder,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryGreenButton(
                  label: CartFlowStrings.confirmNow,
                  height: 53,
                  enabled: !_finishing,
                  onPressed: _goWaiting,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
