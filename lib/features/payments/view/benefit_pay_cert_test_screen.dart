import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/payments/pay_now_helper.dart';

/// Temporary UAT / debug screen for BenefitPay certification amount cases.
/// Creates a BP-CERT order via backend, then runs the real native SDK flow.
class BenefitPayCertTestScreen extends ConsumerStatefulWidget {
  const BenefitPayCertTestScreen({super.key});

  @override
  ConsumerState<BenefitPayCertTestScreen> createState() =>
      _BenefitPayCertTestScreenState();
}

class _BenefitPayCertTestScreenState
    extends ConsumerState<BenefitPayCertTestScreen> {
  final _amountController = TextEditingController(text: '1.123');
  bool _busy = false;
  String? _status;
  String? _lastOrderId;

  static const _presets = ['1.0', '1.1', '1.12', '1.123'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final raw = _amountController.text.trim().replaceAll(',', '.');
    return double.tryParse(raw);
  }

  Future<void> _pay() async {
    if (_busy) return;
    final amount = _parseAmount();
    if (amount == null || amount <= 0) {
      setState(() => _status = 'Enter a valid amount greater than 0');
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Creating cert-test order…';
      _lastOrderId = null;
    });

    try {
      final created = await ref
          .read(ordersRepositoryProvider)
          .createBenefitPayCertTestOrder(amount);
      if (!mounted) return;

      if (created == null || !created.ok) {
        setState(() {
          _status = created?.errorMessage ??
              'Could not create cert-test order. Ensure backend has '
                  'BENEFITPAY_CERT_TEST_ENABLED=true and NODE_ENV is not production.';
        });
        return;
      }

      final orderId = created.orderId;
      setState(() {
        _lastOrderId = orderId;
        _status =
            'Order ${created.orderNumber ?? orderId} created '
            '(BHD ${created.amount}). Launching BenefitPay…';
      });

      final helper = PayNowHelper(ref, context);
      final ok = await helper.payWithBenefitPayNative(orderIds: [orderId]);
      if (!mounted) return;

      if (ok) {
        setState(() {
          _status =
              'Payment successful (AUTHORIZED). '
              'orderId=$orderId amount=${created.amount}';
        });
      } else {
        setState(() {
          _status =
              'Payment failed or cancelled. '
              'orderId=$orderId — check snackbar / logs.';
        });
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('BenefitPayCertTest error: $e\n$st');
      }
      if (!mounted) return;
      setState(() => _status = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'BenefitPay Test Payment',
          style: AppTextStyles.labelMedium().copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
        children: [
          Text(
            'UAT / debug only. Creates a BP-CERT order with the amount you '
            'enter, then runs the real BenefitPay native SDK + confirm flow.',
            style: AppTextStyles.caption(color: AppColors.textSecondary),
          ),
          SizedBox(height: 20.h),
          Text(
            'Amount (BHD)',
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              hintText: '1.123',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final preset in _presets)
                ActionChip(
                  label: Text(preset),
                  onPressed: _busy
                      ? null
                      : () => setState(() => _amountController.text = preset),
                ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: FilledButton(
              onPressed: _busy ? null : _pay,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _busy
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Pay with BenefitPay'),
            ),
          ),
          if (_lastOrderId != null) ...[
            SizedBox(height: 16.h),
            SelectableText(
              'Last orderId: $_lastOrderId',
              style: AppTextStyles.caption(color: AppColors.textSecondary),
            ),
          ],
          if (_status != null) ...[
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                _status!,
                style: AppTextStyles.caption(color: AppColors.textPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
