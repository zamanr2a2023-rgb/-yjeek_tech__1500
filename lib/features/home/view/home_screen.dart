import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/widgets/custom_button.dart';
import 'package:yjeek_app/features/auth/view/widgets/checkout_login_sheet.dart';
import 'package:yjeek_app/routes/route_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Yjeek', style: AppTextStyles.titleSmall(color: AppColors.primary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, RouteNames.welcome),
            child: Text('Logout', style: AppTextStyles.labelMedium(color: AppColors.primary)),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You are in!', style: AppTextStyles.displayMedium()),
              const SizedBox(height: 8),
              Text(
                'Browse the app or try the checkout login flow.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Preview checkout login',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const _CheckoutPreviewPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutPreviewPage extends StatefulWidget {
  const _CheckoutPreviewPage();

  @override
  State<_CheckoutPreviewPage> createState() => _CheckoutPreviewPageState();
}

class _CheckoutPreviewPageState extends State<_CheckoutPreviewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CheckoutLoginSheet.show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BasketPreviewBackground(child: SizedBox.expand()),
    );
  }
}
