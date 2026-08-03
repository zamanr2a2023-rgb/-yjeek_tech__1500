import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/wallet_repository.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/routes/route_names.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key, this.showBottomNav = false});

  final bool showBottomNav;

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else if (showBottomNav) {
      context.goHome(tab: 0);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletSnapshotProvider);
    final wallet = walletAsync.valueOrNull ?? WalletSnapshot.empty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          NavBackHeader(
            title: NavigationStrings.walletTitleShort,
            backIconColor: AppColors.textPrimary,
            onBack: () => _handleBack(context),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(walletSnapshotProvider);
                await ref.read(walletSnapshotProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                children: [
                  if (walletAsync.isLoading && walletAsync.valueOrNull == null)
                    Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else ...[
                    WalletMainBalanceCard(
                      title: NavigationStrings.cashBack,
                      amount: wallet.cashbackLabel,
                      iconBg: const Color(0xFFF4EBD0),
                      iconAsset: AppAssets.walletCashBack,
                      onView: () => context.push(RouteNames.walletCashback),
                    ),
                    SizedBox(height: 14.h),
                    WalletMainBalanceCard(
                      title: NavigationStrings.refundsCredits,
                      amount: wallet.refundsLabel,
                      iconBg: const Color(0xFFE6F1FB),
                      iconAsset: AppAssets.walletRefunds,
                      onView: () => context.push(RouteNames.walletRefunds),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: showBottomNav
          ? null
          : const ShellBottomNavBar(currentIndex: 3),
    );
  }
}
