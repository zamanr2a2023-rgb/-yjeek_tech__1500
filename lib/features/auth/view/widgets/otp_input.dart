import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_strings.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';

enum OtpFieldState { empty, filled, active, error, disabled }

class OtpInputRow extends StatefulWidget {
  const OtpInputRow({
    super.key,
    required this.length,
    this.onChanged,
    this.onCompleted,
    this.error = false,
    this.disabled = false,
    this.controller,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool error;
  final bool disabled;
  final TextEditingController? controller;

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits != value) {
      _controller.value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }
    widget.onChanged?.call(digits);
    if (digits.length == widget.length) {
      widget.onCompleted?.call(digits);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        final boxWidth =
            (constraints.maxWidth - gap * (widget.length - 1)) / widget.length;
        final boxHeight = boxWidth * (68 / 74);

        return Stack(
          children: [
            Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.disabled,
                keyboardType: TextInputType.number,
                maxLength: widget.length,
                autofocus: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _onChanged,
                decoration: const InputDecoration(counterText: ''),
              ),
            ),
            GestureDetector(
              onTap: widget.disabled ? null : () => _focusNode.requestFocus(),
              child: Row(
                children: [
                  for (var index = 0; index < widget.length; index++) ...[
                    if (index > 0) const SizedBox(width: gap),
                    Expanded(
                      child: _OtpBox(
                        height: boxHeight,
                        digit: index < _controller.text.length
                            ? _controller.text[index]
                            : '',
                        state: _boxState(index),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  OtpFieldState _boxState(int index) {
    final digit = index < _controller.text.length
        ? _controller.text[index]
        : '';
    final isActive =
        !widget.disabled &&
        index == _controller.text.length &&
        _focusNode.hasFocus;

    if (widget.disabled) return OtpFieldState.disabled;
    if (widget.error) return OtpFieldState.error;
    if (digit.isNotEmpty) return OtpFieldState.filled;
    if (isActive) return OtpFieldState.active;
    return OtpFieldState.empty;
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.digit,
    required this.state,
    required this.height,
  });

  final String digit;
  final OtpFieldState state;
  final double height;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color backgroundColor;
    Color textColor;

    switch (state) {
      case OtpFieldState.error:
        borderColor = AppColors.error;
        backgroundColor = AppColors.white;
        textColor = AppColors.error;
      case OtpFieldState.filled:
      case OtpFieldState.active:
        borderColor = AppColors.primary;
        backgroundColor = AppColors.white;
        textColor = AppColors.textPrimary;
      case OtpFieldState.disabled:
        borderColor = AppColors.border;
        backgroundColor = AppColors.disabledOtp;
        textColor = AppColors.textSecondary;
      case OtpFieldState.empty:
        borderColor = AppColors.border;
        backgroundColor = AppColors.white;
        textColor = AppColors.textPrimary;
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width:
                state == OtpFieldState.filled || state == OtpFieldState.active
                ? 2
                : 1,
          ),
        ),
        child: Opacity(
          opacity: state == OtpFieldState.disabled ? 0.6 : 1,
          child: Text(digit, style: AppTextStyles.otpDigit(color: textColor)),
        ),
      ),
    );
  }
}

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    const fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: AppColors.border, width: 1),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Text(
                AppStrings.countryLabel,
                style: AppTextStyles.bodyMedium(
                  color: AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.countryCode,
                style: AppTextStyles.bodyMedium(
                  color: AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 54,
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              style: AppTextStyles.bodyMedium(
                color: AppColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: '3300 0000',
                hintStyle: AppTextStyles.bodyMedium(color: AppColors.dividerText)
                    .copyWith(fontWeight: FontWeight.w600),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 0,
                ),
                border: fieldBorder,
                enabledBorder: fieldBorder,
                focusedBorder: fieldBorder,
                disabledBorder: fieldBorder,
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class TermsCheckboxRow extends StatelessWidget {
  const TermsCheckboxRow({
    super.key,
    required this.checked,
    required this.onChanged,
    this.onTermsTap,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTermsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onChanged(!checked),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: checked ? AppColors.primary : AppColors.white,
              border: Border.all(
                color: checked ? AppColors.primary : AppColors.checkboxBorder,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: checked
                ? const Icon(Icons.check, size: 14, color: AppColors.white)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTermsTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.labelSmall(
                      color: AppColors.textMuted,
                    ).copyWith(fontWeight: FontWeight.w500),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' & '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StatusBanner extends StatelessWidget {
  const StatusBanner.success({super.key, required this.message})
    : backgroundColor = AppColors.successBackground,
      iconColor = AppColors.primary,
      textColor = AppColors.successText,
      icon = Icons.check;

  const StatusBanner.error({super.key, required this.message})
    : backgroundColor = AppColors.errorBackground,
      iconColor = AppColors.error,
      textColor = AppColors.error,
      icon = Icons.error_outline;

  final String message;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 12, color: AppColors.white),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: AppTextStyles.labelSmall(
                color: textColor,
              ).copyWith(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class BlockedBanner extends StatelessWidget {
  const BlockedBanner({super.key, required this.remaining});

  final String remaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: AppColors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Too many attempts',
                  style: AppTextStyles.labelMedium(
                    color: AppColors.error,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppStrings.tooManyAttempts} $remaining.',
                  style: AppTextStyles.labelSmall(
                    color: AppColors.error,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
