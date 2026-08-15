import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/auth/model/auth_api.dart';
import 'package:yjeek_app/features/browse/model/electronics_vendors_repository.dart';
import 'package:yjeek_app/features/browse/model/food_vendors_repository.dart';
import 'package:yjeek_app/features/browse/model/dine_in_vendors_repository.dart';
import 'package:yjeek_app/features/browse/model/services_vendors_repository.dart';
import 'package:yjeek_app/features/browse/model/vape_vendors_repository.dart';
import 'package:yjeek_app/features/browse/model/pickup_vendors_repository.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/locations_repository.dart';
import 'package:yjeek_app/features/cart/model/payment_methods_repository.dart';
import 'package:yjeek_app/features/cart/model/zood_repository.dart';
import 'package:yjeek_app/features/home/model/active_order_repository.dart';
import 'package:yjeek_app/features/home/model/categories_repository.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/features/home/model/home_feed.dart';
import 'package:yjeek_app/features/home/model/home_repository.dart';
import 'package:yjeek_app/features/navigation/model/content_repository.dart';
import 'package:yjeek_app/features/navigation/model/offers_repository.dart';
import 'package:yjeek_app/features/navigation/model/orders_repository.dart';
import 'package:yjeek_app/features/navigation/model/user_me.dart';
import 'package:yjeek_app/features/navigation/model/user_repository.dart';
import 'package:yjeek_app/features/navigation/model/wallet_repository.dart';
import 'package:yjeek_app/features/help/model/support_repository.dart';
import 'package:yjeek_app/features/order_flow/model/order_chat_repository.dart';
import 'package:yjeek_app/features/payments/model/wallet_pay_repository.dart';
import 'package:yjeek_app/features/ui_content/model/banner_models.dart';
import 'package:yjeek_app/features/ui_content/model/banners_repository.dart';

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

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => SupportRepository(
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

final bannersRepositoryProvider = Provider<BannersRepository>(
  (ref) => BannersRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

/// Per-placement CMS banners. No long-lived disk cache — refetch on invalidate.
final cmsBannersProvider =
    FutureProvider.family<List<UiBanner>, String>((ref, placementKey) {
  return ref.watch(bannersRepositoryProvider).fetchBanners(
        placementKey: placementKey,
      );
    });

/// Invalidate all placement banner fetches (pull-to-refresh / app resume).
void invalidateCmsBanners(WidgetRef ref) {
  ref.invalidate(cmsBannersProvider);
}

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

final vapeVendorsRepositoryProvider = Provider<VapeVendorsRepository>(
  (ref) => VapeVendorsRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final pickupVendorsRepositoryProvider = Provider<PickupVendorsRepository>(
  (ref) => PickupVendorsRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final addressesRepositoryProvider = Provider<AddressesRepository>(
  (ref) => AddressesRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final locationsRepositoryProvider = Provider<LocationsRepository>(
  (ref) => LocationsRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final zoodRepositoryProvider = Provider<ZoodRepository>(
  (ref) => ZoodRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final orderChatRepositoryProvider = Provider<OrderChatRepository>(
  (ref) => OrderChatRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final paymentMethodsRepositoryProvider = Provider<PaymentMethodsRepository>(
  (ref) => PaymentMethodsRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final walletPayRepositoryProvider = Provider<WalletPayRepository>(
  (ref) => WalletPayRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final offersRepositoryProvider = Provider<OffersRepository>(
  (ref) => OffersRepository(
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

/// GET /content/languages — enabled languages from admin localization.
final appLanguagesProvider = FutureProvider<List<AppLanguageOption>>((ref) {
  return ref.watch(userRepositoryProvider).fetchLanguages();
});

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(ref.watch(apiClientProvider)),
);
