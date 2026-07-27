import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';

class SupportTicketItem {
  const SupportTicketItem({
    required this.id,
    required this.displayCode,
    required this.subject,
    required this.status,
    this.remark,
    this.issueType,
    this.orderId,
    this.orderNumber,
  });

  final String id;
  final String displayCode;
  final String subject;
  final String status;
  final String? remark;
  final String? issueType;
  final String? orderId;
  final String? orderNumber;

  factory SupportTicketItem.fromJson(Map<String, dynamic> json) {
    return SupportTicketItem(
      id: json['id']?.toString() ?? '',
      displayCode: json['displayCode']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OPEN',
      remark: json['remark']?.toString(),
      issueType: json['issueType']?.toString(),
      orderId: json['orderId']?.toString(),
      orderNumber: json['orderNumber']?.toString(),
    );
  }
}

class SupportTicketMessage {
  const SupportTicketMessage({
    required this.id,
    required this.sender,
    required this.body,
    this.senderName,
    this.attachments = const [],
    this.createdAt,
  });

  final String id;
  final String sender;
  final String body;
  final String? senderName;
  final List<String> attachments;
  final DateTime? createdAt;

  bool get isCustomer => sender.toUpperCase() == 'CUSTOMER';

  factory SupportTicketMessage.fromJson(Map<String, dynamic> json) {
    final attachments = <String>[];
    final raw = json['attachments'];
    if (raw is List) {
      for (final a in raw) {
        if (a is String && a.isNotEmpty) attachments.add(a);
      }
    }
    return SupportTicketMessage(
      id: json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? 'CUSTOMER',
      body: json['body']?.toString() ?? '',
      senderName: json['senderName']?.toString(),
      attachments: attachments,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class SupportRepository {
  const SupportRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// POST /support/tickets
  Future<SupportTicketItem?> createTicket({
    required String subject,
    String? remark,
    String? orderId,
    String? issueType,
    List<Map<String, dynamic>>? items,
    List<String>? evidenceUrls,
    double? disputedAmount,
  }) async {
    final response = await _apiClient.postJson('/support/tickets', {
      'subject': subject,
      if (remark != null && remark.isNotEmpty) 'remark': remark,
      if (orderId != null && orderId.isNotEmpty) 'orderId': orderId,
      if (issueType != null && issueType.isNotEmpty) 'issueType': issueType,
      if (items != null && items.isNotEmpty) 'items': items,
      if (evidenceUrls != null && evidenceUrls.isNotEmpty)
        'evidenceUrls': evidenceUrls,
      if (disputedAmount != null) 'disputedAmount': disputedAmount,
    }, bearerToken: _token);
    if (!response.ok) return null;
    final data = response.data;
    if (data is! Map<String, dynamic>) return null;
    return SupportTicketItem.fromJson(data);
  }

  /// GET /support/tickets/:id/messages
  Future<List<SupportTicketMessage>> listMessages(String ticketId) async {
    final response = await _apiClient.getJson(
      '/support/tickets/$ticketId/messages',
      bearerToken: _token,
    );
    final data = response?['data'];
    final rows = data is Map<String, dynamic> ? data['messages'] : data;
    if (rows is! List) return const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(SupportTicketMessage.fromJson)
        .toList();
  }

  /// POST /support/tickets/:id/messages
  Future<SupportTicketMessage?> addMessage(
    String ticketId, {
    required String body,
    List<String>? attachments,
  }) async {
    final response = await _apiClient.postJson(
      '/support/tickets/$ticketId/messages',
      {
        'body': body,
        if (attachments != null && attachments.isNotEmpty)
          'attachments': attachments,
      },
      bearerToken: _token,
    );
    if (!response.ok) return null;
    final data = response.data;
    if (data is! Map<String, dynamic>) return null;
    return SupportTicketMessage.fromJson(data);
  }

  /// GET /support/tickets/:id
  Future<SupportTicketItem?> getTicket(String ticketId) async {
    final response = await _apiClient.getJson(
      '/support/tickets/$ticketId',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;
    return SupportTicketItem.fromJson(data);
  }
}
