import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/rewards/model/rewards_summary.dart';

class RewardsRepository {
  const RewardsRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /customer/rewards/summary
  Future<RewardsSummary> fetchSummary() async {
    final response = await _apiClient.getJson(
      '/customer/rewards/summary',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return RewardsSummary.empty;
    return RewardsSummary.fromJson(data);
  }
}
