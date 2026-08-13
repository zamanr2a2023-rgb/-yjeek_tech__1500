import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/payments/model/benefit_pay_models.dart';

/// Opens Benefit hosted PaymentURL (preferred) or FOO Web Checkout via sdkPayload.
/// Host checkout pages often block WebView embedding — use the system browser.
class BenefitPayCheckoutScreen extends StatefulWidget {
  const BenefitPayCheckoutScreen({
    super.key,
    this.sdkPayload,
    this.paymentUrl,
    this.paymentId,
    this.referenceNumber,
    this.amountLabel,
    this.title = 'BenefitPay',
    this.useLiveSdk = false,
  }) : assert(
          paymentUrl != null || sdkPayload != null,
          'Provide paymentUrl or sdkPayload',
        );

  final BenefitPaySdkPayload? sdkPayload;
  final String? paymentUrl;
  final String? paymentId;
  final String? referenceNumber;
  final String? amountLabel;
  final String title;
  final bool useLiveSdk;

  @override
  State<BenefitPayCheckoutScreen> createState() =>
      _BenefitPayCheckoutScreenState();
}

class _BenefitPayCheckoutScreenState extends State<BenefitPayCheckoutScreen>
    with WidgetsBindingObserver {
  bool _finished = false;
  bool _opened = false;
  bool _launching = false;
  String? _status;

  Uri get _checkoutUri {
    final url = widget.paymentUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Uri.parse(url);
    }
    return buildBenefitPayCheckoutUri(
      widget.sdkPayload!,
      live: widget.useLiveSdk,
    );
  }

  String get _refLabel {
    final fromWidget = widget.referenceNumber?.trim();
    if (fromWidget != null && fromWidget.isNotEmpty) return fromWidget;
    final fromPayload = widget.sdkPayload?.referenceNumber;
    if (fromPayload != null && fromPayload.isNotEmpty) return fromPayload;
    return widget.paymentId ?? '—';
  }

  String get _amount {
    final fromWidget = widget.amountLabel?.trim();
    if (fromWidget != null && fromWidget.isNotEmpty) return fromWidget;
    return widget.sdkPayload?.transactionAmount ?? '—';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCheckout());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _opened && mounted) {
      setState(() {
        _status ??=
            'If you finished in BenefitPay, tap “I’ve paid”. Otherwise open again or cancel.';
      });
    }
  }

  Future<void> _openCheckout() async {
    if (_launching || _finished) return;
    setState(() {
      _launching = true;
      _status = null;
    });
    try {
      final ok = await launchUrl(
        _checkoutUri,
        mode: LaunchMode.externalApplication,
      );
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _status = 'Could not open BenefitPay. Try again.';
          _launching = false;
        });
        return;
      }
      setState(() {
        _opened = true;
        _launching = false;
        _status =
            'Complete payment in BenefitPay, then return here and tap “I’ve paid”.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _launching = false;
        _status = 'Could not open BenefitPay: $e';
      });
    }
  }

  void _finish(BenefitPayCheckoutResult result) {
    if (_finished || !mounted) return;
    _finished = true;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: AppTextStyles.labelMedium().copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _finish(
            const BenefitPayCheckoutResult(
              outcome: BenefitPayCheckoutOutcome.closed,
              message: 'Payment cancelled',
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pay with BenefitPay',
              style: AppTextStyles.titleMedium().copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.paymentUrl != null
                  ? 'Benefit opens the official Payment URL in your browser. After you finish, return here and tap “I’ve paid”.'
                  : 'BenefitPay opens in your browser. If you see “Sorry, you have been blocked”, that is Cloudflare on Benefit’s side — ask FOO/Benefit to allowlist your IP, or pay with Yjeek Wallet.',
              style: AppTextStyles.bodySmall(
                color: AppColors.textSecondary,
              ).copyWith(height: 1.4, fontSize: 13.sp),
            ),
            SizedBox(height: 20.h),
            Text(
              'BHD $_amount',
              style: AppTextStyles.titleMedium(
                color: const Color(0xFF0F4D27),
              ).copyWith(fontWeight: FontWeight.w800, fontSize: 28.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              'Ref $_refLabel',
              style: AppTextStyles.caption(color: AppColors.textSecondary),
            ),
            if (widget.paymentId != null && widget.paymentId!.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                'Payment ID ${widget.paymentId}',
                style: AppTextStyles.caption(color: AppColors.textSecondary),
              ),
            ],
            SizedBox(height: 20.h),
            if (_status != null)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7F2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _status!,
                  style: AppTextStyles.bodySmall(
                    color: const Color(0xFF0F4D27),
                  ).copyWith(height: 1.35),
                ),
              ),
            const Spacer(),
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: _launching ? null : _openCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  _opened ? 'Open BenefitPay again' : 'Open BenefitPay',
                  style: AppTextStyles.labelMedium(color: AppColors.white)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 52.h,
              child: OutlinedButton(
                onPressed: !_opened
                    ? null
                    : () => _finish(
                          BenefitPayCheckoutResult(
                            outcome: BenefitPayCheckoutOutcome.success,
                            message: 'User returned from BenefitPay',
                            raw: {
                              'referenceNumber': _refLabel,
                              'paymentId': widget.paymentId,
                              'paymentUrl': widget.paymentUrl,
                              'openedExternally': true,
                            },
                          ),
                        ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  "I've paid",
                  style: AppTextStyles.labelMedium(
                    color: AppColors.primary,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => _finish(
                const BenefitPayCheckoutResult(
                  outcome: BenefitPayCheckoutOutcome.closed,
                  message: 'Payment cancelled',
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelSmall(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Official FOO / BenefitPay hosted checkout (sandbox vs live) — fallback when PaymentURL is absent.
Uri buildBenefitPayCheckoutUri(
  BenefitPaySdkPayload payload, {
  bool live = false,
}) {
  final host = live
      ? 'benefit-checkout.benefitpay.bh'
      : 'benefit-checkout.test-benefitpay.bh';
  final data = payload.toRequestData();
  final query = <String, String>{
    for (final e in data.entries)
      if (e.value != null) e.key: e.value.toString(),
  };
  final fragmentQuery = Uri(queryParameters: query).query;
  return Uri(
    scheme: 'https',
    host: host,
    fragment: '/home?$fragmentQuery',
  );
}
