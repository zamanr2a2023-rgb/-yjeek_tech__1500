import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
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
                SizedBox(height: 12.h),
                HelpCard(
                  child: HelpChevronRow(
                    title: 'Policies — Refund · Terms · Privacy',
                    dense: true,
                    showDivider: false,
                    leading: Icon(
                      Icons.description_outlined,
                      size: 18.sp,
                      color: const Color(0xFF6B7B6E),
                    ),
                    onTap: () => context.push(HelpRoutes.helpPoliciesLegal()),
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
        context.push(HelpRoutes.helpFaq());
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
        context.push(HelpRoutes.helpChat());
    }
  }
}
