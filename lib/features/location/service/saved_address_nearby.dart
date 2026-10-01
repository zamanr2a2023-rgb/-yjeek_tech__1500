import 'package:geolocator/geolocator.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';

/// Max distance to treat a saved address as "at" the customer's GPS fix.
const savedAddressMatchRadiusMeters = 1000.0;

/// Picks the nearest saved address within [maxMeters] of [lat]/[lng].
/// Tie-break: default address first, then first in [candidates] order (API: default desc, updated desc).
DeliveryAddressSnapshot? pickNearestSavedAddressWithin({
  required double lat,
  required double lng,
  required List<DeliveryAddressSnapshot> candidates,
  double maxMeters = savedAddressMatchRadiusMeters,
}) {
  DeliveryAddressSnapshot? best;
  double? bestDistance;
  var bestIsDefault = false;

  for (final address in candidates) {
    final aLat = address.latitude;
    final aLng = address.longitude;
    if (aLat == null || aLng == null) continue;

    final distance = Geolocator.distanceBetween(lat, lng, aLat, aLng);
    if (distance > maxMeters) continue;

    final isDefault = address.isDefault;
    if (best == null) {
      best = address;
      bestDistance = distance;
      bestIsDefault = isDefault;
      continue;
    }

    if (distance < bestDistance!) {
      best = address;
      bestDistance = distance;
      bestIsDefault = isDefault;
      continue;
    }

    if (distance == bestDistance && isDefault && !bestIsDefault) {
      best = address;
      bestIsDefault = true;
    }
  }

  return best;
}
