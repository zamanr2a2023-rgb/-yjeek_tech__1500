import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class OrderReceiptScreen extends ConsumerStatefulWidget {
  const OrderReceiptScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<OrderReceiptScreen> createState() => _OrderReceiptScreenState();
}

class _OrderReceiptScreenState extends ConsumerState<OrderReceiptScreen> {
  Map<String, dynamic>? _receipt;
  bool _loading = true;
  String? _shareText;

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
      final data = await ref.read(ordersRepositoryProvider).getReceipt(id);
      if (!mounted) return;
      final share = data?['share'];
      setState(() {
        _receipt = data;
        _shareText = share is Map<String, dynamic>
            ? share['text'] as String?
            : null;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final receipt = _receipt;
    final orderNumber = receipt?['orderNumber'] as String?;
    final vendor = receipt?['vendor'];
    final vendorMap = vendor is Map<String, dynamic> ? vendor : null;
    final vendorName = vendorMap?['name'] as String? ?? OrderFlowData.vendor;
    final locationName = vendorMap?['locationName'] as String?;
    final vendorLocation = locationName != null && locationName.isNotEmpty
        ? '$vendorName — $locationName'
        : vendorName;
    final vendorAddress =
        vendorMap?['details'] as String? ?? OrderFlowData.vendorAddress;
    final address = receipt?['address'];
    final deliverTo = receipt?['deliverToLabel'] as String? ??
        (address is Map<String, dynamic>
            ? [
                address['label'],
                address['area'],
              ].whereType<String>().where((s) => s.isNotEmpty).join(' · ')
            : null);
    final totals = receipt?['totals'];
    final totalsMap = totals is Map<String, dynamic> ? totals : null;
    final items = receiptItemsFromApi(
      receipt?['items'] is List ? receipt!['items'] as List : null,
    );
    final billLines = receiptBillFromTotals(totalsMap);
    final badgeRaw = receipt?['statusBadge'] as String?;
    final badgeLabel = badgeRaw != null && badgeRaw.isNotEmpty
        ? '✓ ${badgeRaw.replaceAll('_', ' ').toUpperCase()}'
        : null;

    return OrderFlowScaffold(
      title: OrderFlowStrings.receipt,
      subtitle: orderNumber != null
          ? 'Order #$orderNumber'
          : OrderFlowStrings.receiptSubtitle,
      lightHeader: true,
      trailing: Icon(
        Icons.more_horiz,
        color: AppColors.textPrimary,
        size: 24.sp,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              children: [
                OrderReceiptPaper(
                  badgeLabel: badgeLabel,
                  vendorLocation: receipt != null ? vendorLocation : null,
                  vendorAddress: receipt != null ? vendorAddress : null,
                  orderNumber: orderNumber,
                  orderDate: receipt != null
                      ? formatOrderDate(receipt['placedAt'])
                      : null,
                  typeLabel: receipt != null
                      ? formatOrderType(receipt['orderType'] as String?)
                      : null,
                  deliverTo: deliverTo,
                  items: receipt != null ? items : null,
                  billLines: receipt != null ? billLines : null,
                  paymentMethod: receipt != null
                      ? formatPaymentMethod(
                          receipt['paymentMethod'] as String?,
                        )
                      : null,
                ),
                SizedBox(height: 14.h),
                PrimaryGreenButton(
                  label: OrderFlowStrings.shareReceipt,
                  backgroundColor: AppColors.cartTabActive,
                  height: 50,
                  onPressed: () async {
                    final text = _shareText;
                    if (text != null && text.isNotEmpty) {
                      await Clipboard.setData(ClipboardData(text: text));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Receipt copied')),
                      );
                    }
                  },
                ),
              ],
            ),
    );
  }
}
