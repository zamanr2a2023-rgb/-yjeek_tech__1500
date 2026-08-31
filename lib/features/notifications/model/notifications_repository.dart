import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/notifications/model/customer_notification.dart';

class NotificationsRepository {
  const NotificationsRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /notifications
  Future<NotificationsInbox> fetchInbox({int limit = 50}) async {
    if (!_storage.hasSession) {
      return const NotificationsInbox(
        today: [],
        earlier: [],
        unreadCount: 0,
      );
    }

    final response = await _apiClient.getJson(
      '/notifications?limit=$limit',
      bearerToken: _token,
    );
    if (response == null) {
      throw const FormatException('Failed to load notifications');
    }
    return NotificationsInbox.fromJson(response);
  }

  /// GET /notifications/unread-count
  Future<int> fetchUnreadCount() async {
    if (!_storage.hasSession) return 0;

    final response = await _apiClient.getJson(
      '/notifications/unread-count',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final value = map['unreadCount'] ?? map['count'];
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  /// PATCH /notifications/:id/read
  Future<bool> markRead(String id) async {
    if (!_storage.hasSession || id.trim().isEmpty) return false;
    final response = await _apiClient.patchJson(
      '/notifications/${Uri.encodeComponent(id.trim())}/read',
      const {},
      bearerToken: _token,
    );
    return response.ok;
  }

  /// POST /notifications/mark-all-read
  Future<bool> markAllRead() async {
    if (!_storage.hasSession) return false;
    final response = await _apiClient.postJson(
      '/notifications/mark-all-read',
      const {},
      bearerToken: _token,
    );
    return response.ok;
  }

  /// POST /users/me/devices
  Future<bool> registerDevice({
    required String token,
    required String platform,
    String provider = 'FCM',
  }) async {
    if (!_storage.hasSession || token.trim().isEmpty) return false;
    final response = await _apiClient.postJson(
      '/users/me/devices',
      {
        'token': token.trim(),
        'platform': platform,
        'provider': provider,
      },
      bearerToken: _token,
    );
    return response.ok;
  }

  /// DELETE /users/me/devices/:token
  Future<bool> unregisterDevice(String token) async {
    if (!_storage.hasSession || token.trim().isEmpty) return false;
    final response = await _apiClient.deleteJson(
      '/users/me/devices/${Uri.encodeComponent(token.trim())}',
      bearerToken: _token,
    );
    return response.ok;
  }
}
