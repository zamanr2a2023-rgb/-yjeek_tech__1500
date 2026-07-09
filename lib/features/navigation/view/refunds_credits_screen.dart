import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class RefundsCreditsScreen extends StatelessWidget {
  const RefundsCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          NavBackHeader(
            title: NavigationStrings.refundsCredits,
            backIconColor: AppColors.textPrimary,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              children: [
                WalletGradientBalanceCard(
                  label: 'REFUNDS & CREDITS',
                  amount: WalletData.refundsCreditsBalance,
                  subtitle: NavigationStrings.refundsCreditsSubtitle,
                ),
                SizedBox(height: 20.h),
                const SectionHeaderLabel(label: 'TRANSACTIONS'),
                ...WalletData.refundTransactions.map(
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
