class UiBanner {
  const UiBanner({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.bannerType,
    required this.placementKey,
    this.tapAction,
    this.targetId,
    this.ctaLabel,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String bannerType; // STATIC | SCROLL | POPUP
  final String placementKey;
  final String? tapAction;
  final String? targetId;
  final String? ctaLabel;
  final int sortOrder;

  bool get isScroll => bannerType.toUpperCase() == 'SCROLL';
  bool get isPopup => bannerType.toUpperCase() == 'POPUP';

  factory UiBanner.fromJson(Map<String, dynamic> json) {
    return UiBanner(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      bannerType: (json['bannerType']?.toString() ?? 'STATIC').toUpperCase(),
      placementKey: json['placementKey']?.toString() ?? '',
      tapAction: json['tapAction']?.toString(),
      targetId: json['targetId']?.toString(),
      ctaLabel: json['ctaLabel']?.toString(),
      sortOrder: (json['sortOrder'] is num)
          ? (json['sortOrder'] as num).toInt()
          : int.tryParse('${json['sortOrder']}') ?? 0,
    );
  }
}

/// In-memory session flags for CMS (popup once per app process).
class UiBannerSession {
  UiBannerSession._();
  static final UiBannerSession instance = UiBannerSession._();

  bool appOpenPopupShown = false;
  final Set<String> dismissedPopupIds = <String>{};

  void markPopupShown(String? bannerId) {
    appOpenPopupShown = true;
    if (bannerId != null && bannerId.isNotEmpty) {
      dismissedPopupIds.add(bannerId);
    }
  }

  bool shouldShowPopup(String? bannerId) {
    if (appOpenPopupShown) return false;
    if (bannerId != null && dismissedPopupIds.contains(bannerId)) return false;
    return true;
  }
}
