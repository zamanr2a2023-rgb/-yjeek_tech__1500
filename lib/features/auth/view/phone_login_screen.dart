import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_strings.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/widgets/custom_button.dart';
import 'package:yjeek_app/features/auth/view/widgets/auth_widgets.dart';
import 'package:yjeek_app/features/auth/view/widgets/otp_input.dart';
import 'package:yjeek_app/features/auth/view/widgets/terms_bottom_sheet.dart';
import 'package:yjeek_app/routes/route_names.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canSendCode =>
      _termsAccepted && _phoneController.text.trim().length >= 8;

  String get _formattedPhone {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return digits;
    return '${digits.substring(0, 4)} ${digits.substring(4)}';
  }

  void _sendCode() {
    if (!_canSendCode) return;
    Navigator.pushNamed(
      context,
      RouteNames.otpVerify,
      arguments: '${AppStrings.countryCode} $_formattedPhone',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.enterPhoneTitle,
            style: AppTextStyles.displayMedium(),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.enterPhoneSubtitle,
            style: AppTextStyles.bodyMedium(),
          ),
          const SizedBox(height: 24),
          PhoneNumberField(controller: _phoneController, enabled: true),
          const SizedBox(height: 48),
          TermsCheckboxRow(
            checked: _termsAccepted,
            onChanged: (value) => setState(() => _termsAccepted = value),
            onTermsTap: () {
              TermsBottomSheet.show(
                context,
                onAgree: () => setState(() => _termsAccepted = true),
              );
            },
          ),
          const SizedBox(height: 12),
          CustomButton(
            label: AppStrings.sendCode,
            enabled: _canSendCode,
            onPressed: _sendCode,
          ),
          const SizedBox(height: 16),
          const OrDivider(),
          const SizedBox(height: 16),
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
            leading: const Icon(Icons.apple, color: Colors.white, size: 22),
            onPressed: () {},
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
