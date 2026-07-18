import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/services_order_flow_routes.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';

class ServicesConfirmedScreen extends StatelessWidget {
  const ServicesConfirmedScreen({super.key});

  static const Color _text = Color(0xFF1A1A1A);
  static const Color _muted = Color(0xFF6B756E);
  static const Color _green = Color(0xFF2E9E4D);
  static const Color _border = Color(0xFFE0E6E0);
  static const Color _bg = Color(0xFFF2F7F2);

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    // Figma frame: status 44 + body padding 20 before the check icon.
    final topPad = (safeTop < 44.h ? 44.h : safeTop) + 20.h;

    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 0,
      backgroundColor: _bg,
      body: ListView(
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
            ServicesOrderFlowStrings.appointmentBooked,
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              color: _muted,
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 16 / 13,
            ),
          ),
          SizedBox(height: 14.h),
          const ServicesBookingDetailsCard(showPaid: true),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () => context.push(ServicesOrderFlowRoutes.status),
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
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: _text,
                backgroundColor: AppColors.white,
                side: const BorderSide(color: _border, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
                padding: EdgeInsets.zero,
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
