import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/model/pickup_order_api_mappers.dart';
import 'package:yjeek_app/features/pickup_order_flow/model/pickup_order_flow_data.dart';
import 'package:yjeek_app/features/pickup_order_flow/pickup_order_flow_routes.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/widgets/pickup_order_flow_widgets.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_api_mappers.dart';

class PickupStatusScreen extends ConsumerStatefulWidget {
  const PickupStatusScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<PickupStatusScreen> createState() => _PickupStatusScreenState();
}

class _PickupStatusScreenState extends ConsumerState<PickupStatusScreen> {
  Timer? _pollTimer;
  String _subtitle = PickupOrderFlowData.statusSubtitle;
  String _preparing = PickupOrderFlowStrings.preparingBanner;
  List<PickupOrderTimelineStep> _timeline = PickupOrderFlowData.statusTimeline;
  String _items = PickupOrderFlowData.statusItems;
  String _pickup = PickupOrderFlowData.statusPickup;
  String _total = PickupOrderFlowData.confirmedTotal;
  bool _loading = true;
  bool _canMarkArrived = false;
  bool _markingArrived = false;
  String? _error;

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
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = null;
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
    final area = vendor is Map ? vendor['area']?.toString() : null;
    final loc = data['vendorLocation'] ?? data['pickup'] ?? data['venue'];
    final locArea = loc is Map
        ? (loc['area']?.toString() ?? loc['name']?.toString())
        : null;
    final orderNumber = data['orderNumber']?.toString();
    final status = data['status']?.toString();
    final statusUpper = (status ?? '').toUpperCase();
    final eta = data['etaLabel']?.toString();
    final statusLabel = formatStatusLabel(status);

    final trackSteps = pickupTimelineFromTrack(
      timeline: data['timeline'] is List ? data['timeline'] as List : null,
      currentStatus: status,
    );

    setState(() {
      final number = orderNumber != null && orderNumber.isNotEmpty
          ? orderNumber
          : '—';
      _subtitle = vendorName != null && vendorName.isNotEmpty
          ? 'Pickup · $vendorName · #$number'
          : 'Pickup · #$number';
      _timeline = trackSteps;
      _items = itemsSummaryFromOrderApi(data);
      final place = locArea ?? area;
      if (vendorName != null && vendorName.isNotEmpty) {
        _pickup = place != null && place.isNotEmpty
            ? '$vendorName · $place'
            : vendorName;
      }
      _total = data['totalAmount'] != null
          ? formatBhd(data['totalAmount'])
          : _total;
      if (statusUpper == 'READY_FOR_PICKUP' ||
          statusUpper == 'READY' ||
          statusUpper == 'READY_FOR_YOU' ||
          statusUpper == 'CUSTOMER_ARRIVED') {
        _preparing = eta != null && eta.isNotEmpty
            ? 'Ready for pickup · $eta'
            : 'Ready for pickup';
      } else if (statusUpper == 'COLLECTED' || statusUpper == 'COMPLETED') {
        _preparing = 'Collected';
      } else {
        _preparing = eta != null && eta.isNotEmpty
            ? '$statusLabel · $eta'
            : statusLabel;
      }
      _canMarkArrived = data['canMarkArrived'] == true ||
          const {
            'CONFIRMED',
            'PREPARING',
            'READY_FOR_YOU',
            'READY_FOR_PICKUP',
            'READY',
          }.contains(statusUpper);
      _loading = false;
      _error = null;
    });

    if (statusUpper == 'COLLECTED' || statusUpper == 'COMPLETED') {
      _pollTimer?.cancel();
    }
  }

  Future<void> _markArrived() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty || _markingArrived || !_canMarkArrived) {
      return;
    }
    setState(() => _markingArrived = true);
    final ok = await ref.read(ordersRepositoryProvider).markArrived(id);
    if (!mounted) return;
    setState(() => _markingArrived = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not mark arrival. Try again.')),
      );
      return;
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    return OrderFlowScaffold(
      title: PickupOrderFlowStrings.orderStatus,
      subtitle: _subtitle,
      bottomNavIndex: 1,
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
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                  children: [
                    const OrderMapPlaceholder(),
                    SizedBox(height: 14.h),
                    const PickupNotifyBanner(),
                    SizedBox(height: 10.h),
                    PickupPreparingBanner(label: _preparing),
                    SizedBox(height: 14.h),
                    PickupStatusTimeline(steps: _timeline),
                    SizedBox(height: 14.h),
                    PickupStatusSummaryCard(
                      items: _items,
                      pickup: _pickup,
                      total: _total,
                    ),
                    if (_canMarkArrived) ...[
                      SizedBox(height: 14.h),
                      PrimaryGreenButton(
                        label: _markingArrived
                            ? 'Updating…'
                            : PickupOrderFlowStrings.imHere,
                        onPressed: _markingArrived ? () {} : _markArrived,
                      ),
                    ],
                    SizedBox(height: 14.h),
                    OrderOutlineButton(
                      label: PickupOrderFlowStrings.viewReceipt,
                      onPressed: () => context.push(
                        PickupOrderFlowRoutes.receiptFor(orderId),
                      ),
                    ),
                  ],
                ),
    );
  }
}
