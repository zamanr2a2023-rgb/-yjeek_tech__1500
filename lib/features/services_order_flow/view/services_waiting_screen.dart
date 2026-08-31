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
import 'package:yjeek_app/features/services_order_flow/model/services_order_api_mappers.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/services_order_flow_routes.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class ServicesWaitingScreen extends ConsumerStatefulWidget {
  const ServicesWaitingScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<ServicesWaitingScreen> createState() =>
      _ServicesWaitingScreenState();
}

class _ServicesWaitingScreenState extends ConsumerState<ServicesWaitingScreen> {
  static const _defaultWindow = Duration(seconds: 300);
  static const Color _muted = Color(0xFF6B7A6E);

  Timer? _pollTimer;
  Timer? _tickTimer;
  bool _cancelling = false;
  String _vendor = ServicesOrderFlowData.providerName;
  String _summary = ServicesOrderFlowData.bookingSummary;
  String _total = ServicesOrderFlowData.payTotal;
  DateTime? _deadline;
  Duration _totalWindow = _defaultWindow;

  static const _accepted = {
    'VENDOR_ACCEPTED',
    'CONFIRMED',
    'PREPARING',
    'AWAITING_PAYMENT',
    'IN_PROGRESS',
    'READY_FOR_YOU',
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
    return '${m.toString()}:${s.toString().padLeft(2, '0')}';
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
    final vendorName =
        vendor is Map ? vendor['name']?.toString() ?? _vendor : _vendor;
    final orderNumber =
        order['orderNumber']?.toString() ?? order['id']?.toString() ?? '';
    final serviceName = servicesServiceNameFromOrder(order);
    final shortId = orderNumber.length > 8
        ? '…${orderNumber.substring(orderNumber.length - 5)}'
        : orderNumber;
    final deadline =
        DateTime.tryParse(order['vendorAcceptDeadline']?.toString() ?? '')
            ?.toLocal();
    final created =
        DateTime.tryParse(order['createdAt']?.toString() ?? '')?.toLocal();

    setState(() {
      _vendor = vendorName;
      _summary = '$serviceName · Booking $shortId';
      _total = formatBhd(order['totalAmount']);
      if (deadline != null) {
        _deadline = deadline;
        if (created != null) {
          final window = deadline.difference(created);
          if (!window.isNegative && window.inSeconds > 0) {
            _totalWindow = window;
          }
        }
      }
    });

    if (status != null && _accepted.contains(status)) {
      _pollTimer?.cancel();
      _tickTimer?.cancel();
      final needsPay = !_isPaidOrCash(paymentMethod, paymentStatus);
      if (needsPay) {
        context.pushReplacement(ServicesOrderFlowRoutes.payFor(orderId));
      } else {
        context.pushReplacement(ServicesOrderFlowRoutes.confirmedFor(orderId));
      }
    }
  }

  Future<void> _cancelBooking() async {
    final orderId = widget.orderId;
    if (_cancelling) return;
    if (orderId == null || orderId.isEmpty) {
      context.go('${RouteNames.home}?tab=1');
      return;
    }
    setState(() => _cancelling = true);
    final ok = await ref.read(ordersRepositoryProvider).cancel(
          orderId,
          reason: 'Changed mind',
        );
    if (!mounted) return;
    setState(() => _cancelling = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not cancel booking')),
      );
      return;
    }
    _pollTimer?.cancel();
    _tickTimer?.cancel();
    context.go('${RouteNames.home}?tab=1');
  }

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 0,
      body: ListView(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 28.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 12.h),
          Center(child: ServicesWaitingTimer(label: _timerLabel)),
          SizedBox(height: 16.h),
          Text(
            'Sent to $_vendor',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium(color: AppColors.textPrimary)
                .copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 22.sp,
                  height: 27 / 22,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            ServicesOrderFlowStrings.waitingSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(color: _muted).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              height: 17 / 14,
            ),
          ),
          SizedBox(height: 16.h),
          const ServicesInfoBanner(),
          SizedBox(height: 16.h),
          ServicesBookingSummaryRow(summary: _summary, total: _total),
          SizedBox(height: 24.h),
          ServicesCancelBookingButton(
            onPressed: _cancelling ? () {} : _cancelBooking,
          ),
          SizedBox(height: 6.h),
          Text(
            ServicesOrderFlowStrings.freeCancelHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: _muted).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              height: 15 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
