import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/navigation/model/content_repository.dart';
import 'package:yjeek_app/l10n/app_locales.dart';
import 'package:yjeek_app/l10n/l10n.dart';

@immutable
class AppLocaleState {
  const AppLocaleState({
    required this.locale,
    this.revision = 0,
  });

  final Locale locale;
  final int revision;

  String get code => AppLocales.codeOf(locale);

  AppLocaleState copyWith({Locale? locale, int? revision}) {
    return AppLocaleState(
      locale: locale ?? this.locale,
      revision: revision ?? this.revision,
    );
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, AppLocaleState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final content = ref.watch(contentRepositoryProvider);
  final initial = AppLocales.fromCode(storage.languageCode);
  L10n.load(AppLocales.codeOf(initial));
  final controller = LocaleController(storage, content, initial);
  // Fire-and-forget: pull backend catalog for the saved language.
  controller.ensureTranslationsLoaded();
  return controller;
});

class LocaleController extends StateNotifier<AppLocaleState> {
  LocaleController(this._storage, this._content, Locale initial)
      : super(AppLocaleState(locale: initial));

  final StorageService _storage;
  final ContentRepository _content;
  final Set<String> _loading = {};

  String get code => state.code;

  Future<void> setLanguage(String code) async {
    final locale = AppLocales.fromCode(code);
    final normalized = AppLocales.codeOf(locale);
    await _loadRemote(normalized);
    L10n.load(normalized);
    await _storage.saveLanguageCode(normalized);
    state = AppLocaleState(
      locale: locale,
      revision: state.revision + 1,
    );
  }

  /// Prefetch / refresh backend strings for the current language.
  Future<void> ensureTranslationsLoaded({bool force = false}) async {
    final normalized = code;
    if (!force && L10n.hasRemote(normalized)) return;
    await _loadRemote(normalized);
    L10n.load(normalized);
    state = state.copyWith(revision: state.revision + 1);
  }

  Future<void> _loadRemote(String lang) async {
    if (_loading.contains(lang)) return;
    _loading.add(lang);
    try {
      final strings = await _content.fetchTranslations(lang);
      if (strings.isNotEmpty) {
        L10n.setRemoteTranslations(lang, strings);
      }
    } catch (_) {
      // Keep bundled offline fallbacks.
    } finally {
      _loading.remove(lang);
    }
  }

  /// Cycle through backend-enabled languages (fallback en ↔ ar).
  Future<void> cycleNext(List<String> codes) async {
    final list = codes
        .map((c) => c.trim().toLowerCase())
        .where(AppLocales.isSupported)
        .toList();
    if (list.isEmpty) {
      await toggle();
      return;
    }
    final idx = list.indexOf(code);
    final next = list[(idx < 0 ? 0 : idx + 1) % list.length];
    await setLanguage(next);
  }

  Future<void> toggle() async {
    await setLanguage(code == 'ar' ? 'en' : 'ar');
  }
}
