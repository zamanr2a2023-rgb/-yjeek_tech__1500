import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/rewards/model/rewards_summary.dart';
import 'package:yjeek_app/routes/route_names.dart';

class RewardWalletCard extends StatelessWidget {
  const RewardWalletCard({super.key, required this.wallet});

  final RewardsWalletBucket wallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WITHDRAWABLE',
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary)
                .copyWith(fontWeight: FontWeight.w600, fontSize: 11.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            wallet.withdrawableLabel,
            style: AppTextStyles.titleMedium(color: AppColors.textPrimary)
                .copyWith(fontWeight: FontWeight.w700, fontSize: 22.sp),
          ),
          SizedBox(height: 14.h),
          PrimaryGreenButton(
            label:
                '${NavigationStrings.withdrawableBalance} · ${wallet.withdrawableLabel}',
            backgroundColor: AppColors.primary,
            onPressed: () => context.push(RouteNames.withdrawBank),
          ),
        ],
      ),
    );
  }
}
