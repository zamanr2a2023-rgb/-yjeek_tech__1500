import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/vouchers/widgets/voucher_card.dart';

class VouchersScreen extends ConsumerStatefulWidget {
  const VouchersScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends ConsumerState<VouchersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  static const _statuses = ['active', 'used', 'expired'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const NavBackHeader(
            title: 'Vouchers',
            backIconColor: AppColors.textPrimary,
          ),
          TabBar(
            controller: _tabs,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Used'),
              Tab(text: 'Expired'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                for (final status in _statuses) _VoucherTab(status: status),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 3),
    );
  }
}

class _VoucherTab extends ConsumerWidget {
  const _VoucherTab({required this.status});

  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(customerVouchersProvider(status));
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(customerVouchersProvider(status));
        await ref.read(customerVouchersProvider(status).future);
      },
      child: async.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 80.h),
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ],
        ),
        error: (_, __) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(24.w),
          children: [
            Text(
              'Could not load vouchers',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
            TextButton(
              onPressed: () => ref.invalidate(customerVouchersProvider(status)),
              child: const Text('Retry'),
            ),
          ],
        ),
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(24.w),
              children: [
                SizedBox(height: 40.h),
                Text(
                  'No $status vouchers',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                ),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (_, i) => VoucherCard(voucher: items[i]),
          );
        },
      ),
    );
  }
}
