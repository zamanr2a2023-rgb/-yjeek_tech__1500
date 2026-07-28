import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/widgets/pickup_order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Food delivery: wait for vendor accept — polls order + live accept countdown.
class OrderWaitingScreen extends ConsumerStatefulWidget {
  const OrderWaitingScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<OrderWaitingScreen> createState() => _OrderWaitingScreenState();
}

class _OrderWaitingScreenState extends ConsumerState<OrderWaitingScreen> {
  static const _defaultAcceptWindow = Duration(seconds: 180);

  Timer? _pollTimer;
  Timer? _tickTimer;
  bool _cancelling = false;
  String? _status;
  String _summary = '…';
  String _total = 'BHD —';
  DateTime? _deadline;
  DateTime? _windowStart;
  Duration _totalWindow = _defaultAcceptWindow;

  static const _accepted = {
    'VENDOR_ACCEPTED',
    'CONFIRMED',
    'PREPARING',
    'SEARCHING_DRIVER',
    'AWAITING_DRIVER_CONFIRM',
    'DRIVER_ASSIGNED',
    'ARRIVED_AT_PICKUP',
    'PICKED_UP',
    'IN_TRANSIT',
    'ON_THE_WAY',
    'AWAITING_PAYMENT',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _poll();
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
      _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  Duration get _remaining {
    final deadline = _deadline;
    if (deadline == null) return _totalWindow;
    final left = deadline.difference(DateTime.now());
    if (left.isNegative) return Duration.zero;
    return left;
  }

  double get _progress {
    final totalMs = _totalWindow.inMilliseconds;
    if (totalMs <= 0) return 0;
    return (_remaining.inMilliseconds / totalMs).clamp(0.0, 1.0);
  }

  String get _timerLabel {
    final sec = _remaining.inSeconds;
    if (sec <= 0) return '0s';
    if (sec < 60) return '${sec}s';
    final mins = (sec / 60).ceil();
    return '~${mins}m';
  }

  Future<void> _poll() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty || !mounted) return;
    final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
    if (!mounted || order == null) return;

    final status = order['status']?.toString();
    final paymentMethod = order['paymentMethod']?.toString();
    final paymentStatus = order['paymentStatus']?.toString() ??
        (order['payment'] is Map
            ? (order['payment'] as Map)['status']?.toString()
            : null);

    final orderNumber =
        order['orderNumber']?.toString() ?? order['id']?.toString() ?? '';
    final items = order['items'];
    final itemCount = items is List
        ? items.length
        : (order['itemCount'] as num?)?.toInt() ?? 0;
    final shortId = orderNumber.length > 8
        ? '…${orderNumber.substring(orderNumber.length - 5)}'
        : orderNumber;

    final deadlineRaw = order['vendorAcceptDeadline']?.toString();
    final createdRaw =
        order['createdAt']?.toString() ?? order['placedAt']?.toString();
    final deadline = DateTime.tryParse(deadlineRaw ?? '')?.toLocal();
    final created = DateTime.tryParse(createdRaw ?? '')?.toLocal();

    setState(() {
      _status = status;
      _summary =
          '$itemCount ${itemCount == 1 ? 'Item' : 'Items'} · Order $shortId';
      _total = formatBhd(order['totalAmount']);
      if (deadline != null) {
        _deadline = deadline;
        if (created != null && deadline.isAfter(created)) {
          _windowStart = created;
          _totalWindow = deadline.difference(created);
        } else if (_windowStart == null) {
          // First time we see deadline — assume default window ending at deadline.
          _windowStart = deadline.subtract(_defaultAcceptWindow);
          _totalWindow = _defaultAcceptWindow;
        }
      } else if (_deadline == null) {
        _deadline = DateTime.now().add(_defaultAcceptWindow);
        _windowStart = DateTime.now();
        _totalWindow = _defaultAcceptWindow;
      }
    });

    if (status == 'CANCELLED' || status == 'REJECTED') {
      _pollTimer?.cancel();
      _tickTimer?.cancel();
      context.go('${RouteNames.home}?tab=1');
      return;
    }
    if (status != null && _accepted.contains(status)) {
      _pollTimer?.cancel();
      _tickTimer?.cancel();
      final needsPay = !_isPaidOrCash(paymentMethod, paymentStatus);
      if (needsPay) {
        context.pushReplacement(OrderFlowRoutes.payFor(orderId));
      } else {
        context.pushReplacement(OrderFlowRoutes.confirmedFor(orderId));
      }
    }
  }

  bool _isPaidOrCash(String? method, String? paymentStatus) {
    final m = (method ?? '').toUpperCase();
    final p = (paymentStatus ?? '').toUpperCase();
    if (p == 'PAID' || p == 'AUTHORIZED') return true;
    return m == 'CASH' || m == 'COD' || m == 'CASH_ON_DELIVERY';
  }

  Future<void> _cancel() async {
    final orderId = widget.orderId;
    if (_cancelling) return;
    _pollTimer?.cancel();
    if (orderId == null || orderId.isEmpty) {
      context.go('${RouteNames.home}?tab=1');
      return;
    }
    setState(() => _cancelling = true);
    final ok = await ref.read(ordersRepositoryProvider).cancel(
          orderId,
          reason: 'Cancelled while waiting for vendor',
        );
    if (!mounted) return;
    setState(() => _cancelling = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not cancel order'),
          backgroundColor: Color(0xFFB42318),
        ),
      );
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
      return;
    }
    _tickTimer?.cancel();
    context.go('${RouteNames.home}?tab=1');
  }

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          Center(
            child: PickupWaitingTimer(
              progress: _progress,
              label: _timerLabel,
            ),
          ),
          SizedBox(height: 10.h),
          const Center(child: PickupWaitingDots()),
          SizedBox(height: 16.h),
          Text(
            OrderFlowStrings.sentToVendor,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _status == null
                ? OrderFlowStrings.waitingSubtitle
                : 'Status: ${_status!.replaceAll('_', ' ')}',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(
              color: AppColors.textSecondary,
            ).copyWith(fontSize: 14.sp, height: 1.35),
          ),
          SizedBox(height: 16.h),
          const PickupSecureBanner(),
          SizedBox(height: 16.h),
          PickupOrderSummaryRow(summary: _summary, total: _total),
          SizedBox(height: 24.h),
          OrderOutlineButton(
            label: _cancelling ? 'Cancelling…' : OrderFlowStrings.cancelOrder,
            onPressed: _cancelling ? null : _cancel,
          ),
          SizedBox(height: 10.h),
          Text(
            OrderFlowStrings.freeCancelHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(
              color: AppColors.textSecondary,
            ).copyWith(fontSize: 11.sp),
          ),
        ],
      ),
    );
  }
}
