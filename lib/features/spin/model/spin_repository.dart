import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/spin/model/spin_models.dart';

class SpinRepository {
  const SpinRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  Future<SpinActiveResponse> fetchActive() async {
    final response = await _apiClient.getJson(
      '/customer/spin/active',
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return const SpinActiveResponse();
    return SpinActiveResponse.fromJson(data);
  }

  Future<SpinDrawResult> draw({required String campaignId}) async {
    final response = await _apiClient.postJson(
      '/customer/spin/draw',
      {'campaignId': campaignId},
      bearerToken: _storage.token,
    );
    if (!response.ok) {
      final code = response.errorCode ?? '';
      if (code == 'SPIN_NONE_LEFT') {
        throw SpinException('No spins left today');
      }
      throw SpinException(response.message ?? 'Spin failed');
    }
    final data = response.data;
    if (data == null) throw SpinException('Invalid spin response');
    return SpinDrawResult.fromJson(data);
  }
}

class SpinException implements Exception {
  SpinException(this.message);
  final String message;
  @override
  String toString() => message;
}
