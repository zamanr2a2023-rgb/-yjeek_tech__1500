import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yjeek_app/core/constants/api_constants.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/services/cache_service.dart';
import 'package:yjeek_app/core/utils/network_image_request.dart';
import 'package:yjeek_app/core/utils/responsive.dart';

bool _shouldMemCacheResize(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  final host = uri.host.toLowerCase();
  final apiHost = Uri.tryParse(ApiConstants.baseUrl)?.host.toLowerCase();
  if (apiHost != null && host == apiHost) return true;
  final path = uri.path.toLowerCase();
  return path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.png') ||
      path.endsWith('.webp') ||
      path.endsWith('.gif');
}

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
      return _wrap(context, errorWidget ?? _defaultError());
    }

    return _wrap(
      context,
      _AppNetworkImageBody(
        url: trimmed,
        width: width,
        height: height,
        fit: fit,
        showShimmer: showShimmer,
        borderRadius: borderRadius,
        errorWidget: errorWidget,
        defaultError: _defaultError(),
      ),
    );
  }

  Widget _wrap(BuildContext context, Widget child) {
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

class _AppNetworkImageBody extends StatefulWidget {
  const _AppNetworkImageBody({
    required this.url,
    required this.width,
    required this.height,
    required this.fit,
    required this.showShimmer,
    required this.borderRadius,
    required this.errorWidget,
    required this.defaultError,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool showShimmer;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Widget defaultError;

  @override
  State<_AppNetworkImageBody> createState() => _AppNetworkImageBodyState();
}

class _AppNetworkImageBodyState extends State<_AppNetworkImageBody> {
  bool _useDirectNetwork = false;

  @override
  Widget build(BuildContext context) {
    final headers = networkImageHttpHeaders(widget.url);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final memW = widget.width == null ||
            !widget.width!.isFinite ||
            widget.width!.isInfinite
        ? null
        : (widget.width! * dpr).round();
    final memH = widget.height == null ||
            !widget.height!.isFinite ||
            widget.height!.isInfinite
        ? null
        : (widget.height! * dpr).round();

    final lowerUrl = widget.url.toLowerCase();
    final keepAlpha = lowerUrl.contains('.png') || lowerUrl.contains('.webp');
    final resizeInMem = _shouldMemCacheResize(widget.url);

    if (_useDirectNetwork) {
      return Image.network(
        widget.url,
        headers: headers,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => widget.errorWidget ?? widget.defaultError,
        loadingBuilder: (context, child, progress) {
          if (!widget.showShimmer || progress == null) return child;
          return ShimmerBox(
            width: widget.width ?? double.infinity,
            height: widget.height ?? 76.h,
            borderRadius: widget.borderRadius,
          );
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.url,
      httpHeaders: headers,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheManager: appCacheManager,
      memCacheWidth: !resizeInMem || keepAlpha ? null : memW,
      memCacheHeight: !resizeInMem || keepAlpha ? null : memH,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: widget.showShimmer
          ? (_, _) => ShimmerBox(
              width: widget.width ?? double.infinity,
              height: widget.height ?? 76.h,
              borderRadius: widget.borderRadius,
            )
          : (_, _) => SizedBox(width: widget.width, height: widget.height),
      errorWidget: (_, _, _) {
        if (!_useDirectNetwork) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _useDirectNetwork = true);
          });
        }
        return widget.errorWidget ?? widget.defaultError;
      },
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
