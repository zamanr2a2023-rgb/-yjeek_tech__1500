import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';

class ZoodStatus {
  const ZoodStatus({
    required this.joined,
    required this.dismissed,
    this.title,
    this.subtitle,
  });

  final bool joined;
  final bool dismissed;
  final String? title;
  final String? subtitle;

  factory ZoodStatus.fromJson(Map<String, dynamic> json) {
    return ZoodStatus(
      joined: json['joined'] == true ||
          json['waitlistJoined'] == true ||
          json['zoodWaitlistJoinedAt'] != null,
      dismissed: json['dismissed'] == true ||
          json['waitlistDismissed'] == true ||
          json['zoodWaitlistDismissedAt'] != null,
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString() ?? json['message']?.toString(),
    );
  }
}

class ZoodRepository {
  const ZoodRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  Future<ZoodStatus?> fetchStatus() async {
    final response = await _apiClient.getJson('/zood', bearerToken: _token);
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;
    return ZoodStatus.fromJson(data);
  }

  Future<bool> joinWaitlist() async {
    final response = await _apiClient.postJson(
      '/zood/waitlist',
      const {},
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
