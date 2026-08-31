import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/model/pickup_order_flow_data.dart';
import 'package:yjeek_app/features/pickup_order_flow/pickup_order_flow_routes.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/widgets/pickup_order_flow_widgets.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_api_mappers.dart';
import 'package:yjeek_app/routes/route_names.dart';

class PickupWaitingScreen extends ConsumerStatefulWidget {
  const PickupWaitingScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<PickupWaitingScreen> createState() =>
      _PickupWaitingScreenState();
}

class _PickupWaitingScreenState extends ConsumerState<PickupWaitingScreen> {
  static const _defaultWindow = Duration(seconds: 180);

  Timer? _pollTimer;
  Timer? _tickTimer;
  bool _cancelling = false;
  String _title = PickupOrderFlowStrings.sentToVendor;
  String _summary = PickupOrderFlowData.waitingSummary;
  String _total = PickupOrderFlowData.payTotal;
  DateTime? _deadline;
  Duration _totalWindow = _defaultWindow;

  static const _accepted = {
    'VENDOR_ACCEPTED',
    'CONFIRMED',
    'PREPARING',
    'AWAITING_PAYMENT',
    'READY_FOR_PICKUP',
    'READY',
    'COLLECTED',
    'COMPLETED',
  };

  @override
  void initState() {
    super.initState();
    _deadline = DateTime.now().add(_defaultWindow);
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

  String get _timerLabel {
    final sec = _remaining.inSeconds;
    final m = sec ~/ 60;
    final s = sec % 60;
    if (m <= 0) return '${s}s';
    return '~${m}m';
  }

  double get _progress {
    final total = _totalWindow.inSeconds;
    if (total <= 0) return 0;
    return (_remaining.inSeconds / total).clamp(0.0, 1.0);
  }

  bool _isPaidOrCash(String? method, String? paymentStatus) {
    final m = (method ?? '').toUpperCase();
    final p = (paymentStatus ?? '').toUpperCase();
    if (p == 'PAID' || p == 'AUTHORIZED') return true;
    return m == 'CASH' || m == 'COD' || m == 'CASH_ON_DELIVERY';
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
    final vendor = order['vendor'];
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;
    final orderNumber =
        order['orderNumber']?.toString() ?? order['id']?.toString() ?? '';
    final itemLabel = itemsSummaryFromOrderApi(order);
    final shortId = orderNumber.length > 8
        ? '…${orderNumber.substring(orderNumber.length - 5)}'
        : orderNumber;
    final deadline =
        DateTime.tryParse(order['vendorAcceptDeadline']?.toString() ?? '')
            ?.toLocal();
    final created =
        DateTime.tryParse(order['createdAt']?.toString() ?? '')?.toLocal();

    setState(() {
      if (vendorName != null && vendorName.isNotEmpty) {
        _title = 'Sent to $vendorName';
      }
      _summary = shortId.isEmpty
          ? itemLabel
          : '$itemLabel · Order $shortId';
      _total = formatBhd(order['totalAmount']);
      if (deadline != null) {
        _deadline = deadline;
        if (created != null && deadline.isAfter(created)) {
          _totalWindow = deadline.difference(created);
        }
      } else {
        _deadline ??= DateTime.now().add(_defaultWindow);
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
        context.pushReplacement(PickupOrderFlowRoutes.payFor(orderId));
      } else {
        context.pushReplacement(PickupOrderFlowRoutes.confirmedFor(orderId));
      }
    }
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
            _title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            PickupOrderFlowStrings.waitingSubtitle,
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
            label: _cancelling
                ? 'Cancelling…'
                : PickupOrderFlowStrings.cancelOrder,
            onPressed: _cancelling ? null : _cancel,
          ),
          SizedBox(height: 10.h),
          Text(
            PickupOrderFlowStrings.freeCancelHint,
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
