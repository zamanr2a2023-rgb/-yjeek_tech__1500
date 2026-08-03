import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_api_mappers.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/services_order_flow_routes.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';

class ServicesConfirmedScreen extends ConsumerStatefulWidget {
  const ServicesConfirmedScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<ServicesConfirmedScreen> createState() =>
      _ServicesConfirmedScreenState();
}

class _ServicesConfirmedScreenState
    extends ConsumerState<ServicesConfirmedScreen> {
  static const Color _text = Color(0xFF1A1A1A);
  static const Color _muted = Color(0xFF6B756E);
  static const Color _green = Color(0xFF2E9E4D);
  static const Color _border = Color(0xFFE0E6E0);
  static const Color _bg = Color(0xFFF2F7F2);

  String _refLine = ServicesOrderFlowStrings.appointmentBooked;
  String _service = ServicesOrderFlowData.serviceName;
  String _provider = ServicesOrderFlowData.providerName;
  String _when = ServicesOrderFlowData.appointmentWhen;
  String _location = ServicesOrderFlowData.locationLabel;
  String _paid = ServicesOrderFlowData.confirmedPaid;
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
    final orderNumber = order['orderNumber']?.toString();
    final method = formatPaymentMethod(order['paymentMethod']?.toString());
    final paid = '${formatBhd(order['totalAmount'])} · $method';

    setState(() {
      if (orderNumber != null && orderNumber.isNotEmpty) {
        _refLine = 'Your appointment is booked · Ref #$orderNumber';
      }
      _service = servicesServiceNameFromOrder(order);
      if (vendorName != null && vendorName.isNotEmpty) _provider = vendorName;
      _when = servicesWhenFromOrder(order);
      _location = servicesLocationFromOrder(order);
      _paid = paid;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    final safeTop = MediaQuery.paddingOf(context).top;
    final topPad = (safeTop < 44.h ? 44.h : safeTop) + 20.h;

    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 0,
      backgroundColor: _bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, topPad, 20.w, 24.h),
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: ServicesConfirmedIcon(),
                ),
                SizedBox(height: 14.h),
                Text(
                  ServicesOrderFlowStrings.bookingConfirmed,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.inter(
                    color: _text,
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    height: 27 / 22,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  _refLine,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.inter(
                    color: _muted,
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    height: 16 / 13,
                  ),
                ),
                SizedBox(height: 14.h),
                ServicesBookingDetailsCard(
                  showPaid: true,
                  serviceName: _service,
                  providerName: _provider,
                  whenLabel: _when,
                  locationLabel: _location,
                  paidLabel: _paid,
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () => context.push(
                      ServicesOrderFlowRoutes.statusFor(orderId),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                    ),
                    child: Text(
                      ServicesOrderFlowStrings.trackBooking,
                      style: GoogleFonts.inter(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        height: 19 / 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calendar invite coming soon'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _text,
                      backgroundColor: AppColors.white,
                      side: const BorderSide(color: _border, width: 1.5),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                    ),
                    child: Text(
                      ServicesOrderFlowStrings.addToCalendar,
                      style: GoogleFonts.inter(
                        color: _text,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                        height: 18 / 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
