import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/campaigns/model/campaign_models.dart';

/// Late-delivery promise shown on delivery checkout. Copy comes from the API.
class OnTimePromiseBanner extends ConsumerStatefulWidget {
  const OnTimePromiseBanner({super.key});

  @override
  ConsumerState<OnTimePromiseBanner> createState() =>
      _OnTimePromiseBannerState();
}

class _OnTimePromiseBannerState extends ConsumerState<OnTimePromiseBanner> {
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
    if (promise == null || !promise.active) return const SizedBox.shrink();
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
              promise.bannerTitle ?? 'On-Time Promise',
              style: AppTextStyles.labelMedium(
                color: AppColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            if (promise.bannerBody != null) ...[
              SizedBox(height: 4.h),
              Text(
                promise.bannerBody!,
                style: AppTextStyles.labelSmall(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
