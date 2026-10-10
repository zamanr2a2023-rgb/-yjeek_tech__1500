import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/campaigns/model/campaign_models.dart';
import 'package:yjeek_app/l10n/l10n.dart';

/// On-time promise for **on-demand delivery** order tracking only (not checkout).
class OnTimePromiseTrackingBanner extends ConsumerStatefulWidget {
  const OnTimePromiseTrackingBanner({
    super.key,
    required this.scheduledTimeLabel,
  });

  /// ETA / arrival window shown to the customer (e.g. `45–60 min`).
  final String scheduledTimeLabel;

  @override
  ConsumerState<OnTimePromiseTrackingBanner> createState() =>
      _OnTimePromiseTrackingBannerState();
}

class _OnTimePromiseTrackingBannerState
    extends ConsumerState<OnTimePromiseTrackingBanner> {
  OnTimePromiseCampaign? _promise;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final promise =
          await ref.read(campaignsRepositoryProvider).fetchOnTimePromise();
      if (!mounted) return;
      setState(() => _promise = promise);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final promise = _promise;
    final time = widget.scheduledTimeLabel.trim();
    if (promise == null ||
        !promise.active ||
        time.isEmpty ||
        time == '—' ||
        time == '-') {
      return const SizedBox.shrink();
    }

    final amount = promise.compensationAmountBhd ?? '1.000';
    final body = L10n.trParams(
      'If your order arrives after the scheduled {time}, you will receive BHD {amount}.',
      {'time': time, 'amount': amount},
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              promise.bannerTitle ?? L10n.tr('On-Time Promise'),
              style: AppTextStyles.labelMedium(
                color: AppColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4.h),
            Text(
              body,
              style: AppTextStyles.labelSmall(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
