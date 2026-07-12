import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class DineInCompleteScreen extends StatelessWidget {
  const DineInCompleteScreen({super.key});

  static const Color _screenBg = Color(0xFF8BAE9A);

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      backgroundColor: _screenBg,
      bottomNavIndex: 0,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top),
          Align(
            alignment: Alignment.centerLeft,
            child: OrderSuccessIcon(size: 64.w),
          ),
          SizedBox(height: 14.h),
          Text(
            DineInOrderFlowStrings.visitComplete,
            textAlign: TextAlign.left,
            style: AppTextStyles.titleMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 24.sp,
              height: 1.2,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            DineInOrderFlowStrings.thankYouVisit,
            textAlign: TextAlign.left,
            style: AppTextStyles.bodySmall(color: const Color(0xFF6B756E)).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 1.23,
            ),
          ),
          SizedBox(height: 14.h),
          const OrderStarRatingCard(
            title: DineInOrderFlowStrings.rateExperience,
            initialRating: 5,
          ),
          SizedBox(height: 14.h),
          const OrderStarRatingCard(
            title: DineInOrderFlowStrings.rateFood,
            initialRating: 4,
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
                  DineInOrderFlowStrings.tipStaff,
                  style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 10.h),
                const DineInTipChips(),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          const DineInReviewField(),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () => context.go('${RouteNames.home}?tab=1'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cartTabActive,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
              child: Text(
                DineInOrderFlowStrings.submit,
                style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton.icon(
              onPressed: () => context.push(BrowseRoutes.dineInBrowse()),
              icon: Icon(Icons.refresh, size: 18.sp, color: AppColors.textPrimary),
              label: Text(
                DineInOrderFlowStrings.bookAgain,
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.white,
                side: const BorderSide(color: Color(0xFFE0E6E0), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
