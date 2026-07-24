import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/auth/model/auth_api.dart';
import 'package:yjeek_app/features/browse/model/electronics_vendors_repository.dart';
import 'package:yjeek_app/features/browse/model/food_vendors_repository.dart';
import 'package:yjeek_app/features/browse/model/dine_in_vendors_repository.dart';
import 'package:yjeek_app/features/browse/model/services_vendors_repository.dart';
import 'package:yjeek_app/features/home/model/active_order_repository.dart';
import 'package:yjeek_app/features/home/model/categories_repository.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/features/home/model/home_feed.dart';
import 'package:yjeek_app/features/home/model/home_repository.dart';
import 'package:yjeek_app/features/navigation/model/orders_repository.dart';
import 'package:yjeek_app/features/navigation/model/user_me.dart';
import 'package:yjeek_app/features/navigation/model/user_repository.dart';
import 'package:yjeek_app/features/navigation/model/wallet_repository.dart';

final storageServiceProvider = Provider<StorageService>(
  (ref) => Get.find<StorageService>(),
);

final apiClientProvider = Provider<ApiClient>((ref) => Get.find<ApiClient>());

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(apiClientProvider)),
);

final activeOrderRepositoryProvider = Provider<ActiveOrderRepository>(
  (ref) => ActiveOrderRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => OrdersRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => WalletRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final walletSnapshotProvider = FutureProvider<WalletSnapshot>((ref) {
  final storage = ref.watch(storageServiceProvider);
  if (!storage.hasSession) return Future.value(WalletSnapshot.empty);
  return ref.watch(walletRepositoryProvider).fetchWallet();
});

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final homeFeedProvider = FutureProvider<HomeFeed>((ref) {
  return ref.watch(homeRepositoryProvider).fetchHome();
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>(
  (ref) => CategoriesRepository(ref.watch(apiClientProvider)),
);

final categoriesProvider = FutureProvider<List<CategoryItem>>((ref) {
  return ref.watch(categoriesRepositoryProvider).fetchCategories();
});

final foodVendorsRepositoryProvider = Provider<FoodVendorsRepository>(
  (ref) => FoodVendorsRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final foodCuisineFiltersProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(foodVendorsRepositoryProvider).fetchCuisineFilters();
});

final servicesVendorsRepositoryProvider = Provider<ServicesVendorsRepository>(
  (ref) => ServicesVendorsRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final electronicsVendorsRepositoryProvider =
    Provider<ElectronicsVendorsRepository>(
  (ref) => ElectronicsVendorsRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final dineInVendorsRepositoryProvider = Provider<DineInVendorsRepository>(
  (ref) => DineInVendorsRepository(
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
  final storage = ref.watch(storageServiceProvider);
  if (!storage.hasSession) return Future.value(null);
  return ref.watch(userRepositoryProvider).fetchMe();
});
