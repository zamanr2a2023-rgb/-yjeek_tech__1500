import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class SetLocationScreen extends StatelessWidget {
  const SetLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(
            title: CartFlowStrings.setYourLocation,
            subtitle: CartFlowStrings.moveMapPin,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 20.sp, color: AppColors.textSecondary),
                  SizedBox(width: 10.w),
                  Text(
                    CartFlowStrings.searchAreaHint,
                    style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2EB),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                Icon(Icons.location_on, color: const Color(0xFFE53935), size: 44.sp),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: CartFlowCard(
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      CartFlowData.detectedLocation,
                      style: AppTextStyles.labelMedium().copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: PrimaryGreenButton(
                label: CartFlowStrings.confirmLocation,
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 2),
    );
  }
}
