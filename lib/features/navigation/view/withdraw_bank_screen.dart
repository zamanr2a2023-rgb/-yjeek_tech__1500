import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/wallet_repository.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class WithdrawBankScreen extends ConsumerStatefulWidget {
  const WithdrawBankScreen({super.key});

  @override
  ConsumerState<WithdrawBankScreen> createState() => _WithdrawBankScreenState();
}

class _WithdrawBankScreenState extends ConsumerState<WithdrawBankScreen> {
  bool _loading = true;
  bool _submitting = false;
  WalletSnapshot _wallet = WalletSnapshot.empty;
  WithdrawalQuote? _quote;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      final wallet = await repo.fetchWallet();
      final amount = (wallet.balance ?? 0).toDouble();
      WithdrawalQuote? quote;
      if (amount > 0) {
        quote = await repo.fetchWithdrawalQuote(amount);
      } else {
        final rate = wallet.payoutRate.toDouble();
        quote = WithdrawalQuote(
          amountRequested: 0,
          amountPayable: 0,
          feeAmount: 0,
          payoutRate: rate,
          balance: 0,
          eligible: false,
          reasons: const ['No withdrawable balance'],
          currency: wallet.currency,
          processingSla:
              'Review ≤ 2 working days · bank transfer 3–7 working days after approval',
        );
      }
      if (!mounted) return;
      setState(() {
        _wallet = wallet;
        _quote = quote;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _kycVerified => _wallet.kycVerified;

  bool get _canRequest {
    final balance = (_wallet.balance ?? 0).toDouble();
    final min = _wallet.withdrawalMinimum.toDouble();
    final quoteOk = _quote?.eligible ?? _wallet.withdrawalEligible;
    return _kycVerified && balance >= min && quoteOk && !_submitting;
  }

  String get _balanceLabel => _wallet.balanceLabel == '___'
      ? 'BHD 0.000'
      : _wallet.balanceLabel;

  String get _eligibilityLabel {
    final balance = (_wallet.balance ?? 0).toDouble();
    final min = _wallet.withdrawalMinimum.toDouble();
    if (balance >= min) {
      return 'Eligible · minimum BHD ${min.toStringAsFixed(0)} met';
    }
    return 'Minimum BHD ${min.toStringAsFixed(0)} required';
  }

  Future<void> _requestWithdrawal() async {
    final amount = (_wallet.balance ?? 0).toDouble();
    if (amount <= 0 || !_canRequest) return;

    setState(() => _submitting = true);
    final response = await ref.read(walletRepositoryProvider).requestWithdrawal(
          amount: amount,
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (response.ok) {
      ref.invalidate(walletSnapshotProvider);
      final code = response.data?['displayCode'] as String?;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            code != null
                ? 'Withdrawal $code submitted'
                : (response.message ?? 'Withdrawal submitted'),
          ),
        ),
      );
      await _load();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? 'Could not request withdrawal'),
        backgroundColor: const Color(0xFFB42318),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quote = _quote;
    final receivePct = quote?.receivePercent ??
        (_wallet.payoutRate * 100).round();
    final feePct = quote?.feePercent ?? (100 - receivePct);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(title: NavigationStrings.withdrawToBank),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                      children: [
                        _WithdrawBalanceCard(
                          balanceLabel: _balanceLabel,
                          eligibilityLabel: _eligibilityLabel,
                          eligible:
                              (_wallet.balance ?? 0) >= _wallet.withdrawalMinimum,
                        ),
                        SizedBox(height: 14.h),
                        PayoutSplitCard(
                          title: quote?.splitTitle ??
                              '$receivePct / $feePct pay-out split',
                          withdrawLabel: quote?.money(quote.amountRequested) ??
                              _balanceLabel,
                          receiveLabel: quote?.money(quote.amountPayable) ??
                              'BHD 0.000',
                          feeLabel:
                              quote?.money(quote.feeAmount) ?? 'BHD 0.000',
                          receivePercent: receivePct,
                          feePercent: feePct,
                        ),
                        SizedBox(height: 14.h),
                        if (_kycVerified)
                          const _VerifiedKycTile()
                        else
                          _KycPromptTile(
                            onTap: () async {
                              await context.push(RouteNames.idVerification);
                              if (mounted) await _load();
                            },
                          ),
                        SizedBox(height: 14.h),
                        InfoNoticeBox(
                          variant: InfoNoticeVariant.green,
                          text: quote?.processingSla ??
                              'Names must match across all documents. Review ≤ 2 working days · '
                                  'bank transfer 3–7 working days after approval.',
                        ),
                        SizedBox(height: 14.h),
                        PrimaryGreenButton(
                          label: _submitting
                              ? 'Submitting…'
                              : _kycVerified
                                  ? NavigationStrings.requestWithdrawal
                                  : NavigationStrings.verifyToWithdraw,
                          enabled: _kycVerified ? _canRequest : false,
                          height: 50,
                          borderRadius: 13,
                          disabledBackgroundColor: const Color(0xFFCCD6CF),
                          backgroundColor: AppColors.cartTabActive,
                          onPressed: _kycVerified
                              ? _requestWithdrawal
                              : null,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 3),
    );
  }
}

class _WithdrawBalanceCard extends StatelessWidget {
  const _WithdrawBalanceCard({
    required this.balanceLabel,
    required this.eligibilityLabel,
    required this.eligible,
  });

  final String balanceLabel;
  final String eligibilityLabel;
  final bool eligible;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.successText,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            NavigationStrings.withdrawableBalance,
            style: AppTextStyles.caption(color: const Color(0xFFCFE3D5)).copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            balanceLabel,
            style: AppTextStyles.displayMedium(color: AppColors.white).copyWith(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              height: 1.32,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: const Color(0xFF15401F),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  eligible ? Icons.check : Icons.info_outline,
                  size: 14.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  eligibilityLabel,
                  style: AppTextStyles.caption(color: const Color(0xFFCFE3D5))
                      .copyWith(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KycPromptTile extends StatelessWidget {
  const _KycPromptTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54.h,
        padding: EdgeInsets.fromLTRB(14.w, 0, 16.w, 0),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2EB),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFF2E9E4D), width: 1.3),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    NavigationStrings.verifyIdentity,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelMedium(
                      color: const Color(0xFF127036),
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5.sp,
                      height: 18 / 14.5,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    NavigationStrings.requiredBeforeWithdrawal,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall(
                      color: const Color(0xFF597361),
                    ).copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      height: 15 / 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              '›',
              style: TextStyle(
                fontSize: 20.sp,
                height: 24 / 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E9E4D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedKycTile extends StatelessWidget {
  const _VerifiedKycTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54.h,
      padding: EdgeInsets.fromLTRB(14.w, 0, 16.w, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2EB),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF2E9E4D), width: 1.3),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF2E9E4D), size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NavigationStrings.identityVerified,
                  style: AppTextStyles.labelMedium(
                    color: const Color(0xFF127036),
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5.sp,
                    height: 18 / 14.5,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  NavigationStrings.kycApproved,
                  style: AppTextStyles.labelSmall(
                    color: const Color(0xFF597361),
                  ).copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    height: 15 / 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
