import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:yjeek_app/core/utils/network_image_request.dart';

class AppNetworkFileService extends HttpFileService {
  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) {
    return super.get(
      url,
      headers: {
        ...networkImageHttpHeaders(url),
        ...?headers,
      },
    );
  }
}

/// Disk cache for remote images used by [AppNetworkImage] / CachedNetworkImage.
///
/// Cache id bumped when download headers change (e.g. avoid cached AVIF blobs).
final appCacheManager = CacheManager(
  Config(
    'yjeek_cache_v2',
    stalePeriod: const Duration(days: 30),
    maxNrOfCacheObjects: 500,
    fileService: AppNetworkFileService(),
  ),
);

/// In-memory decoded-image budget (Flutter [ImageCache]).
void configureAppImageCaches() {
  final cache = PaintingBinding.instance.imageCache;
  cache.maximumSize = 500;
  cache.maximumSizeBytes = 250 << 20; // 250 MB
}
