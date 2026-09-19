// DTOs for customer Geofence Offers APIs.

enum GeofenceEventType {
  enter,
  appOpen,
  appResume;

  String get apiValue => switch (this) {
        GeofenceEventType.enter => 'ENTER',
        GeofenceEventType.appOpen => 'APP_OPEN',
        GeofenceEventType.appResume => 'APP_RESUME',
      };
}

class GeofenceFence {
  const GeofenceFence({
    required this.campaignId,
    required this.vendorId,
    required this.vendorName,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.distanceMeters,
    required this.promoCode,
    this.vendorLogoUrl,
    this.offerWindowMinutes,
    this.notificationTitle,
    this.endsAt,
  });

  final String campaignId;
  final String vendorId;
  final String vendorName;
  final String? vendorLogoUrl;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final double distanceMeters;
  final String promoCode;
  final int? offerWindowMinutes;
  final String? notificationTitle;
  final DateTime? endsAt;

  bool get isInside => distanceMeters <= radiusMeters + 50;

  factory GeofenceFence.fromJson(Map<String, dynamic> json) {
    return GeofenceFence(
      campaignId: json['campaignId']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? '',
      vendorLogoUrl: json['vendorLogoUrl']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      radiusMeters: (json['radiusMeters'] as num?)?.toDouble() ?? 0,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      promoCode: json['promoCode']?.toString() ?? '',
      offerWindowMinutes: (json['offerWindowMinutes'] as num?)?.toInt(),
      notificationTitle: json['notificationTitle']?.toString(),
      endsAt: DateTime.tryParse(json['endsAt']?.toString() ?? ''),
    );
  }
}

class GeofenceTriggerInfo {
  const GeofenceTriggerInfo({
    required this.id,
    required this.status,
    this.expiresAt,
    this.triggeredAt,
    this.distanceMeters,
  });

  final String id;
  final String status;
  final DateTime? expiresAt;
  final DateTime? triggeredAt;
  final double? distanceMeters;

  factory GeofenceTriggerInfo.fromJson(Map<String, dynamic> json) {
    return GeofenceTriggerInfo(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
      triggeredAt: DateTime.tryParse(json['triggeredAt']?.toString() ?? ''),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
    );
  }
}

class GeofenceEnterResult {
  const GeofenceEnterResult({
    required this.alreadyTriggered,
    required this.trigger,
    required this.promoCode,
    required this.vendorName,
    this.offerWindowMinutes,
    this.notificationSent = false,
    this.campaignId,
  });

  final bool alreadyTriggered;
  final GeofenceTriggerInfo trigger;
  final String promoCode;
  final String vendorName;
  final int? offerWindowMinutes;
  final bool notificationSent;
  final String? campaignId;

  factory GeofenceEnterResult.fromJson(
    Map<String, dynamic> json, {
    String? campaignId,
  }) {
    final triggerRaw = json['trigger'];
    final triggerMap = triggerRaw is Map
        ? Map<String, dynamic>.from(triggerRaw)
        : <String, dynamic>{};
    return GeofenceEnterResult(
      alreadyTriggered: json['alreadyTriggered'] == true,
      trigger: GeofenceTriggerInfo.fromJson(triggerMap),
      promoCode: json['promoCode']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? '',
      offerWindowMinutes: (json['offerWindowMinutes'] as num?)?.toInt(),
      notificationSent: json['notificationSent'] == true,
      campaignId: campaignId ?? json['campaignId']?.toString(),
    );
  }
}

class GeofenceVendorCard {
  const GeofenceVendorCard({
    required this.vendorId,
    required this.name,
    this.logoUrl,
    this.latitude,
    this.longitude,
    this.vendorLocationId,
    this.distanceMeters,
    this.orderTypes = const [],
  });

  final String vendorId;
  final String name;
  final String? logoUrl;
  final double? latitude;
  final double? longitude;
  final String? vendorLocationId;
  final double? distanceMeters;
  final List<String> orderTypes;

  factory GeofenceVendorCard.fromJson(Map<String, dynamic> json) {
    final modesRaw = json['orderTypes'];
    final modes = <String>[];
    if (modesRaw is List) {
      for (final m in modesRaw) {
        final s = m?.toString().trim();
        if (s != null && s.isNotEmpty) modes.add(s.toUpperCase());
      }
    }
    return GeofenceVendorCard(
      vendorId: json['vendorId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? json['logo']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      vendorLocationId: json['vendorLocationId']?.toString(),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      orderTypes: modes,
    );
  }
}

/// Active unlock from GET /geofence/active-offers (or events response).
class ActiveGeofenceOffer {
  const ActiveGeofenceOffer({
    required this.campaignId,
    required this.geofenceTriggerId,
    required this.expiresAt,
    required this.participatingVendors,
    required this.applicableOrderTypes,
    this.activationId,
    this.title,
    this.notificationTitle,
    this.notificationBody,
    this.discountPercent,
    this.discountBadge,
    this.discountType,
    this.discountValue,
    this.offerWindowMinutes,
    this.activatedAt,
    this.serverCurrentTime,
    this.remainingSeconds,
    this.offerStatus,
    this.nearestMatchedVendorId,
  });

  final String campaignId;
  final String geofenceTriggerId;
  final String? activationId;
  final String? title;
  final String? notificationTitle;
  final String? notificationBody;
  final double? discountPercent;
  final String? discountBadge;
  final String? discountType;
  final double? discountValue;
  final List<String> applicableOrderTypes;
  final int? offerWindowMinutes;
  final DateTime? activatedAt;
  final DateTime expiresAt;
  final DateTime? serverCurrentTime;
  final int? remainingSeconds;
  final String? offerStatus;
  final List<GeofenceVendorCard> participatingVendors;
  final String? nearestMatchedVendorId;

  String get triggerId =>
      geofenceTriggerId.isNotEmpty
          ? geofenceTriggerId
          : (activationId ?? '');

  bool get isActive {
    if (offerStatus != null &&
        offerStatus!.toUpperCase() != 'ACTIVE') {
      return false;
    }
    return remainingDuration(DateTime.now()).inSeconds > 0;
  }

  /// Authoritative countdown from [expiresAt], optionally skewed by server clock.
  Duration remainingDuration([DateTime? now]) {
    final localNow = now ?? DateTime.now();
    DateTime effectiveNow = localNow;
    final server = serverCurrentTime;
    if (server != null) {
      final skew = localNow.difference(server);
      // If device clock is skewed, prefer expiresAt against "server now" mapped locally.
      effectiveNow = localNow.subtract(skew);
    }
    final left = expiresAt.difference(effectiveNow);
    return left.isNegative ? Duration.zero : left;
  }

  String get modesLabel {
    if (applicableOrderTypes.isEmpty) return 'All modes';
    return applicableOrderTypes
        .map((m) {
          switch (m.toUpperCase()) {
            case 'DELIVERY':
              return 'Delivery';
            case 'PICKUP':
              return 'Pickup';
            case 'DINE_IN':
              return 'Dine-in';
            case 'SERVICE':
              return 'Service';
            default:
              return m;
          }
        })
        .join(' · ');
  }

  String get badgeLabel {
    final badge = discountBadge?.trim();
    if (badge != null && badge.isNotEmpty) return badge;
    final pct = discountPercent;
    if (pct != null) {
      final n = pct == pct.roundToDouble() ? pct.toInt().toString() : '$pct';
      return '$n% OFF';
    }
    return 'Offer';
  }

  factory ActiveGeofenceOffer.fromJson(Map<String, dynamic> json) {
    final vendorsRaw =
        json['participatingVendors'] ?? json['vendors'] ?? const [];
    final vendors = vendorsRaw is List
        ? vendorsRaw
            .whereType<Map>()
            .map(
              (row) =>
                  GeofenceVendorCard.fromJson(Map<String, dynamic>.from(row)),
            )
            .where((v) => v.vendorId.isNotEmpty)
            .toList(growable: false)
        : const <GeofenceVendorCard>[];

    final modesRaw = json['applicableOrderTypes'];
    final modes = modesRaw is List
        ? modesRaw.map((e) => e.toString()).toList(growable: false)
        : const <String>[];

    final triggerId = json['geofenceTriggerId']?.toString() ??
        json['activationId']?.toString() ??
        '';
    final expires = DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
        DateTime.now();

    return ActiveGeofenceOffer(
      campaignId: json['campaignId']?.toString() ?? '',
      geofenceTriggerId: triggerId,
      activationId: json['activationId']?.toString() ?? triggerId,
      title: json['title']?.toString(),
      notificationTitle: json['notificationTitle']?.toString(),
      notificationBody: json['notificationBody']?.toString(),
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      discountBadge: json['discountBadge']?.toString(),
      discountType: json['discountType']?.toString(),
      discountValue: (json['discountValue'] as num?)?.toDouble(),
      applicableOrderTypes: modes,
      offerWindowMinutes: (json['offerWindowMinutes'] as num?)?.toInt(),
      activatedAt: DateTime.tryParse(json['activatedAt']?.toString() ?? ''),
      expiresAt: expires,
      serverCurrentTime:
          DateTime.tryParse(json['serverCurrentTime']?.toString() ?? ''),
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt(),
      offerStatus: json['offerStatus']?.toString(),
      participatingVendors: vendors,
      nearestMatchedVendorId: json['nearestMatchedVendorId']?.toString(),
    );
  }
}

class GeofenceLocationEventResult {
  const GeofenceLocationEventResult({
    required this.eventType,
    required this.offers,
    this.serverCurrentTime,
    this.offerCount = 0,
    this.notificationScheduled = false,
  });

  final String eventType;
  final List<ActiveGeofenceOffer> offers;
  final DateTime? serverCurrentTime;
  final int offerCount;
  final bool notificationScheduled;

  factory GeofenceLocationEventResult.fromJson(Map<String, dynamic> json) {
    final offersRaw = json['offers'];
    final offers = offersRaw is List
        ? offersRaw
            .whereType<Map>()
            .map(
              (row) =>
                  ActiveGeofenceOffer.fromJson(Map<String, dynamic>.from(row)),
            )
            .where((o) => o.triggerId.isNotEmpty && o.campaignId.isNotEmpty)
            .toList(growable: false)
        : const <ActiveGeofenceOffer>[];
    return GeofenceLocationEventResult(
      eventType: json['eventType']?.toString() ?? '',
      offers: offers,
      serverCurrentTime:
          DateTime.tryParse(json['serverCurrentTime']?.toString() ?? ''),
      offerCount: (json['offerCount'] as num?)?.toInt() ?? offers.length,
      notificationScheduled: json['notificationScheduled'] == true,
    );
  }
}
