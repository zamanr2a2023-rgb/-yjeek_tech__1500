import 'package:yjeek_app/core/constants/home_strings.dart';
import 'package:yjeek_app/core/services/location_service.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/cart/model/locations_repository.dart';
import 'package:yjeek_app/features/location/model/customer_delivery_location.dart';

class DeliveryLocationResolver {
  const DeliveryLocationResolver({
    required this.storage,
    required this.locationService,
    this.addresses,
    this.locations,
  });

  final StorageService storage;
  final LocationService locationService;
  final AddressesRepository? addresses;
  final LocationsRepository? locations;

  Future<CustomerDeliveryLocation> resolve() async {
    final selected = await _selectedSavedAddress();
    if (selected != null) {
      final position = selected.latitude == null || selected.longitude == null
          ? await locationService.currentPosition()
          : null;
      final resolved = CustomerDeliveryLocation(
        kind: CustomerDeliveryLocationKind.saved,
        latitude: selected.latitude ?? position?.lat,
        longitude: selected.longitude ?? position?.lng,
        displayTitle: selected.label,
        displaySubtitle: selected.subtitle,
        addressId: selected.id,
        savedSnapshot: selected,
      );
      final lat = resolved.latitude;
      final lng = resolved.longitude;
      if (lat != null && lng != null) {
        await storage.saveDeliveryLocationCache(
          kind: resolved.kind.name,
          latitude: lat,
          longitude: lng,
          displayTitle: resolved.displayTitle,
          displaySubtitle: resolved.displaySubtitle,
          addressId: resolved.addressId,
        );
      }
      return resolved;
    }

    final position = await locationService.currentPosition();
    if (position != null) {
      final resolved = await _resolveAt(position.lat, position.lng);
      await storage.saveDeliveryLocationCache(
        kind: resolved.kind.name,
        latitude: position.lat,
        longitude: position.lng,
        displayTitle: resolved.displayTitle,
        displaySubtitle: resolved.displaySubtitle,
        addressId: resolved.addressId,
      );
      return resolved;
    }

    final cached = storage.loadDeliveryLocationCache();
    if (cached != null) {
      return _fromCache(cached);
    }

    return CustomerDeliveryLocation(
      kind: CustomerDeliveryLocationKind.unknown,
      displayTitle: HomeStrings.chooseLocation,
    );
  }

  /// Address checked on the Delivery address screen (default), else the first saved one.
  Future<DeliveryAddressSnapshot?> _selectedSavedAddress() async {
    if (!storage.hasSession || addresses == null) return null;
    final list = await addresses!.listAddresses();
    if (list.isEmpty) return null;
    for (final address in list) {
      if (address.isDefault) return address;
    }
    return list.first;
  }

  Future<CustomerDeliveryLocation> _resolveAt(double lat, double lng) async {

    var title = _cachedTitle() ?? 'Current location';
    String? subtitle;
    if (locations != null) {
      final reverse = await locations!.reverse(lat: lat, lng: lng);
      if (reverse != null) {
        title = reverse.label;
        subtitle = _formatReverseSubtitle(reverse);
      }
    }

    return CustomerDeliveryLocation(
      kind: CustomerDeliveryLocationKind.detected,
      latitude: lat,
      longitude: lng,
      displayTitle: title,
      displaySubtitle: subtitle,
    );
  }

  String? _cachedTitle() {
    final c = storage.loadDeliveryLocationCache();
    if (c == null || c.displayTitle.isEmpty) return null;
    return c.displayTitle;
  }

  CustomerDeliveryLocation _fromCache(DeliveryLocationCache cache) {
    final kind = CustomerDeliveryLocationKind.values.firstWhere(
      (k) => k.name == cache.kind,
      orElse: () => CustomerDeliveryLocationKind.detected,
    );
    return CustomerDeliveryLocation(
      kind: kind,
      latitude: cache.latitude,
      longitude: cache.longitude,
      displayTitle: cache.displayTitle.isNotEmpty
          ? cache.displayTitle
          : HomeStrings.chooseLocation,
      displaySubtitle: cache.displaySubtitle,
      addressId: cache.addressId,
    );
  }

  static String? _formatReverseSubtitle(ReverseGeocodeResult reverse) {
    final parts = <String>[
      if (reverse.road != null && reverse.road!.isNotEmpty)
        reverse.road!.toLowerCase().startsWith('road')
            ? reverse.road!
            : 'Road ${reverse.road}',
      if (reverse.block != null && reverse.block!.isNotEmpty)
        reverse.block!.toLowerCase().startsWith('block')
            ? reverse.block!
            : 'Block ${reverse.block}',
      if (reverse.area != null && reverse.area!.isNotEmpty)
        'near ${reverse.area}',
    ];
    final joined = parts.join(' · ');
    return joined.isEmpty ? null : joined;
  }
}
