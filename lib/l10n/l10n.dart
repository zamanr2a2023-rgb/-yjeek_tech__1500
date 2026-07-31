import 'package:yjeek_app/l10n/app_locales.dart';
import 'package:yjeek_app/l10n/translations_ar.dart';

/// Lightweight i18n lookup keyed by English source strings.
///
/// [AppStrings] / [NavigationStrings] / feature `*Strings` classes call
/// [tr] so existing call sites keep working without BuildContext.
abstract final class L10n {
  static String _code = AppLocales.defaultCode;

  static String get code => _code;

  static bool get isArabic => _code == 'ar';

  static bool get isEnglish => _code == 'en';

  static void load(String code) {
    _code = AppLocales.isSupported(code) ? code.toLowerCase() : AppLocales.defaultCode;
  }

  /// Translate an English UI string. Falls back to [english] when missing.
  static String tr(String english) {
    if (_code != 'ar') return english;
    return kArabicTranslations[english] ?? english;
  }

  /// Replace `{name}` placeholders after translation.
  static String trParams(String english, Map<String, String> params) {
    var out = tr(english);
    params.forEach((key, value) {
      out = out.replaceAll('{$key}', value);
    });
    return out;
  }
}
