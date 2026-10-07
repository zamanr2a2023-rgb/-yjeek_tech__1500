import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/cart/model/zood_promo.dart';

class ZoodRepository {
  const ZoodRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  Future<ZoodPromo?> fetchPromo() async {
    final response = await _apiClient.getJson('/zood', bearerToken: _token);
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;
    return ZoodPromo.fromJson(data);
  }

  Future<bool> joinWaitlist({
    String source = 'checkout',
    required String screen,
  }) async {
    final response = await _apiClient.postJson(
      '/zood/waitlist',
      {
        'source': source,
        'screen': screen,
      },
      bearerToken: _token,
    );
    return response.ok;
  }

  Future<bool> dismissWaitlist() async {
    final response = await _apiClient.postJson(
      '/zood/waitlist/dismiss',
      const {},
      bearerToken: _token,
    );
    return response.ok;
  }
}
