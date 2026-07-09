import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_strings.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/widgets/custom_button.dart';

class TermsBottomSheet extends StatelessWidget {
  const TermsBottomSheet({super.key, this.onAgree});

  final VoidCallback? onAgree;

  static Future<void> show(BuildContext context, {VoidCallback? onAgree}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!context.mounted) return;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: AppStrings.termsTitle,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TermsBottomSheet(
              onAgree: () {
                onAgree?.call();
                Navigator.of(dialogContext).pop();
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.74;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD9DBD9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.termsTitle,
                          style: AppTextStyles.titleMedium(),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.termsCompany,
                          style: AppTextStyles.labelSmall(),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      '✕',
                      style: AppTextStyles.titleSmall(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFE6E8E6), height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _TermsIntro(),
                    SizedBox(height: 12),
                    _Article(
                      title: AppStrings.article1Title,
                      body: AppStrings.article1Body,
                    ),
                    SizedBox(height: 12),
                    _Article(
                      title: AppStrings.article2Title,
                      body: AppStrings.article2Body,
                    ),
                    SizedBox(height: 12),
                    _Article(
                      title: AppStrings.article3Title,
                      body: AppStrings.article3Body,
                    ),
                    SizedBox(height: 12),
                    _Article(
                      title: AppStrings.article4Title,
                      body: AppStrings.article4Body,
                    ),
                    SizedBox(height: 12),
                    _Article(
                      title: AppStrings.article5Title,
                      body: AppStrings.article5Body,
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const Divider(color: Color(0xFFE6E8E6), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
              child: Column(
                children: [
                  CustomButton(
                    label: AppStrings.iAgree,
                    onPressed: onAgree,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppStrings.close,
                      style: AppTextStyles.labelMedium(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsIntro extends StatelessWidget {
  const _TermsIntro();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.termsIntro,
      style: AppTextStyles.labelSmall(),
    );
  }
}

class _Article extends StatelessWidget {
  const _Article({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelSmall(
            color: AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: AppTextStyles.labelSmall(
            color: AppColors.bodyText,
          ).copyWith(height: 1.44),
        ),
      ],
    );
  }
}
