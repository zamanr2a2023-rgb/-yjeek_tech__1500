import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/ui_content/model/banner_models.dart';

class BannersRepository {
  const BannersRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  /// GET /banners?placementKey=… or ?screen=…
  Future<List<UiBanner>> fetchBanners({
    String? placementKey,
    String? screen,
  }) async {
    final params = <String>[];
    if (placementKey != null && placementKey.isNotEmpty) {
      params.add('placementKey=${Uri.encodeQueryComponent(placementKey)}');
    } else if (screen != null && screen.isNotEmpty) {
      params.add('screen=${Uri.encodeQueryComponent(screen)}');
    }
    final path =
        params.isEmpty ? '/banners' : '/banners?${params.join('&')}';

    final response = await _apiClient.getJson(
      path,
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return const [];

    final raw = data['banners'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((e) => UiBanner.fromJson(Map<String, dynamic>.from(e)))
        .where((b) => b.id.isNotEmpty)
        .toList(growable: false);
  }
}
