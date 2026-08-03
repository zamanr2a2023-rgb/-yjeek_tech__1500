import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class ChangePhoneScreen extends ConsumerStatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  ConsumerState<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends ConsumerState<ChangePhoneScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _busy = false;
  String? _devCode;
  static const _countryCode = '+973';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
      );
      return;
    }

    setState(() => _busy = true);
    final response = await ref.read(userRepositoryProvider).requestPhoneChange(
          phone: phone,
          countryCode: _countryCode,
        );
    if (!mounted) return;
    setState(() => _busy = false);

    if (response.ok) {
      setState(() {
        _otpSent = true;
        _devCode = response.data?['devCode']?.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _devCode != null
                ? 'Code sent (dev: $_devCode)'
                : (response.message ?? 'Verification code sent'),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? 'Could not send code'),
        backgroundColor: const Color(0xFFB42318),
      ),
    );
  }

  Future<void> _confirmOtp() async {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final code = _otpController.text.trim();
    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 4-digit code')),
      );
      return;
    }

    setState(() => _busy = true);
    final response = await ref.read(userRepositoryProvider).confirmPhoneChange(
          phone: phone,
          code: code,
          countryCode: _countryCode,
        );
    if (!mounted) return;
    setState(() => _busy = false);

    if (response.ok) {
      ref.invalidate(userMeProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number updated')),
      );
      if (context.canPop()) context.pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? 'Verification failed'),
        backgroundColor: const Color(0xFFB42318),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(title: NavigationStrings.changePhone),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
              children: [
                Text(
                  _otpSent
                      ? 'Enter the code sent to $_countryCode ${_phoneController.text}'
                      : 'Enter your new Bahrain mobile number. We’ll send a verification code.',
                  style: AppTextStyles.labelMedium(
                    color: const Color(0xFF6B756E),
                  ).copyWith(fontSize: 13.sp, height: 1.35),
                ),
                SizedBox(height: 18.h),
                if (!_otpSent) ...[
                  AccountFormField(
                    label: 'New phone number',
                    controller: _phoneController,
                    readOnly: false,
                    keyboardType: TextInputType.phone,
                    hintText: '3300 0000',
                    suffix: Text(
                      _countryCode,
                      style: AppTextStyles.labelSmall(
                        color: const Color(0xFF6B756E),
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  PrimaryGreenButton(
                    label: _busy ? 'Sending…' : 'Send code',
                    enabled: !_busy,
                    height: 50,
                    onPressed: _busy ? null : _requestOtp,
                  ),
                ] else ...[
                  AccountFormField(
                    label: 'Verification code',
                    controller: _otpController,
                    readOnly: false,
                    keyboardType: TextInputType.number,
                    hintText: '4-digit code',
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _busy ? null : _requestOtp,
                      child: const Text('Resend code'),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  PrimaryGreenButton(
                    label: _busy ? 'Verifying…' : 'Confirm new number',
                    enabled: !_busy,
                    height: 50,
                    onPressed: _busy ? null : _confirmOtp,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }
}
