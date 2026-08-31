import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/model/pending_checkout.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/services_booking/model/services_booking_data.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';
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
  bool _placing = false;

  String _vendor = ServicesBookingStrings.provider;
  String _service = ServicesBookingData.mainService;
  String _when = ServicesBookingData.appointmentWhen;
  String _location = ServicesBookingStrings.venueLocationShort;
  String _people = ServicesBookingData.peopleCount;
  List<BillLine> _bill = ServicesBookingData.reviewBillLines;

  bool get _hasExistingOrder =>
      widget.orderId != null && widget.orderId!.isNotEmpty;

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
      if (!mounted || _leaving || _placing) return;
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() => _secondsLeft = 0);
        _confirmAndPlace();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  double get _progress => _secondsLeft / _initialSeconds;

  Future<void> _hydrate() async {
    if (_hasExistingOrder) {
      await _hydrateFromOrder(widget.orderId!);
      return;
    }
    await _hydrateFromCart();
  }

  Future<void> _hydrateFromOrder(String id) async {
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

  Future<void> _hydrateFromCart() async {
    final pending = ref.read(pendingServiceCheckoutProvider);
    final cart = await ref
        .read(cartRepositoryProvider)
        .fetchCart(CartOrderType.service);
    if (!mounted) return;

    final tip = pending?.tipAmount ?? 0;
    final serviceName = cart.items.isNotEmpty
        ? (cart.items.length > 1
            ? '${cart.items.first.name} +${cart.items.length - 1}'
            : cart.items.first.name)
        : _service;
    final when = cart.serviceScheduledAt != null
        ? formatPickupTimeLabel(cart.serviceScheduledAt)
        : _when;
    final location = cart.serviceMode == 'AT_HOME'
        ? 'At home'
        : 'At venue · ${cart.vendorName.isNotEmpty ? cart.vendorName : _vendor}';
    final people = (cart.partySize ?? 1) == 1
        ? '1 person'
        : '${cart.partySize} people';

    setState(() {
      if (cart.vendorName.isNotEmpty) _vendor = cart.vendorName;
      _service = serviceName;
      _when = when;
      _location = location;
      _people = people;
      _bill = billLinesWithTip(cart, tip);
    });
  }

  Future<void> _confirmAndPlace() async {
    if (_leaving || _placing) return;
    _timer?.cancel();

    if (_hasExistingOrder) {
      _leaving = true;
      if (!mounted) return;
      context.pushReplacement(
        ServicesOrderFlowRoutes.waitingFor(widget.orderId),
      );
      return;
    }

    final pending = ref.read(pendingServiceCheckoutProvider);
    if (pending == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout session expired. Try again.')),
      );
      context.go(ServicesBookingRoutes.checkout);
      return;
    }

    setState(() => _placing = true);
    try {
      final cart = await ref
          .read(cartRepositoryProvider)
          .fetchCart(CartOrderType.service);
      final duration = cart.items
          .map(
            (i) =>
                int.tryParse(
                  i.durationLabel?.replaceAll(RegExp(r'\D'), '') ?? '',
                ) ??
                0,
          )
          .fold<int>(0, (a, b) => a + b);
      final result = await ref.read(cartRepositoryProvider).checkout(
            type: CartOrderType.service,
            paymentMethod: paymentMethodApiValue(pending.paymentId),
            tipAmount: pending.tipAmount,
            serviceFulfillmentMode: cart.serviceMode ?? 'IN_SALON',
            serviceStaffId: pending.specialistId,
            servicePeopleCount: cart.partySize ?? 1,
            serviceDurationMin: duration >= 15 ? duration : 45,
          );
      if (!mounted) return;
      _leaving = true;
      ref.read(pendingServiceCheckoutProvider.notifier).state = null;
      final orderId = result?['id']?.toString() ??
          result?['orderId']?.toString() ??
          (result?['order'] is Map
              ? (result!['order'] as Map)['id']?.toString()
              : null);
      context.pushReplacement(ServicesOrderFlowRoutes.waitingFor(orderId));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _placing = false;
        _secondsLeft = _initialSeconds;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      _startTimer();
    }
  }

  /// Same route as editing booking details — back to checkout.
  void _editOrder() {
    if (_leaving || _placing) return;
    _timer?.cancel();
    _leaving = true;
    if (_hasExistingOrder) {
      final id = widget.orderId!;
      ref.read(ordersRepositoryProvider).cancel(id, reason: 'Changed mind');
    }
    ref.read(pendingServiceCheckoutProvider.notifier).state = null;
    context.go(ServicesBookingRoutes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    final busy = _leaving || _placing;
    return CartFlowScaffold(
      title: ServicesBookingStrings.reviewConfirm,
      subtitle: _vendor,
      lightHeader: true,
      bottomNavIndex: 0,
      onBack: busy ? null : _editOrder,
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
                  label: ServicesBookingStrings.editOrder,
                  onPressed: busy ? () {} : _editOrder,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryGreenButton(
                  label: _placing
                      ? '…'
                      : ServicesBookingStrings.confirmBooking,
                  backgroundColor: AppColors.cartTabActive,
                  height: 52,
                  enabled: !busy,
                  onPressed: _confirmAndPlace,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
