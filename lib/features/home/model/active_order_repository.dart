import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';

class ActiveOrderRepository {
  const ActiveOrderRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  /// Returns the active order payload, or null when the API reports no
  /// active order (`{"success": true, "data": null}`).
  Future<Map<String, dynamic>?> fetchActiveOrder() async {
    final response = await _apiClient.getJson(
      '/orders/active',
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    return data is Map<String, dynamic> ? data : null;
  }
}
