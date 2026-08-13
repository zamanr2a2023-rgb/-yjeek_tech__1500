import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/ui_content/model/banner_models.dart';
import 'package:yjeek_app/features/ui_content/model/banner_tap_router.dart';

/// Renders CMS banners for a placement. Empty / error → nothing.
class UiPlacementBanner extends ConsumerWidget {
  const UiPlacementBanner({
    super.key,
    required this.placementKey,
    this.height = 124,
    this.padding = EdgeInsets.zero,
    this.fallbackWhenEmpty,
  });

  final String placementKey;
  final double height;
  final EdgeInsetsGeometry padding;
  final Widget? fallbackWhenEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(cmsBannersProvider(placementKey));
    return async.when(
      data: (banners) {
        if (banners.isEmpty) {
          return fallbackWhenEmpty ?? const SizedBox.shrink();
        }
        final scroll = banners.any((b) => b.isScroll) || banners.length > 1;
        final child = scroll
            ? UiBannerCarousel(banners: banners, height: height)
            : UiStaticBanner(banner: banners.first, height: height);
        if (padding == EdgeInsets.zero) return child;
        return Padding(padding: padding, child: child);
      },
      loading: () => fallbackWhenEmpty ?? const SizedBox.shrink(),
      error: (_, _) => fallbackWhenEmpty ?? const SizedBox.shrink(),
    );
  }
}

class UiStaticBanner extends StatelessWidget {
  const UiStaticBanner({
    super.key,
    required this.banner,
    this.height = 124,
  });

  final UiBanner banner;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _BannerCard(
      banner: banner,
      height: height,
      onTap: () => handleUiBannerTap(context, banner),
    );
  }
}

class UiBannerCarousel extends StatefulWidget {
  const UiBannerCarousel({
    super.key,
    required this.banners,
    this.height = 124,
  });

  final List<UiBanner> banners;
  final double height;

  @override
  State<UiBannerCarousel> createState() => _UiBannerCarouselState();
}

class _UiBannerCarouselState extends State<UiBannerCarousel> {
  late final PageController _controller;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.banners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted || !_controller.hasClients) return;
        final next = (_index + 1) % widget.banners.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;
    if (banners.isEmpty) return const SizedBox.shrink();
    if (banners.length == 1) {
      return UiStaticBanner(banner: banners.first, height: widget.height);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final banner = banners[i];
              return Padding(
                padding: EdgeInsets.only(right: i == banners.length - 1 ? 0 : 8),
                child: _BannerCard(
                  banner: banner,
                  height: widget.height,
                  onTap: () => handleUiBannerTap(context, banner),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.banner,
    required this.height,
    required this.onTap,
  });

  final UiBanner banner;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = banner.imageUrl != null && banner.imageUrl!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  AppNetworkImage(url: banner.imageUrl!, fit: BoxFit.cover)
                else
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF0F4D27),
                          Color(0xFF1A6B3C),
                          Color(0xFF3F5C38),
                          Color(0xFF6B4A2A),
                        ],
                        stops: [0.0, 0.42, 0.68, 1.0],
                      ),
                    ),
                  ),
                if (!hasImage ||
                    banner.title.isNotEmpty ||
                    (banner.subtitle?.isNotEmpty ?? false))
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: hasImage ? 0.55 : 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (banner.subtitle != null &&
                          banner.subtitle!.trim().isNotEmpty)
                        Text(
                          banner.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const Spacer(),
                      if (banner.title.trim().isNotEmpty)
                        Text(
                          banner.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      if (banner.ctaLabel != null &&
                          banner.ctaLabel!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            banner.ctaLabel!,
                            style: const TextStyle(
                              color: Color(0xFF0F4D27),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows first `app_open_popup` banner once per app session.
class UiAppOpenPopupHost extends ConsumerStatefulWidget {
  const UiAppOpenPopupHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UiAppOpenPopupHost> createState() => _UiAppOpenPopupHostState();
}

class _UiAppOpenPopupHostState extends ConsumerState<UiAppOpenPopupHost> {
  bool _scheduled = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<UiBanner>>>(
      cmsBannersProvider('app_open_popup'),
      (prev, next) {
        final banners = next.valueOrNull;
        if (banners == null || banners.isEmpty) return;
        if (_scheduled) return;
        final banner = banners.first;
        if (!UiBannerSession.instance.shouldShowPopup(banner.id)) return;
        _scheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showPopup(banner);
        });
      },
    );

    return widget.child;
  }

  Future<void> _showPopup(UiBanner banner) async {
    UiBannerSession.instance.markPopupShown(banner.id);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1.1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (banner.imageUrl != null && banner.imageUrl!.isNotEmpty)
                        AppNetworkImage(url: banner.imageUrl!, fit: BoxFit.cover)
                      else
                        Container(color: AppColors.primary),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black45,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        banner.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (banner.subtitle != null &&
                          banner.subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          banner.subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          handleUiBannerTap(context, banner);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text(
                          (banner.ctaLabel?.trim().isNotEmpty ?? false)
                              ? banner.ctaLabel!
                              : 'Continue',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
