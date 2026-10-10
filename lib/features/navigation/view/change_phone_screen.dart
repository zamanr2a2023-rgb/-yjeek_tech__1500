import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/ltr_phone_text.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/l10n/l10n.dart';

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
        SnackBar(content: Text(NavigationStrings.enterValidPhone)),
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
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message ?? NavigationStrings.verificationCodeSent,
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? L10n.tr('Could not send code')),
        backgroundColor: const Color(0xFFB42318),
      ),
    );
  }

  Future<void> _confirmOtp() async {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final code = _otpController.text.trim();
    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(NavigationStrings.enterFourDigitCode)),
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
        SnackBar(content: Text(NavigationStrings.phoneNumberUpdated)),
      );
      if (context.canPop()) context.pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? L10n.tr('Verification failed')),
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
                      ? NavigationStrings.changePhoneCodeSent(
                          _countryCode,
                          _phoneController.text,
                        )
                      : NavigationStrings.changePhoneIntro,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.labelMedium(
                    color: const Color(0xFF6B756E),
                  ).copyWith(fontSize: 13.sp, height: 1.35),
                ),
                SizedBox(height: 18.h),
                if (!_otpSent) ...[
                  Text(
                    NavigationStrings.newPhoneNumber,
                    style: AppTextStyles.labelSmall(
                      color: const Color(0xFF6B7B6E),
                    ).copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 7.h),
                  Container(
                    height: 44.h,
                    padding: EdgeInsets.symmetric(horizontal: 13.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(11.r),
                      border: Border.all(
                        color: const Color(0xFFE6EBE3),
                        width: 1.2,
                      ),
                    ),
                    alignment: AlignmentDirectional.centerStart,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          LtrPhoneText(
                            '$_countryCode ',
                            style: AppTextStyles.bodyMedium(
                              color: const Color(0xFF6B756E),
                            ).copyWith(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              style: AppTextStyles.bodyMedium(
                                color: const Color(0xFF1A1A1A),
                              ).copyWith(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: '3300 0000',
                                hintStyle: AppTextStyles.bodyMedium(
                                  color: const Color(0xFF9AA39A),
                                ).copyWith(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  PrimaryGreenButton(
                    label: _busy
                        ? NavigationStrings.sending
                        : NavigationStrings.sendCode,
                    enabled: !_busy,
                    height: 50,
                    onPressed: _busy ? null : _requestOtp,
                  ),
                ] else ...[
                  AccountFormField(
                    label: NavigationStrings.verificationCode,
                    controller: _otpController,
                    readOnly: false,
                    keyboardType: TextInputType.number,
                    ltrValue: true,
                    hintText: NavigationStrings.fourDigitCode,
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: _busy ? null : _requestOtp,
                      child: Text(NavigationStrings.resendCode),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  PrimaryGreenButton(
                    label: _busy
                        ? NavigationStrings.verifying
                        : NavigationStrings.confirmNewNumber,
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
