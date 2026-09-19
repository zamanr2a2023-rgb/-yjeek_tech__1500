import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/geofence/model/geofence_models.dart';

/// Customer Geofence Offers API (`/geofence/*`).
class GeofenceRepository {
  const GeofenceRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /geofence/nearby?latitude=&longitude=
  Future<List<GeofenceFence>> nearby({
    required double lat,
    required double lng,
    int limit = 15,
  }) async {
    final response = await _apiClient.getJson(
      '/geofence/nearby?latitude=$lat&longitude=$lng&limit=$limit',
      bearerToken: _token,
    );
    final data = response?['data'];
    final fencesRaw = data is Map ? data['fences'] : null;
    if (fencesRaw is! List) return const [];
    return fencesRaw
        .whereType<Map>()
        .map((row) => GeofenceFence.fromJson(Map<String, dynamic>.from(row)))
        .where((f) => f.campaignId.isNotEmpty)
        .toList(growable: false);
  }

  /// POST /geofence/events — ENTER | APP_OPEN | APP_RESUME
  Future<GeofenceLocationEventResult?> postLocationEvent({
    required double lat,
    required double lng,
    required GeofenceEventType eventType,
    String? campaignId,
  }) async {
    final body = <String, dynamic>{
      'latitude': lat,
      'longitude': lng,
      'eventType': eventType.apiValue,
      if (campaignId != null && campaignId.isNotEmpty) 'campaignId': campaignId,
    };
    final response = await _apiClient.postJson(
      '/geofence/events',
      body,
      bearerToken: _token,
    );
    if (!response.ok || response.data == null) return null;
    return GeofenceLocationEventResult.fromJson(response.data!);
  }

  /// GET /geofence/active-offers — Home section (no activation side effects).
  Future<List<ActiveGeofenceOffer>> fetchActiveOffers() async {
    final response = await _apiClient.getJson(
      '/geofence/active-offers',
      bearerToken: _token,
    );
    final data = response?['data'];
    final offersRaw = data is Map ? data['offers'] : null;
    if (offersRaw is! List) return const [];
    return offersRaw
        .whereType<Map>()
        .map(
          (row) => ActiveGeofenceOffer.fromJson(Map<String, dynamic>.from(row)),
        )
        .where((o) => o.triggerId.isNotEmpty && o.isActive)
        .toList(growable: false);
  }

  /// POST /geofence/entered (legacy ENTER for a known campaign).
  Future<GeofenceEnterResult?> entered({
    required String campaignId,
    required double lat,
    required double lng,
  }) async {
    final response = await _apiClient.postJson(
      '/geofence/entered',
      {
        'campaignId': campaignId,
        'latitude': lat,
        'longitude': lng,
      },
      bearerToken: _token,
    );
    if (!response.ok) return null;
    final data = response.data;
    if (data == null) return null;
    return GeofenceEnterResult.fromJson(data, campaignId: campaignId);
  }

  /// POST /geofence/triggers/:triggerId/opened
  Future<bool> markOpened(String triggerId) async {
    final id = triggerId.trim();
    if (id.isEmpty) return false;
    final response = await _apiClient.postJson(
      '/geofence/triggers/$id/opened',
      const {},
      bearerToken: _token,
    );
    return response.ok;
  }
}
