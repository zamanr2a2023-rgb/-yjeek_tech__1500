import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/rewards/model/rewards_summary.dart';

class RewardSummaryCards extends StatelessWidget {
  const RewardSummaryCards({super.key, required this.wallet});

  final RewardsWalletBucket wallet;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _BucketCard(
                label: 'Available',
                value: wallet.availableLabel,
                color: const Color(0xFFE8F5E9),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _BucketCard(
                label: 'Pending',
                value: wallet.pendingLabel,
                color: const Color(0xFFFFF8E1),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        _BucketCard(
          label: 'Expiring soon',
          value: wallet.expiringSoonLabel,
          subtitle: wallet.expiringSoonBy == null
              ? null
              : 'By ${_formatDate(wallet.expiringSoonBy!)}',
          color: const Color(0xFFFFEBEE),
          fullWidth: true,
        ),
      ],
    );
  }

  static String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '${local.year}-$m-$d';
  }
}

class _BucketCard extends StatelessWidget {
  const _BucketCard({
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final Color color;
  final String? subtitle;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary)
                .copyWith(fontWeight: FontWeight.w600, fontSize: 11.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: AppTextStyles.titleMedium(color: AppColors.textPrimary)
                .copyWith(fontWeight: FontWeight.w700, fontSize: 18.sp),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle!,
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary)
                  .copyWith(fontSize: 12.sp),
            ),
          ],
        ],
      ),
    );
  }
}
