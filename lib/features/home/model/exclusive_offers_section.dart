import 'package:yjeek_app/core/constants/home_strings.dart';
import 'package:yjeek_app/l10n/l10n.dart';

/// Admin-published Super Exclusive section chrome from `GET /home` or `/home/exclusive-offers`.
class ExclusiveOffersSection {
  const ExclusiveOffersSection({
    required this.title,
    this.titleAr,
    this.isVisible = true,
  });

  final String title;
  final String? titleAr;
  final bool isVisible;

  String get displayTitle {
    if (L10n.isArabic) {
      final ar = titleAr?.trim();
      if (ar != null && ar.isNotEmpty) return ar;
    }
    final en = title.trim();
    return en.isNotEmpty ? en : HomeStrings.exclusiveOffers;
  }

  factory ExclusiveOffersSection.fromJson(Map<String, dynamic> json) {
    return ExclusiveOffersSection(
      title: json['title'] as String? ?? '',
      titleAr: json['titleAr'] as String?,
      isVisible: json['isVisible'] as bool? ?? true,
    );
  }

  factory ExclusiveOffersSection.fallback() {
    return ExclusiveOffersSection(
      title: HomeStrings.exclusiveOffers,
      isVisible: true,
    );
  }
}
