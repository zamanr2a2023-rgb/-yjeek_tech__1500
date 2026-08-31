import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/receipt_share.dart';
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
  bool _sharing = false;
  String? _error;
  String? _shareText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Order not found';
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
    final apiItems = receiptItemsFromApi(
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
    final locationName = vendorMap?['locationName']?.toString();
    final vendorLocation = vendorName == null || vendorName.isEmpty
        ? null
        : (locationName != null && locationName.isNotEmpty
            ? '$vendorName — $locationName'
            : vendorName);
    final vendorAddress = vendorMap?['details']?.toString();
    final address = receipt?['address'];
    final deliverTo = receipt?['deliverToLabel']?.toString() ??
        (address is Map
            ? [
                address['label'],
                address['area'],
              ]
                .whereType<String>()
                .where((s) => s.isNotEmpty)
                .join(' · ')
            : null);
    final totals = receipt?['totals'];
    final totalsMap = totals is Map ? Map<String, dynamic>.from(totals) : null;
    final items = receiptItemsFromApi(
      receipt?['items'] is List ? receipt!['items'] as List : null,
    );
    final billLines = receiptBillFromTotals(totalsMap);
    final badge = receiptBadgeLabel(receipt);
    final badgeLabel = badge != null ? '✓ $badge' : null;

    return OrderFlowScaffold(
      title: OrderFlowStrings.receipt,
      subtitle: orderNumber != null && orderNumber.isNotEmpty
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
                    OrderReceiptPaper(
                      badgeLabel: badgeLabel,
                      vendorLocation: vendorLocation,
                      vendorAddress: vendorAddress,
                      orderNumber: orderNumber,
                      orderDate: receipt != null
                          ? formatOrderDate(receipt['placedAt'])
                          : null,
                      typeLabel: receipt != null
                          ? formatOrderType(receipt['orderType']?.toString())
                          : null,
                      deliverTo:
                          deliverTo == null || deliverTo.isEmpty ? null : deliverTo,
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
                      label: OrderFlowStrings.shareReceipt,
                      backgroundColor: AppColors.cartTabActive,
                      height: 50,
                      onPressed: _sharing ? () {} : _share,
                    ),
                  ],
                ),
    );
  }
}
