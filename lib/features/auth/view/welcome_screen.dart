import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_strings.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/features/auth/view/widgets/auth_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      showLanguageToggle: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.welcomeTitle, style: AppTextStyles.displayLarge()),
          const SizedBox(height: 8),
          Text(AppStrings.welcomeSubtitle, style: AppTextStyles.bodyMedium()),
          const Spacer(),
          WelcomeActionCard(
            title: AppStrings.browseAsGuest,
            icon: const Icon(Icons.explore_outlined, color: Color(0xFF4CAF50), size: 28),
            onTap: () => Navigator.pushReplacementNamed(context, RouteNames.home),
          ),
          const SizedBox(height: 12),
          WelcomeActionCard(
            title: AppStrings.loginOrSignUp,
            isPrimary: true,
            icon: const Icon(Icons.login_rounded, color: Color(0xFF4CAF50), size: 28),
            onTap: () => Navigator.pushNamed(context, RouteNames.phoneLogin),
          ),
          // const SizedBox(height: 40),
          Spacer(),
        ],
      ),
    );
  }
}
