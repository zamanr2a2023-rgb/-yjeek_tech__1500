import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/navigation/model/user_me.dart';

class UserRepository {
  const UserRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  /// GET /users/me — requires Bearer token from login.
  Future<UserMe?> fetchMe() async {
    final response = await _apiClient.getJson(
      '/users/me',
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;
    return UserMe.fromJson(data);
  }
}
