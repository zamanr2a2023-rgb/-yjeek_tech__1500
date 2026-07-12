import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DineInReceiptScreen extends StatelessWidget {
  const DineInReceiptScreen({super.key});

  static const Color _screenBg = Color(0xFF8BAE9A);

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: DineInOrderFlowStrings.receipt,
      subtitle: DineInOrderFlowData.receiptHeaderSubtitle,
      lightHeader: true,
      backgroundColor: _screenBg,
      bottomNavIndex: 0,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        children: [
          const DineInReceiptPaper(),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () {},
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
                style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
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
