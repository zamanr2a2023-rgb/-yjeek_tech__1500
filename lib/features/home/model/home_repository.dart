import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/home/model/home_feed.dart';

class HomeRepository {
  const HomeRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  /// GET /home — optional Bearer token for personalized greeting / address.
  Future<HomeFeed> fetchHome() async {
    final response = await _apiClient.getJson(
      '/home',
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return HomeFeed.fallback();
    }
    return HomeFeed.fromJson(data);
  }
}
