import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_strings.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/widgets/custom_button.dart';
import 'package:yjeek_app/features/auth/view/widgets/auth_widgets.dart';
import 'package:yjeek_app/features/auth/view/widgets/otp_input.dart';
import 'package:yjeek_app/routes/route_names.dart';

enum OtpScreenState { normal, wrongCode, resent, blocked }

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  OtpScreenState _state = OtpScreenState.normal;
  int _attemptsLeft = 3;
  int _resendSeconds = 24;
  int _blockSeconds = 299;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _otpController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    _resendSeconds = 24;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
        setState(() {});
      }
    });
  }

  void _startBlockTimer() {
    _timer?.cancel();
    _blockSeconds = 299;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_blockSeconds > 0) {
        setState(() => _blockSeconds--);
      } else {
        timer.cancel();
        setState(() {
          _state = OtpScreenState.normal;
          _attemptsLeft = 3;
          _otpController.clear();
        });
        _startResendTimer();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _verify(String code) {
    if (_state == OtpScreenState.blocked) return;

    if (code == AppStrings.wrongOtpDemo) {
      setState(() {
        _attemptsLeft--;
        if (_attemptsLeft <= 0) {
          _state = OtpScreenState.blocked;
          _startBlockTimer();
        } else {
          _state = OtpScreenState.wrongCode;
        }
      });
      return;
    }

    if (code.length == 4) {
      Navigator.pushReplacementNamed(context, RouteNames.home);
    }
  }

  void _resendCode() {
    if (_resendSeconds > 0 || _state == OtpScreenState.blocked) return;
    setState(() {
      _state = OtpScreenState.resent;
      _otpController.clear();
    });
    _startResendTimer();
  }

  String get _buttonLabel {
    if (_state == OtpScreenState.wrongCode) return AppStrings.tryAgain;
    if (_state == OtpScreenState.blocked) return AppStrings.verify;
    return AppStrings.verifyAndContinue;
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = _state == OtpScreenState.blocked;
    final hasError = _state == OtpScreenState.wrongCode;

    return AuthScreenScaffold(
      scrollable: true,
      bottomBar: CustomButton(
        label: _buttonLabel,
        enabled: !isBlocked && _otpController.text.length == 4,
        onPressed: () => _verify(_otpController.text),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.verifyTitle, style: AppTextStyles.displayMedium()),
          const SizedBox(height: 10),
          Text(
            AppStrings.verifySubtitle(widget.phoneNumber),
            style: AppTextStyles.bodyMedium(),
          ),
          const SizedBox(height: 10),
          OtpInputRow(
            controller: _otpController,
            length: 4,
            error: hasError,
            disabled: isBlocked,
            onCompleted: _verify,
          ),
          const SizedBox(height: 8),
          if (_state == OtpScreenState.resent)
            const StatusBanner.success(message: AppStrings.newCodeSent),
          if (hasError)
            StatusBanner.error(
              message: AppStrings.incorrectCode(_attemptsLeft),
            ),
          if (isBlocked) BlockedBanner(remaining: _formatTime(_blockSeconds)),
          const SizedBox(height: 8),
          if (!isBlocked && _resendSeconds > 0)
            Row(
              children: [
                Text(
                  '${AppStrings.resendCodeIn} ',
                  style: AppTextStyles.bodySmall(),
                ),
                Text(
                  _formatTime(_resendSeconds),
                  style: AppTextStyles.labelMedium(color: AppColors.primary),
                ),
              ],
            )
          else if (!isBlocked)
            Row(
              children: [
                GestureDetector(
                  onTap: _resendCode,
                  child: Text(
                    AppStrings.resendCode,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.primary,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(' · ', style: AppTextStyles.labelMedium()),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    AppStrings.changeNumber,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.primary,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                AppStrings.changeNumber,
                style: AppTextStyles.labelMedium(
                  color: AppColors.primary,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}
