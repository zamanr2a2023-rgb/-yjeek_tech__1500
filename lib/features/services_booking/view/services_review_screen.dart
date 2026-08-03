import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/services_booking/model/services_booking_data.dart';
import 'package:yjeek_app/features/services_booking/view/widgets/services_booking_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_api_mappers.dart';
import 'package:yjeek_app/features/services_order_flow/services_order_flow_routes.dart';

class ServicesReviewScreen extends ConsumerStatefulWidget {
  const ServicesReviewScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<ServicesReviewScreen> createState() =>
      _ServicesReviewScreenState();
}

class _ServicesReviewScreenState extends ConsumerState<ServicesReviewScreen> {
  static const _initialSeconds = 10;

  late int _secondsLeft;
  Timer? _timer;
  bool _leaving = false;

  String _vendor = ServicesBookingStrings.provider;
  String _service = ServicesBookingData.mainService;
  String _when = ServicesBookingData.appointmentWhen;
  String _location = ServicesBookingStrings.venueLocationShort;
  String _people = ServicesBookingData.peopleCount;
  List<BillLine> _bill = ServicesBookingData.reviewBillLines;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _leaving) return;
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() => _secondsLeft = 0);
        _goWaiting();
        return;
      }
      setState(() => _secondsLeft--);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double get _progress => _secondsLeft / _initialSeconds;

  Future<void> _hydrate() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) return;
    final order = await ref.read(ordersRepositoryProvider).getOrder(id);
    if (!mounted || order == null) return;

    final vendor = order['vendor'];
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;
    final items = order['items'];
    String service = _service;
    if (items is List && items.isNotEmpty) {
      final first = items.first;
      if (first is Map) {
        final name = first['name']?.toString();
        final qty = (first['quantity'] as num?)?.toInt() ?? 1;
        if (name != null && name.isNotEmpty) {
          service = items.length > 1 || qty > 1
              ? '$name${items.length > 1 ? ' +${items.length - 1}' : ''}'
              : name;
        }
      }
    }
    final scheduled = DateTime.tryParse(
          order['scheduledAt']?.toString() ??
              order['serviceScheduledAt']?.toString() ??
              '',
        )?.toLocal();
    final booking = order['serviceBooking'];
    final mode = booking is Map
        ? booking['fulfillmentMode']?.toString()
        : (order['serviceMode']?.toString() ??
            order['serviceFulfillmentMode']?.toString());
    final venue = order['venue'] ?? order['vendorLocation'];
    final area = venue is Map
        ? (venue['area']?.toString() ?? venue['name']?.toString())
        : null;
    final people = servicesPeopleCount(order) ?? 1;
    final money = <BillLine>[
      BillLine(label: 'Service', value: formatBhd(order['subtotal'])),
      BillLine(label: 'Service fee', value: formatBhd(order['serviceFee'])),
      if ((order['discountAmount'] as num?) != null &&
          (order['discountAmount'] as num) > 0)
        BillLine(
          label: 'Discount',
          value: '− ${formatBhd(order['discountAmount'])}',
          isDiscount: true,
        ),
      if ((order['vatAmount'] as num?) != null)
        BillLine(label: 'VAT (10%)', value: formatBhd(order['vatAmount'])),
      BillLine(
        label: 'Total',
        value: formatBhd(order['totalAmount']),
        isBold: true,
      ),
    ];

    setState(() {
      if (vendorName != null && vendorName.isNotEmpty) _vendor = vendorName;
      _service = service;
      if (scheduled != null) _when = formatPickupTimeLabel(scheduled);
      _location = mode == 'AT_HOME'
          ? 'At home'
          : (area != null && area.isNotEmpty
              ? 'At venue · $area'
              : 'At venue · $_vendor');
      _people = people == 1 ? '1 person' : '$people people';
      _bill = money;
    });
  }

  Future<void> _goWaiting() async {
    if (_leaving) return;
    _leaving = true;
    _timer?.cancel();
    if (!mounted) return;
    context.pushReplacement(
      ServicesOrderFlowRoutes.waitingFor(widget.orderId),
    );
  }

  Future<void> _cancel() async {
    final id = widget.orderId;
    _timer?.cancel();
    if (id != null && id.isNotEmpty) {
      await ref.read(ordersRepositoryProvider).cancel(id, reason: 'Changed mind');
    }
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: ServicesBookingStrings.reviewConfirm,
      subtitle: _vendor,
      lightHeader: true,
      bottomNavIndex: 0,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
        children: [
          ServicesBookingReviewStatusCard(
            secondsLeft: _secondsLeft,
            progress: _progress,
            title: 'Sending your booking to $_vendor',
          ),
          SizedBox(height: 14.h),
          CartSectionTitle(ServicesBookingStrings.bookingSummary),
          ServicesBookingSummaryCard(
            serviceName: _service,
            providerName: _vendor,
            whenLabel: _when,
            locationLabel: _location,
            peopleLabel: _people,
          ),
          SizedBox(height: 14.h),
          CartSectionTitle(ServicesBookingStrings.billSummary),
          BillSummaryCard(lines: _bill),
          SizedBox(height: 10.h),
          TextButton(
            onPressed: _leaving ? null : _cancel,
            child: const Text('Cancel / edit'),
          ),
        ],
      ),
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
          child: PrimaryGreenButton(
            label: ServicesBookingStrings.confirmBooking,
            backgroundColor: AppColors.cartTabActive,
            height: 52,
            onPressed: _leaving ? null : _goWaiting,
          ),
        ),
      ),
    );
  }
}
