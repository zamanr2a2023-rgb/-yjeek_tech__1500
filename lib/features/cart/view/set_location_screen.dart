import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';

class SetLocationScreen extends StatelessWidget {
  const SetLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: CartFlowStrings.setYourLocation,
      subtitle: CartFlowStrings.moveMapPin,
      lightHeader: true,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
        child: Column(
          children: [
            Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE0E6E0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18.sp, color: AppColors.textSecondary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      CartFlowStrings.searchAreaHint,
                      style: AppTextStyles.bodySmall(
                        color: AppColors.textSecondary,
                      ).copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1E0D4),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: const BoxDecoration(
                      color: AppColors.cartTabActive,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.location_on,
                      color: const Color(0xFFE53935),
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE0E6E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CartFlowStrings.detectedLocationLabel,
                    style: AppTextStyles.labelSmall(
                      color: AppColors.textSecondary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                      letterSpacing: 0.44,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE3F2EB),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.location_on,
                          color: const Color(0xFFE53935),
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CartFlowData.detectedLocation,
                              style: AppTextStyles.labelMedium(
                                color: AppColors.textPrimary,
                              ).copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              CartFlowData.detectedLocationDetail,
                              style: AppTextStyles.labelSmall(
                                color: AppColors.textSecondary,
                              ).copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: PrimaryGreenButton(
                  label: CartFlowStrings.confirmLocation,
                  backgroundColor: AppColors.cartTabActive,
                  height: 54,
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
