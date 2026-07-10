import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class ZoodWaitingListScreen extends StatelessWidget {
  const ZoodWaitingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(
            title: 'Zood',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
              children: [
                Center(
                  child: Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: CartFlowData.zoodRed,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Icon(Icons.auto_awesome, color: AppColors.white, size: 36.sp),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  CartFlowStrings.zoodTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium().copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  CartFlowStrings.zoodSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                    fontSize: 14.sp,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 24.h),
                for (final benefit in CartFlowData.zoodBenefits) ...[
                  Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE8E9),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(benefit.icon, color: CartFlowData.zoodRed, size: 20.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            benefit.text,
                            style: AppTextStyles.labelMedium().copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                children: [
                  PrimaryGreenButton(
                    label: CartFlowStrings.zoodJoin,
                    backgroundColor: CartFlowData.zoodRed,
                    onPressed: () => context.pop(),
                  ),
                  SizedBox(height: 10.h),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 49.h),
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                    ),
                    child: Text(
                      CartFlowStrings.zoodNotNow,
                      style: AppTextStyles.labelMedium().copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 2),
    );
  }
}
