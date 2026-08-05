import 'package:yjeek_app/l10n/l10n.dart';

/// Pick catalog copy for the active app language.
/// Prefers Arabic when locale is `ar` and [ar] is non-empty; else English.
String catalogLocalized(String? en, String? ar) {
  if (L10n.isArabic) {
    final arabic = ar?.trim();
    if (arabic != null && arabic.isNotEmpty) return arabic;
  }
  final english = en?.trim();
  return english ?? '';
}
