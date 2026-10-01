import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/location/model/customer_delivery_location.dart';
import 'package:yjeek_app/features/location/provider/delivery_location_provider.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Resolves the address row shown at checkout from [deliveryLocationProvider].
DeliveryAddressSnapshot? checkoutAddressFromLocation(
  CustomerDeliveryLocation? location,
) {
  if (location == null) return null;
  if (location.isSaved) return location.savedSnapshot;
  return null;
}

/// Synthetic display when browsing on detected GPS without a saved id.
DeliveryAddressSnapshot? checkoutAddressDisplay(
  CustomerDeliveryLocation? location,
) {
  final saved = checkoutAddressFromLocation(location);
  if (saved != null) return saved;
  if (location == null || !location.isDetected || !location.hasCoordinates) {
    return null;
  }
  return DeliveryAddressSnapshot(
    id: '',
    label: location.displayTitle,
    subtitle: location.displaySubtitle ?? '',
    latitude: location.latitude,
    longitude: location.longitude,
  );
}

/// Navigates to add-address when checkout needs a saved record. Returns saved snapshot or null.
Future<DeliveryAddressSnapshot?> ensureSavedAddressForCheckout(
  BuildContext context,
  WidgetRef ref,
) async {
  final location = ref.read(deliveryLocationProvider).valueOrNull;
  if (location == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enable location or choose an address')),
    );
    return null;
  }

  if (location.isSaved && location.savedSnapshot != null) {
    return location.savedSnapshot;
  }

  if (!location.hasCoordinates) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location is required to deliver here')),
    );
    return null;
  }

  final params = <String, String>{
    'lat': location.latitude!.toStringAsFixed(6),
    'lng': location.longitude!.toStringAsFixed(6),
    if (location.displayTitle.isNotEmpty) 'area': location.displayTitle,
  };
  final query = params.entries
      .map(
        (e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
      )
      .join('&');

  await context.push('${RouteNames.addAddress}?$query');
  if (!context.mounted) return null;

  await ref.read(deliveryLocationProvider.notifier).refresh(force: true);
  final updated = ref.read(deliveryLocationProvider).valueOrNull;
  return checkoutAddressFromLocation(updated);
}
