import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/location/service/saved_address_nearby.dart';

DeliveryAddressSnapshot _addr({
  required String id,
  required double lat,
  required double lng,
  bool isDefault = false,
}) {
  return DeliveryAddressSnapshot(
    id: id,
    label: id,
    subtitle: 'line',
    isDefault: isDefault,
    latitude: lat,
    longitude: lng,
  );
}

void main() {
  // Reference point: Bahrain Seef area (approx).
  const gpsLat = 26.2361;
  const gpsLng = 50.5331;

  test('returns null when no addresses within 1 km', () {
    final far = _addr(id: 'far', lat: 26.25, lng: 50.55);
    final result = pickNearestSavedAddressWithin(
      lat: gpsLat,
      lng: gpsLng,
      candidates: [far],
    );
    expect(result, isNull);
  });

  test('picks address within 1 km', () {
    final near = _addr(
      id: 'near',
      lat: gpsLat + 0.0005,
      lng: gpsLng + 0.0005,
    );
    final result = pickNearestSavedAddressWithin(
      lat: gpsLat,
      lng: gpsLng,
      candidates: [near],
    );
    expect(result?.id, 'near');
  });

  test('prefers nearer address among multiple in range', () {
    final closer = _addr(
      id: 'closer',
      lat: gpsLat + 0.0001,
      lng: gpsLng,
    );
    final farther = _addr(
      id: 'farther',
      lat: gpsLat + 0.003,
      lng: gpsLng,
    );
    final result = pickNearestSavedAddressWithin(
      lat: gpsLat,
      lng: gpsLng,
      candidates: [farther, closer],
    );
    expect(result?.id, 'closer');
  });

  test('tie-break prefers default at same distance', () {
    final a = _addr(
      id: 'a',
      lat: gpsLat + 0.0002,
      lng: gpsLng,
      isDefault: false,
    );
    final b = _addr(
      id: 'b',
      lat: gpsLat + 0.0002,
      lng: gpsLng,
      isDefault: true,
    );
    final result = pickNearestSavedAddressWithin(
      lat: gpsLat,
      lng: gpsLng,
      candidates: [a, b],
    );
    expect(result?.id, 'b');
  });

  test('skips addresses without coordinates', () {
    final noCoords = DeliveryAddressSnapshot(
      id: 'x',
      label: 'x',
      subtitle: '',
    );
    final withCoords = _addr(
      id: 'with',
      lat: gpsLat + 0.0003,
      lng: gpsLng,
    );
    final result = pickNearestSavedAddressWithin(
      lat: gpsLat,
      lng: gpsLng,
      candidates: [noCoords, withCoords],
    );
    expect(result?.id, 'with');
  });
}
