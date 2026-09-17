import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';

enum DeliveryRangeOutcome {
  /// Address is within vendor delivery radius.
  inRange,

  /// Address is outside vendor delivery radius.
  outOfRange,

  /// Customer has no saved / selected address yet.
  noAddress,

  /// Could not determine (API/network); use with [failClosed].
  unknown,
}

class DeliveryRangeCheck {
  const DeliveryRangeCheck({
    required this.outcome,
    this.address,
  });

  final DeliveryRangeOutcome outcome;
  final DeliveryAddressSnapshot? address;

  bool get allowsDelivery => outcome == DeliveryRangeOutcome.inRange;

  bool get isOutOfRange => outcome == DeliveryRangeOutcome.outOfRange;
}

/// Thrown when the API rejects a delivery action for range.
class OutOfDeliveryRangeException implements Exception {
  OutOfDeliveryRangeException([
    this.message = 'This address is outside the vendor delivery area',
  ]);

  final String message;

  @override
  String toString() => message;
}

bool isOutOfDeliveryRangeMessage(String? message) {
  if (message == null || message.isEmpty) return false;
  final lower = message.toLowerCase();
  return lower.contains('outside the vendor delivery') ||
      lower.contains('outside the delivery area') ||
      lower.contains('out_of_delivery_range');
}

bool isOutOfDeliveryRangeCode(String? code) {
  return code == 'OUT_OF_DELIVERY_RANGE';
}

/// Builds `/cart/out-of-delivery?id=&lat=&lng=` like Change Address.
String outOfDeliveryLocation({
  String? addressId,
  double? latitude,
  double? longitude,
}) {
  final params = <String, String>{
    if (addressId != null && addressId.isNotEmpty) 'id': addressId,
    if (latitude != null) 'lat': '$latitude',
    if (longitude != null) 'lng': '$longitude',
  };
  if (params.isEmpty) return CartRoutes.outOfDelivery;
  final q = params.entries
      .map(
        (e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
      )
      .join('&');
  return '${CartRoutes.outOfDelivery}?$q';
}

String outOfDeliveryLocationFor(DeliveryAddressSnapshot? address) {
  return outOfDeliveryLocation(
    addressId: address?.id,
    latitude: address?.latitude,
    longitude: address?.longitude,
  );
}

/// Check whether [vendorId] can deliver to [addressId] (or the default address).
///
/// When [failClosed] is true (checkout/place), [unknown] is treated as out of range.
Future<DeliveryRangeCheck> checkDeliveryRange({
  required AddressesRepository addresses,
  required String vendorId,
  String? addressId,
  bool failClosed = false,
}) async {
  if (vendorId.isEmpty) {
    return const DeliveryRangeCheck(outcome: DeliveryRangeOutcome.unknown);
  }

  DeliveryAddressSnapshot? address;
  if (addressId != null && addressId.isNotEmpty) {
    final all = await addresses.listAddresses();
    for (final a in all) {
      if (a.id == addressId) {
        address = a;
        break;
      }
    }
  }
  address ??= await addresses.defaultAddress();

  if (address == null) {
    return const DeliveryRangeCheck(outcome: DeliveryRangeOutcome.noAddress);
  }

  final result = await addresses.checkInRangeResult(
    vendorId: vendorId,
    addressId: address.id,
  );

  switch (result) {
    case true:
      return DeliveryRangeCheck(
        outcome: DeliveryRangeOutcome.inRange,
        address: address,
      );
    case false:
      return DeliveryRangeCheck(
        outcome: DeliveryRangeOutcome.outOfRange,
        address: address,
      );
    case null:
      final outcome = failClosed
          ? DeliveryRangeOutcome.outOfRange
          : DeliveryRangeOutcome.unknown;
      return DeliveryRangeCheck(outcome: outcome, address: address);
  }
}

Future<void> pushOutOfDelivery(
  BuildContext context, {
  DeliveryAddressSnapshot? address,
  String? addressId,
  double? latitude,
  double? longitude,
}) {
  final location = address != null
      ? outOfDeliveryLocationFor(address)
      : outOfDeliveryLocation(
          addressId: addressId,
          latitude: latitude,
          longitude: longitude,
        );
  return context.push(location);
}
