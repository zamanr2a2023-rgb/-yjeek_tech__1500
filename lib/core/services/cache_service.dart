import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Disk cache for remote images used by [AppNetworkImage] / CachedNetworkImage.
///
/// First visit downloads over the network; later visits reuse these files.
/// Cap is ~500 images with a 30-day freshness window.
final appCacheManager = CacheManager(
  Config(
    'yjeek_cache',
    stalePeriod: const Duration(days: 30),
    maxNrOfCacheObjects: 500,
  ),
);

/// In-memory decoded-image budget (Flutter [ImageCache]).
void configureAppImageCaches() {
  final cache = PaintingBinding.instance.imageCache;
  cache.maximumSize = 500;
  cache.maximumSizeBytes = 250 << 20; // 250 MB
}
