import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yjeek_app/core/utils/app_logger.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = 'https://api.yjeek.com';

  Future<Map<String, dynamic>?> getJson(String path) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      appLogger.d('GET $uri');
      final response = await _client.get(uri);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      appLogger.w('GET $path failed: ${response.statusCode}');
    } catch (error, stack) {
      appLogger.e('GET $path error', error: error, stackTrace: stack);
    }
    return null;
  }
}
