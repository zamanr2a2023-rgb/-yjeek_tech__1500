import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_api_mappers.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_flow_data.dart';
import 'package:yjeek_app/features/scheduled_order_flow/scheduled_order_flow_routes.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/widgets/scheduled_order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class ScheduledWaitingScreen extends ConsumerStatefulWidget {
  const ScheduledWaitingScreen({super.key, this.orderIds = const []});

  final List<String> orderIds;

  @override
  ConsumerState<ScheduledWaitingScreen> createState() =>
      _ScheduledWaitingScreenState();
}

class _ScheduledWaitingScreenState
    extends ConsumerState<ScheduledWaitingScreen> {
  static const _defaultWindow = Duration(seconds: 120);
  static const _accepted = {
    'VENDOR_ACCEPTED',
    'CONFIRMED',
    'PREPARING',
    'AWAITING_PAYMENT',
    'OUT_FOR_DELIVERY',
    'DELIVERED',
    'COMPLETED',
  };

  Timer? _pollTimer;
  Timer? _tickTimer;
  bool _cancelling = false;
  bool _advanced = false;
  String _title = ScheduledOrderFlowStrings.sentToVendor;
  String _summary = '—';
  String _total = '—';
  DateTime? _deadline;
  Duration _totalWindow = _defaultWindow;

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
    final ids = widget.orderIds;
    if (ids.isEmpty || !mounted || _advanced) return;

    final orders = <Map<String, dynamic>>[];
    for (final id in ids) {
      final order = await ref.read(ordersRepositoryProvider).getOrder(id);
      if (order != null) orders.add(order);
    }
    if (!mounted || orders.isEmpty) return;

    final first = orders.first;
    final vendor = first['vendor'];
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;
    var total = 0.0;
    DateTime? minDeadline;
    var allAccepted = true;
    var needsPay = false;

    for (final order in orders) {
      total += (order['totalAmount'] as num?)?.toDouble() ?? 0;
      final deadline =
          DateTime.tryParse(order['vendorAcceptDeadline']?.toString() ?? '')
              ?.toLocal();
      if (deadline != null &&
          (minDeadline == null || deadline.isBefore(minDeadline))) {
        minDeadline = deadline;
      }
      final status = order['status']?.toString().toUpperCase() ?? '';
      if (!_accepted.contains(status)) allAccepted = false;
      final method = order['paymentMethod']?.toString();
      final paymentStatus = order['paymentStatus']?.toString() ??
          (order['payment'] is Map
              ? (order['payment'] as Map)['status']?.toString()
              : null);
      if (!_isPaidOrCash(method, paymentStatus) &&
          (status == 'AWAITING_PAYMENT' ||
              status == 'VENDOR_ACCEPTED' ||
              status == 'CONFIRMED')) {
        needsPay = true;
      }
    }

    final count = orders.length;
    final orderNumber = first['orderNumber']?.toString();
    final itemLabel = itemsSummaryFromOrderApi(first);
    setState(() {
      if (vendorName != null && vendorName.isNotEmpty) {
        _title = count > 1
            ? 'Sent to $vendorName +${count - 1}'
            : 'Sent to $vendorName';
      }
      if (count > 1) {
        _summary = '$count scheduled orders · $itemLabel';
      } else if (orderNumber != null && orderNumber.isNotEmpty) {
        _summary = '$itemLabel · Order $orderNumber';
      } else {
        _summary = itemLabel;
      }
      _total = formatBhd(total);
      if (minDeadline != null) {
        _deadline = minDeadline;
        final created =
            DateTime.tryParse(first['createdAt']?.toString() ?? '')?.toLocal();
        if (created != null) {
          final window = minDeadline.difference(created);
          if (!window.isNegative && window.inSeconds > 0) {
            _totalWindow = window;
          }
        }
      }
    });

    if (allAccepted) {
      _advanced = true;
      _pollTimer?.cancel();
      _tickTimer?.cancel();
      if (needsPay) {
        context.pushReplacement(ScheduledOrderFlowRoutes.payFor(ids));
      } else {
        context.pushReplacement(ScheduledOrderFlowRoutes.confirmedFor(ids));
      }
    }
  }

  Future<void> _cancel() async {
    if (_cancelling) return;
    final ids = widget.orderIds;
    if (ids.isEmpty) {
      context.go('${RouteNames.home}?tab=0');
      return;
    }
    setState(() => _cancelling = true);
    for (final id in ids) {
      await ref
          .read(ordersRepositoryProvider)
          .cancel(id, reason: 'Changed mind');
    }
    if (!mounted) return;
    setState(() => _cancelling = false);
    context.go('${RouteNames.home}?tab=0');
  }

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.paddingOf(context).top + 10.h),
            Center(
              child: ScheduledWaitingTimer(
                label: _timerLabel,
                progress: _progress,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium(color: const Color(0xFF1A1A1A))
                  .copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 23.sp,
                height: 1.32,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              ScheduledOrderFlowStrings.waitingSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(color: const Color(0xFF6B7B6E))
                  .copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 15.sp,
                height: 1.32,
              ),
            ),
            SizedBox(height: 12.h),
            const Center(child: ScheduledWaitingDots()),
            SizedBox(height: 16.h),
            const ScheduledSecureBanner(),
            SizedBox(height: 16.h),
            ScheduledOrderSummaryRow(summary: _summary, total: _total),
            const Spacer(),
            _CancelOrderBlock(
              onCancel: _cancelling ? () {} : _cancel,
            ),
            SizedBox(height: 28.h),
          ],
        ),
      ),
    );
  }
}

class _CancelOrderBlock extends StatelessWidget {
  const _CancelOrderBlock({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 53.h,
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFF7FAF7),
              foregroundColor: const Color(0xFF1A1A1A),
              side: const BorderSide(color: Color(0xFFE2E8DD), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r),
              ),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              ScheduledOrderFlowStrings.cancelOrder,
              style: AppTextStyles.labelMedium(
                color: const Color(0xFF1A1A1A),
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                height: 1.32,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          ScheduledOrderFlowStrings.freeCancelHint,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
            height: 1.32,
          ),
        ),
      ],
    );
  }
}
