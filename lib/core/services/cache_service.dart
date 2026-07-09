import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final appCacheManager = CacheManager(
  Config(
    'yjeek_cache',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 120,
  ),
);
