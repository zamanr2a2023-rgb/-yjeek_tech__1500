import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class GreenScreenHeader extends StatelessWidget {
  const GreenScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onBack,
    this.flat = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool flat;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        flat ? 16.w : 16.w,
        0,
        flat ? 20.w : 16.w,
        flat ? 16.h : 14.h,
      ),
      decoration: BoxDecoration(
        color: flat ? AppColors.cartTabActive : AppColors.primary,
        borderRadius: flat
            ? null
            : BorderRadius.vertical(bottom: Radius.circular(22.r)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack ?? () => context.pop(),
              child: flat
                  ? Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF248040),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '‹',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          height: 1,
                        ),
                      ),
                    )
                  : Text(
                      '‹',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        height: 1,
                      ),
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall(color: AppColors.white).copyWith(
                      fontSize: flat ? 20.sp : 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption(
                        color: const Color(0xFFEBF5EB),
                      ).copyWith(fontSize: 12.sp),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class WalletGradientBalanceCard extends StatelessWidget {
  const WalletGradientBalanceCard({
    super.key,
    required this.label,
    required this.amount,
    required this.subtitle,
  });

  final String label;
  final String amount;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A7A40), Color(0xFF0F4D27)],
        ),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption(color: const Color(0xFF9FD8B8)).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            amount,
            style: AppTextStyles.displayMedium(color: AppColors.white).copyWith(
              fontSize: 38.sp,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: AppTextStyles.labelSmall(color: const Color(0xFFCFE8D8)).copyWith(
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class WalletMainBalanceCard extends StatelessWidget {
  const WalletMainBalanceCard({
    super.key,
    required this.title,
    required this.amount,
    required this.iconBg,
    required this.iconAsset,
    required this.onView,
  });

  final String title;
  final String amount;
  final Color iconBg;
  final String iconAsset;
  final VoidCallback onView;

  static const Color _viewLinkColor = Color(0xFF1AA34D);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFE3E6E3)),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    iconAsset,
                    width: 16.w,
                    height: 16.w,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17.sp,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'View ›',
                      style: AppTextStyles.caption(color: _viewLinkColor).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WalletTransactionTile extends StatelessWidget {
  const WalletTransactionTile({super.key, required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final amountColor = transaction.positive
        ? AppColors.primary
        : AppColors.textPrimary;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: transaction.iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: transaction.iconAsset != null
                ? Image.asset(
                    transaction.iconAsset!,
                    width: 17.w,
                    height: 17.w,
                    fit: BoxFit.contain,
                  )
                : Icon(
                    transaction.icon,
                    size: 17.sp,
                    color: AppColors.textPrimary,
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        transaction.title,
                        style: AppTextStyles.labelMedium(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          height: 1.28,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      transaction.amount,
                      style: AppTextStyles.labelMedium(color: amountColor).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        height: 1.28,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  transaction.subtitle,
                  style: AppTextStyles.labelSmall(
                    color: AppColors.textSecondary,
                  ).copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.28,
                  ),
                ),
                if (transaction.expiryNote != null) ...[
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5E0),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      transaction.expiryNote!,
                      style: AppTextStyles.caption(
                        color: const Color(0xFFD98C1A),
                      ).copyWith(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeaderLabel extends StatelessWidget {
  const SectionHeaderLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        label,
        style: AppTextStyles.caption(
          color: const Color(0xFF6B7B6E),
        ).copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

class AccountFormField extends StatelessWidget {
  const AccountFormField({
    super.key,
    required this.label,
    required this.value,
    this.suffix,
    this.readOnly = true,
    this.valueColor,
  });

  final String label;
  final String value;
  final Widget? suffix;
  final bool readOnly;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall(
            color: const Color(0xFF6B756E),
          ).copyWith(fontSize: 12.5.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFD6DED6), width: 1.2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium(
                    color: valueColor ?? AppColors.textPrimary,
                  ).copyWith(fontSize: 15.sp, fontWeight: FontWeight.w500),
                ),
              ),
              if (suffix != null) suffix!,
            ],
          ),
        ),
      ],
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2EB),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFF2E9E4D), width: 0.95),
      ),
      child: Text(
        'Verified',
        style: AppTextStyles.caption(color: AppColors.cartTabActive).copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.verified,
  });

  final String label;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: verified ? const Color(0xFFE6F5E8) : const Color(0xFFFFF2DB),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(
          color: verified ? const Color(0xFF2E7D33) : const Color(0xFFC74D00),
        ).copyWith(fontWeight: FontWeight.w700, fontSize: 10.sp),
      ),
    );
  }
}

class GenderChipRow extends StatelessWidget {
  const GenderChipRow({super.key, required this.selected});

  final String selected;

  @override
  Widget build(BuildContext context) {
    const options = ['Female', 'Male', 'Prefer not to say'];
    return Row(
      children: options.map((option) {
        final isSelected = option == selected;
        return Padding(
          padding: EdgeInsets.only(right: option != options.last ? 8.w : 0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.cartTabActive : AppColors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? AppColors.cartTabActive : const Color(0xFFD6DED6),
                width: 1.2,
              ),
            ),
            child: Text(
              option,
              style: AppTextStyles.labelSmall(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.5.sp,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class PrimaryGreenButton extends StatelessWidget {
  const PrimaryGreenButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.icon,
    this.iconAsset,
    this.backgroundColor = AppColors.cartTabActive,
    this.disabledBackgroundColor = const Color(0xFFDCE7D4),
    this.borderRadius = 28,
    this.height = 49,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final IconData? icon;
  final String? iconAsset;
  final Color backgroundColor;
  final Color disabledBackgroundColor;
  final double borderRadius;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height.h,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? backgroundColor : disabledBackgroundColor,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: disabledBackgroundColor,
          disabledForegroundColor: AppColors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconAsset != null) ...[
              Image.asset(
                iconAsset!,
                width: 18.w,
                height: 18.w,
                color: AppColors.white,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 8.w),
            ] else if (icon != null) ...[
              Icon(icon, size: 18.sp),
              SizedBox(width: 8.w),
            ],
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelLarge().copyWith(fontSize: 15.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoNoticeBox extends StatelessWidget {
  const InfoNoticeBox({
    super.key,
    required this.text,
    this.variant = InfoNoticeVariant.warning,
  });

  final String text;
  final InfoNoticeVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = switch (variant) {
      InfoNoticeVariant.warning => (
          bg: const Color(0xFFFFF8E6),
          border: const Color(0xFFF0E4C4),
          icon: const Color(0xFFD98C1A),
          text: const Color(0xFF6B5E3A),
        ),
      InfoNoticeVariant.green => (
          bg: const Color(0xFFEAF3DE),
          border: Colors.transparent,
          icon: const Color(0xFF2E7D32),
          text: const Color(0xFF5E7A4E),
        ),
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(12.r),
        border: colors.border == Colors.transparent
            ? null
            : Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.access_time, size: 18.sp, color: colors.icon),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelSmall(color: colors.text).copyWith(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w500,
                height: 1.32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum InfoNoticeVariant { warning, green }

abstract final class PolicyTypography {
  static const Color muted = Color(0xFF6B756E);

  static TextStyle intro() => AppTextStyles.labelSmall(color: muted).copyWith(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle sectionTitle() =>
      AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 14.sp,
        height: 20 / 14,
      );

  static TextStyle sectionBody() => AppTextStyles.labelSmall(color: muted).copyWith(
        fontWeight: FontWeight.w400,
        height: 18 / 12.5,
      );
}

class PolicySectionCard extends StatelessWidget {
  const PolicySectionCard({super.key, required this.section});

  final PolicySection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFDBE3DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: PolicyTypography.sectionTitle(),
          ),
          SizedBox(height: 6.h),
          Text(
            section.body,
            style: PolicyTypography.sectionBody(),
          ),
        ],
      ),
    );
  }
}

class AboutPolicyMenuItem extends StatelessWidget {
  const AboutPolicyMenuItem({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconBg = const Color(0xFFE3F2EB),
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFDBE3DB)),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                iconAsset,
                width: 20.w,
                height: 20.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSmall(
                      color: const Color(0xFF6B756E),
                    ).copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '›',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B756E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountInfoRow extends StatelessWidget {
  const AccountInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.iconAsset,
    this.icon,
    this.suffix,
  }) : assert(iconAsset != null || icon != null);

  final String label;
  final String value;
  final String? iconAsset;
  final IconData? icon;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          AccountIconBadge(iconAsset: iconAsset, icon: icon),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption(
                    color: const Color(0xFF6B7B6E),
                  ).copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  value,
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5.sp,
                  ),
                ),
              ],
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}

class AccountActionRow extends StatelessWidget {
  const AccountActionRow({
    super.key,
    required this.title,
    this.iconAsset,
    this.icon,
    this.destructive = false,
    this.onTap,
  }) : assert(iconAsset != null || icon != null);

  final String title;
  final String? iconAsset;
  final IconData? icon;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFF9B111E) : AppColors.textPrimary;
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              AccountIconBadge(
                iconAsset: iconAsset,
                icon: icon,
                destructive: destructive,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMedium(color: color).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5.sp,
                  ),
                ),
              ),
              Text('›', style: TextStyle(fontSize: 18.sp, color: const Color(0xFF6B7B6E))),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountIconBadge extends StatelessWidget {
  const AccountIconBadge({
    super.key,
    this.iconAsset,
    this.icon,
    this.destructive = false,
    this.size = 38,
    this.iconSize = 19,
  }) : assert(iconAsset != null || icon != null);

  final String? iconAsset;
  final IconData? icon;
  final bool destructive;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: destructive
            ? const Color(0xFFFBEAEC)
            : AppColors.accountIconBackground,
        borderRadius: BorderRadius.circular(10.r),
      ),
      alignment: Alignment.center,
      child: iconAsset != null
          ? Image.asset(
              iconAsset!,
              width: iconSize.w,
              height: iconSize.w,
              fit: BoxFit.contain,
            )
          : Icon(
              icon,
              size: iconSize.w,
              color: destructive
                  ? const Color(0xFF9B111E)
                  : const Color(0xFF2E7D32),
            ),
    );
  }
}

class PrivacyFooterBanner extends StatelessWidget {
  const PrivacyFooterBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.accountIconBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppAssets.accountShield,
            width: 18.w,
            height: 18.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              NavigationStrings.privacyFooter,
              style: AppTextStyles.caption(
                color: const Color(0xFF5E7A4E),
              ).copyWith(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PayoutSplitCard extends StatelessWidget {
  const PayoutSplitCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '70 / 30 pay-out split',
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.5.sp,
            ),
          ),
          SizedBox(height: 12.h),
          _PayoutRow(
            label: 'You withdraw',
            value: WalletData.withdrawableBalance,
            valueColor: AppColors.textPrimary,
            valueWeight: FontWeight.w600,
          ),
          _PayoutRow(
            label: 'You receive (70%)',
            value: WalletData.withdrawReceive,
            valueColor: AppColors.successText,
            valueWeight: FontWeight.w700,
          ),
          _PayoutRow(
            label: 'Processing fee (30%)',
            value: WalletData.withdrawFee,
            valueColor: AppColors.textSecondary,
            valueWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

class _PayoutRow extends StatelessWidget {
  const _PayoutRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.valueWeight,
  });

  final String label;
  final String value;
  final Color valueColor;
  final FontWeight valueWeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.labelSmall(
                color: AppColors.textSecondary,
              ).copyWith(fontSize: 12.5.sp, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelMedium(color: valueColor).copyWith(
              fontWeight: valueWeight,
              fontSize: 12.5.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class LightScreenScaffold extends StatelessWidget {
  const LightScreenScaffold({
    super.key,
    required this.title,
    this.body,
    this.children,
    this.bottom,
  });

  final String title;
  final Widget? body;
  final List<Widget>? children;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          NavBackHeader(title: title, backIconColor: AppColors.textPrimary),
          Expanded(
            child: body ??
                ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                  children: children ?? [],
                ),
          ),
          if (bottom != null) bottom!,
        ],
      ),
    );
  }
}
