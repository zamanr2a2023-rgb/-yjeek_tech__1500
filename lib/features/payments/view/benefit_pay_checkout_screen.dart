import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/payments/model/benefit_pay_models.dart';

/// Opens the official BENEFIT Hosted PaymentURL in an in-app WebView.
/// Merchant success/error URLs are intercepted — backend HTML is not shown.
class BenefitPayCheckoutScreen extends StatefulWidget {
  const BenefitPayCheckoutScreen({
    super.key,
    required this.paymentUrl,
    this.paymentId,
    this.referenceNumber,
    this.amountLabel,
    this.title = 'BenefitPay',
  });

  final String paymentUrl;
  final String? paymentId;
  final String? referenceNumber;
  final String? amountLabel;
  final String title;

  @override
  State<BenefitPayCheckoutScreen> createState() =>
      _BenefitPayCheckoutScreenState();
}

class _BenefitPayCheckoutScreenState extends State<BenefitPayCheckoutScreen> {
  late final WebViewController _controller;
  bool _finished = false;
  bool _loading = true;
  Timer? _errorHold;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final kind = benefitHostedCallbackKind(request.url);
            if (kind == BenefitHostedCallbackKind.error) {
              // Let /error load so BENEFIT can complete the CANCELED notification cycle.
              _armErrorFinish(request.url);
              return NavigationDecision.navigate;
            }
            if (_interceptSuccess(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            final kind = benefitHostedCallbackKind(url);
            if (kind == BenefitHostedCallbackKind.success) {
              _interceptSuccess(url);
              return;
            }
            if (kind == BenefitHostedCallbackKind.error) {
              _armErrorFinish(url);
              return;
            }
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (_finished || !mounted) return;
            setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (_finished || !mounted) return;
            setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl.trim()));
  }

  @override
  void dispose() {
    _errorHold?.cancel();
    super.dispose();
  }

  bool _interceptSuccess(String url) {
    if (_finished) return true;
    if (benefitHostedCallbackKind(url) != BenefitHostedCallbackKind.success) {
      return false;
    }
    _errorHold?.cancel();
    _finish(
      BenefitPayCheckoutResult(
        outcome: BenefitPayCheckoutOutcome.success,
        message: 'Payment successful',
        raw: {
          'callbackUrl': url,
          'paymentId': widget.paymentId,
          'referenceNumber': widget.referenceNumber,
        },
      ),
    );
    return true;
  }

  /// Cancel/decline hits errorURL. Do not block the request — BENEFIT needs it.
  void _armErrorFinish(String url) {
    if (_finished) return;
    _errorHold?.cancel();
    _errorHold = Timer(const Duration(milliseconds: 500), () {
      if (_finished || !mounted) return;
      _finish(
        BenefitPayCheckoutResult(
          outcome: BenefitPayCheckoutOutcome.error,
          message: 'Payment failed or cancelled',
          raw: {
            'callbackUrl': url,
            'paymentId': widget.paymentId,
            'referenceNumber': widget.referenceNumber,
          },
        ),
      );
    });
  }

  void _finish(BenefitPayCheckoutResult result) {
    if (_finished) return;
    _finished = true;
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  Future<void> _onSystemBack() async {
    if (_finished) return;
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    _finish(
      const BenefitPayCheckoutResult(
        outcome: BenefitPayCheckoutOutcome.closed,
        message: 'Payment cancelled',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onSystemBack();
      },
      child: Scaffold(
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
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      ),
    );
  }
}

/// Explicit FOO Web Checkout URL builder. Not used by Hosted BENEFIT Pay Now.
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
