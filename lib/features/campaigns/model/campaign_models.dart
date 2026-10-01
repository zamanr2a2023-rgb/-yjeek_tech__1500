import 'package:yjeek_app/features/ui_content/model/banner_models.dart';

class CampaignWindowsResponse {
  const CampaignWindowsResponse({
    required this.timezone,
    required this.campaigns,
  });

  final String timezone;
  final List<CampaignWindow> campaigns;

  factory CampaignWindowsResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CampaignWindowsResponse(timezone: 'Asia/Bahrain', campaigns: []);
    }
    final raw = json['campaigns'];
    final list = <CampaignWindow>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          list.add(CampaignWindow.fromJson(item));
        }
      }
    }
    return CampaignWindowsResponse(
      timezone: json['timezone']?.toString() ?? 'Asia/Bahrain',
      campaigns: list,
    );
  }
}

class CampaignWindow {
  const CampaignWindow({
    required this.id,
    required this.name,
    required this.type,
    required this.inWindow,
    this.countdownEndsAt,
    this.banner,
  });

  final String id;
  final String name;
  final String type;
  final bool inWindow;
  final DateTime? countdownEndsAt;
  final CampaignBanner? banner;

  factory CampaignWindow.fromJson(Map<String, dynamic> json) {
    final bannerRaw = json['banner'];
    return CampaignWindow(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      inWindow: json['inWindow'] == true,
      countdownEndsAt:
          DateTime.tryParse(json['countdownEndsAt']?.toString() ?? ''),
      banner: bannerRaw is Map<String, dynamic>
          ? CampaignBanner.fromJson(bannerRaw)
          : null,
    );
  }
}

class CampaignBanner {
  const CampaignBanner({
    required this.id,
    this.title,
    this.imageUrl,
    this.tapAction,
    this.targetId,
    this.ctaUrl,
  });

  final String id;
  final String? title;
  final String? imageUrl;
  final String? tapAction;
  final String? targetId;
  final String? ctaUrl;

  UiBanner toUiBanner() => UiBanner(
        id: id,
        title: title ?? 'Campaign',
        imageUrl: imageUrl,
        bannerType: 'STATIC',
        placementKey: 'campaign_window',
        tapAction: tapAction,
        targetId: ctaUrl?.trim().isNotEmpty == true ? ctaUrl : targetId,
      );

  factory CampaignBanner.fromJson(Map<String, dynamic> json) {
    return CampaignBanner(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      tapAction: json['tapAction']?.toString(),
      targetId: json['targetId']?.toString(),
      ctaUrl: json['ctaUrl']?.toString(),
    );
  }
}

class OnTimePromiseCampaign {
  const OnTimePromiseCampaign({
    required this.active,
    this.bannerTitle,
    this.bannerBody,
  });

  final bool active;
  final String? bannerTitle;
  final String? bannerBody;

  factory OnTimePromiseCampaign.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OnTimePromiseCampaign(active: false);
    return OnTimePromiseCampaign(
      active: json['active'] == true,
      bannerTitle: json['bannerTitle']?.toString(),
      bannerBody: json['bannerBody']?.toString(),
    );
  }
}
