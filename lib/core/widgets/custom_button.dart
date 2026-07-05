import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';

enum AppButtonVariant { primary, outlined, apple, ghost }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: _textStyle(),
          ),
        ),
        ?trailing,
      ],
    );

    final borderRadius = BorderRadius.circular(28);

    switch (variant) {
      case AppButtonVariant.primary:
        return SizedBox(
          width: expand ? double.infinity : null,
          height: 55,
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
              foregroundColor: AppColors.white,
              disabledForegroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
            ),
            child: child,
          ),
        );
      case AppButtonVariant.outlined:
        return SizedBox(
          width: expand ? double.infinity : null,
          height: 55,
          child: OutlinedButton(
            onPressed: enabled ? onPressed : null,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border, width: 1.4),
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
            ),
            child: child,
          ),
        );
      case AppButtonVariant.apple:
        return SizedBox(
          width: expand ? double.infinity : null,
          height: 55,
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appleBlack,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
            ),
            child: child,
          ),
        );
      case AppButtonVariant.ghost:
        return SizedBox(
          width: expand ? double.infinity : null,
          height: 55,
          child: TextButton(
            onPressed: enabled ? onPressed : null,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius,
                side: const BorderSide(color: AppColors.border, width: 1.5),
              ),
            ),
            child: Text(label, style: AppTextStyles.labelLarge(color: AppColors.textPrimary)),
          ),
        );
    }
  }

  TextStyle _textStyle() {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.apple:
        return AppTextStyles.labelLarge();
      case AppButtonVariant.outlined:
        return AppTextStyles.bodyLarge(color: AppColors.textPrimary).copyWith(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        );
      case AppButtonVariant.ghost:
        return AppTextStyles.labelLarge(color: AppColors.textPrimary);
    }
  }
}
