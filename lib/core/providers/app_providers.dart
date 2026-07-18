import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/auth/model/auth_api.dart';
import 'package:yjeek_app/features/home/model/active_order_repository.dart';
import 'package:yjeek_app/features/navigation/model/user_me.dart';
import 'package:yjeek_app/features/navigation/model/user_repository.dart';

final storageServiceProvider = Provider<StorageService>(
  (ref) => Get.find<StorageService>(),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => Get.find<ApiClient>(),
);

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(apiClientProvider)),
);

final activeOrderRepositoryProvider = Provider<ActiveOrderRepository>(
  (ref) => ActiveOrderRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final userMeProvider = FutureProvider<UserMe?>((ref) {
  return ref.watch(userRepositoryProvider).fetchMe();
});
