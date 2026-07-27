import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';

class OrderChatMessage {
  const OrderChatMessage({
    required this.id,
    required this.body,
    required this.isMine,
    this.senderName,
    this.createdAt,
  });

  final String id;
  final String body;
  final bool isMine;
  final String? senderName;
  final DateTime? createdAt;

  factory OrderChatMessage.fromJson(Map<String, dynamic> json, {String? myRole}) {
    final sender = json['sender']?.toString().toUpperCase() ?? '';
    final role = json['senderRole']?.toString().toUpperCase() ?? sender;
    final isMine = role.contains('CUSTOMER') || sender == 'CUSTOMER';
    return OrderChatMessage(
      id: json['id']?.toString() ?? '',
      body: json['body']?.toString() ?? json['text']?.toString() ?? '',
      isMine: isMine,
      senderName: json['senderName']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class OrderChatRepository {
  const OrderChatRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /chat/orders/:orderId — returns conversation + messages when present.
  Future<({String? conversationId, List<OrderChatMessage> messages})> openOrderChat(
    String orderId,
  ) async {
    final response = await _apiClient.getJson(
      '/chat/orders/$orderId',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return (conversationId: null, messages: const <OrderChatMessage>[]);
    }
    final conversationId =
        data['conversationId']?.toString() ?? data['id']?.toString();
    final raw = data['messages'];
    final messages = <OrderChatMessage>[];
    if (raw is List) {
      for (final row in raw) {
        if (row is Map<String, dynamic>) {
          messages.add(OrderChatMessage.fromJson(row));
        }
      }
    }
    return (conversationId: conversationId, messages: messages);
  }

  /// GET /chat/:conversationId/messages
  Future<List<OrderChatMessage>> listMessages(String conversationId) async {
    final response = await _apiClient.getJson(
      '/chat/$conversationId/messages',
      bearerToken: _token,
    );
    final data = response?['data'];
    final rows = data is Map ? data['messages'] : data;
    if (rows is! List) return const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(OrderChatMessage.fromJson)
        .toList();
  }

  /// POST /chat/orders/:orderId/messages
  Future<OrderChatMessage?> sendMessage(String orderId, String body) async {
    final response = await _apiClient.postJson(
      '/chat/orders/$orderId/messages',
      {'body': body},
      bearerToken: _token,
    );
    if (!response.ok) return null;
    final data = response.data;
    if (data is! Map<String, dynamic>) return null;
    return OrderChatMessage.fromJson(data);
  }

  /// GET /chat/quick-replies
  Future<List<String>> quickReplies() async {
    final response = await _apiClient.getJson(
      '/chat/quick-replies',
      bearerToken: _token,
    );
    final data = response?['data'];
    final rows = data is Map ? (data['replies'] ?? data['items']) : data;
    if (rows is! List) return const [];
    return rows
        .map((e) {
          if (e is String) return e;
          if (e is Map) return e['text']?.toString() ?? e['label']?.toString() ?? '';
          return '';
        })
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
