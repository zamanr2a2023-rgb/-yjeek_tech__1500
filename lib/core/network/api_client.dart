import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yjeek_app/core/constants/api_constants.dart';
import 'package:yjeek_app/core/utils/app_logger.dart';

/// Raw HTTP response wrapper. `statusCode == 0` means the request never
/// reached the server (network error).
class ApiResponse {
  const ApiResponse({required this.statusCode, this.json});

  final int statusCode;
  final Map<String, dynamic>? json;

  bool get ok =>
      statusCode >= 200 && statusCode < 300 && (json?['success'] ?? true) != false;

  bool get isNetworkError => statusCode == 0;

  Map<String, dynamic>? get data {
    final value = json?['data'];
    return value is Map<String, dynamic> ? value : null;
  }

  String? get message {
    final dataMessage = data?['message'];
    if (dataMessage is String) return dataMessage;

    final rootMessage = json?['message'];
    if (rootMessage is String) return rootMessage;

    final error = json?['error'];
    if (error is String) return error;
    if (error is Map) {
      final errorMessage = error['message'];
      if (errorMessage is String) return errorMessage;
    }
    return null;
  }
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // Dev setup: phone reaches the backend over USB via
  // `adb reverse tcp:3000 tcp:3000` (see ApiConstants.baseUrl).
  Future<Map<String, dynamic>?> getJson(
    String path, {
    String? bearerToken,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$path');
      appLogger.d('GET $uri');
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (bearerToken != null && bearerToken.isNotEmpty)
            'Authorization': 'Bearer $bearerToken',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      appLogger.w('GET $path failed: ${response.statusCode}');
    } catch (error, stack) {
      appLogger.e('GET $path error', error: error, stackTrace: stack);
    }
    return null;
  }

  Future<ApiResponse> postJson(
    String path,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    try {
      appLogger.d('POST $uri $body');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (bearerToken != null && bearerToken.isNotEmpty)
            'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode(body),
      );
      Map<String, dynamic>? json;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) json = decoded;
      } catch (_) {}
      if (response.statusCode >= 300) {
        appLogger.w('POST $path failed: ${response.statusCode} ${response.body}');
      }
      return ApiResponse(statusCode: response.statusCode, json: json);
    } catch (error, stack) {
      appLogger.e('POST $path error', error: error, stackTrace: stack);
      return const ApiResponse(statusCode: 0);
    }
  }
}
