import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class HelpScreenScaffold extends StatelessWidget {
  const HelpScreenScaffold({
    super.key,
    required this.title,
    required this.body,
    this.banner,
    this.bottomNavIndex = 4,
    this.bottom,
    this.onBack,
  });

  final String title;
  final Widget body;
  final Widget? banner;
  final int bottomNavIndex;
  final Widget? bottom;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(title: title, onBack: onBack),
          if (banner != null) banner!,
          Expanded(child: body),
          if (bottom != null) bottom!,
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: bottomNavIndex),
    );
  }
}

class HelpSectionTitle extends StatelessWidget {
  const HelpSectionTitle({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 15.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 7.w),
        Text(
          label,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class HelpOrderCompactCard extends StatelessWidget {
  const HelpOrderCompactCard({
    super.key,
    required this.order,
    this.actionLabel,
    this.onAction,
  });

  final HelpOrder order;
  final String? actionLabel;
  final VoidCallback? onAction;

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
        children: [
          Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 22.sp,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.vendorName,
                      style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                          .copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      order.subtitle,
                      style: AppTextStyles.caption(color: const Color(0xFF6B7B6E))
                          .copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: onAction,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  actionLabel!,
                  style: AppTextStyles.labelSmall(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class HelpOrderDetailCard extends StatelessWidget {
  const HelpOrderDetailCard({super.key, required this.order});

  final HelpOrder order;

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
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.accountIconBackground,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 24.sp,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.vendorName,
                      style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                          .copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      order.detailSubtitle,
                      style: AppTextStyles.caption(color: const Color(0xFF6B7B6E))
                          .copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColors.accountIconBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              order.deliveredAt,
              style: AppTextStyles.caption(color: const Color(0xFF2E7D32)).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpChevronRow extends StatelessWidget {
  const HelpChevronRow({
    super.key,
    required this.title,
    this.onTap,
    this.leading,
    this.dense = false,
    this.showDivider = true,
  });

  final String title;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool dense;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: Color(0xFFE6EBE3)))
              : null,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                  fontWeight: dense ? FontWeight.w500 : FontWeight.w700,
                  fontSize: dense ? 13.sp : 13.5.sp,
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
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpIssueTile extends StatelessWidget {
  const HelpIssueTile({
    super.key,
    required this.option,
    this.onTap,
    this.showDivider = true,
  });

  final HelpIssueOption option;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: Color(0xFFE6EBE3)))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: option.iconBg,
                borderRadius: BorderRadius.circular(11.r),
              ),
              alignment: Alignment.center,
              child: Icon(option.icon, size: 21.sp, color: option.iconColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                option.title,
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5.sp,
                  height: 1.3,
                ),
              ),
            ),
            Text(
              '›',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFC0C4C1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpInfoBanner extends StatelessWidget {
  const HelpInfoBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      color: const Color(0xFFE8F5E9),
      child: Row(
        children: [
          Text('⏱', style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption(color: const Color(0xFF14532B)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpWarningBanner extends StatelessWidget {
  const HelpWarningBanner({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEFE0),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 20.sp, color: const Color(0xFFE08A1E)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelSmall(color: const Color(0xFFE08A1E)).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  subtitle,
                  style: AppTextStyles.caption(color: const Color(0xFF9A6A1E)).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 10.5.sp,
                    height: 1.3,
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

class HelpCard extends StatelessWidget {
  const HelpCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      child: child,
    );
  }
}

class HelpPhotoUploadBox extends StatelessWidget {
  const HelpPhotoUploadBox({super.key, this.hint = '+ Add photo'});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFB),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFCFD4D0), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            '＋ $hint',
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'JPG/PNG · up to 5MB',
            style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class HelpPrimaryButton extends StatelessWidget {
  const HelpPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.showCheck = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCheck) ...[
                Icon(Icons.check, color: AppColors.white, size: 18.sp),
                SizedBox(width: 8.w),
              ],
              Text(
                label,
                style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpDestructiveButton extends StatelessWidget {
  const HelpDestructiveButton({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFC0392B),
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}

class HelpOutlineButton extends StatelessWidget {
  const HelpOutlineButton({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}

class HelpChipSelector extends StatelessWidget {
  const HelpChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((option) {
        final active = option == selected;
        return GestureDetector(
          onTap: () => onSelected(option),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: active ? AppColors.primary : const Color(0xFFE6EBE3),
              ),
            ),
            child: Text(
              option,
              style: AppTextStyles.labelSmall(
                color: active ? AppColors.white : const Color(0xFF6B7B6E),
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
                height: 1.3,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class HelpItemCheckboxRow extends StatelessWidget {
  const HelpItemCheckboxRow({
    super.key,
    required this.label,
    required this.price,
    required this.checked,
    required this.onChanged,
    this.showDivider = true,
  });

  final String label;
  final String price;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: Color(0xFFE6EBE3)))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: checked ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: checked ? AppColors.primary : const Color(0xFFE6EBE3),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: checked
                  ? Icon(Icons.check, size: 15.sp, color: AppColors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  height: 1.3,
                ),
              ),
            ),
            Text(
              price,
              style: AppTextStyles.labelSmall(color: AppColors.textPrimary).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.5.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpFormHeading extends StatelessWidget {
  const HelpFormHeading({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            height: 1.32,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 6.h),
          Text(
            subtitle!,
            style: AppTextStyles.labelSmall(color: const Color(0xFF6B7B6E)).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 12.5.sp,
              height: 1.32,
            ),
          ),
        ],
      ],
    );
  }
}

class HelpNoteField extends StatelessWidget {
  const HelpNoteField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: 3,
          style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(color: const Color(0xFF9AA89C)).copyWith(
              fontSize: 13.sp,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.all(14.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE6EBE3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE6EBE3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class HelpRefundSummaryCard extends StatelessWidget {
  const HelpRefundSummaryCard({super.key});

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
        children: [
          _row('Order total', 'BHD 33.000'),
          SizedBox(height: 10.h),
          _row('Cancellation fee', '-BHD 17.000', valueColor: const Color(0xFFC0392B)),
          SizedBox(height: 10.h),
          const Divider(height: 1, color: Color(0xFFE6EBE3)),
          SizedBox(height: 10.h),
          _row('Refund to you', 'BHD 17.000', bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall(color: const Color(0xFF6B7B6E)).copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium(color: valueColor ?? AppColors.textPrimary)
              .copyWith(
            fontSize: 13.sp,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
