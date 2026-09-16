import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/services/location_service.dart';
import 'package:yjeek_app/core/utils/app_logger.dart';
import 'package:yjeek_app/features/geofence/model/geofence_models.dart';
import 'package:yjeek_app/features/geofence/model/geofence_repository.dart';

/// Latest unlock from foreground geofence polling (for snackbars).
final geofenceLastUnlockProvider = StateProvider<GeofenceEnterResult?>(
  (ref) => null,
);

/// Promo code to prefill in cart after "Use in cart".
final pendingGeofencePromoProvider = StateProvider<String?>((ref) => null);

/// Set when geofence needs the user to allow location (snackbar in MainShell).
final geofenceLocationPromptProvider =
    StateProvider<LocationPermissionOutcome?>((ref) => null);

final geofenceSessionControllerProvider =
    Provider<GeofenceSessionController>((ref) {
  final controller = GeofenceSessionController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

/// Foreground GPS poll → nearby → entered (deduped per campaign).
class GeofenceSessionController {
  GeofenceSessionController(this._ref);

  final Ref _ref;
  final LocationService _location = const LocationService();
  final Set<String> _enteredCampaignIds = <String>{};
  Timer? _pollTimer;
  bool _running = false;
  bool _scanInFlight = false;
  bool _askedPermissionThisSession = false;

  static const _pollInterval = Duration(seconds: 75);

  GeofenceRepository get _repo => _ref.read(geofenceRepositoryProvider);

  void start() {
    if (_running) return;
    final storage = _ref.read(storageServiceProvider);
    if (!storage.hasSession) return;
    _running = true;
    unawaited(scan(forcePermissionPrompt: true));
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      _pollInterval,
      (_) => unawaited(scan()),
    );
  }

  void stop() {
    _running = false;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void dispose() {
    stop();
  }

  /// Call on app resume / shell mount.
  Future<void> scan({bool forcePermissionPrompt = false}) async {
    if (!_running || _scanInFlight) return;
    final storage = _ref.read(storageServiceProvider);
    if (!storage.hasSession) return;

    _scanInFlight = true;
    try {
      final shouldAsk =
          forcePermissionPrompt || !_askedPermissionThisSession;
      if (shouldAsk) {
        _askedPermissionThisSession = true;
      }

      final outcome = await _location.requestPermission();
      if (outcome != LocationPermissionOutcome.granted) {
        if (shouldAsk) {
          _ref.read(geofenceLocationPromptProvider.notifier).state = outcome;
        }
        return;
      }

      late final double lat;
      late final double lng;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 12),
          ),
        );
        lat = position.latitude;
        lng = position.longitude;
      } catch (e, st) {
        appLogger.e('Geofence GPS fix failed', error: e, stackTrace: st);
        return;
      }

      final fences = await _repo.nearby(lat: lat, lng: lng);
      for (final fence in fences) {
        if (!fence.isInside) continue;
        if (_enteredCampaignIds.contains(fence.campaignId)) continue;

        final result = await _repo.entered(
          campaignId: fence.campaignId,
          lat: lat,
          lng: lng,
        );
        if (result == null || result.trigger.id.isEmpty) continue;

        _enteredCampaignIds.add(fence.campaignId);

        if (!result.alreadyTriggered) {
          _ref.read(geofenceLastUnlockProvider.notifier).state = result;
        }
      }
    } catch (e, st) {
      appLogger.e('Geofence scan failed', error: e, stackTrace: st);
    } finally {
      _scanInFlight = false;
    }
  }

  Future<void> retryPermissionFromSettings() async {
    final outcome = await _location.requestPermission();
    if (outcome == LocationPermissionOutcome.serviceDisabled) {
      await _location.openLocationSettings();
      return;
    }
    if (outcome == LocationPermissionOutcome.deniedForever) {
      await _location.openAppSettings();
      return;
    }
    if (outcome == LocationPermissionOutcome.denied) {
      // Show OS dialog again if still possible.
      final again = await _location.requestPermission();
      if (again != LocationPermissionOutcome.granted) {
        _ref.read(geofenceLocationPromptProvider.notifier).state = again;
        return;
      }
    }
    if (outcome == LocationPermissionOutcome.granted ||
        await _location.ensurePermission()) {
      _ref.read(geofenceLocationPromptProvider.notifier).state = null;
      await scan(forcePermissionPrompt: false);
    }
  }
}
