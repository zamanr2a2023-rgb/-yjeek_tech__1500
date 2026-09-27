import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/network/api_client.dart';

enum PharmacyDeliveryMode { deliverNow, scheduled }

/// `GET /vendors/:id/order-modes` — server decides Deliver Now vs Scheduled.
class PharmacyOrderModes {
  const PharmacyOrderModes({
    required this.deliverNow,
    required this.scheduled,
    required this.dualMode,
    required this.customerInsideOnDemandRadius,
    this.banner,
    this.distanceKm,
  });

  final PharmacyDeliverNow deliverNow;
  final PharmacyScheduledMode scheduled;
  final String? banner;
  final bool dualMode;
  final bool customerInsideOnDemandRadius;
  final double? distanceKm;

  PharmacyDeliveryMode get selectedMode {
    if (deliverNow.enabled && deliverNow.selected && !deliverNow.faded) {
      return PharmacyDeliveryMode.deliverNow;
    }
    return PharmacyDeliveryMode.scheduled;
  }

  PharmacyOrderModes copyWith({String? banner}) {
    return PharmacyOrderModes(
      deliverNow: deliverNow,
      scheduled: scheduled,
      dualMode: dualMode,
      customerInsideOnDemandRadius: customerInsideOnDemandRadius,
      banner: banner ?? this.banner,
      distanceKm: distanceKm,
    );
  }

  factory PharmacyOrderModes.fromJson(Map<String, dynamic> json) {
    final nowRaw = json['deliverNow'];
    final scheduledRaw = json['scheduled'];
    return PharmacyOrderModes(
      deliverNow: PharmacyDeliverNow.fromJson(
        nowRaw is Map ? Map<String, dynamic>.from(nowRaw) : const {},
      ),
      scheduled: PharmacyScheduledMode.fromJson(
        scheduledRaw is Map
            ? Map<String, dynamic>.from(scheduledRaw)
            : const {},
      ),
      banner: _text(json['banner']),
      dualMode: json['dualMode'] == true,
      customerInsideOnDemandRadius:
          json['customerInsideOnDemandRadius'] == true,
      distanceKm: _money(json['distanceKm']),
    );
  }
}

class PharmacyDeliverNow {
  const PharmacyDeliverNow({
    required this.enabled,
    required this.selected,
    required this.faded,
    this.etaMin,
    this.deliveryFee,
    this.minOrderAmount,
  });

  final bool enabled;
  final bool selected;
  final bool faded;
  final int? etaMin;
  final double? deliveryFee;
  final double? minOrderAmount;

  factory PharmacyDeliverNow.fromJson(Map<String, dynamic> json) {
    return PharmacyDeliverNow(
      enabled: json['enabled'] == true,
      selected: json['selected'] == true,
      faded: json['faded'] == true,
      etaMin: (json['etaMin'] as num?)?.toInt(),
      deliveryFee: _money(json['deliveryFee']),
      minOrderAmount: _money(json['minOrderAmount']),
    );
  }
}

class PharmacyScheduledMode {
  const PharmacyScheduledMode({
    required this.selected,
    this.shippingFee,
    this.minOrderAmount,
    this.earliestSlotLabel,
  });

  final bool selected;
  final double? shippingFee;
  final double? minOrderAmount;
  final String? earliestSlotLabel;

  factory PharmacyScheduledMode.fromJson(Map<String, dynamic> json) {
    return PharmacyScheduledMode(
      selected: json['selected'] == true,
      shippingFee: _money(json['shippingFee']),
      minOrderAmount: _money(json['minOrderAmount']),
      earliestSlotLabel: _text(json['earliestSlotLabel']),
    );
  }
}

/// Vendor page selection. Scheduled checkout of a kept delivery cart is
/// [continueDeliveryAsScheduled] after `INSTANT_DELIVERY_UNAVAILABLE`.
class PharmacySession {
  const PharmacySession({
    required this.vendorId,
    required this.mode,
    this.continueDeliveryAsScheduled = false,
    this.banner,
  });

  final String vendorId;
  final PharmacyDeliveryMode mode;
  final bool continueDeliveryAsScheduled;
  final String? banner;

  bool matches(String? vendorId) =>
      vendorId != null && vendorId.isNotEmpty && vendorId == this.vendorId;

  PharmacySession copyWith({
    PharmacyDeliveryMode? mode,
    bool? continueDeliveryAsScheduled,
    String? banner,
  }) {
    return PharmacySession(
      vendorId: vendorId,
      mode: mode ?? this.mode,
      continueDeliveryAsScheduled:
          continueDeliveryAsScheduled ?? this.continueDeliveryAsScheduled,
      banner: banner ?? this.banner,
    );
  }
}

final pharmacySessionProvider = StateProvider<PharmacySession?>((ref) => null);

/// Thrown when Deliver Now checkout is outside the instant radius.
class InstantDeliveryUnavailableException implements Exception {
  const InstantDeliveryUnavailableException({
    required this.offerMoveToScheduled,
    required this.keepCart,
    required this.banner,
  });

  final bool offerMoveToScheduled;
  final bool keepCart;
  final String banner;

  @override
  String toString() => banner;
}

InstantDeliveryUnavailableException? instantDeliveryUnavailableFrom(
  ApiResponse response,
) {
  if (response.errorCode != 'INSTANT_DELIVERY_UNAVAILABLE') return null;
  final error = response.json?['error'];
  final details = error is Map ? error['details'] : null;
  final banner = details is Map ? details['banner']?.toString() : null;
  return InstantDeliveryUnavailableException(
    offerMoveToScheduled:
        details is Map && details['offerMoveToScheduled'] == true,
    keepCart: details is! Map || details['keepCart'] != false,
    banner: (banner != null && banner.trim().isNotEmpty)
        ? banner.trim()
        : (response.message ??
            "You are outside this pharmacy's instant delivery area, scheduled delivery only."),
  );
}

/// `badge=PRESCRIPTION` and price 0. Name matching is not used.
bool isPrescriptionWithoutPrice({
  required List<String> badges,
  required String price,
}) {
  final flagged = badges.any(
    (badge) => badge.toUpperCase().replaceAll('-', '_') == 'PRESCRIPTION',
  );
  if (!flagged) return false;
  final amount = double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), ''));
  return amount != null && amount == 0;
}

double? _money(dynamic raw) {
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw?.toString() ?? '');
}

String? _text(dynamic raw) {
  final value = raw?.toString().trim();
  if (value == null || value.isEmpty || value == 'null') return null;
  return value;
}
