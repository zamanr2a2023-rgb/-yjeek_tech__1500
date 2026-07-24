import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_strings.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/widgets/custom_button.dart';
import 'package:yjeek_app/features/auth/view/widgets/auth_widgets.dart';
import 'package:yjeek_app/features/auth/view/widgets/otp_input.dart';
import 'package:yjeek_app/routes/app_router.dart';

enum OtpScreenState { normal, wrongCode, resent, blocked }

class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.phoneNumber,
    this.phoneDigits = '',
    this.expiresInSeconds = 300,
  });

  /// Display form, e.g. `+973 3300 0000`.
  final String phoneNumber;

  /// Local digits sent to the API, e.g. `33000001`.
  final String phoneDigits;
  final int expiresInSeconds;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  OtpScreenState _state = OtpScreenState.normal;
  int _attemptsLeft = 3;
  late int _resendSeconds;
  int _blockSeconds = 299;
  bool _verifying = false;
  String? _responseMessage;
  Timer? _timer;

  String get _apiPhone => widget.phoneDigits.isNotEmpty
      ? widget.phoneDigits
      : widget.phoneNumber
          .replaceAll(AppStrings.countryCode, '')
          .replaceAll(RegExp(r'\D'), '');

  @override
  void initState() {
    super.initState();
    _startResendTimer(widget.expiresInSeconds);
    _otpController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer([int? seconds]) {
    _timer?.cancel();
    _resendSeconds = seconds ?? widget.expiresInSeconds;
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

  void _startBlockTimer([int seconds = 300]) {
    _timer?.cancel();
    _blockSeconds = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_blockSeconds > 0) {
        setState(() => _blockSeconds--);
      } else {
        timer.cancel();
        setState(() {
          _state = OtpScreenState.normal;
          _attemptsLeft = 3;
          _responseMessage = null;
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

  Future<void> _verify(String code) async {
    if (_state == OtpScreenState.blocked || _verifying || code.length != 4) {
      return;
    }
    setState(() => _verifying = true);

    final result = await ref.read(authApiProvider).verifyOtp(
          phone: _apiPhone,
          countryCode: AppStrings.countryCode,
          code: code,
        );

    if (!mounted) return;
    setState(() => _verifying = false);

    if (result.success) {
      final storage = ref.read(storageServiceProvider);
      await storage.setLoggedIn(true);
      await storage.savePhone(widget.phoneNumber);
      if (result.token != null) await storage.saveToken(result.token!);
      ref.invalidate(userMeProvider);
      ref.invalidate(homeFeedProvider);
      if (!mounted) return;
      context.goHome();
      return;
    }

    if (result.isNetworkError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Network error.')),
      );
      return;
    }

    final message = result.error ?? 'Verification failed. Please try again.';
    final isTooManyAttempts =
        message.toLowerCase().contains('too many attempts');
    final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(message);
    final blockSeconds = timeMatch == null
        ? 300
        : (int.parse(timeMatch.group(1)!) * 60) +
            int.parse(timeMatch.group(2)!);

    setState(() {
      _responseMessage = message;
      if (isTooManyAttempts) {
        _state = OtpScreenState.blocked;
        _startBlockTimer(blockSeconds);
      } else {
        _attemptsLeft--;
        _state = OtpScreenState.wrongCode;
      }
    });
  }

  Future<void> _resendCode() async {
    if (_resendSeconds > 0 || _state == OtpScreenState.blocked) return;

    final result = await ref.read(authApiProvider).resendOtp(
          phone: _apiPhone,
          countryCode: AppStrings.countryCode,
        );

    if (!mounted) return;

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Failed to resend code.')),
      );
      return;
    }

    setState(() {
      _state = OtpScreenState.resent;
      _responseMessage = null;
      _otpController.clear();
    });
    _startResendTimer(result.expiresInSeconds);
  }

  String get _buttonLabel {
    if (_verifying) return 'Verifying...';
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
        enabled: !isBlocked && !_verifying && _otpController.text.length == 4,
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
          ),
          const SizedBox(height: 8),
          if (_state == OtpScreenState.resent)
            const StatusBanner.success(message: AppStrings.newCodeSent),
          if (hasError)
            StatusBanner.error(
              message:
                  _responseMessage ?? AppStrings.incorrectCode(_attemptsLeft),
            ),
          if (isBlocked)
            BlockedBanner(
              remaining: _formatTime(_blockSeconds),
              message: _responseMessage,
            ),
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
                  onTap: () => context.pop(),
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
              onTap: () => context.pop(),
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
