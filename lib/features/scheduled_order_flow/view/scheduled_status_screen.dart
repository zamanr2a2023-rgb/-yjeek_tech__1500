import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_api_mappers.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_flow_data.dart';
import 'package:yjeek_app/features/scheduled_order_flow/scheduled_order_flow_routes.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/widgets/scheduled_order_flow_widgets.dart';

class ScheduledStatusScreen extends ConsumerStatefulWidget {
  const ScheduledStatusScreen({super.key, this.orderIds = const []});

  final List<String> orderIds;

  @override
  ConsumerState<ScheduledStatusScreen> createState() =>
      _ScheduledStatusScreenState();
}

class _ScheduledStatusScreenState extends ConsumerState<ScheduledStatusScreen> {
  Timer? _pollTimer;
  String _subtitle = 'Electronics';
  String _packed = ScheduledOrderFlowStrings.packedBanner;
  String _mapHint = ScheduledOrderFlowStrings.liveMapHint;
  bool _mapUnlocked = false;
  List<ScheduledOrderTimelineStep> _timeline = const [];
  String _items = '—';
  String _delivery = '—';
  String _total = '—';
  bool _loading = true;
  String? _error;

  String? get _primaryId =>
      widget.orderIds.isEmpty ? null : widget.orderIds.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _load());
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final id = _primaryId;
    if (id == null || id.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Order not found';
        });
      }
      return;
    }
    final data = await ref.read(ordersRepositoryProvider).trackOrder(id);
    if (!mounted) return;
    if (data == null) {
      setState(() {
        _loading = false;
        _error ??= 'Could not load order status';
      });
      return;
    }

    final vendor = data['vendor'];
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;
    final orderNumber = data['orderNumber']?.toString();
    final status = data['status']?.toString();
    final champ = data['champ'];
    final hasChamp = champ is Map &&
        ((champ['name']?.toString().isNotEmpty ?? false) ||
            (champ['firstName']?.toString().isNotEmpty ?? false));
    final statusUpper = (status ?? '').toUpperCase();
    final liveTracking = hasChamp ||
        statusUpper == 'PICKED_UP' ||
        statusUpper == 'IN_TRANSIT' ||
        statusUpper == 'ON_THE_WAY' ||
        statusUpper == 'ARRIVED_AT_CUSTOMER';

    setState(() {
      final number = orderNumber != null && orderNumber.isNotEmpty
          ? orderNumber
          : '—';
      _subtitle = vendorName != null && vendorName.isNotEmpty
          ? 'Electronics · $vendorName · #$number'
          : 'Electronics · #$number';
      _timeline = scheduledTimelineFromTrack(
        timeline: data['timeline'] is List ? data['timeline'] as List : null,
        currentStatus: status,
      );
      _items = itemsSummaryFromOrderApi(data);
      _delivery = deliveryWindowFromOrderApi(data);
      _total = data['totalAmount'] != null
          ? formatBhd(data['totalAmount'])
          : _total;
      _packed = packedBannerFromTrack(data);
      _mapUnlocked = liveTracking;
      _mapHint = liveTracking
          ? (hasChamp
              ? 'Live map tracking active · champ on the way.'
              : 'Live map tracking available for this delivery.')
          : ScheduledOrderFlowStrings.liveMapHint;
      _loading = false;
      _error = null;
    });

    if (statusUpper == 'DELIVERED' ||
        statusUpper == 'COLLECTED' ||
        statusUpper == 'COMPLETED') {
      _pollTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: ScheduledOrderFlowStrings.orderStatus,
      subtitle: _subtitle,
      lightHeader: true,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null && _timeline.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        SizedBox(height: 12.h),
                        TextButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              children: [
                const OrderMapPlaceholder(),
                SizedBox(height: 16.h),
                ScheduledLiveMapBanner(
                  label: _mapHint,
                  unlocked: _mapUnlocked,
                ),
                SizedBox(height: 16.h),
                ScheduledPackedBanner(label: _packed),
                SizedBox(height: 16.h),
                ScheduledStatusTimeline(steps: _timeline),
                SizedBox(height: 16.h),
                ScheduledStatusSummaryCard(
                  items: _items,
                  delivery: _delivery,
                  total: _total,
                ),
              ],
            ),
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
          child: OrderOutlineButton(
            label: ScheduledOrderFlowStrings.viewReceipt,
            onPressed: () => context.push(
              ScheduledOrderFlowRoutes.receiptFor(widget.orderIds),
            ),
          ),
        ),
      ),
    );
  }
}
