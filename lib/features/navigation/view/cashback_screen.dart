import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/navigation/model/wallet_repository.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

final _cashbackTxProvider = FutureProvider<List<WalletTransaction>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  if (!storage.hasSession) return Future.value(const []);
  return ref
      .watch(walletRepositoryProvider)
      .fetchTransactions(ledger: 'CASHBACK');
});

class CashbackScreen extends ConsumerWidget {
  const CashbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletSnapshotProvider).valueOrNull ??
        WalletSnapshot.empty;
    final txAsync = ref.watch(_cashbackTxProvider);
    final transactions = txAsync.valueOrNull ?? const <WalletTransaction>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          NavBackHeader(
            title: NavigationStrings.cashback,
            backIconColor: AppColors.textPrimary,
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(walletSnapshotProvider);
                ref.invalidate(_cashbackTxProvider);
                await Future.wait([
                  ref.read(walletSnapshotProvider.future),
                  ref.read(_cashbackTxProvider.future),
                ]);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                children: [
                  WalletGradientBalanceCard(
                    label: 'CASHBACK BALANCE',
                    amount: wallet.cashbackLabel,
                    subtitle: NavigationStrings.cashbackEarnedSubtitle,
                  ),
                  SizedBox(height: 14.h),
                  PrimaryGreenButton(
                    label:
                        '${NavigationStrings.cashOutCashback} · ${wallet.cashbackLabel}',
                    iconAsset: AppAssets.walletCashOut,
                    backgroundColor: AppColors.primary,
                    onPressed: () => context.push(RouteNames.withdrawBank),
                  ),
                  SizedBox(height: 20.h),
                  const SectionHeaderLabel(label: 'TRANSACTIONS'),
                  if (txAsync.isLoading && transactions.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (transactions.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Text(
                        '___',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  else
                    ...transactions.map(
                      (t) => WalletTransactionTile(transaction: t),
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
