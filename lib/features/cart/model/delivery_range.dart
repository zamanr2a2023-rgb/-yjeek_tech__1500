import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/l10n/l10n.dart';

enum DeliveryRangeOutcome {
  /// Address is inside the included delivery radius.
  inRange,

  /// Past the included radius and still inside the vendor's max distance.
  extraCharge,

  /// Address is past the vendor's max distance.
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
    this.message,
    this.extraKm,
    this.extraChargeBhd,
  });

  final DeliveryRangeOutcome outcome;
  final DeliveryAddressSnapshot? address;
  final String? message;
  final double? extraKm;
  final String? extraChargeBhd;

  bool get allowsDelivery =>
      outcome == DeliveryRangeOutcome.inRange ||
      outcome == DeliveryRangeOutcome.extraCharge;

  bool get isOutOfRange => outcome == DeliveryRangeOutcome.outOfRange;

  bool get isExtraCharge => outcome == DeliveryRangeOutcome.extraCharge;

  /// Warning built from the live kilometres and BHD returned by the API.
  String get warningMessage {
    final km = extraKm;
    final amount = extraChargeBhd;
    if (km == null || amount == null || amount.isEmpty) {
      final fallback = message?.trim();
      if (fallback != null && fallback.isNotEmpty) return fallback;
      return '';
    }
    final kmLabel = km.toStringAsFixed(2);
    return L10n.trParams(
      'This address is {km} km past the included delivery radius. An extra BHD {amount} will be charged.',
      {'km': kmLabel, 'amount': amount},
    );
  }
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
  double? latitude,
  double? longitude,
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

  final DeliveryRangeApiResult? result;
  if (address != null) {
    result = await addresses.checkRangeForAddress(
      vendorId: vendorId,
      addressId: address.id,
    );
  } else if (latitude != null && longitude != null) {
    result = await addresses.checkRangeAtCoords(
      vendorId: vendorId,
      latitude: latitude,
      longitude: longitude,
    );
  } else {
    address = await addresses.defaultAddress();
    if (address == null) {
      return const DeliveryRangeCheck(outcome: DeliveryRangeOutcome.noAddress);
    }
    result = await addresses.checkRangeForAddress(
      vendorId: vendorId,
      addressId: address.id,
    );
  }

  switch (result?.rangeStatus) {
    case 'out_of_range':
      return DeliveryRangeCheck(
        outcome: DeliveryRangeOutcome.outOfRange,
        address: address,
        message: result?.message,
      );
    case 'extra_charge':
      return DeliveryRangeCheck(
        outcome: DeliveryRangeOutcome.extraCharge,
        address: address,
        message: result?.message,
        extraKm: result?.extraKm,
        extraChargeBhd: result?.extraChargeBhd,
      );
    case 'inside_included':
      return DeliveryRangeCheck(
        outcome: DeliveryRangeOutcome.inRange,
        address: address,
        message: result?.message,
      );
    default:
      break;
  }

  switch (result?.inRange) {
    case true:
      return DeliveryRangeCheck(
        outcome: DeliveryRangeOutcome.inRange,
        address: address,
      );
    case false:
      return DeliveryRangeCheck(
        outcome: DeliveryRangeOutcome.outOfRange,
        address: address,
        message: result?.message,
      );
    case null:
      final outcome = failClosed
          ? DeliveryRangeOutcome.outOfRange
          : DeliveryRangeOutcome.unknown;
      return DeliveryRangeCheck(outcome: outcome, address: address);
  }
}

/// Lets the customer continue, or stay and pick another address.
/// Returns true when there is nothing to confirm.
Future<bool> confirmExtraDeliveryCharge(
  BuildContext context,
  DeliveryRangeCheck range,
) {
  if (!range.isExtraCharge) return Future.value(true);
  return confirmExtraDeliveryChargeMessage(context, range.warningMessage);
}

Future<bool> confirmExtraDeliveryChargeMessage(
  BuildContext context,
  String? message,
) async {
  final text = message?.trim() ?? '';
  if (text.isEmpty) return true;
  final proceed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(CartFlowStrings.extraChargeTitle),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(CartFlowStrings.chooseAnotherAddress),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(CartFlowStrings.extraChargeContinue),
        ),
      ],
    ),
  );
  return proceed == true;
}

/// After an item is added in the extra-charge band, explain the live fee.
/// Choosing another address opens the address list.
Future<void> acknowledgeExtraDeliveryCharge(
  BuildContext context,
  String? message,
) async {
  final proceed = await confirmExtraDeliveryChargeMessage(context, message);
  if (!proceed && context.mounted) {
    await context.push(CartRoutes.changeAddress);
  }
}

Future<void> pushOutOfDelivery(
  BuildContext context, {
  DeliveryAddressSnapshot? address,
  String? addressId,
  double? latitude,
  double? longitude,
  String? message,
}) {
  final location = address != null
      ? outOfDeliveryLocationFor(address)
      : outOfDeliveryLocation(
          addressId: addressId,
          latitude: latitude,
          longitude: longitude,
        );
  final trimmed = message?.trim();
  if (trimmed == null || trimmed.isEmpty) return context.push(location);
  final uri = Uri.parse(location).replace(
    queryParameters: {
      ...Uri.parse(location).queryParameters,
      'message': trimmed,
    },
  );
  return context.push(uri.toString());
}
