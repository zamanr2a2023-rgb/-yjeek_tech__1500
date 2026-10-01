import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/services/location_service.dart';
import 'package:yjeek_app/features/location/model/customer_delivery_location.dart';
import 'package:yjeek_app/features/location/service/delivery_location_resolver.dart';

/// Minimum interval between automatic refreshes on app resume.
const deliveryLocationResumeThrottle = Duration(minutes: 3);

class DeliveryLocationNotifier extends AsyncNotifier<CustomerDeliveryLocation> {
  DateTime? _lastRefreshAt;

  @override
  Future<CustomerDeliveryLocation> build() async {
    return _resolve();
  }

  Future<void> refresh({bool force = false}) async {
    if (!force &&
        _lastRefreshAt != null &&
        DateTime.now().difference(_lastRefreshAt!) <
            deliveryLocationResumeThrottle) {
      return;
    }
    _lastRefreshAt = DateTime.now();
    state = const AsyncLoading();
    state = AsyncData(await _resolve());
  }

  Future<CustomerDeliveryLocation> _resolve() async {
    final storage = ref.read(storageServiceProvider);
    final resolver = DeliveryLocationResolver(
      storage: storage,
      locationService: const LocationService(),
      addresses: storage.hasSession
          ? ref.read(addressesRepositoryProvider)
          : null,
      locations: storage.hasSession
          ? ref.read(locationsRepositoryProvider)
          : null,
    );
    return resolver.resolve();
  }
}

final deliveryLocationProvider =
    AsyncNotifierProvider<DeliveryLocationNotifier, CustomerDeliveryLocation>(
  DeliveryLocationNotifier.new,
);

/// Coordinates for vendor browse APIs; null when unknown.
({double lat, double lng})? watchBrowseCoordinates(WidgetRef ref) {
  final loc = ref.watch(deliveryLocationProvider).valueOrNull;
  if (loc == null || !loc.hasCoordinates) return null;
  return (lat: loc.latitude!, lng: loc.longitude!);
}
