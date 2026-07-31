import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/l10n/app_locales.dart';
import 'package:yjeek_app/l10n/l10n.dart';

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final initial = AppLocales.fromCode(storage.languageCode);
  L10n.load(AppLocales.codeOf(initial));
  return LocaleController(storage, initial);
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._storage, Locale initial) : super(initial);

  final StorageService _storage;

  String get code => AppLocales.codeOf(state);

  Future<void> setLanguage(String code) async {
    final locale = AppLocales.fromCode(code);
    final normalized = AppLocales.codeOf(locale);
    L10n.load(normalized);
    await _storage.saveLanguageCode(normalized);
    state = locale;
  }

  Future<void> toggle() async {
    await setLanguage(code == 'ar' ? 'en' : 'ar');
  }
}
