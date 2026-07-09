import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';

abstract final class AppTextStyles {
  static TextStyle get _base => GoogleFonts.inter();

  static TextStyle displayLarge({Color? color}) => _base.copyWith(
        fontSize: 27.sp,
        fontWeight: FontWeight.w700,
        height: 1.32,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle displayMedium({Color? color}) => _base.copyWith(
        fontSize: 25.sp,
        fontWeight: FontWeight.w700,
        height: 1.32,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle titleLarge({Color? color}) => _base.copyWith(
        fontSize: 21.sp,
        fontWeight: FontWeight.w700,
        height: 1.32,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle titleMedium({Color? color}) => _base.copyWith(
        fontSize: 19.sp,
        fontWeight: FontWeight.w700,
        height: 1.21,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle titleSmall({Color? color}) => _base.copyWith(
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        height: 1.32,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle bodyLarge({Color? color}) => _base.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        height: 1.32,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle bodyMedium({Color? color}) => _base.copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        height: 1.32,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle bodySmall({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        height: 1.32,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle labelLarge({Color? color}) => _base.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        height: 1.32,
        color: color ?? AppColors.white,
      );

  static TextStyle labelMedium({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 1.32,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle labelSmall({Color? color}) => _base.copyWith(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w500,
        height: 1.32,
        color: color ?? AppColors.textMuted,
      );

  static TextStyle caption({Color? color}) => _base.copyWith(
        fontSize: 11.5.sp,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: color ?? AppColors.dividerText,
      );

  static TextStyle otpDigit({Color? color}) => _base.copyWith(
        fontSize: 26.sp,
        fontWeight: FontWeight.w700,
        height: 1.32,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle logoArabic({Color? color}) => _base.copyWith(
        fontSize: 42.sp,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: color ?? AppColors.white,
      );

  static TextStyle logoEnglish({Color? color}) => _base.copyWith(
        fontSize: 48.sp,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: color ?? AppColors.white,
      );
}
