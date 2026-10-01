import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/referral/model/referral_models.dart';

class ReferralRepository {
  const ReferralRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  Future<ReferralMe> fetchMe() async {
    final response = await _apiClient.getJson(
      '/customer/referral/me',
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return const ReferralMe(
        programmeEnabled: false,
        inviterRewardAmount: '0.000',
        inviteeRewardAmount: '0.000',
        minOrderAmount: '0.000',
        remainingDay: 0,
        remainingMonth: 0,
      );
    }
    return ReferralMe.fromJson(data);
  }

  Future<ReferralInviteResult> sendInvite({required String phone}) async {
    final response = await _apiClient.postJson(
      '/customer/referral/invites',
      {'phone': phone},
      bearerToken: _storage.token,
    );
    if (!response.ok) {
      throw Exception(response.message ?? 'Could not send invite');
    }
    final data = response.data;
    if (data == null) throw Exception('Invalid invite response');
    return ReferralInviteResult.fromJson(data);
  }

  Future<List<ReferralInviteRow>> fetchInvites() async {
    final response = await _apiClient.getJson(
      '/customer/referral/invites',
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return const [];
    final items = data['items'];
    if (items is! List) return const [];
    final out = <ReferralInviteRow>[];
    for (final raw in items) {
      if (raw is Map<String, dynamic>) {
        out.add(ReferralInviteRow.fromJson(raw));
      }
    }
    return out;
  }
}
