import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/rewards/model/rewards_summary.dart';
import 'package:yjeek_app/features/rewards/widgets/reward_summary_cards.dart';
import 'package:yjeek_app/features/rewards/widgets/reward_wallet_card.dart';
import 'package:yjeek_app/routes/route_names.dart';

class MyRewardsScreen extends ConsumerWidget {
  const MyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final summaryAsync = ref.watch(rewardsSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const NavBackHeader(
            title: 'My Rewards',
            backIconColor: AppColors.textPrimary,
          ),
          Expanded(
            child: !storage.hasSession
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        'Sign in to view your rewards',
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(rewardsSummaryProvider);
                      await ref.read(rewardsSummaryProvider.future);
                    },
                    child: summaryAsync.when(
                      loading: () => ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 80.h),
                          const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      error: (_, __) => ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(24.w),
                        children: [
                          Text(
                            'Could not load rewards',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12.h),
                          TextButton(
                            onPressed: () =>
                                ref.invalidate(rewardsSummaryProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                      data: (summary) => _RewardsBody(summary: summary),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 3),
    );
  }
}

class _RewardsBody extends StatelessWidget {
  const _RewardsBody({required this.summary});

  final RewardsSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      children: [
        const SectionHeaderLabel(label: 'WALLET'),
        SizedBox(height: 10.h),
        RewardSummaryCards(wallet: summary.wallet),
        SizedBox(height: 12.h),
        RewardWalletCard(wallet: summary.wallet),
        SizedBox(height: 20.h),
        const SectionHeaderLabel(label: 'VOUCHERS'),
        SizedBox(height: 10.h),
        _NavTile(
          title: 'Active vouchers',
          trailing: '${summary.activeVoucherCount}',
          onTap: () => context.push(RouteNames.vouchers),
        ),
        SizedBox(height: 20.h),
        const SectionHeaderLabel(label: 'SPIN WHEEL'),
        SizedBox(height: 10.h),
        _PlaceholderTile(
          title: summary.spin.live
              ? 'Spins remaining: ${summary.spin.spinsRemaining}'
              : 'No live spin campaign',
          subtitle: 'Coming soon',
        ),
        SizedBox(height: 20.h),
        const SectionHeaderLabel(label: 'MISSIONS'),
        SizedBox(height: 10.h),
        if (summary.missions.isEmpty)
          const _PlaceholderTile(
            title: 'No missions yet',
            subtitle: 'Missions will appear here when available',
          )
        else
          ...summary.missions.map(
            (m) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _PlaceholderTile(
                title: m.title,
                subtitle: '${m.progress} / ${m.target}',
              ),
            ),
          ),
        SizedBox(height: 16.h),
        TextButton(
          onPressed: () => context.push(RouteNames.wallet),
          child: const Text('Open Wallet'),
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  final String title;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                trailing,
                style: AppTextStyles.labelMedium(color: AppColors.primary)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 6.w),
              Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderTile extends StatelessWidget {
  const _PlaceholderTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
