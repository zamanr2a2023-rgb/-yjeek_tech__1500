import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/auth/model/auth_api.dart';
import 'package:yjeek_app/features/browse/model/age_verification_repository.dart';
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
import 'package:yjeek_app/features/home/model/top_picks_models.dart';
import 'package:yjeek_app/features/home/model/top_picks_repository.dart';
import 'package:yjeek_app/features/location/provider/delivery_location_provider.dart';
import 'package:yjeek_app/features/home/model/home_repository.dart';
import 'package:yjeek_app/features/navigation/model/content_repository.dart';
import 'package:yjeek_app/features/notifications/model/notifications_repository.dart';
import 'package:yjeek_app/features/navigation/model/offers_repository.dart';
import 'package:yjeek_app/features/geofence/model/geofence_repository.dart';
import 'package:yjeek_app/features/navigation/model/orders_repository.dart';
import 'package:yjeek_app/features/navigation/model/user_me.dart';
import 'package:yjeek_app/features/navigation/model/user_repository.dart';
import 'package:yjeek_app/features/navigation/model/wallet_repository.dart';
import 'package:yjeek_app/features/help/model/support_repository.dart';
import 'package:yjeek_app/features/order_flow/model/order_chat_repository.dart';
import 'package:yjeek_app/features/payments/model/wallet_pay_repository.dart';
import 'package:yjeek_app/features/rewards/model/rewards_repository.dart';
import 'package:yjeek_app/features/rewards/model/rewards_summary.dart';
import 'package:yjeek_app/features/ui_content/model/banner_models.dart';
import 'package:yjeek_app/features/ui_content/model/banners_repository.dart';
import 'package:yjeek_app/features/vouchers/model/voucher_models.dart';
import 'package:yjeek_app/features/vouchers/model/vouchers_repository.dart';
import 'package:yjeek_app/features/offers/model/marketing_offers_repository.dart';
import 'package:yjeek_app/features/rewards/model/wallet_ledger_repository.dart';
import 'package:yjeek_app/features/referral/model/referral_repository.dart';
import 'package:yjeek_app/features/spin/model/spin_repository.dart';
import 'package:yjeek_app/features/campaigns/model/campaigns_repository.dart';
import 'package:yjeek_app/core/services/device_id_service.dart';

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

final rewardsRepositoryProvider = Provider<RewardsRepository>(
  (ref) => RewardsRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final rewardsSummaryProvider = FutureProvider<RewardsSummary>((ref) {
  final storage = ref.watch(storageServiceProvider);
  if (!storage.hasSession) return Future.value(RewardsSummary.empty);
  return ref.watch(rewardsRepositoryProvider).fetchSummary();
});

final vouchersRepositoryProvider = Provider<VouchersRepository>(
  (ref) => VouchersRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final customerVouchersProvider =
    FutureProvider.family<List<CustomerVoucher>, String>((ref, status) {
      final storage = ref.watch(storageServiceProvider);
      if (!storage.hasSession) return Future.value(const []);
      return ref
          .watch(vouchersRepositoryProvider)
          .fetchVouchers(status: status);
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

final topPicksRepositoryProvider = Provider<TopPicksRepository>(
  (ref) => TopPicksRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

/// Coordinates only — avoids refetch when location reloads with the same lat/lng.
final _topPicksCoordsProvider = Provider<({double lat, double lng})?>((ref) {
  final loc = ref.watch(deliveryLocationProvider).valueOrNull;
  if (loc == null || !loc.hasCoordinates) return null;
  return (lat: loc.latitude!, lng: loc.longitude!);
});

/// Branch-scoped picks from GET /home/top-picks (backend filters by radius).
final topPicksProvider = FutureProvider<List<HomeTopPickItem>>((ref) async {
  final coords = ref.watch(_topPicksCoordsProvider);
  if (coords == null) return const [];
  return ref.read(topPicksRepositoryProvider).fetchTopPicks(
        latitude: coords.lat,
        longitude: coords.lng,
      );
});

final bannersRepositoryProvider = Provider<BannersRepository>(
  (ref) => BannersRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

/// Per-placement CMS banners. No long-lived disk cache — refetch on invalidate.
final cmsBannersProvider = FutureProvider.family<List<UiBanner>, String>((
  ref,
  placementKey,
) {
  return ref
      .watch(bannersRepositoryProvider)
      .fetchBanners(placementKey: placementKey);
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

final addressesRepositoryProvider = Provider<AddressesRepository>(
  (ref) => AddressesRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final foodVendorsRepositoryProvider = Provider<FoodVendorsRepository>(
  (ref) => FoodVendorsRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
    addresses: ref.watch(addressesRepositoryProvider),
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
    addresses: ref.watch(addressesRepositoryProvider),
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
    addresses: ref.watch(addressesRepositoryProvider),
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

final geofenceRepositoryProvider = Provider<GeofenceRepository>(
  (ref) => GeofenceRepository(
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

final ageVerificationRepositoryProvider = Provider<AgeVerificationRepository>(
  (ref) => AgeVerificationRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final ageVerificationStatusProvider = FutureProvider<AgeVerificationStatus>((
  ref,
) async {
  final storage = ref.watch(storageServiceProvider);
  if (!storage.hasSession) {
    return const AgeVerificationStatus(
      status: 'NOT_VERIFIED',
      canPurchaseAgeRestricted: false,
    );
  }
  return ref.watch(ageVerificationRepositoryProvider).fetchStatus();
});

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final notificationsUnreadCountProvider = FutureProvider<int>((ref) {
  final storage = ref.watch(storageServiceProvider);
  if (!storage.hasSession) return Future.value(0);
  return ref.watch(notificationsRepositoryProvider).fetchUnreadCount();
});

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

final marketingOffersRepositoryProvider = Provider<MarketingOffersRepository>(
  (ref) => MarketingOffersRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final walletLedgerRepositoryProvider = Provider<WalletLedgerRepository>(
  (ref) => WalletLedgerRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final referralRepositoryProvider = Provider<ReferralRepository>(
  (ref) => ReferralRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final spinRepositoryProvider = Provider<SpinRepository>(
  (ref) => SpinRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);

final campaignsRepositoryProvider = Provider<CampaignsRepository>(
  (ref) => CampaignsRepository(ref.watch(apiClientProvider)),
);

final deviceIdServiceProvider = Provider<DeviceIdService>(
  (ref) => DeviceIdService(ref.watch(storageServiceProvider)),
);
