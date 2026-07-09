import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = NavigationStrings.english;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(title: NavigationStrings.language),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFE6EBE3)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _LanguageRow(
                        label: NavigationStrings.english,
                        selected: _selected == NavigationStrings.english,
                        onTap: () => setState(() => _selected = NavigationStrings.english),
                      ),
                      const Divider(height: 1, color: Color(0xFFE6EBE3)),
                      _LanguageRow(
                        label: NavigationStrings.arabic,
                        selected: _selected == NavigationStrings.arabic,
                        onTap: () => setState(() => _selected = NavigationStrings.arabic),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                PrimaryGreenButton(
                  label: NavigationStrings.apply,
                  backgroundColor: AppColors.primary,
                  borderRadius: 13,
                  height: 49,
                  icon: Icons.check,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: AppColors.accountIconBackground,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  AppAssets.accountGlobe,
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5.sp,
                    height: 1.3,
                  ),
                ),
              ),
              _LanguageRadio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageRadio extends StatelessWidget {
  const _LanguageRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFD6DED6),
          width: selected ? 6.5 : 1.5,
        ),
      ),
    );
  }
}
