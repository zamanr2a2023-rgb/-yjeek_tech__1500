import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class AboutPoliciesScreen extends StatelessWidget {
  const AboutPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          NavBackHeader(
            title: NavigationStrings.aboutPolicies,
            backIconColor: AppColors.textPrimary,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
              children: [
                AboutPolicyMenuItem(
                  iconAsset: AppAssets.policyAbout,
                  title: NavigationStrings.aboutYjeek,
                  subtitle: NavigationStrings.aboutYjeekSubtitle,
                  onTap: () => context.push(RouteNames.aboutYjeek),
                ),
                SizedBox(height: 14.h),
                AboutPolicyMenuItem(
                  iconAsset: AppAssets.policyTerms,
                  title: NavigationStrings.termsConditions,
                  subtitle: 'YTW-TC-2026',
                  onTap: () => context.push('${RouteNames.policyDocument}?type=terms'),
                ),
                SizedBox(height: 14.h),
                AboutPolicyMenuItem(
                  iconAsset: AppAssets.policyPrivacy,
                  title: NavigationStrings.privacyPolicy,
                  subtitle: 'PDPL Decree 30 of 2018',
                  onTap: () => context.push('${RouteNames.policyDocument}?type=privacy'),
                ),
                SizedBox(height: 14.h),
                AboutPolicyMenuItem(
                  iconAsset: AppAssets.policyRefund,
                  title: NavigationStrings.refundReturnPolicy,
                  subtitle: 'Consumer Protection Law 35/2012',
                  onTap: () => context.push('${RouteNames.policyDocument}?type=refund'),
                ),
                SizedBox(height: 14.h),
                AboutPolicyMenuItem(
                  iconAsset: AppAssets.policyFaq,
                  title: NavigationStrings.faq,
                  subtitle: NavigationStrings.faqSubtitle,
                  onTap: () {},
                ),
                SizedBox(height: 14.h),
                AboutPolicyMenuItem(
                  iconAsset: AppAssets.policyEmail,
                  title: NavigationStrings.contactUs,
                  subtitle: 'contact@yjeektech.com',
                  onTap: () {},
                ),
                SizedBox(height: 20.h),
                Text(
                  NavigationStrings.aboutFooter,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(
                    color: const Color(0xFF6B756E),
                  ).copyWith(fontSize: 10.5.sp, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }
}
