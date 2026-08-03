import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/dine_in_order_flow_routes.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DineInConfirmedScreen extends ConsumerStatefulWidget {
  const DineInConfirmedScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<DineInConfirmedScreen> createState() =>
      _DineInConfirmedScreenState();
}

class _DineInConfirmedScreenState extends ConsumerState<DineInConfirmedScreen> {
  static const Color _screenBg = Color(0xFF8BAE9A);

  String _vendor = DineInOrderFlowData.vendor;
  String _code = DineInOrderFlowData.arrivalCode;
  String _venue = DineInOrderFlowData.venue;
  String _time = DineInOrderFlowData.dineInTime;
  String _track = DineInOrderFlowData.prepTrack;
  String _status = DineInOrderFlowData.statusPreparing;
  bool _loading = true;

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
    final order = await ref.read(ordersRepositoryProvider).getOrder(id);
    if (!mounted) return;
    if (order == null) {
      setState(() => _loading = false);
      return;
    }
    final vendor = order['vendor'];
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;
    final loc = order['vendorLocation'];
    final locName = loc is Map ? loc['name']?.toString() ?? loc['area']?.toString() : null;
    final area = vendor is Map ? vendor['area']?.toString() : null;
    final venue = [
      vendorName,
      locName ?? area,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' - ');
    final prep = order['dineInPrepMode']?.toString();
    final track = order['dineInTimeLabel']?.toString() ??
        (prep == 'PREPARE_NOW'
            ? 'Start preparing now'
            : DineInOrderFlowData.prepTrack);
    final statusLabel = formatStatusLabel(order['status']?.toString());
    final paid = formatBhd(order['totalAmount']);

    setState(() {
      _vendor = vendorName ?? _vendor;
      _code = order['arrivalCode']?.toString() ??
          order['orderNumber']?.toString() ??
          _code;
      _venue = venue.isNotEmpty ? venue : _venue;
      _time = order['dineInTimeLabel']?.toString() ?? _time;
      _track = track;
      _status = '$statusLabel · Paid $paid';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    return OrderFlowScaffold(
      showHeader: false,
      backgroundColor: _screenBg,
      bottomNavIndex: 0,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.white))
          : ListView(
              padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 16.h),
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
                const Center(child: DineInSuccessIcon()),
                SizedBox(height: 16.h),
                Text(
                  DineInOrderFlowStrings.youreAllSet,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium(color: AppColors.textPrimary)
                      .copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 24.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Show this number to the vendor when you arrive at $_vendor.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(color: const Color(0xFF072F0F))
                      .copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 16.h),
                DineInArrivalCodeCard(code: _code),
                SizedBox(height: 16.h),
                DineInDetailsCard(
                  venue: _venue,
                  dineInTime: _time,
                  track: _track,
                  status: _status,
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () => context.push(
                      DineInOrderFlowRoutes.statusFor(orderId),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26.r),
                      ),
                    ),
                    child: Text(
                      DineInOrderFlowStrings.viewOrderStatus,
                      style: AppTextStyles.labelMedium(color: AppColors.white)
                          .copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
