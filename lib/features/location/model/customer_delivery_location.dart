import 'package:yjeek_app/features/cart/model/addresses_repository.dart';

enum CustomerDeliveryLocationKind { saved, detected, unknown }

/// Active delivery / browse location for the customer app.
class CustomerDeliveryLocation {
  const CustomerDeliveryLocation({
    required this.kind,
    this.latitude,
    this.longitude,
    required this.displayTitle,
    this.displaySubtitle,
    this.addressId,
    this.savedSnapshot,
  });

  final CustomerDeliveryLocationKind kind;
  final double? latitude;
  final double? longitude;
  final String displayTitle;
  final String? displaySubtitle;
  final String? addressId;
  final DeliveryAddressSnapshot? savedSnapshot;

  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite;

  bool get isSaved => kind == CustomerDeliveryLocationKind.saved;

  bool get isDetected => kind == CustomerDeliveryLocationKind.detected;

  bool get requiresSaveBeforeCheckout =>
      kind == CustomerDeliveryLocationKind.detected && hasCoordinates;

  DeliveryAddressSnapshot? toCheckoutSnapshot() {
    if (isSaved && savedSnapshot != null) return savedSnapshot;
    return null;
  }

  ({String? addressId, double? latitude, double? longitude}) get forRangeCheck {
    if (isSaved && addressId != null && addressId!.isNotEmpty) {
      return (addressId: addressId, latitude: null, longitude: null);
    }
    if (hasCoordinates) {
      return (addressId: null, latitude: latitude, longitude: longitude);
    }
    return (addressId: null, latitude: null, longitude: null);
  }

  static const unknown = CustomerDeliveryLocation(
    kind: CustomerDeliveryLocationKind.unknown,
    displayTitle: '',
  );
}
