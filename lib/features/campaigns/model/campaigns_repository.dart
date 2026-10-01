import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/features/campaigns/model/campaign_models.dart';

class CampaignsRepository {
  const CampaignsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<CampaignWindowsResponse> fetchWindows({String? vendorId}) async {
    final query = vendorId != null && vendorId.isNotEmpty
        ? '?vendorId=${Uri.encodeQueryComponent(vendorId)}'
        : '';
    final response = await _apiClient.getJson('/customer/campaigns/windows$query');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return const CampaignWindowsResponse(
        timezone: 'Asia/Bahrain',
        campaigns: [],
      );
    }
    return CampaignWindowsResponse.fromJson(data);
  }

  Future<OnTimePromiseCampaign> fetchOnTimePromise() async {
    final response =
        await _apiClient.getJson('/customer/campaigns/on-time-promise');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return const OnTimePromiseCampaign(active: false);
    }
    return OnTimePromiseCampaign.fromJson(data);
  }
}
