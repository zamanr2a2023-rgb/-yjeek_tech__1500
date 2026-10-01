import 'package:yjeek_app/l10n/l10n.dart';

class SpinActiveResponse {
  const SpinActiveResponse({
    this.campaignId,
    this.spinsRemaining = 0,
    this.live = false,
    this.campaign,
  });

  final String? campaignId;
  final int spinsRemaining;
  final bool live;
  final SpinCampaign? campaign;

  factory SpinActiveResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SpinActiveResponse();
    final campaignRaw = json['campaign'];
    return SpinActiveResponse(
      campaignId: json['campaignId']?.toString(),
      spinsRemaining: (json['spinsRemaining'] as num?)?.toInt() ?? 0,
      live: json['live'] == true,
      campaign: campaignRaw is Map<String, dynamic>
          ? SpinCampaign.fromJson(campaignRaw)
          : null,
    );
  }
}

class SpinCampaign {
  const SpinCampaign({
    required this.id,
    required this.segments,
    this.headerTextEn,
    this.headerTextAr,
    this.subHeaderEn,
    this.subHeaderAr,
    this.spinButtonText,
    this.spinButtonColor,
    this.screenBgValue,
    this.wheelBgValue,
  });

  final String id;
  final List<SpinSegment> segments;
  final String? headerTextEn;
  final String? headerTextAr;
  final String? subHeaderEn;
  final String? subHeaderAr;
  final String? spinButtonText;
  final String? spinButtonColor;
  final String? screenBgValue;
  final String? wheelBgValue;

  String get headerText =>
      L10n.isArabic ? (headerTextAr ?? headerTextEn ?? '') : (headerTextEn ?? headerTextAr ?? '');

  String get subHeaderText =>
      L10n.isArabic ? (subHeaderAr ?? subHeaderEn ?? '') : (subHeaderEn ?? subHeaderAr ?? '');

  factory SpinCampaign.fromJson(Map<String, dynamic> json) {
    final segmentsRaw = json['segments'];
    final segments = <SpinSegment>[];
    if (segmentsRaw is List) {
      for (final raw in segmentsRaw) {
        if (raw is Map<String, dynamic>) {
          segments.add(SpinSegment.fromJson(raw));
        }
      }
    }
    return SpinCampaign(
      id: json['id']?.toString() ?? '',
      segments: segments,
      headerTextEn: json['headerTextEn']?.toString(),
      headerTextAr: json['headerTextAr']?.toString(),
      subHeaderEn: json['subHeaderEn']?.toString(),
      subHeaderAr: json['subHeaderAr']?.toString(),
      spinButtonText: json['spinButtonText']?.toString(),
      spinButtonColor: json['spinButtonColor']?.toString(),
      screenBgValue: json['screenBgValue']?.toString(),
      wheelBgValue: json['wheelBgValue']?.toString(),
    );
  }
}

class SpinSegment {
  const SpinSegment({
    required this.id,
    required this.labelEn,
    required this.labelAr,
    required this.segmentColor,
    required this.textColor,
    required this.prizeType,
    this.image,
  });

  final String id;
  final String labelEn;
  final String labelAr;
  final String segmentColor;
  final String textColor;
  final String prizeType;
  final String? image;

  String get label =>
      L10n.isArabic ? (labelAr.isNotEmpty ? labelAr : labelEn) : labelEn;

  factory SpinSegment.fromJson(Map<String, dynamic> json) {
    return SpinSegment(
      id: json['id']?.toString() ?? '',
      labelEn: json['labelEn']?.toString() ?? '',
      labelAr: json['labelAr']?.toString() ?? '',
      segmentColor: json['segmentColor']?.toString() ?? '#3B82F6',
      textColor: json['textColor']?.toString() ?? '#FFFFFF',
      prizeType: json['prizeType']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }
}

class SpinDrawResult {
  const SpinDrawResult({
    required this.campaignId,
    required this.spinsRemaining,
    required this.segment,
    this.prizeRef,
    this.noticeCode,
  });

  final String campaignId;
  final int spinsRemaining;
  final SpinSegment segment;
  final String? prizeRef;
  final String? noticeCode;

  bool get isTryAgain =>
      noticeCode == 'SPIN_BUDGET_EXHAUSTED' ||
      segment.prizeType.toUpperCase().contains('TRY');

  factory SpinDrawResult.fromJson(Map<String, dynamic> json) {
    final seg = json['segment'];
    return SpinDrawResult(
      campaignId: json['campaignId']?.toString() ?? '',
      spinsRemaining: (json['spinsRemaining'] as num?)?.toInt() ?? 0,
      segment: seg is Map<String, dynamic>
          ? SpinSegment.fromJson(seg)
          : const SpinSegment(
              id: '',
              labelEn: '',
              labelAr: '',
              segmentColor: '#6B7280',
              textColor: '#FFFFFF',
              prizeType: 'TRY_AGAIN',
            ),
      prizeRef: json['prizeRef']?.toString(),
      noticeCode: json['noticeCode']?.toString(),
    );
  }
}
