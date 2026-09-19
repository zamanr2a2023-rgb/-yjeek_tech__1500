import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/services/location_service.dart';
import 'package:yjeek_app/core/utils/app_logger.dart';
import 'package:yjeek_app/features/geofence/model/active_geofence_order_context.dart';
import 'package:yjeek_app/features/geofence/model/geofence_models.dart';
import 'package:yjeek_app/features/geofence/model/geofence_repository.dart';

/// Latest unlock from ENTER creating a new activation (snackbars).
final geofenceLastUnlockProvider = StateProvider<GeofenceEnterResult?>(
  (ref) => null,
);

/// @deprecated Prefer [activeGeofenceOrderContextProvider]; kept for soft compat.
final pendingGeofencePromoProvider = StateProvider<String?>((ref) => null);

/// Set when geofence needs the user to allow location (snackbar in MainShell).
final geofenceLocationPromptProvider =
    StateProvider<LocationPermissionOutcome?>((ref) => null);

/// Active Home offers — refreshed after events / on demand.
final activeGeofenceOffersProvider =
    StateNotifierProvider<ActiveGeofenceOffersNotifier, List<ActiveGeofenceOffer>>(
  (ref) => ActiveGeofenceOffersNotifier(ref),
);

class ActiveGeofenceOffersNotifier
    extends StateNotifier<List<ActiveGeofenceOffer>> {
  ActiveGeofenceOffersNotifier(this._ref) : super(const []);

  final Ref _ref;

  GeofenceRepository get _repo => _ref.read(geofenceRepositoryProvider);

  Future<void> refresh() async {
    final storage = _ref.read(storageServiceProvider);
    if (!storage.hasSession) {
      state = const [];
      return;
    }
    try {
      final offers = await _repo.fetchActiveOffers();
      state = offers;
      _pruneOrderContext(offers);
    } catch (e, st) {
      appLogger.e('active-offers refresh failed', error: e, stackTrace: st);
    }
  }

  void setFromEvent(List<ActiveGeofenceOffer> offers) {
    state = offers.where((o) => o.isActive).toList(growable: false);
    _pruneOrderContext(state);
  }

  void removeExpiredLocally() {
    final next = state.where((o) => o.isActive).toList(growable: false);
    if (next.length != state.length) {
      state = next;
      _pruneOrderContext(next);
    }
  }

  void _pruneOrderContext(List<ActiveGeofenceOffer> offers) {
    final ctx = _ref.read(activeGeofenceOrderContextProvider);
    if (ctx == null) return;
    final stillValid = offers.any(
      (o) =>
          o.triggerId == ctx.geofenceTriggerId &&
          o.isActive &&
          o.participatingVendors.any((v) => v.vendorId == ctx.vendorId),
    );
    if (!stillValid || ctx.isExpired) {
      _ref.read(activeGeofenceOrderContextProvider.notifier).state = null;
    }
  }
}

final geofenceSessionControllerProvider =
    Provider<GeofenceSessionController>((ref) {
  final controller = GeofenceSessionController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

/// Foreground GPS → /geofence/events + active-offers refresh.
class GeofenceSessionController {
  GeofenceSessionController(this._ref);

  final Ref _ref;
  final LocationService _location = const LocationService();
  final Set<String> _enteredCampaignIds = <String>{};
  Timer? _pollTimer;
  bool _running = false;
  bool _scanInFlight = false;
  bool _askedPermissionThisSession = false;
  bool _didColdOpen = false;

  static const _pollInterval = Duration(seconds: 75);

  GeofenceRepository get _repo => _ref.read(geofenceRepositoryProvider);

  void start() {
    if (_running) return;
    final storage = _ref.read(storageServiceProvider);
    if (!storage.hasSession) return;
    _running = true;
    unawaited(
      scan(
        forcePermissionPrompt: true,
        eventType: _didColdOpen
            ? GeofenceEventType.appResume
            : GeofenceEventType.appOpen,
      ),
    );
    _didColdOpen = true;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      _pollInterval,
      (_) => unawaited(scan(eventType: GeofenceEventType.enter)),
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
  Future<void> scan({
    bool forcePermissionPrompt = false,
    GeofenceEventType eventType = GeofenceEventType.appResume,
  }) async {
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

      if (eventType == GeofenceEventType.appOpen ||
          eventType == GeofenceEventType.appResume) {
        final result = await _repo.postLocationEvent(
          lat: lat,
          lng: lng,
          eventType: eventType,
        );
        if (result != null) {
          _ref
              .read(activeGeofenceOffersProvider.notifier)
              .setFromEvent(result.offers);
          for (final offer in result.offers) {
            _enteredCampaignIds.add(offer.campaignId);
          }
        }
        await _ref.read(activeGeofenceOffersProvider.notifier).refresh();
        return;
      }

      // ENTER path: discover nearby inside fences, then events(ENTER) per campaign.
      final fences = await _repo.nearby(lat: lat, lng: lng);
      for (final fence in fences) {
        if (!fence.isInside) continue;
        if (_enteredCampaignIds.contains(fence.campaignId)) continue;

        final result = await _repo.postLocationEvent(
          lat: lat,
          lng: lng,
          eventType: GeofenceEventType.enter,
          campaignId: fence.campaignId,
        );
        if (result == null) continue;

        _enteredCampaignIds.add(fence.campaignId);
        _ref
            .read(activeGeofenceOffersProvider.notifier)
            .setFromEvent(result.offers);

        final created = result.offers.isNotEmpty &&
            result.notificationScheduled;
        final first = result.offers.isNotEmpty ? result.offers.first : null;
        if (created && first != null) {
          _ref.read(geofenceLastUnlockProvider.notifier).state =
              GeofenceEnterResult(
            alreadyTriggered: false,
            trigger: GeofenceTriggerInfo(
              id: first.triggerId,
              status: first.offerStatus ?? 'TRIGGERED',
              expiresAt: first.expiresAt,
              triggeredAt: first.activatedAt,
            ),
            promoCode: first.discountBadge ?? '',
            vendorName: first.participatingVendors.isNotEmpty
                ? first.participatingVendors.first.name
                : (first.title ?? 'Nearby store'),
            offerWindowMinutes: first.offerWindowMinutes,
            notificationSent: result.notificationScheduled,
            campaignId: first.campaignId,
          );
        } else if (first != null && result.offers.isNotEmpty) {
          // Reused activation — still refresh Home, no snackbar spam.
        }
      }

      await _ref.read(activeGeofenceOffersProvider.notifier).refresh();
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
      final again = await _location.requestPermission();
      if (again != LocationPermissionOutcome.granted) {
        _ref.read(geofenceLocationPromptProvider.notifier).state = again;
        return;
      }
    }
    if (outcome == LocationPermissionOutcome.granted ||
        await _location.ensurePermission()) {
      _ref.read(geofenceLocationPromptProvider.notifier).state = null;
      await scan(
        forcePermissionPrompt: false,
        eventType: GeofenceEventType.appResume,
      );
    }
  }
}
