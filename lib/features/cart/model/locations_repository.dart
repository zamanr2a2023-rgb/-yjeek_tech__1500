import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';

class LocationSuggestion {
  const LocationSuggestion({
    required this.id,
    required this.title,
    this.subtitle,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String title;
  final String? subtitle;
  final double? latitude;
  final double? longitude;
}

class ReverseGeocodeResult {
  const ReverseGeocodeResult({
    required this.label,
    this.area,
    this.road,
    this.block,
    this.city,
    this.latitude,
    this.longitude,
  });

  final String label;
  final String? area;
  final String? road;
  final String? block;
  final String? city;
  final double? latitude;
  final double? longitude;
}

class LocationsRepository {
  const LocationsRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /locations/reverse?lat=&lng=
  Future<ReverseGeocodeResult?> reverse({
    required double lat,
    required double lng,
  }) async {
    final response = await _apiClient.getJson(
      '/locations/reverse?lat=$lat&lng=$lng',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;
    return ReverseGeocodeResult(
      label: data['label']?.toString() ??
          data['formatted']?.toString() ??
          data['address']?.toString() ??
          'Selected location',
      area: data['area']?.toString(),
      road: data['road']?.toString(),
      block: data['block']?.toString(),
      city: data['city']?.toString(),
      latitude: (data['latitude'] as num?)?.toDouble() ?? lat,
      longitude: (data['longitude'] as num?)?.toDouble() ?? lng,
    );
  }

  /// GET /locations/search?q=
  Future<List<LocationSuggestion>> search(String query) async {
    if (query.trim().isEmpty) return const [];
    final response = await _apiClient.getJson(
      '/locations/search?q=${Uri.encodeQueryComponent(query.trim())}',
      bearerToken: _token,
    );
    final data = response?['data'];
    final rows = data is Map ? (data['results'] ?? data['items']) : data;
    if (rows is! List) return const [];
    final out = <LocationSuggestion>[];
    for (final row in rows) {
      if (row is! Map) continue;
      final id = row['placeId']?.toString() ??
          row['id']?.toString() ??
          row['title']?.toString() ??
          '';
      final title = row['title']?.toString() ??
          row['name']?.toString() ??
          row['label']?.toString() ??
          '';
      if (id.isEmpty || title.isEmpty) continue;
      out.add(
        LocationSuggestion(
          id: id,
          title: title,
          subtitle: row['subtitle']?.toString() ?? row['address']?.toString(),
          latitude: (row['latitude'] as num?)?.toDouble(),
          longitude: (row['longitude'] as num?)?.toDouble(),
        ),
      );
    }
    return out;
  }

  /// GET /locations/places/:placeId
  Future<ReverseGeocodeResult?> placeDetails(String placeId) async {
    final response = await _apiClient.getJson(
      '/locations/places/${Uri.encodeComponent(placeId)}',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;
    return ReverseGeocodeResult(
      label: data['label']?.toString() ??
          data['formatted']?.toString() ??
          data['address']?.toString() ??
          'Selected location',
      area: data['area']?.toString(),
      road: data['road']?.toString(),
      block: data['block']?.toString(),
      city: data['city']?.toString(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }
}
