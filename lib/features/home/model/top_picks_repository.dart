import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/home/model/top_picks_models.dart';

class TopPicksRepository {
  const TopPicksRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  /// GET /home/top-picks?latitude=&longitude=&limit=
  Future<List<HomeTopPickItem>> fetchTopPicks({
    required double latitude,
    required double longitude,
    int limit = 20,
  }) async {
    if (!latitude.isFinite ||
        !longitude.isFinite ||
        latitude == 0 &&
            longitude == 0) {
      return const [];
    }
    final capped = limit.clamp(1, 50);
    final path =
        '/home/top-picks?latitude=${Uri.encodeQueryComponent(latitude.toString())}'
        '&longitude=${Uri.encodeQueryComponent(longitude.toString())}'
        '&limit=${Uri.encodeQueryComponent(capped.toString())}';

    final response = await _apiClient.getJson(
      path,
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return const [];
    return HomeTopPickItem.parseTopPicksData(data)
        .where((i) => i.isAvailable)
        .toList(growable: false);
  }
}
