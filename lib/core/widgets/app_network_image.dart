import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/services/cache_service.dart';
import 'package:yjeek_app/core/utils/responsive.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.showShimmer = true,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final bool showShimmer;

  @override
  Widget build(BuildContext context) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return _wrap(errorWidget ?? _defaultError());
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final memW = width == null || !width!.isFinite || width!.isInfinite
        ? null
        : (width! * dpr).round();
    final memH = height == null || !height!.isFinite || height!.isInfinite
        ? null
        : (height! * dpr).round();

    final image = CachedNetworkImage(
      imageUrl: trimmed,
      width: width,
      height: height,
      fit: fit,
      cacheManager: appCacheManager,
      memCacheWidth: memW,
      memCacheHeight: memH,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: showShimmer
          ? (_, _) => ShimmerBox(
                width: width ?? double.infinity,
                height: height ?? 76.h,
                borderRadius: borderRadius,
              )
          : (_, _) => SizedBox(width: width, height: height),
      errorWidget: (_, _, _) => errorWidget ?? _defaultError(),
    );

    return _wrap(image);
  }

  Widget _wrap(Widget child) {
    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _defaultError() {
    return Container(
      width: width,
      height: height,
      color: AppColors.iconBackground,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textSecondary,
        size: 24.sp,
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.skeleton,
      highlightColor: AppColors.skeletonLight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.skeleton,
          borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

class AppPlaceholderImage extends StatelessWidget {
  const AppPlaceholderImage({
    super.key,
    required this.color,
    this.width,
    this.height,
    this.icon = Icons.image_outlined,
  });

  final Color color;
  final double? width;
  final double? height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 76.w,
      height: height ?? 76.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        icon,
        color: AppColors.textSecondary.withValues(alpha: 0.5),
        size: 32.sp,
      ),
    );
  }
}
