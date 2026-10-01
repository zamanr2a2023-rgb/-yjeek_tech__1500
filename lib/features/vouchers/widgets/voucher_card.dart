import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/vouchers/model/voucher_models.dart';

class VoucherCard extends StatelessWidget {
  const VoucherCard({
    super.key,
    required this.voucher,
    this.selected = false,
    this.onTap,
    this.subtitle,
    this.dimmed = false,
  });

  final CustomerVoucher voucher;
  final bool selected;
  final VoidCallback? onTap;
  final String? subtitle;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Opacity(
        opacity: dimmed ? 0.55 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    voucher.title,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: AppColors.primary, size: 18.sp),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              voucher.valueLabel,
              style: AppTextStyles.labelMedium(color: AppColors.primary)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            if (voucher.minOrder != null) ...[
              SizedBox(height: 4.h),
              Text(
                'Min order BHD ${voucher.minOrder}',
                style: AppTextStyles.labelSmall(color: AppColors.textSecondary),
              ),
            ],
            if (voucher.maxDiscount != null) ...[
              SizedBox(height: 2.h),
              Text(
                'Max discount BHD ${voucher.maxDiscount}',
                style: AppTextStyles.labelSmall(color: AppColors.textSecondary),
              ),
            ],
            SizedBox(height: 4.h),
            Text(
              'Expires ${voucher.validToLabel}',
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary),
            ),
            if (voucher.vendorScopeSummary.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                voucher.vendorScopeSummary,
                style: AppTextStyles.labelSmall(color: AppColors.textSecondary),
              ),
            ],
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                subtitle!,
                style: AppTextStyles.labelSmall(color: AppColors.primary)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: child,
      ),
    );
  }
}
