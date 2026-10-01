class UiBannerSlide {
  const UiBannerSlide({
    required this.id,
    this.title,
    this.subtitle,
    this.imageUrl,
    this.tapAction,
    this.targetId,
    this.ctaLabel,
    this.ctaUrl,
    this.sortOrder = 0,
  });

  final String id;
  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final String? tapAction;
  final String? targetId;
  final String? ctaLabel;
  final String? ctaUrl;
  final int sortOrder;

  factory UiBannerSlide.fromJson(Map<String, dynamic> json) {
    return UiBannerSlide(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      tapAction: json['tapAction']?.toString(),
      targetId: json['targetId']?.toString(),
      ctaLabel: json['ctaLabel']?.toString(),
      ctaUrl: json['ctaUrl']?.toString(),
      sortOrder: (json['sortOrder'] is num)
          ? (json['sortOrder'] as num).toInt()
          : int.tryParse('${json['sortOrder']}') ?? 0,
    );
  }

  /// One carousel page — slide fields override parent banner where set.
  UiBanner toCarouselPage(UiBanner parent) {
    final action = (tapAction ?? parent.tapAction)?.trim();
    var target = targetId ?? parent.targetId;
    if ((action ?? '').toUpperCase() == 'OPEN_URL') {
      final url = ctaUrl?.trim();
      if (url != null && url.isNotEmpty) target = url;
    }
    return UiBanner(
      id: id.isNotEmpty ? '${parent.id}_slide_$id' : parent.id,
      title: (title?.trim().isNotEmpty ?? false) ? title!.trim() : parent.title,
      subtitle: (subtitle?.trim().isNotEmpty ?? false)
          ? subtitle!.trim()
          : parent.subtitle,
      imageUrl: (imageUrl?.trim().isNotEmpty ?? false)
          ? imageUrl!.trim()
          : parent.imageUrl,
      bannerType: parent.bannerType,
      placementKey: parent.placementKey,
      tapAction: action,
      targetId: target,
      ctaLabel: (ctaLabel?.trim().isNotEmpty ?? false)
          ? ctaLabel!.trim()
          : parent.ctaLabel,
      sortOrder: sortOrder,
      slides: const [],
    );
  }
}

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
    this.slides = const [],
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

  /// Nested carousel pages for SCROLL banners (empty for STATIC / POPUP).
  final List<UiBannerSlide> slides;

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
      slides: parseBannerSlides(json['slides']),
    );
  }

  static List<UiBannerSlide> parseBannerSlides(Object? raw) {
    if (raw is! List || raw.isEmpty) return const [];
    final out = <UiBannerSlide>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final slide = UiBannerSlide.fromJson(Map<String, dynamic>.from(entry));
      if (slide.id.isEmpty) continue;
      out.add(slide);
    }
    out.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return out;
  }

  /// Inline carousel pages: expands SCROLL `slides[]`; other banners stay one page.
  static List<UiBanner> expandCarouselPages(List<UiBanner> banners) {
    final pages = <UiBanner>[];
    for (final banner in banners) {
      if (banner.isScroll && banner.slides.isNotEmpty) {
        for (final slide in banner.slides) {
          pages.add(slide.toCarouselPage(banner));
        }
      } else {
        pages.add(banner);
      }
    }
    return pages;
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
