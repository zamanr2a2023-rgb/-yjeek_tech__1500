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
    final formattedAddress = map['formattedAddress']?.toString();
    final label = (title != null && title.isNotEmpty)
        ? title
        : (formattedAddress != null && formattedAddress.isNotEmpty)
            ? formattedAddress
            : map['label']?.toString() ??
                map['address']?.toString() ??
                'Selected location';
    final formatted = [
      formattedAddress,
      map['subtitle']?.toString(),
      label,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');
    return ReverseGeocodeResult(
      label: label,
      area: _trimOrNull(map['area']?.toString()),
      road: _roadPart(map['road']?.toString()) ?? _captureRoad(formatted),
      block: _blockPart(map['block']?.toString()) ?? _captureBlock(formatted),
      city: _trimOrNull(map['city']?.toString()),
      latitude: (map['latitude'] as num?)?.toDouble() ?? fallbackLat,
      longitude: (map['longitude'] as num?)?.toDouble() ?? fallbackLng,
    );
  }

  String? _trimOrNull(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? _roadPart(String? raw) {
    final value = _trimOrNull(raw);
    if (value == null) return null;
    return _captureRoad(value) ?? value;
  }

  String? _blockPart(String? raw) {
    final value = _trimOrNull(raw);
    if (value == null) return null;
    return _captureBlock(value) ??
        value.replaceFirst(RegExp(r'^block\s*', caseSensitive: false), '').trim();
  }

  String? _captureBlock(String text) {
    final match = RegExp(r'\bblock\s*(\d+[a-zA-Z]?)', caseSensitive: false)
        .firstMatch(text);
    return match?.group(1);
  }

  String? _captureRoad(String text) {
    final match = RegExp(
      r'\b(?:road|rd\.?)\s*(?:no\.?\s*)?(\d+[a-zA-Z]?)',
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(1);
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
    return _fromPayload(data, fallbackLat: lat, fallbackLng: lng);
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
    return _fromPayload(data);
  }

  /// Prefer the richest row. The first geocode hit is often only the area
  /// (Seef) while a later hit has the road and block.
  ReverseGeocodeResult? _fromPayload(
    Map<String, dynamic> data, {
    double? fallbackLat,
    double? fallbackLng,
  }) {
    final rows = <Map<String, dynamic>>[];
    final detected = _asMap(data['detected']);
    if (detected != null) rows.add(detected);
    final results = data['results'];
    if (results is List) {
      for (final row in results) {
        final map = _asMap(row);
        if (map != null) rows.add(map);
      }
    }
    if (rows.isEmpty) rows.add(data);

    ReverseGeocodeResult? merged;
    for (final row in rows) {
      final next = _parseDetected(row, fallbackLat: fallbackLat, fallbackLng: fallbackLng);
      merged = merged == null ? next : _fillMissing(merged, next);
    }
    return merged;
  }

  ReverseGeocodeResult _fillMissing(
    ReverseGeocodeResult base,
    ReverseGeocodeResult extra,
  ) {
    return ReverseGeocodeResult(
      label: base.label,
      area: _nonEmpty(base.area) ?? _nonEmpty(extra.area),
      road: _nonEmpty(base.road) ?? _nonEmpty(extra.road),
      block: _nonEmpty(base.block) ?? _nonEmpty(extra.block),
      city: _nonEmpty(base.city) ?? _nonEmpty(extra.city),
      latitude: base.latitude ?? extra.latitude,
      longitude: base.longitude ?? extra.longitude,
    );
  }

  String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
