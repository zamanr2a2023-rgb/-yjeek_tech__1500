import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';

class ServicesReceiptScreen extends StatelessWidget {
  const ServicesReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: ServicesOrderFlowStrings.receipt,
      subtitle: '#${ServicesOrderFlowData.bookingId}',
      lightHeader: true,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        children: [
          const ServicesReceiptPaper(),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: () {},
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
                        Icon(Icons.download, size: 18.sp, color: const Color(0xFF1A1A1A)),
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
                    onPressed: () {},
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
                        fontSize: 16.sp,
                        height: 19 / 16,
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
