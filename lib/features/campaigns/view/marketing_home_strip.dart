import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/deep_links/yjeek_deep_link_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/campaigns/model/campaign_models.dart';
import 'package:yjeek_app/features/ui_content/model/banner_tap_router.dart';
import 'package:yjeek_app/routes/app_router.dart';

class MarketingHomeStrip extends ConsumerStatefulWidget {
  const MarketingHomeStrip({super.key});

  @override
  ConsumerState<MarketingHomeStrip> createState() => _MarketingHomeStripState();
}

class _MarketingHomeStripState extends ConsumerState<MarketingHomeStrip> {
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
      final windows =
          await ref.read(campaignsRepositoryProvider).fetchWindows();
      CampaignWindow? live;
      for (final c in windows.campaigns) {
        if (c.inWindow) {
          live = c;
          break;
        }
      }
      if (!mounted) return;
      setState(() => _window = live);
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
    final window = _window;
    if (window == null) return const SizedBox.shrink();
    return Column(
      children: [
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
    );
  }
}
