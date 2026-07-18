import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class ServicesCompleteScreen extends StatelessWidget {
  const ServicesCompleteScreen({super.key});

  static const Color _text = Color(0xFF1A1A1A);
  static const Color _muted = Color(0xFF6B756E);
  static const Color _green = Color(0xFF2E9E4D);
  static const Color _border = Color(0xFFE0E6E0);
  static const Color _bg = Color(0xFFF2F7F2);

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    final topPad = (safeTop < 44.h ? 44.h : safeTop) + 20.h;

    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 0,
      backgroundColor: _bg,
      body: ListView(
        // Figma body: padding 20/20/24, gap 14, align left
        padding: EdgeInsets.fromLTRB(20.w, topPad, 20.w, 24.h),
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: ServicesConfirmedIcon(),
          ),
          SizedBox(height: 14.h),
          Text(
            ServicesOrderFlowStrings.serviceComplete,
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              color: _text,
              fontWeight: FontWeight.w700,
              fontSize: 24.sp,
              height: 29 / 24,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            ServicesOrderFlowStrings.thankYouVisit,
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              color: _muted,
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 16 / 13,
            ),
          ),
          SizedBox(height: 14.h),
          const OrderStarRatingCard(
            title: ServicesOrderFlowStrings.rateProvider,
            initialRating: 5,
          ),
          SizedBox(height: 14.h),
          const OrderStarRatingCard(
            title: ServicesOrderFlowStrings.rateService,
            initialRating: 5,
          ),
          SizedBox(height: 14.h),
          OrderFlowCard(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ServicesOrderFlowStrings.tipSpecialist,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.inter(
                    color: _text,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    height: 17 / 14,
                  ),
                ),
                SizedBox(height: 10.h),
                const ServicesTipChips(),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () => context.go('${RouteNames.home}?tab=0'),
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
                ServicesOrderFlowStrings.submit,
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
            height: 52.h,
            child: OutlinedButton(
              onPressed: () => context.push(BrowseRoutes.servicesBrowse()),
              style: OutlinedButton.styleFrom(
                foregroundColor: _text,
                backgroundColor: AppColors.white,
                side: const BorderSide(color: _border, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: _text, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    ServicesOrderFlowStrings.bookAgain,
                    style: GoogleFonts.inter(
                      color: _text,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      height: 18 / 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
