import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GreenScreenHeader(title: NavigationStrings.helpSupport),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              children: [
                const HelpSectionTitle(label: 'Help with an order'),
                SizedBox(height: 10.h),
                HelpOrderCompactCard(
                  order: HelpData.defaultContext.order,
                  actionLabel: NavigationStrings.getHelp,
                  onAction: () => context.push(
                    HelpRoutes.orderHelp(orderId: HelpData.defaultOrderId),
                  ),
                ),
                SizedBox(height: 16.h),
                const HelpSectionTitle(label: 'Popular help topics'),
                SizedBox(height: 10.h),
                HelpCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < HelpData.popularTopics.length; i++)
                        HelpChevronRow(
                          title: HelpData.popularTopics[i],
                          dense: true,
                          showDivider: i < HelpData.popularTopics.length - 1,
                          onTap: () => _openPopularTopic(context, i),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () => context.push(RouteNames.aboutPolicies),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE6EBE3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 18.sp,
                          color: const Color(0xFF6B7B6E),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Policies — Refund · Terms · Privacy',
                            style: AppTextStyles.labelSmall(color: AppColors.textPrimary)
                                .copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5.sp,
                              height: 1.3,
                            ),
                          ),
                        ),
                        Text(
                          '›',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7B6E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }

  void _openPopularTopic(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.push('${RouteNames.policyDocument}?type=refund');
      case 1:
        context.push(RouteNames.withdrawBank);
      case 2:
        context.push(
          HelpRoutes.helpIssue(
            type: HelpIssueType.orderLate,
            orderId: HelpData.defaultOrderId,
          ),
        );
      case 3:
        context.push('${RouteNames.policyDocument}?type=terms');
    }
  }
}
