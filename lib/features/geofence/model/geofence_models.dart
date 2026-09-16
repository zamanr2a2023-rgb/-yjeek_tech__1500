/// DTOs for customer Geofence Offers APIs.
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
