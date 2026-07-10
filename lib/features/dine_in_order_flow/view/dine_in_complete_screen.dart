import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/routes/route_names.dart';

class DineInCompleteScreen extends StatelessWidget {
  const DineInCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          const Center(child: OrderSuccessIcon(size: 64)),
          SizedBox(height: 18.h),
          Text(
            DineInOrderFlowStrings.visitComplete,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium().copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            DineInOrderFlowStrings.thankYouVisit,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall().copyWith(
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),
          const OrderStarRatingCard(
            title: DineInOrderFlowStrings.rateExperience,
            initialRating: 5,
          ),
          SizedBox(height: 12.h),
          const OrderStarRatingCard(
            title: DineInOrderFlowStrings.rateFood,
            initialRating: 5,
          ),
          SizedBox(height: 12.h),
          OrderFlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DineInOrderFlowStrings.tipStaff,
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                const DineInTipChips(),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          const DineInReviewField(),
          SizedBox(height: 24.h),
          PrimaryGreenButton(
            label: DineInOrderFlowStrings.submit,
            onPressed: () => context.go('${RouteNames.home}?tab=1'),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => context.push(BrowseRoutes.dineInBrowse()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_outlined, color: AppColors.primary, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  DineInOrderFlowStrings.bookAgain,
                  style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
