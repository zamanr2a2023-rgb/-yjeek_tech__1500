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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: NavCircleBackButton(
                  onTap: () => context.pop(),
                  iconColor: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 28.h),
                children: [
                  Center(
                    child: Container(
                      width: 84.w,
                      height: 84.w,
                      decoration: BoxDecoration(
                        color: CartFlowData.zoodRed,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '✦',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 38.sp,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    CartFlowStrings.zoodTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleMedium(color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 22.sp,
                      height: 27 / 22,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    CartFlowStrings.zoodSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 13.5.sp,
                      height: 16 / 13.5,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFE0E6E0)),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < CartFlowData.zoodBenefits.length; i++) ...[
                          if (i > 0) SizedBox(height: 10.h),
                          Row(
                            children: [
                              Text(
                                CartFlowData.zoodBenefits[i].emoji,
                                style: TextStyle(fontSize: 15.sp, height: 1.2),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  CartFlowData.zoodBenefits[i].text,
                                  style: AppTextStyles.labelMedium(
                                    color: AppColors.textPrimary,
                                  ).copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.5.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  PrimaryGreenButton(
                    label: CartFlowStrings.zoodJoin,
                    backgroundColor: CartFlowData.zoodRed,
                    height: 52,
                    onPressed: () => context.pop(),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        backgroundColor: AppColors.white,
                        side: const BorderSide(color: Color(0xFFE0E6E0), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.r),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        CartFlowStrings.zoodNotNow,
                        style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 2),
    );
  }
}
