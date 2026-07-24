import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
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
  static const _dash = '___';

  String _title = OrderFlowData.orderStatusTitle;
  String _vendor = _dash;
  String _badge = _dash;
  String _arrival = _dash;
  List<OrderTimelineStep> _timeline = const [];
  String _itemCount = _dash;
  String _orderTotal = _dash;
  String _champSubtitle = _dash;
  String _champMeta = _dash;
  String? _champPhone;
  String _payment = _dash;
  bool _loading = true;
  bool _hasChamp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await ref.read(ordersRepositoryProvider).trackOrder(id);
      if (!mounted) return;
      if (data == null) {
        setState(() => _loading = false);
        return;
      }

      final vendor = data['vendor'];
      final vendorName = vendor is Map<String, dynamic>
          ? displayOrDash(vendor['name'] as String?)
          : _dash;
      final orderNumber = data['orderNumber'] as String?;
      final status = data['status'] as String?;
      final etaLabel = data['etaLabel'] as String?;
      final etaMin = data['estimatedArrivalMin'] ?? data['etaMin'];
      final etaMax = data['estimatedArrivalMax'] ?? data['etaMax'];
      final eta = displayOrDash(
        etaLabel ??
            (etaMin != null ? '$etaMin–${etaMax ?? etaMin} min' : null),
      );
      final count = (data['itemCount'] as num?)?.toInt();
      final champ = data['champ'];
      final champMap = champ is Map<String, dynamic> ? champ : null;
      final champName = displayOrDash(champMap?['name'] as String?);
      final hasChamp = champMap != null && champName != _dash;

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
          _champPhone = champMap['phone'] as String?;
        } else {
          _champSubtitle = _dash;
          _champMeta = _dash;
          _champPhone = null;
        }
        final paymentRaw = data['paymentMethod'] as String?;
        _payment = paymentRaw == null || paymentRaw.isEmpty
            ? _dash
            : formatPaymentMethod(paymentRaw);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onCall() {
    final phone = _champPhone;
    if (phone == null || phone.isEmpty) return;
    Clipboard.setData(ClipboardData(text: phone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Champ number copied: $phone')),
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
                const OrderMapPlaceholder(height: 196),
                SizedBox(height: 16.h),
                OrderStatusBadge(label: _badge),
                SizedBox(height: 16.h),
                OrderArrivalCard(arrivalWindow: _arrival),
                SizedBox(height: 16.h),
                OrderTimeline(steps: _timeline),
                SizedBox(height: 16.h),
                OrderVendorSummaryCard(
                  vendor: _vendor,
                  itemCount: _itemCount,
                  orderTotal: _orderTotal,
                ),
                SizedBox(height: 16.h),
                OrderChampCard(
                  subtitle: _champSubtitle,
                  meta: _champMeta,
                  onCall: _hasChamp ? _onCall : null,
                  onChat: _hasChamp
                      ? () => context.push(OrderFlowRoutes.chat)
                      : null,
                ),
                SizedBox(height: 16.h),
                OrderPaymentRow(paymentMethod: _payment),
                SizedBox(height: 16.h),
                OrderContactSupportButton(
                  onTap: () => context.push(
                    HelpRoutes.orderHelp(orderId: orderId, tab: 1),
                  ),
                ),
              ],
            ),
    );
  }
}
