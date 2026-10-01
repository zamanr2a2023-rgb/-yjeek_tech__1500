import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/deep_links/yjeek_deep_link_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/campaigns/model/campaign_models.dart';
import 'package:yjeek_app/features/ui_content/model/banner_tap_router.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/routes/route_names.dart';

class MarketingHomeStrip extends ConsumerStatefulWidget {
  const MarketingHomeStrip({super.key});

  @override
  ConsumerState<MarketingHomeStrip> createState() => _MarketingHomeStripState();
}

class _MarketingHomeStripState extends ConsumerState<MarketingHomeStrip> {
  OnTimePromiseCampaign? _promise;
  CampaignWindow? _window;
  Timer? _tick;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(campaignsRepositoryProvider);
      final promise = await repo.fetchOnTimePromise();
      final windows = await repo.fetchWindows();
      CampaignWindow? live;
      for (final c in windows.campaigns) {
        if (c.inWindow) {
          live = c;
          break;
        }
      }
      if (!mounted) return;
      setState(() {
        _promise = promise;
        _window = live;
      });
      _updateCountdown();
    } catch (_) {}
  }

  void _updateCountdown() {
    final end = _window?.countdownEndsAt;
    if (end == null) return;
    final diff = end.difference(DateTime.now());
    if (!mounted) return;
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  String _countdownLabel() {
    if (_remaining <= Duration.zero) return '';
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    if (h > 0) return 'Ends in ${h}h ${m}m';
    if (m > 0) return 'Ends in ${m}m ${s}s';
    return 'Ends in ${s}s';
  }

  Future<void> _onCampaignTap(CampaignWindow window) async {
    final banner = window.banner;
    if (banner == null) return;
    final cta = banner.ctaUrl?.trim();
    if (cta != null && cta.startsWith('yjeek://')) {
      final router = AppRouter.instance;
      if (router != null) openYjeekDeepLink(router, cta);
      return;
    }
    await handleUiBannerTap(context, banner.toUiBanner());
  }

  @override
  Widget build(BuildContext context) {
    final promise = _promise;
    final window = _window;
    if ((promise == null || !promise.active) && window == null) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        if (promise != null && promise.active) ...[
          InkWell(
            onTap: () => context.push(RouteNames.vouchers),
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 10.h),
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
          ),
        ],
        if (window != null) ...[
          InkWell(
            onTap: () => _onCampaignTap(window),
            child: Container(
              width: double.infinity,
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
                          window.name,
                          style: AppTextStyles.labelMedium(
                            color: AppColors.textPrimary,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (_countdownLabel().isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            _countdownLabel(),
                            style: AppTextStyles.labelSmall(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }
}
