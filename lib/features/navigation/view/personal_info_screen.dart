import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(
            title: NavigationStrings.personalInfo,
            trailing: GestureDetector(
              onTap: () => context.push(RouteNames.editPersonalInfo),
              child: Text(
                NavigationStrings.edit,
                style: AppTextStyles.labelSmall(color: AppColors.white).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              children: [
                _InfoCard(
                  children: [
                    AccountInfoRow(
                      iconAsset: AppAssets.accountPersonal,
                      label: NavigationStrings.fullName,
                      value: NavigationData.userName,
                    ),
                    const Divider(height: 1, color: Color(0xFFE6EBE3)),
                    AccountInfoRow(
                      icon: Icons.phone_outlined,
                      label: NavigationStrings.phoneNumber,
                      value: NavigationData.userPhone,
                      suffix: const VerifiedBadge(),
                    ),
                    const Divider(height: 1, color: Color(0xFFE6EBE3)),
                    AccountInfoRow(
                      iconAsset: AppAssets.accountEmail,
                      label: NavigationStrings.email,
                      value: WalletData.userEmail,
                    ),
                    const Divider(height: 1, color: Color(0xFFE6EBE3)),
                    AccountInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: NavigationStrings.dateOfBirth,
                      value: WalletData.userDob,
                    ),
                    const Divider(height: 1, color: Color(0xFFE6EBE3)),
                    AccountInfoRow(
                      iconAsset: AppAssets.accountStar,
                      label: NavigationStrings.memberSince,
                      value: WalletData.memberSince,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SectionHeaderLabel(label: NavigationStrings.accountActions),
                _InfoCard(
                  children: [
                    AccountActionRow(
                      icon: Icons.phone_outlined,
                      title: NavigationStrings.changePhone,
                    ),
                    const Divider(height: 1, color: Color(0xFFE6EBE3)),
                    AccountActionRow(
                      iconAsset: AppAssets.accountShield,
                      title: NavigationStrings.privacyData,
                    ),
                    const Divider(height: 1, color: Color(0xFFE6EBE3)),
                    AccountActionRow(
                      iconAsset: AppAssets.accountDelete,
                      title: NavigationStrings.deleteAccount,
                      destructive: true,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                const PrivacyFooterBanner(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
