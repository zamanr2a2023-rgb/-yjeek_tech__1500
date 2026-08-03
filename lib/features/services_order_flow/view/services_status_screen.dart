import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/phone_call.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_api_mappers.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/services_order_flow_routes.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';

class ServicesStatusScreen extends ConsumerStatefulWidget {
  const ServicesStatusScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<ServicesStatusScreen> createState() =>
      _ServicesStatusScreenState();
}

class _ServicesStatusScreenState extends ConsumerState<ServicesStatusScreen> {
  Timer? _pollTimer;
  String _subtitle =
      '${ServicesOrderFlowData.providerName} · #${ServicesOrderFlowData.bookingId}';
  String _badge = ServicesOrderFlowStrings.statusConfirmed;
  String _service = ServicesOrderFlowData.serviceName;
  String _when = ServicesOrderFlowData.appointmentWhenShort;
  String _location = ServicesOrderFlowData.locationLabel;
  String _provider = ServicesOrderFlowData.providerName;
  String? _directionsUrl;
  String? _venuePhone;
  List<ServicesOrderTimelineStep> _timeline =
      ServicesOrderFlowData.statusTimeline;
  bool _loading = true;

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
    final status = data['status']?.toString();
    final statusUpper = status?.toUpperCase() ?? '';
    final when = servicesWhenFromOrder(data, short: true);
    final statusLabel = formatStatusLabel(status);

    setState(() {
      _subtitle =
          '${vendorName ?? ServicesOrderFlowData.providerName}${orderNumber == null || orderNumber.isEmpty ? '' : ' · #$orderNumber'}';
      _badge = '✅ $statusLabel · $when';
      _service = servicesServiceNameFromOrder(data);
      _when = when;
      _location = servicesLocationFromOrder(data);
      if (vendorName != null && vendorName.isNotEmpty) _provider = vendorName;
      _directionsUrl = venueMap?['directionsUrl']?.toString();
      _venuePhone = venueMap?['phone']?.toString();
      _timeline = servicesTimelineFromTrack(
        timeline: data['timeline'] is List ? data['timeline'] as List : null,
        currentStatus: status,
      );
      _loading = false;
    });

    if (statusUpper == 'COMPLETED' || statusUpper == 'COLLECTED') {
      _pollTimer?.cancel();
      if (!mounted) return;
      context.pushReplacement(ServicesOrderFlowRoutes.completeFor(id));
    }
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
      title: ServicesOrderFlowStrings.yourBooking,
      subtitle: _subtitle,
      lightHeader: true,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      bottom: ServicesStatusActions(
        stickyOnly: true,
        onDirections: _directions,
        onContact: _contact,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ServicesStatusBadge(label: _badge),
                ),
                SizedBox(height: 16.h),
                ServicesStatusTimeline(steps: _timeline),
                SizedBox(height: 16.h),
                ServicesStatusDetailsCard(
                  serviceName: _service,
                  whenLabel: _when,
                  locationLabel: _location,
                  providerName: _provider,
                ),
                SizedBox(height: 16.h),
                OrderOutlineButton(
                  label: ServicesOrderFlowStrings.viewReceipt,
                  onPressed: () => context.push(
                    ServicesOrderFlowRoutes.receiptFor(orderId),
                  ),
                ),
              ],
            ),
    );
  }
}
