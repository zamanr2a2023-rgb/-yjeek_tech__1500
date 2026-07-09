import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class WithdrawBankScreen extends StatelessWidget {
  const WithdrawBankScreen({super.key, this.verified = false});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(title: NavigationStrings.withdrawToBank),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              children: [
                _WithdrawBalanceCard(),
                SizedBox(height: 14.h),
                const PayoutSplitCard(),
                SizedBox(height: 14.h),
                if (verified)
                  const _VerifiedKycTile()
                else
                  _KycPromptTile(
                    onTap: () => context.push(RouteNames.idVerification),
                  ),
                SizedBox(height: 14.h),
                const InfoNoticeBox(
                  variant: InfoNoticeVariant.green,
                  text:
                      'Names must match across all documents. Review ≤ 2 working days · '
                      'bank transfer 3–7 working days after approval.',
                ),
                SizedBox(height: 14.h),
                PrimaryGreenButton(
                  label: verified
                      ? NavigationStrings.requestWithdrawal
                      : NavigationStrings.verifyToWithdraw,
                  enabled: verified,
                  height: 50,
                  borderRadius: 13,
                  disabledBackgroundColor: const Color(0xFFCCD6CF),
                  backgroundColor: AppColors.cartTabActive,
                  onPressed: verified ? () {} : null,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 3),
    );
  }
}

class _WithdrawBalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.successText,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            NavigationStrings.withdrawableBalance,
            style: AppTextStyles.caption(color: const Color(0xFFCFE3D5)).copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            WalletData.withdrawableBalance,
            style: AppTextStyles.displayMedium(color: AppColors.white).copyWith(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              height: 1.32,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: const Color(0xFF15401F),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 14.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  NavigationStrings.eligibleMinimum,
                  style: AppTextStyles.caption(color: const Color(0xFFCFE3D5)).copyWith(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
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

class _KycPromptTile extends StatelessWidget {
  const _KycPromptTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2EB),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.cartTabActive, width: 1.3),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    NavigationStrings.verifyIdentity,
                    style: AppTextStyles.labelMedium(
                      color: const Color(0xFF127036),
                    ).copyWith(fontWeight: FontWeight.w600, fontSize: 14.5.sp),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    NavigationStrings.requiredBeforeWithdrawal,
                    style: AppTextStyles.labelSmall(
                      color: const Color(0xFF597361),
                    ).copyWith(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            Text(
              '›',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.cartTabActive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedKycTile extends StatelessWidget {
  const _VerifiedKycTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2EB),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cartTabActive, width: 1.3),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.cartTabActive, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NavigationStrings.identityVerified,
                  style: AppTextStyles.labelMedium(
                    color: const Color(0xFF127036),
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 14.5.sp),
                ),
                SizedBox(height: 1.h),
                Text(
                  NavigationStrings.kycApproved,
                  style: AppTextStyles.labelSmall(
                    color: const Color(0xFF597361),
                  ).copyWith(fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
