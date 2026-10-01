import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/rewards/model/wallet_ledger_models.dart';

class RewardLedgerSection extends ConsumerStatefulWidget {
  const RewardLedgerSection({super.key});

  @override
  ConsumerState<RewardLedgerSection> createState() =>
      _RewardLedgerSectionState();
}

class _RewardLedgerSectionState extends ConsumerState<RewardLedgerSection> {
  final _items = <WalletLedgerEntry>[];
  String? _cursor;
  bool _hasMore = false;
  bool _loading = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _items.clear();
        _cursor = null;
      });
    } else {
      setState(() => _loadingMore = true);
    }
    try {
      final page = await ref.read(walletLedgerRepositoryProvider).fetchLedger(
            cursor: reset ? null : _cursor,
          );
      if (!mounted) return;
      setState(() {
        if (reset) {
          _items
            ..clear()
            ..addAll(page.items);
        } else {
          _items.addAll(page.items);
        }
        _cursor = page.nextCursor;
        _hasMore = page.hasMore;
        _loading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeaderLabel(label: 'WALLET HISTORY'),
        SizedBox(height: 10.h),
        if (_loading && _items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (_items.isEmpty)
          Text(
            'No wallet activity yet',
            style: AppTextStyles.bodySmall(color: AppColors.textSecondary),
          )
        else
          ..._items.map(_row),
        if (_hasMore)
          TextButton(
            onPressed: _loadingMore ? null : () => _load(reset: false),
            child: _loadingMore
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Load more'),
          ),
      ],
    );
  }

  Widget _row(WalletLedgerEntry entry) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.typeLabel,
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2.h),
                Text(
                  entry.status.toUpperCase(),
                  style: AppTextStyles.labelSmall(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            entry.amountLabel,
            style: AppTextStyles.labelMedium(color: AppColors.primary)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
