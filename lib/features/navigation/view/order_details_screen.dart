import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/dine_in_order_flow/dine_in_order_flow_routes.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/routes/app_router.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  bool _loading = true;
  String _statusBanner = '';
  String _statusRaw = '';
  String _vendorName = '';
  String? _vendorLogoUrl;
  String _fulfillment = '';
  String _displayId = '';
  List<OrderItemLine> _items = const [];
  List<BillLine> _bill = const [];
  String _deliveredTo = '';
  String _champ = '';
  bool _hasChamp = false;
  String _payment = '';
  String _orderType = 'DELIVERY';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Color get _statusBannerBg {
    final s = _statusRaw.toUpperCase();
    if (s.contains('DELIVER') ||
        s == 'COLLECTED' ||
        s == 'COMPLETED' ||
        s == 'CONFIRMED') {
      return const Color(0xFFE3F2EB);
    }
    if (s.contains('CANCEL') || s.contains('FAIL') || s.contains('REJECT')) {
      return const Color(0xFFFDE8E8);
    }
    return const Color(0xFFFFF4DF);
  }

  Color get _statusBannerFg {
    final s = _statusRaw.toUpperCase();
    if (s.contains('DELIVER') ||
        s == 'COLLECTED' ||
        s == 'COMPLETED' ||
        s == 'CONFIRMED') {
      return AppColors.successText;
    }
    if (s.contains('CANCEL') || s.contains('FAIL') || s.contains('REJECT')) {
      return const Color(0xFFB42318);
    }
    return const Color(0xFFB54708);
  }

  Future<void> _load() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await ref.read(ordersRepositoryProvider).getOrder(id);
      if (!mounted) return;
      if (data == null) {
        setState(() => _loading = false);
        return;
      }
      final vendor = data['vendor'];
      final vendorMap = vendor is Map<String, dynamic> ? vendor : null;
      final vendorName = vendorMap?['name'] as String? ?? 'Vendor';
      final vendorLogo = vendorMap?['logoUrl'] as String?;
      final status = (data['status'] as String?) ?? '';
      final orderType = (data['orderType'] as String?) ?? 'DELIVERY';
      final fulfillment = (data['fulfillmentType'] as String?) ?? 'ON_DEMAND';
      final itemsRaw = data['items'];
      final items = <OrderItemLine>[];
      if (itemsRaw is List) {
        for (final item in itemsRaw) {
          if (item is! Map<String, dynamic>) continue;
          final qty = (item['quantity'] as num?)?.toInt() ?? 1;
          final name = item['name'] as String? ?? 'Item';
          final lineTotal = item['lineTotal'];
          final unitPrice = item['unitPrice'];
          final priceValue = lineTotal is num
              ? lineTotal.toDouble()
              : unitPrice is num
                  ? unitPrice.toDouble() * qty
                  : 0.0;
          items.add(OrderItemLine(
            name: qty > 1 ? '$qty× $name' : name,
            price: formatBhd(priceValue),
          ));
        }
      }

      final deliveryFee = data['deliveryFee'];
      final tipAmount = (data['tipAmount'] as num?)?.toDouble() ?? 0;
      final money = <BillLine>[
        BillLine(
          label: 'Subtotal',
          value: formatBhd(data['subtotal']),
        ),
        if ((data['discountAmount'] as num?) != null &&
            (data['discountAmount'] as num) > 0)
          BillLine(
            label: 'Discount',
            value: '− ${formatBhd(data['discountAmount'])}',
            isDiscount: true,
          ),
        BillLine(
          label: 'Delivery fee',
          value: deliveryFee is num && deliveryFee == 0
              ? 'Free'
              : formatBhd(deliveryFee),
        ),
        BillLine(
          label: 'Service fee',
          value: formatBhd(data['serviceFee']),
        ),
        if (tipAmount > 0)
          BillLine(label: 'Tip', value: formatBhd(tipAmount)),
        if ((data['vatAmount'] as num?) != null &&
            (data['vatAmount'] as num) > 0)
          BillLine(label: 'VAT', value: formatBhd(data['vatAmount'])),
        BillLine(
          label: 'Total',
          value: formatBhd(data['totalAmount']),
          isBold: true,
        ),
      ];

      final address = data['address'];
      final addressLabel = data['deliverToLabel'] as String? ??
          (address is Map<String, dynamic>
              ? [
                  address['label'],
                  address['area'],
                ].whereType<String>().where((s) => s.isNotEmpty).join(' · ')
              : '');

      final driver = data['driver'];
      final driverMap = driver is Map<String, dynamic> ? driver : null;
      final champName = driverDisplayName(driverMap);
      final hasChamp = champName.isNotEmpty;
      final champ = !hasChamp
          ? 'Not assigned yet'
          : driverMap?['isIdVerified'] == true
              ? '$champName · ID-verified'
              : champName;

      final createdAt =
          formatOrderDate(data['createdAt'] ?? data['deliveredAt']);
      final statusLabel = formatStatusLabel(status);

      setState(() {
        _displayId = data['orderNumber']?.toString() ?? id;
        _vendorName = vendorName;
        _vendorLogoUrl = vendorLogo;
        _statusRaw = status;
        _statusBanner = status.toUpperCase().contains('DELIVER') ||
                status == 'COLLECTED' ||
                status == 'COMPLETED'
            ? '$statusLabel · $createdAt'
            : statusLabel;
        _fulfillment = orderType == 'PICKUP'
            ? 'Pickup'
            : orderType == 'DINE_IN'
                ? 'Dine-in'
                : orderType == 'SERVICE'
                    ? 'Service'
                    : fulfillment == 'SCHEDULED'
                        ? 'Scheduled delivery'
                        : NavigationStrings.onDemandDelivery;
        _items = items;
        _bill = money;
        _deliveredTo = addressLabel.isNotEmpty ? addressLabel : '—';
        _champ = champ;
        _hasChamp = hasChamp;
        _payment = formatPaymentMethod(data['paymentMethod'] as String?);
        _orderType = orderType;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reorder() async {
    final id = widget.orderId;
    if (id != null && id.isNotEmpty) {
      await ref.read(ordersRepositoryProvider).reorder(id);
    }
    if (!mounted) return;
    context.goHome(tab: 2, cartHasItems: true);
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              children: [
                NavBackHeader(
                  title: NavigationStrings.orderDetails,
                  subtitle: _displayId.isEmpty ? null : _displayId,
                  backIconColor: AppColors.textPrimary,
                ),
                if (_statusBanner.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: _statusBannerBg,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _statusBanner,
                      style: AppTextStyles.labelMedium(
                        color: _statusBannerFg,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5.sp,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 14.h),
                _OrderDetailCard(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: SizedBox(
                          width: 46.w,
                          height: 46.w,
                          child: (_vendorLogoUrl != null &&
                                  _vendorLogoUrl!.isNotEmpty)
                              ? AppNetworkImage(
                                  url: _vendorLogoUrl!,
                                  width: 46.w,
                                  height: 46.w,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: const Color(0xFFDBE8DE),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.storefront_outlined,
                                    size: 22.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _vendorName.isEmpty ? 'Vendor' : _vendorName,
                              style: AppTextStyles.titleSmall().copyWith(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_fulfillment.isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              Text(
                                _fulfillment,
                                style: AppTextStyles.labelSmall(
                                  color: const Color(0xFF6B756E),
                                ).copyWith(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                _SectionTitle(NavigationStrings.items),
                SizedBox(height: 10.h),
                _OrderDetailCard(
                  child: _items.isEmpty
                      ? Text(
                          'No items',
                          style: AppTextStyles.labelSmall(
                            color: const Color(0xFF6B756E),
                          ),
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < _items.length; i++) ...[
                              if (i > 0) SizedBox(height: 10.h),
                              _DetailRow(
                                label: _items[i].name,
                                value: _items[i].price,
                              ),
                            ],
                          ],
                        ),
                ),
                SizedBox(height: 14.h),
                _SectionTitle(NavigationStrings.billSummary),
                SizedBox(height: 10.h),
                _OrderDetailCard(
                  child: _bill.isEmpty
                      ? Text(
                          'No bill data',
                          style: AppTextStyles.labelSmall(
                            color: const Color(0xFF6B756E),
                          ),
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < _bill.length; i++) ...[
                              if (_bill[i].isBold && i > 0)
                                Divider(
                                  color: AppColors.cartTabBorder,
                                  height: 20.h,
                                ),
                              _DetailRow(
                                label: _bill[i].label,
                                value: _bill[i].value,
                                isDiscount: _bill[i].isDiscount,
                                isBold: _bill[i].isBold,
                              ),
                              if (i < _bill.length - 1 && !_bill[i].isBold)
                                SizedBox(height: 10.h),
                            ],
                          ],
                        ),
                ),
                SizedBox(height: 14.h),
                _OrderDetailCard(
                  child: Column(
                    children: [
                      _DetailRow(
                        label: NavigationStrings.deliveredTo,
                        value: _deliveredTo.isEmpty ? '—' : _deliveredTo,
                      ),
                      SizedBox(height: 10.h),
                      _DetailRow(
                        label: NavigationStrings.champ,
                        value: _champ.isEmpty ? 'Not assigned yet' : _champ,
                        muted: !_hasChamp,
                      ),
                      SizedBox(height: 10.h),
                      _DetailRow(
                        label: NavigationStrings.payment,
                        value: _payment.isEmpty ? '—' : _payment,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _reorder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cartTabActive,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26.r),
                      ),
                    ),
                    child: Text(
                      '↻ ${NavigationStrings.reorder}',
                      style:
                          AppTextStyles.labelLarge().copyWith(fontSize: 16.sp),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: _OutlineActionButton(
                        label: NavigationStrings.receipt,
                        onTap: () => context.push(
                          _orderType == 'DINE_IN'
                              ? DineInOrderFlowRoutes.receiptFor(orderId)
                              : OrderFlowRoutes.receiptFor(orderId),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _OutlineActionButton(
                        label: NavigationStrings.rate,
                        onTap: () => context.push(
                          _orderType == 'DINE_IN'
                              ? DineInOrderFlowRoutes.completeFor(orderId)
                              : OrderFlowRoutes.deliveredFor(orderId),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _OutlineActionButton(
                        label: NavigationStrings.getHelp,
                        onTap: () => context.push(
                          HelpRoutes.helpSupport(
                            orderId: orderId ?? HelpData.defaultOrderId,
                            tab: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) {
            context.pop();
            return;
          }
          context.goHome(tab: index);
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleSmall().copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _OrderDetailCard extends StatelessWidget {
  const _OrderDetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cartTabBorder),
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
    this.isBold = false,
    this.muted = false,
  });

  final String label;
  final String value;
  final bool isDiscount;
  final bool isBold;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = isDiscount
        ? AppColors.successText
        : muted
            ? const Color(0xFF6B756E)
            : AppColors.textPrimary;
    final style = AppTextStyles.labelMedium().copyWith(
      fontSize: isBold ? 14.sp : 13.sp,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      color: color,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.white,
          side: const BorderSide(color: Color(0xFFE0E6E0)),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            color: AppColors.textPrimary,
          ).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}
