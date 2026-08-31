import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/receipt_share.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_api_mappers.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DineInReceiptScreen extends ConsumerStatefulWidget {
  const DineInReceiptScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<DineInReceiptScreen> createState() =>
      _DineInReceiptScreenState();
}

class _DineInReceiptScreenState extends ConsumerState<DineInReceiptScreen> {
  static const Color _screenBg = Color(0xFF8BAE9A);

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
    final locationName = vendorMap?['locationName']?.toString();
    final venueTitle = vendorName == null || vendorName.isEmpty
        ? null
        : (locationName != null && locationName.isNotEmpty
            ? '$vendorName — $locationName'
            : vendorName);
    final totals = receipt['totals'];
    final totalsMap = totals is Map ? Map<String, dynamic>.from(totals) : null;
    final apiItems = receiptItemsFromApi(
      receipt['items'] is List ? receipt['items'] as List : null,
    );
    final billLines = dineInReceiptBillFromTotals(totalsMap);
    final shareText = (_shareText != null && _shareText!.isNotEmpty)
        ? _shareText!
        : 'Yjeek Receipt · $orderNumber';

    setState(() => _sharing = true);
    try {
      await shareReceiptPdf(
        orderNumber: orderNumber,
        shareText: shareText,
        vendorName: venueTitle,
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
    final venueTitle = vendorName == null || vendorName.isEmpty
        ? null
        : (locationName != null && locationName.isNotEmpty
            ? '$vendorName — $locationName'
            : vendorName);
    final details = vendorMap?['details']?.toString();
    final address = vendorMap?['address']?.toString();
    final venueSubtitle = [
      if (details != null && details.isNotEmpty) details,
      if (address != null && address.isNotEmpty) address,
    ].join(' · ');
    final totals = receipt?['totals'];
    final totalsMap = totals is Map ? Map<String, dynamic>.from(totals) : null;
    final apiItems = receiptItemsFromApi(
      receipt?['items'] is List ? receipt!['items'] as List : null,
    );
    final items = apiItems
        .map((e) => DineInReceiptItem(name: e.name, price: e.price))
        .toList();
    final billLines = dineInReceiptBillFromTotals(totalsMap);
    final badge = receiptBadgeLabel(receipt);
    final badgeLabel = badge != null ? '✓ $badge' : null;
    final subtitle = orderNumber != null && orderNumber.isNotEmpty
        ? '#$orderNumber'
        : DineInOrderFlowData.receiptHeaderSubtitle;

    return OrderFlowScaffold(
      title: DineInOrderFlowStrings.receipt,
      subtitle: subtitle,
      lightHeader: true,
      backgroundColor: _screenBg,
      bottomNavIndex: 0,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.white),
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
                    DineInReceiptPaper(
                      badgeLabel: badgeLabel,
                      venueTitle: venueTitle,
                      venueSubtitle:
                          venueSubtitle.isEmpty ? null : venueSubtitle,
                      orderNumber: orderNumber,
                      tableLabel: receipt?['tableLabel']?.toString(),
                      timeLabel: receipt?['dineInTimeLabel']?.toString() ??
                          (receipt != null
                              ? formatOrderDate(receipt['placedAt'])
                              : null),
                      items: items.isEmpty ? null : items,
                      billLines: billLines.isEmpty ? null : billLines,
                      paymentMethod: receipt != null
                          ? formatPaymentMethod(
                              receipt['paymentMethod']?.toString(),
                            )
                          : null,
                    ),
                    SizedBox(height: 14.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _sharing ? null : _share,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cartTabActive,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.r),
                          ),
                        ),
                        child: Text(
                          DineInOrderFlowStrings.shareReceipt,
                          style:
                              AppTextStyles.labelMedium(color: AppColors.white)
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                    height: 19 / 16,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
