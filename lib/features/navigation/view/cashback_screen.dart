import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class CashbackScreen extends StatelessWidget {
  const CashbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          NavBackHeader(
            title: NavigationStrings.cashback,
            backIconColor: AppColors.textPrimary,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              children: [
                WalletGradientBalanceCard(
                  label: 'CASHBACK BALANCE',
                  amount: WalletData.cashbackScreenBalance,
                  subtitle: NavigationStrings.cashbackEarnedSubtitle,
                ),
                SizedBox(height: 14.h),
                PrimaryGreenButton(
                  label:
                      '${NavigationStrings.cashOutCashback} · ${WalletData.cashbackScreenBalance}',
                  iconAsset: AppAssets.walletCashOut,
                  backgroundColor: AppColors.primary,
                  onPressed: () => context.push(RouteNames.withdrawBank),
                ),
                SizedBox(height: 20.h),
                const SectionHeaderLabel(label: 'TRANSACTIONS'),
                ...WalletData.cashbackTransactions.map(
                  (t) => WalletTransactionTile(transaction: t),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 3),
    );
  }
}
