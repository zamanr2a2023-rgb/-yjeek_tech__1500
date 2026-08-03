import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/receipt_share.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_api_mappers.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_flow_data.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/widgets/scheduled_order_flow_widgets.dart';

class ScheduledReceiptScreen extends ConsumerStatefulWidget {
  const ScheduledReceiptScreen({super.key, this.orderIds = const []});

  final List<String> orderIds;

  @override
  ConsumerState<ScheduledReceiptScreen> createState() =>
      _ScheduledReceiptScreenState();
}

class _ScheduledReceiptScreenState
    extends ConsumerState<ScheduledReceiptScreen> {
  Map<String, dynamic>? _receipt;
  bool _loading = true;
  bool _sharing = false;
  String? _error;
  String? _shareText;

  String? get _primaryId =>
      widget.orderIds.isEmpty ? null : widget.orderIds.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final id = _primaryId;
    if (id == null || id.isEmpty) {
      setState(() {
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ref.read(ordersRepositoryProvider).getReceipt(id);
      if (!mounted) return;
      if (data == null) {
        setState(() {
          _receipt = null;
          _shareText = null;
          _error = 'Could not load receipt';
          _loading = false;
        });
        return;
      }
      final share = data['share'];
      setState(() {
        _receipt = data;
        _shareText = share is Map ? share['text']?.toString() : null;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not load receipt';
          _loading = false;
        });
      }
    }
  }

  Future<void> _share() async {
    final receipt = _receipt;
    if (receipt == null || _sharing) return;
    final orderNumber = receipt['orderNumber']?.toString() ?? 'receipt';
    final vendor = receipt['vendor'];
    final vendorMap = vendor is Map ? Map<String, dynamic>.from(vendor) : null;
    final vendorName = vendorMap?['name']?.toString();
    final totals = receipt['totals'];
    final totalsMap = totals is Map ? Map<String, dynamic>.from(totals) : null;
    final apiItems = scheduledReceiptItemsFromApi(
      receipt['items'] is List ? receipt['items'] as List : null,
    );
    final billLines = receiptBillFromTotals(totalsMap);
    final shareText = (_shareText != null && _shareText!.isNotEmpty)
        ? _shareText!
        : 'Yjeek Receipt · $orderNumber';

    setState(() => _sharing = true);
    try {
      await shareReceiptPdf(
        orderNumber: orderNumber,
        shareText: shareText,
        vendorName: vendorName,
        items: [
          for (final i in apiItems) (name: i.name, price: i.price),
        ],
        billLines: [
          for (final b in billLines) (label: b.label, value: b.value),
        ],
        paymentMethod: formatPaymentMethod(receipt['paymentMethod']?.toString()),
      );
    } catch (_) {
      final ok = await shareReceiptWhatsApp(shareText);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not share receipt')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final receipt = _receipt;
    final orderNumber = receipt?['orderNumber']?.toString();
    final vendor = receipt?['vendor'];
    final vendorMap = vendor is Map ? Map<String, dynamic>.from(vendor) : null;
    final vendorName = vendorMap?['name']?.toString();
    final totals = receipt?['totals'];
    final totalsMap = totals is Map ? Map<String, dynamic>.from(totals) : null;
    final items = scheduledReceiptItemsFromApi(
      receipt?['items'] is List ? receipt!['items'] as List : null,
    );
    final billLines = receiptBillFromTotals(totalsMap);
    final badgeRaw = receipt?['statusBadge']?.toString();
    final badgeLabel = badgeRaw != null && badgeRaw.isNotEmpty
        ? badgeRaw.replaceAll('_', ' ').toUpperCase()
        : null;
    final placed = receipt?['placedAt'];
    final dateLabel = orderNumber == null
        ? null
        : 'Order $orderNumber · ${formatOrderDate(placed)}';
    final subtitle = orderNumber != null && orderNumber.isNotEmpty
        ? '#$orderNumber'
        : 'Receipt';

    return OrderFlowScaffold(
      title: ScheduledOrderFlowStrings.receipt,
      subtitle: subtitle,
      lightHeader: true,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null && receipt == null
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
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                  children: [
                    ScheduledReceiptPaper(
                      badgeLabel: badgeLabel,
                      vendorName: vendorName,
                      dateLabel: dateLabel,
                      items: items,
                      billLines: billLines,
                      paymentMethod: receipt != null
                          ? formatPaymentMethod(
                              receipt['paymentMethod']?.toString(),
                            )
                          : null,
                    ),
                    SizedBox(height: 14.h),
                    PrimaryGreenButton(
                      label: ScheduledOrderFlowStrings.shareReceipt,
                      backgroundColor: const Color(0xFF2E9E4D),
                      height: 50,
                      onPressed: _sharing ? () {} : _share,
                    ),
                  ],
                ),
    );
  }
}
