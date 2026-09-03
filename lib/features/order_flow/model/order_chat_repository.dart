import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';

class OrderChatMessage {
  const OrderChatMessage({
    required this.id,
    required this.body,
    required this.isMine,
    this.senderName,
    this.createdAt,
    this.imageUrls = const [],
  });

  final String id;
  final String body;
  final bool isMine;
  final String? senderName;
  final DateTime? createdAt;
  final List<String> imageUrls;

  factory OrderChatMessage.fromJson(Map<String, dynamic> json, {String? myRole}) {
    final sender = json['sender']?.toString().toUpperCase() ?? '';
    final role = json['senderRole']?.toString().toUpperCase() ?? sender;
    final isMine = role.contains('CUSTOMER') || sender == 'CUSTOMER';
    final imageUrls = <String>[];
    final direct = json['attachments'];
    if (direct is List) {
      for (final item in direct) {
        final url = item?.toString().trim() ?? '';
        if (url.isNotEmpty) imageUrls.add(url);
      }
    }
    final metadata = json['metadata'];
    if (metadata is Map && imageUrls.isEmpty) {
      final raw = metadata['attachments'];
      if (raw is List) {
        for (final item in raw) {
          final url = item?.toString().trim() ?? '';
          if (url.isNotEmpty) imageUrls.add(url);
        }
      }
    }
    return OrderChatMessage(
      id: json['id']?.toString() ?? '',
      body: json['body']?.toString() ?? json['text']?.toString() ?? '',
      isMine: isMine,
      senderName: json['senderName']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      imageUrls: imageUrls,
    );
  }
}

class OrderChatRepository {
  const OrderChatRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /chat/orders/:orderId — returns conversation + messages when present.
  Future<
      ({
        bool ok,
        String? conversationId,
        String? conversationStatus,
        List<OrderChatMessage> messages,
        String? error,
      })> openOrderChat(String orderId) async {
    final response = await _apiClient.getApiResponse(
      '/chat/orders/$orderId',
      bearerToken: _token,
    );
    if (!response.ok) {
      return (
        ok: false,
        conversationId: null,
        conversationStatus: null,
        messages: const <OrderChatMessage>[],
        error: response.message ??
            'Champ not assigned yet — chat unavailable',
      );
    }
    final data = response.data;
    if (data == null) {
      return (
        ok: false,
        conversationId: null,
        conversationStatus: null,
        messages: const <OrderChatMessage>[],
        error: response.message ?? 'Chat unavailable',
      );
    }
    final conversationId =
        data['conversationId']?.toString() ?? data['id']?.toString();
    final lifecycle = data['lifecycle'];
    final conversationStatus = data['status']?.toString() ??
        (lifecycle is Map ? lifecycle['status']?.toString() : null);
    final raw = data['messages'];
    final messages = <OrderChatMessage>[];
    if (raw is List) {
      for (final row in raw) {
        if (row is Map<String, dynamic>) {
          messages.add(OrderChatMessage.fromJson(row));
        }
      }
    }
    return (
      ok: true,
      conversationId: conversationId,
      conversationStatus: conversationStatus,
      messages: messages,
      error: null,
    );
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

  /// GET /chat/quick-replies — prefers full `body` text over short `label`.
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
          if (e is Map) {
            final body = e['body']?.toString().trim();
            if (body != null && body.isNotEmpty) return body;
            return e['text']?.toString() ?? e['label']?.toString() ?? '';
          }
          return '';
        })
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
