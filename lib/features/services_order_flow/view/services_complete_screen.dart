import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class ServicesCompleteScreen extends StatelessWidget {
  const ServicesCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          const Center(child: ServicesConfirmedIcon()),
          SizedBox(height: 18.h),
          Text(
            ServicesOrderFlowStrings.serviceComplete,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium().copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            ServicesOrderFlowStrings.thankYouVisit,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall().copyWith(
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),
          const OrderStarRatingCard(
            title: ServicesOrderFlowStrings.rateProvider,
            initialRating: 5,
          ),
          SizedBox(height: 12.h),
          const OrderStarRatingCard(
            title: ServicesOrderFlowStrings.rateService,
            initialRating: 5,
          ),
          SizedBox(height: 12.h),
          OrderFlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ServicesOrderFlowStrings.tipSpecialist,
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                const ServicesTipChips(),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          PrimaryGreenButton(
            label: ServicesOrderFlowStrings.submit,
            onPressed: () => context.go('${RouteNames.home}?tab=1'),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => context.push(BrowseRoutes.servicesBrowse()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, color: AppColors.primary, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  ServicesOrderFlowStrings.bookAgain,
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
