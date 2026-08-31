import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/receipt_share.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/model/pickup_order_api_mappers.dart';
import 'package:yjeek_app/features/pickup_order_flow/model/pickup_order_flow_data.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/widgets/pickup_order_flow_widgets.dart';

class PickupReceiptScreen extends ConsumerStatefulWidget {
  const PickupReceiptScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<PickupReceiptScreen> createState() =>
      _PickupReceiptScreenState();
}

class _PickupReceiptScreenState extends ConsumerState<PickupReceiptScreen> {
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
    final apiItems = receiptItemsFromApi(
      receipt['items'] is List ? receipt['items'] as List : null,
    );
    final money = <String, dynamic>{
      ...?totalsMap,
      'pickupDiscountLabel': totalsMap == null
          ? null
          : pickupDiscountLabelFromOrder(totalsMap),
    };
    final billLines = pickupBillFromOrderMoney(money);
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
    final area = vendorMap?['area']?.toString();
    final totals = receipt?['totals'];
    final totalsMap = totals is Map ? Map<String, dynamic>.from(totals) : null;
    final apiItems = receiptItemsFromApi(
      receipt?['items'] is List ? receipt!['items'] as List : null,
    );
    final items = [
      for (final i in apiItems) PickupReceiptLine(name: i.name, price: i.price),
    ];
    final money = <String, dynamic>{
      ...?totalsMap,
      if (totalsMap != null)
        'pickupDiscountLabel': pickupDiscountLabelFromOrder(totalsMap),
    };
    final billLines = pickupBillFromOrderMoney(money);
    final badgeLabel = receiptBadgeLabel(receipt);
    final placed = receipt?['placedAt'];
    final dateLabel = orderNumber == null
        ? null
        : 'Order $orderNumber · ${area ?? formatOrderDate(placed)}';
    final subtitle = orderNumber != null && orderNumber.isNotEmpty
        ? '#$orderNumber'
        : '#${PickupOrderFlowData.orderId}';

    return OrderFlowScaffold(
      title: PickupOrderFlowStrings.receipt,
      subtitle: subtitle,
      bottomNavIndex: 1,
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
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                  children: [
                    PickupReceiptPaper(
                      badgeLabel: badgeLabel,
                      vendorName: vendorName,
                      dateLabel: dateLabel,
                      items: items.isEmpty ? null : items,
                      billLines: billLines.isEmpty ? null : billLines,
                      paymentMethod: receipt != null
                          ? formatPaymentMethod(
                              receipt['paymentMethod']?.toString(),
                            )
                          : null,
                    ),
                    SizedBox(height: 20.h),
                    PrimaryGreenButton(
                      label: PickupOrderFlowStrings.shareReceipt,
                      onPressed: _sharing ? () {} : _share,
                    ),
                  ],
                ),
    );
  }
}
