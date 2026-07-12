import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_strings.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          AppStrings.arabic,
          style: AppTextStyles.labelMedium(color: AppColors.primary),
        ),
      ),
    );
  }
}

class YjeekLogo extends StatelessWidget {
  const YjeekLogo({
    super.key,
    this.compact = false,
    this.color = AppColors.white,
  });

  final bool compact;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Image.asset(
        AppAssets.nameLogo,
        height: 28,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    }

    return Image.asset(
      AppAssets.nameLogo,
      width: 216,
      height: 170,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.high,
    );
  }
}

class AuthScreenScaffold extends StatelessWidget {
  const AuthScreenScaffold({
    super.key,
    required this.body,
    this.bottomBar,
    this.showLanguageToggle = false,
    this.showBackButton = false,
    this.scrollable = false,
    this.onBack,
  });

  final Widget body;
  final Widget? bottomBar;
  final bool showLanguageToggle;
  final bool showBackButton;
  final bool scrollable;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Row(
                children: [
                  if (showBackButton)
                    IconButton(
                      onPressed: onBack ?? () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      color: AppColors.textPrimary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    const YjeekLogo(compact: true),
                  const Spacer(),
                  if (showLanguageToggle) const LanguageToggle(),
                ],
              ),
            ),
            Expanded(
              child: scrollable
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        const padding = EdgeInsets.fromLTRB(24, 20, 24, 30);
                        return SingleChildScrollView(
                          padding: padding,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - padding.vertical,
                            ),
                            child: body,
                          ),
                        );
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                      child: body,
                    ),
            ),
            if (bottomBar != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                child: bottomBar!,
              ),
          ],
        ),
      ),
    );
  }
}

class WelcomeActionCard extends StatelessWidget {
  const WelcomeActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String title;
  final Widget icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.white,
          border: isPrimary ? null : Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPrimary ? AppColors.white : AppColors.iconBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleSmall(
                  color: isPrimary ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '›',
              style: AppTextStyles.titleSmall(
                color: isPrimary ? AppColors.white : AppColors.textSecondary,
              ).copyWith(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1.4)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: AppTextStyles.caption(),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1.4)),
      ],
    );
  }
}

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -1.57,
      1.57,
      true,
      paint,
    );
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0.78,
      1.57,
      true,
      paint,
    );
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      2.35,
      1.57,
      true,
      paint,
    );
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      3.92,
      1.57,
      true,
      paint,
    );
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.28, paint);
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.45, size.height * 0.42, size.width * 0.55, size.height * 0.16),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
