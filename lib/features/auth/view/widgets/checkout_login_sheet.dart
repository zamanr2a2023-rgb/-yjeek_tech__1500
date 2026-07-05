import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_strings.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/widgets/custom_button.dart';
import 'package:yjeek_app/features/auth/view/widgets/auth_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class CheckoutLoginSheet extends StatelessWidget {
  const CheckoutLoginSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CheckoutLoginSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: AppColors.overlay),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outline, color: AppColors.white, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppStrings.checkoutLoginTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.checkoutLoginSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall(),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    label: AppStrings.continueWithPhone,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RouteNames.phoneLogin);
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    label: AppStrings.continueWithGoogle,
                    variant: AppButtonVariant.outlined,
                    leading: const GoogleLogo(),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    label: AppStrings.continueWithApple,
                    variant: AppButtonVariant.apple,
                    leading: const Icon(Icons.apple, color: AppColors.white, size: 22),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    label: AppStrings.keepBrowsing,
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BasketPreviewBackground extends StatelessWidget {
  const BasketPreviewBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.45,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.yourBasket, style: AppTextStyles.titleLarge(color: AppColors.primary).copyWith(fontSize: 20)),
                        const YjeekLogo(compact: true),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(3, (_) => const _BasketSkeletonItem()),
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _BasketSkeletonItem extends StatelessWidget {
  const _BasketSkeletonItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.skeleton,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 140,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.skeleton,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 90,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.skeletonLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
