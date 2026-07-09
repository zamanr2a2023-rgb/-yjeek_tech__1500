import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>(
  (ref) => Get.find<StorageService>(),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => Get.find<ApiClient>(),
);
