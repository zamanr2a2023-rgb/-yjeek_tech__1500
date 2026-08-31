import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/receipt_share.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_api_mappers.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';

class ServicesReceiptScreen extends ConsumerStatefulWidget {
  const ServicesReceiptScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<ServicesReceiptScreen> createState() =>
      _ServicesReceiptScreenState();
}

class _ServicesReceiptScreenState
    extends ConsumerState<ServicesReceiptScreen> {
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
    final billLines = servicesReceiptBillFromTotals(totalsMap);
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
          for (final i in receiptItemsFromApi(
            receipt['items'] is List ? receipt['items'] as List : null,
          ))
            (name: i.name, price: i.price),
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

  Future<void> _print() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) return;
    final uri = Uri.parse(
      // Relative HTML path is served by API; open share URL if present.
      (_receipt?['share'] is Map
              ? (_receipt!['share'] as Map)['url']?.toString()
              : null) ??
          '',
    );
    if (uri.toString().isEmpty) {
      await _share();
      return;
    }
    if (!await canLaunchUrl(uri)) {
      await _share();
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final receipt = _receipt;
    final orderNumber = receipt?['orderNumber']?.toString();
    final vendor = receipt?['vendor'];
    final vendorMap = vendor is Map ? Map<String, dynamic>.from(vendor) : null;
    final vendorName = vendorMap?['name']?.toString();
    final details = vendorMap?['details']?.toString();
    final totals = receipt?['totals'];
    final totalsMap = totals is Map ? Map<String, dynamic>.from(totals) : null;
    final billLines = servicesReceiptBillFromTotals(totalsMap);
    final badge = receiptBadgeLabel(receipt);
    final badgeLabel = badge != null ? '✓ $badge' : null;
    final subtitle = orderNumber != null && orderNumber.isNotEmpty
        ? '#$orderNumber'
        : '#${ServicesOrderFlowData.bookingId}';

    return OrderFlowScaffold(
      title: ServicesOrderFlowStrings.receipt,
      subtitle: subtitle,
      lightHeader: true,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
                    ServicesReceiptPaper(
                      badgeLabel: badgeLabel,
                      venueTitle: vendorName,
                      venueSubtitle: details,
                      bookingNumber: orderNumber,
                      serviceName: servicesServiceNameFromOrder(receipt),
                      whenLabel: servicesWhenFromOrder(receipt),
                      locationLabel: servicesLocationFromOrder(receipt),
                      billLines: billLines.isEmpty
                          ? null
                          : billLines,
                      paymentLabel: receipt != null
                          ? formatPaymentMethod(
                              receipt['paymentMethod']?.toString(),
                            )
                          : null,
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50.h,
                            child: OutlinedButton(
                              onPressed: _print,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1A1A1A),
                                backgroundColor: AppColors.white,
                                side: const BorderSide(
                                  color: Color(0xFFE0E6E0),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.r),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.download,
                                    size: 18.sp,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    ServicesOrderFlowStrings.print,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.sp,
                                      height: 18 / 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: SizedBox(
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: _sharing ? null : _share,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E9E4D),
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.r),
                                ),
                              ),
                              child: Text(
                                ServicesOrderFlowStrings.shareReceipt,
                                style: GoogleFonts.inter(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.sp,
                                  height: 18 / 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
