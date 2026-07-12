import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/dine_in_order_flow_routes.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DineInConfirmedScreen extends StatelessWidget {
  const DineInConfirmedScreen({super.key});

  static const Color _screenBg = Color(0xFF8BAE9A);

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      backgroundColor: _screenBg,
      bottomNavIndex: 0,
      body: ListView(
        padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          const Center(child: DineInSuccessIcon()),
          SizedBox(height: 16.h),
          Text(
            DineInOrderFlowStrings.youreAllSet,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 24.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            DineInOrderFlowStrings.showCodeHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(color: const Color(0xFF072F0F)).copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 16.h),
          const DineInArrivalCodeCard(),
          SizedBox(height: 16.h),
          const DineInDetailsCard(),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () => context.push(DineInOrderFlowRoutes.status),
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
                style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
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
