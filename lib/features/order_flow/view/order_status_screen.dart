import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/maps_config.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/phone_call.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_google_map.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class OrderStatusScreen extends ConsumerStatefulWidget {
  const OrderStatusScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends ConsumerState<OrderStatusScreen> {
  static const _dash = '—';

  String _title = 'Order';
  String _vendor = _dash;
  String _badge = _dash;
  String _arrival = _dash;
  List<OrderTimelineStep> _timeline = const [];
  String _itemCount = _dash;
  String _orderTotal = _dash;
  String _champSubtitle = 'Champ will be assigned soon';
  String _champMeta = 'Waiting for pickup';
  String? _champPhone;
  String _payment = _dash;
  bool _loading = true;
  bool _hasChamp = false;
  bool _canChangePayment = false;
  bool _navigatingToRate = false;
  double _mapLat = MapsConfig.defaultLat;
  double _mapLng = MapsConfig.defaultLng;
  double? _dropoffLat;
  double? _dropoffLng;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(showSpinner: true);
      _pollTimer = Timer.periodic(
        const Duration(seconds: 8),
        (_) => _load(showSpinner: false),
      );
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({required bool showSpinner}) async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    if (showSpinner && mounted) setState(() => _loading = true);
    try {
      final data = await ref.read(ordersRepositoryProvider).trackOrder(id);
      if (!mounted) return;
      if (data == null) {
        setState(() => _loading = false);
        return;
      }

      final vendor = data['vendor'];
      final vendorName = vendor is Map
          ? displayOrDash(vendor['name']?.toString())
          : _dash;
      final orderNumber = data['orderNumber']?.toString();
      final status = data['status']?.toString();
      final etaLabel = data['etaLabel']?.toString();
      final etaMin = data['estimatedArrivalMin'] ?? data['etaMin'];
      final etaMax = data['estimatedArrivalMax'] ?? data['etaMax'];
      final eta = displayOrDash(
        etaLabel ??
            (etaMin != null ? '$etaMin–${etaMax ?? etaMin} min' : null),
      );
      final count = (data['itemCount'] as num?)?.toInt();
      final champ = data['champ'];
      final champMap = champ is Map<String, dynamic>
          ? champ
          : champ is Map
              ? Map<String, dynamic>.from(champ)
              : null;
      final champName = displayOrDash(
        champMap == null ? null : driverDisplayName(champMap),
      );
      final hasChamp = champMap != null && champName != _dash;
      // Live map only after champ is assigned (champ coords → address fallback).
      final liveCoords = hasChamp ? trackMapCoords(data) : null;
      final dropoffCoords = trackDropoffCoords(data);
      final canRate = data['canRate'] == true;
      final statusUpper = (status ?? '').toUpperCase();
      final isDelivered = statusUpper == 'DELIVERED' ||
          statusUpper == 'COLLECTED' ||
          statusUpper == 'COMPLETED';

      setState(() {
        _title = orderNumber != null && orderNumber.isNotEmpty
            ? 'Order #$orderNumber'
            : _dash;
        _vendor = vendorName;
        _badge = status != null && status.isNotEmpty
            ? formatStatusLabel(status)
            : _dash;
        _arrival = eta;
        _timeline = timelineFromTrack(
          timeline: data['timeline'] is List ? data['timeline'] as List : null,
          currentStatus: status,
        );
        _itemCount = count != null
            ? '$count ${count == 1 ? 'item' : 'items'}'
            : _dash;
        _orderTotal = data['totalAmount'] != null
            ? formatBhd(data['totalAmount'])
            : _dash;
        _hasChamp = hasChamp;
        if (hasChamp) {
          _champSubtitle = '$champName · your champ';
          _champMeta = champMetaFromTrack(champMap);
          _champPhone = champMap['phone']?.toString();
          if (liveCoords != null) {
            _mapLat = liveCoords.lat;
            _mapLng = liveCoords.lng;
          }
          _dropoffLat = dropoffCoords?.lat;
          _dropoffLng = dropoffCoords?.lng;
        } else {
          _champSubtitle = 'Champ will be assigned soon';
          _champMeta = 'Waiting for pickup';
          _champPhone = null;
          _dropoffLat = null;
          _dropoffLng = null;
        }
        final paymentRaw = data['paymentMethod']?.toString();
        _payment = paymentRaw == null || paymentRaw.isEmpty
            ? _dash
            : formatPaymentMethod(paymentRaw);
        _canChangePayment = data['canChangePayment'] == true;
        _loading = false;
      });

      if (canRate && isDelivered && !_navigatingToRate) {
        _navigatingToRate = true;
        _pollTimer?.cancel();
        if (!mounted) return;
        context.pushReplacement(OrderFlowRoutes.deliveredFor(id));
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onCall() async {
    if (!_hasChamp || _champPhone == null || _champPhone!.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Champ not assigned yet — call unavailable'),
        ),
      );
      return;
    }
    final ok = await launchPhoneCall(_champPhone);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open phone dialer')),
      );
    }
  }

  void _onChat() {
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order not found')),
      );
      return;
    }
    // Champ not assigned yet → snackbar only (do not open payment / other sheets).
    if (!_hasChamp) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Champ not assigned yet — chat unavailable'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.push(OrderFlowRoutes.chatFor(id));
  }

  Future<void> _changePayment() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) return;
    if (!_canChangePayment) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment method cannot be changed right now'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    const options = <(String, String)>[
      ('CASH', 'Cash on delivery'),
      ('CARD', 'Card'),
      ('BENEFIT_PAY', 'BenefitPay'),
      ('YJEEK_WALLET', 'Yjeek Wallet'),
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
              child: Text(
                'Change payment method',
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final opt in options)
              ListTile(
                title: Text(opt.$2),
                onTap: () => Navigator.pop(ctx, opt.$1),
              ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    final ok = await ref
        .read(ordersRepositoryProvider)
        .changePaymentMethod(orderId, selected);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not change payment method')),
      );
      return;
    }
    setState(() => _payment = formatPaymentMethod(selected));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment updated to ${formatPaymentMethod(selected)}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    return OrderFlowScaffold(
      title: _title,
      subtitle: _vendor,
      lightHeader: true,
      trailing: Icon(
        Icons.more_horiz_rounded,
        size: 22.sp,
        color: const Color(0xFF1A1A1A),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              children: [
                // Spec: live map only after driver/champ is assigned.
                if (_hasChamp)
                  AppLiveTrackingMap(
                    driverLatitude: _mapLat,
                    driverLongitude: _mapLng,
                    dropoffLatitude: _dropoffLat,
                    dropoffLongitude: _dropoffLng,
                    height: 196.h,
                    borderRadius: BorderRadius.circular(16.r),
                  )
                else
                  const OrderMapPlaceholder(height: 196),
                SizedBox(height: 16.h),
                OrderStatusBadge(label: _badge),
                SizedBox(height: 16.h),
                OrderArrivalCard(arrivalWindow: _arrival),
                SizedBox(height: 16.h),
                OrderTimeline(steps: _timeline),
                SizedBox(height: 16.h),
                OrderChampCard(
                  subtitle: _champSubtitle,
                  meta: _champMeta,
                  onCall: _onCall,
                  onChat: _onChat,
                ),
                SizedBox(height: 16.h),
                OrderVendorSummaryCard(
                  vendor: _vendor,
                  itemCount: _itemCount,
                  orderTotal: _orderTotal,
                ),
                SizedBox(height: 16.h),
                OrderPaymentRow(
                  paymentMethod: _payment,
                  onChange: _canChangePayment ? _changePayment : null,
                ),
                SizedBox(height: 16.h),
                OrderContactSupportButton(
                  onTap: () => context.push(
                    HelpRoutes.helpSupport(orderId: orderId, tab: 1),
                  ),
                ),
              ],
            ),
    );
  }
}
