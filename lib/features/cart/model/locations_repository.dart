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

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  ReverseGeocodeResult _parseDetected(
    Map<String, dynamic> map, {
    double? fallbackLat,
    double? fallbackLng,
  }) {
    final title = map['title']?.toString();
    final formatted = map['formattedAddress']?.toString();
    final label = (title != null && title.isNotEmpty)
        ? title
        : (formatted != null && formatted.isNotEmpty)
            ? formatted
            : map['label']?.toString() ??
                map['address']?.toString() ??
                'Selected location';
    return ReverseGeocodeResult(
      label: label,
      area: map['area']?.toString(),
      road: map['road']?.toString(),
      block: map['block']?.toString(),
      city: map['city']?.toString(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? fallbackLat,
      longitude: (map['longitude'] as num?)?.toDouble() ?? fallbackLng,
    );
  }

  /// GET /locations/reverse?latitude=&longitude=
  Future<ReverseGeocodeResult?> reverse({
    required double lat,
    required double lng,
  }) async {
    final response = await _apiClient.getJson(
      '/locations/reverse?latitude=$lat&longitude=$lng',
      bearerToken: _token,
    );
    final data = _asMap(response?['data']);
    if (data == null) return null;
    final detected = _asMap(data['detected']) ?? data;
    return _parseDetected(detected, fallbackLat: lat, fallbackLng: lng);
  }

  /// GET /locations/search?q=
  Future<List<LocationSuggestion>> search(String query) async {
    if (query.trim().isEmpty) return const [];
    final response = await _apiClient.getJson(
      '/locations/search?q=${Uri.encodeQueryComponent(query.trim())}',
      bearerToken: _token,
    );
    final data = response?['data'];
    final rows = data is Map
        ? (data['predictions'] ?? data['results'] ?? data['items'])
        : data;
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
    final data = _asMap(response?['data']);
    if (data == null) return null;
    return _parseDetected(data);
  }
}
