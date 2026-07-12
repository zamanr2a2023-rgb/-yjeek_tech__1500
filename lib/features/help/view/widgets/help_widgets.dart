import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class HelpScreenScaffold extends StatelessWidget {
  const HelpScreenScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.banner,
    this.bottomNavIndex = 4,
    this.bottom,
    this.onBack,
    this.showBottomNav = true,
    this.darkTitle = false,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? banner;
  final int bottomNavIndex;
  final Widget? bottom;
  final VoidCallback? onBack;
  final bool showBottomNav;
  final bool darkTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(
            title: title,
            subtitle: subtitle,
            onBack: onBack,
            darkTitle: darkTitle,
          ),
          if (banner != null) banner!,
          Expanded(child: body),
          if (bottom != null) bottom!,
        ],
      ),
      bottomNavigationBar:
          showBottomNav ? ShellBottomNavBar(currentIndex: bottomNavIndex) : null,
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
    this.subtitle,
    this.iconAsset = 'assets/Frame (27).png',
    this.actionLabel,
    this.onAction,
  });

  final HelpOrder order;
  final String? subtitle;
  final String iconAsset;
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
                child: Image.asset(
                  iconAsset,
                  width: 22.sp,
                  height: 22.sp,
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
                      subtitle ?? order.subtitle,
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
                child: Image.asset(
                  'assets/Frame (27).png',
                  width: 24.sp,
                  height: 24.sp,
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
    this.expanded = false,
  });

  final String title;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool dense;
  final bool showDivider;
  final bool expanded;

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
                  fontWeight: dense ? FontWeight.w700 : FontWeight.w700,
                  fontSize: dense ? 13.sp : 13.5.sp,
                  height: 1.3,
                ),
              ),
            ),
            Icon(
              expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              size: 18.sp,
              color: const Color(0xFF6B7B6E),
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
              child: Image.asset(
                option.image,
                width: 21.sp,
                height: 21.sp,
              ),
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
  const HelpInfoBanner({
    super.key,
    required this.message,
    this.icon = '⏱',
    this.borderRadius,
  });

  final String message;
  final String icon;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 10.w),
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
          Icon(Icons.schedule, size: 20.sp, color: const Color(0xFFE08A1E)),
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
  const HelpPhotoUploadBox({
    super.key,
    this.hint = 'Add photo',
    this.subtitle = 'JPG/PNG · up to 5MB',
  });

  final String hint;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFB),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: CustomPaint(
        foregroundPainter: _HelpDashedBorderPainter(
          color: const Color(0xFFCFD4D0),
          radius: 14.r,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
          child: Column(
            children: [
              Text(
                '＋ $hint',
                style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: AppTextStyles.caption(color: const Color(0xFF6B7280)).copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
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
    this.inline = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool showCheck;
  final bool inline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: inline
          ? EdgeInsets.only(top: 16.h)
          : EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
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
  const HelpDestructiveButton({
    super.key,
    required this.label,
    this.onTap,
    this.inline = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool inline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: inline
          ? EdgeInsets.only(top: 16.h)
          : EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFFC62828),
            borderRadius: BorderRadius.circular(16.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15.5.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class HelpOutlineButton extends StatelessWidget {
  const HelpOutlineButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.primary, width: 1.4),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpMultiChipSelector extends StatelessWidget {
  const HelpMultiChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((option) {
        final active = selected.contains(option);
        return GestureDetector(
          onTap: () {
            final next = Set<String>.from(selected);
            if (active) {
              next.remove(option);
            } else {
              next.add(option);
            }
            onChanged(next);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: active ? AppColors.primary : const Color(0xFFD7DDD6),
                width: 1.2,
              ),
            ),
            child: Text(
              option,
              style: AppTextStyles.labelSmall(
                color: active ? AppColors.white : const Color(0xFF404842),
              ).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.5.sp,
                height: 1.2,
              ),
            ),
          ),
        );
      }).toList(),
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
  });

  final String label;
  final String price;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE6EBE3)),
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
    this.maxLines = 3,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : null,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Refund summary',
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.5.sp,
            ),
          ),
          SizedBox(height: 12.h),
          _row('Order total', 'BHD 35.800'),
          SizedBox(height: 10.h),
          _row(
            'Cancellation fee (up to 50%)',
            '− BHD 17.900',
            valueColor: const Color(0xFFC0392B),
          ),
          SizedBox(height: 10.h),
          const Divider(height: 1, color: Color(0xFFE6EBE3)),
          SizedBox(height: 10.h),
          _row(
            'Refund to you',
            'BHD 17.900',
            valueColor: AppColors.successText,
            bold: true,
          ),
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
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium(color: valueColor ?? AppColors.textPrimary)
              .copyWith(
            fontSize: 12.5.sp,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class HelpOrangeButton extends StatelessWidget {
  const HelpOrangeButton({super.key, required this.label, this.onTap});

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
          color: const Color(0xFFE08A1E),
          borderRadius: BorderRadius.circular(13.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }
}

class HelpAlertCard extends StatelessWidget {
  const HelpAlertCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.schedule,
    this.iconAsset,
    this.backgroundColor = const Color(0xFFFBEFE0),
    this.foregroundColor = const Color(0xFFE08A1E),
    this.subtitleColor = const Color(0xFF9A6A1E),
    this.borderColor,
    this.iconBackgroundColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? iconAsset;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color subtitleColor;
  final Color? borderColor;
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor ?? backgroundColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (iconAsset != null || iconBackgroundColor != null)
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? foregroundColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: iconAsset != null
                      ? Image.asset(iconAsset!, width: 22.sp, height: 22.sp)
                      : Icon(icon, size: 20.sp, color: AppColors.white),
                )
              else
                Icon(icon, size: 20.sp, color: foregroundColor),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMedium(color: foregroundColor).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: AppTextStyles.caption(color: subtitleColor).copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class HelpStarRating extends StatelessWidget {
  const HelpStarRating({
    super.key,
    required this.rating,
    required this.onChanged,
    this.label,
    this.labelColor,
  });

  final int rating;
  final ValueChanged<int> onChanged;
  final String? label;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            final filled = index < rating;
            return GestureDetector(
              onTap: () => onChanged(index + 1),
              child: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 30.sp,
                  color: filled ? const Color(0xFFF5A623) : const Color(0xFFC9CFC9),
                ),
              ),
            );
          }),
        ),
        if (label != null) ...[
          SizedBox(height: 10.h),
          Text(
            label!,
            style: AppTextStyles.caption(
              color: labelColor ?? const Color(0xFF6B7B6E),
            ).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12.5.sp,
            ),
          ),
        ],
      ],
    );
  }
}

class HelpRadioOptionRow extends StatelessWidget {
  const HelpRadioOptionRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.highlightBorder = false,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool highlightBorder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: highlightBorder && selected
              ? const Color(0xFFF1FAF1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: highlightBorder && selected
                ? AppColors.primary
                : const Color(0xFFE6EBE3),
            width: highlightBorder && selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : const Color(0xFFCFD4D0),
                  width: 1.6,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5.sp,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption(color: const Color(0xFF6B7280)).copyWith(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpDetailRowsCard extends StatelessWidget {
  const HelpDetailRowsCard({
    super.key,
    this.title,
    required this.lines,
    this.trailing,
    this.showDividers = false,
    this.footer,
    this.dividerColor = const Color(0xFFF0F0F0),
  });

  final String? title;
  final List<HelpDetailLine> lines;
  final Widget? trailing;
  final bool showDividers;
  final String? footer;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.5.sp,
              ),
            ),
            SizedBox(height: 12.h),
          ],
          if (trailing != null) ...[trailing!, SizedBox(height: 12.h)],
          for (var i = 0; i < lines.length; i++) ...[
            if (showDividers && i > 0)
              Divider(
                height: 10.h,
                thickness: 1,
                color: dividerColor,
              )
            else if (!showDividers && i > 0)
              SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    lines[i].label,
                    style: AppTextStyles.labelSmall(color: const Color(0xFF6B7B6E)).copyWith(
                      fontSize: 12.5.sp,
                    ),
                  ),
                ),
                Text(
                  lines[i].value,
                  style: AppTextStyles.labelMedium(
                    color: lines[i].valueColor ?? AppColors.textPrimary,
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5.sp,
                  ),
                ),
              ],
            ),
          ],
          if (footer != null) ...[
            SizedBox(height: 10.h),
            Text(
              footer!,
              style: AppTextStyles.caption(color: const Color(0xFF6B7280)).copyWith(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class HelpAutomaticCheckCard extends StatelessWidget {
  const HelpAutomaticCheckCard({super.key, required this.items});

  final List<({String label, bool passed})> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: items[i].passed
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFDECEC),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    items[i].passed ? '✓' : '✕',
                    style: AppTextStyles.labelSmall(
                      color: items[i].passed
                          ? const Color(0xFF1D8A3E)
                          : const Color(0xFFC62828),
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      height: 1,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    items[i].label,
                    style: AppTextStyles.caption(color: const Color(0xFF3D4842)).copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class HelpSearchField extends StatelessWidget {
  const HelpSearchField({super.key, this.hint = 'Search help topics…'});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18.sp, color: const Color(0xFF6B7B6E)),
          SizedBox(width: 10.w),
          Text(
            hint,
            style: AppTextStyles.bodyMedium(color: const Color(0xFF9AA89C)).copyWith(
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class HelpChatBubble extends StatelessWidget {
  const HelpChatBubble({super.key, required this.message});

  final HelpChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      final isJoin = message.isAgentJoin;
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isJoin ? const Color(0xFFEDE7F6) : const Color(0xFFDFE6DD),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              message.text,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(
                color: isJoin ? const Color(0xFF5A45B0) : const Color(0xFF5B6B58),
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 10.5.sp,
              ),
            ),
          ),
        ),
      );
    }

    final isUser = message.isUser;
    final isMaryam = message.isAgentMaryam;
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: 270.w),
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: isUser ? null : Border.all(color: const Color(0xFFE3E8E0)),
      ),
      child: Text(
        message.text,
        style: AppTextStyles.labelSmall(
          color: isUser ? AppColors.white : const Color(0xFF25302B),
        ).copyWith(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          height: 16 / 13,
        ),
      ),
    );

    if (isUser) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Align(alignment: Alignment.centerRight, child: bubble),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: isMaryam ? const Color(0xFFEDE7F6) : AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              message.avatarLabel,
              style: AppTextStyles.labelSmall(
                color: isMaryam ? const Color(0xFF6A3AA0) : AppColors.white,
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class HelpChatInputBar extends StatelessWidget {
  const HelpChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 12.w, 12.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8DD))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 36.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5F1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Message…',
                  style: AppTextStyles.bodyMedium(color: const Color(0xFF9AA09B))
                      .copyWith(fontSize: 13.sp),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.send_rounded, size: 18.sp, color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpNumberedStep extends StatelessWidget {
  const HelpNumberedStep({
    super.key,
    required this.number,
    required this.text,
    this.title,
  });

  final int number;
  final String text;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26.w,
          height: 26.w,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: AppTextStyles.labelSmall(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12.5.sp,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: title == null
              ? Text(
                  text,
                  style: AppTextStyles.labelSmall(color: AppColors.textPrimary).copyWith(
                    fontSize: 12.5.sp,
                    height: 1.35,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      text,
                      style: AppTextStyles.caption(color: const Color(0xFF6B7280)).copyWith(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class HelpSuccessCircle extends StatelessWidget {
  const HelpSuccessCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88.w,
      height: 88.w,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.check_rounded, size: 44.sp, color: AppColors.white),
    );
  }
}

class HelpPhotoUploadBoxRed extends StatelessWidget {
  const HelpPhotoUploadBoxRed({
    super.key,
    this.hint = 'Add photos',
    this.subtitle = 'Required · JPG/PNG · up to 5MB',
  });

  final String hint;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFB),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: CustomPaint(
        foregroundPainter: _HelpDashedBorderPainter(
          color: const Color(0xFFC62828),
          radius: 14.r,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
          child: Column(
            children: [
              Text(
                '＋ $hint',
                style: AppTextStyles.labelMedium(color: const Color(0xFFC62828)).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: AppTextStyles.caption(color: const Color(0xFF6B7280)).copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpDashedBorderPainter extends CustomPainter {
  _HelpDashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final inset = paint.strokeWidth / 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2),
          Radius.circular(radius),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
