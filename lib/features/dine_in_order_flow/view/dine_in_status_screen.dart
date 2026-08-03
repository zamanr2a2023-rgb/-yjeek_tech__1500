import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/phone_call.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/dine_in_order_flow_routes.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_api_mappers.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DineInStatusScreen extends ConsumerStatefulWidget {
  const DineInStatusScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<DineInStatusScreen> createState() => _DineInStatusScreenState();
}

class _DineInStatusScreenState extends ConsumerState<DineInStatusScreen> {
  static const Color _screenBg = Color(0xFF8BAE9A);

  Timer? _pollTimer;
  String _subtitle = DineInOrderFlowStrings.orderHeaderSubtitle;
  String _code = DineInOrderFlowData.arrivalCode;
  String _pill = DineInOrderFlowStrings.preparingPill;
  String _venue = DineInOrderFlowData.venue;
  String _table = DineInOrderFlowData.tableLabel;
  String _time = DineInOrderFlowData.dineInTime;
  String? _directionsUrl;
  String? _venuePhone;
  List<DineInOrderTimelineStep> _timeline = DineInOrderFlowData.statusTimeline;
  bool _loading = true;
  bool _canMarkArrived = false;
  bool _markingArrived = false;

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
      if (mounted) setState(() => _loading = false);
      return;
    }
    final data = await ref.read(ordersRepositoryProvider).trackOrder(id);
    if (!mounted) return;
    if (data == null) {
      setState(() => _loading = false);
      return;
    }

    final vendor = data['vendor'];
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;
    final orderNumber = data['orderNumber']?.toString();
    final venue = data['venue'];
    final venueMap = venue is Map ? venue : null;
    final venueLabel = [
      venueMap?['name']?.toString() ?? vendorName,
      venueMap?['area']?.toString(),
    ].whereType<String>().where((s) => s.isNotEmpty).join(' - ');
    final eta = data['etaLabel']?.toString();
    final status = data['status']?.toString();
    final statusUpper = status?.toUpperCase() ?? '';

    setState(() {
      _subtitle =
          '${vendorName ?? DineInOrderFlowData.vendor}${orderNumber == null || orderNumber.isEmpty ? '' : ' · #$orderNumber'}';
      _code = data['arrivalCode']?.toString() ??
          orderNumber ??
          _code;
      _pill = eta != null && eta.isNotEmpty
          ? '👨‍🍳 ${formatStatusLabel(status)} · $eta'
          : '👨‍🍳 ${formatStatusLabel(status)}';
      _venue = venueLabel.isNotEmpty ? venueLabel : _venue;
      _table = data['tableLabel']?.toString() ?? _table;
      _time = data['dineInTimeLabel']?.toString() ?? _time;
      _directionsUrl = venueMap?['directionsUrl']?.toString();
      _venuePhone = venueMap?['phone']?.toString();
      _timeline = dineInTimelineFromTrack(
        timeline: data['timeline'] is List ? data['timeline'] as List : null,
        currentStatus: status,
      );
      _canMarkArrived = data['canMarkArrived'] == true ||
          const {
            'CONFIRMED',
            'PREPARING',
            'READY_FOR_YOU',
            'READY_FOR_PICKUP',
            'READY',
          }.contains(statusUpper);
      _loading = false;
    });

    if (statusUpper == 'COMPLETED' || statusUpper == 'COLLECTED') {
      _pollTimer?.cancel();
      if (!mounted) return;
      context.pushReplacement(DineInOrderFlowRoutes.completeFor(id));
    }
  }

  Future<void> _markArrived() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty || _markingArrived || !_canMarkArrived) return;
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

  Future<void> _directions() async {
    final url = _directionsUrl;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Directions unavailable')),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _contact() async {
    final ok = await launchPhoneCall(_venuePhone);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue phone unavailable')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    return OrderFlowScaffold(
      title: DineInOrderFlowStrings.dineInOrder,
      subtitle: _subtitle,
      lightHeader: true,
      backgroundColor: _screenBg,
      bottomNavIndex: 0,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.white),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              children: [
                DineInArrivalCodeCard(compact: true, code: _code),
                SizedBox(height: 16.h),
                DineInPreparingPill(label: _pill),
                SizedBox(height: 16.h),
                DineInStatusTimeline(
                  steps: _timeline,
                  onYouArrivedTap: _canMarkArrived ? _markArrived : null,
                ),
                SizedBox(height: 16.h),
                DineInStatusInfoCard(
                  venue: _venue,
                  table: _table,
                  time: _time,
                ),
                SizedBox(height: 16.h),
                DineInStatusActions(
                  onReceipt: () => context.push(
                    DineInOrderFlowRoutes.receiptFor(orderId),
                  ),
                  onDirections: _directions,
                  onContact: _contact,
                ),
              ],
            ),
    );
  }
}
