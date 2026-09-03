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
    this.conversationId,
    this.conversationStatus,
    this.reused = false,
  });

  final String id;
  final String displayCode;
  final String subject;
  final String status;
  final String? remark;
  final String? issueType;
  final String? orderId;
  final String? orderNumber;
  final String? conversationId;
  final String? conversationStatus;
  final bool reused;

  bool get isActive =>
      status.toUpperCase() == 'OPEN' || status.toUpperCase() == 'PENDING';

  bool get isClosed =>
      status.toUpperCase() == 'RESOLVED' ||
      conversationStatus?.toUpperCase() == 'CLOSED' ||
      conversationStatus?.toUpperCase() == 'RESOLVED';

  bool get canChat => isActive && !isClosed;

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
      conversationId: json['conversationId']?.toString(),
      conversationStatus: json['conversationStatus']?.toString(),
      reused: json['reused'] == true,
    );
  }
}

class SupportActiveTicketResult {
  const SupportActiveTicketResult({
    required this.ticket,
    required this.canCreateNew,
  });

  final SupportTicketItem? ticket;
  final bool canCreateNew;
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

  /// GET /support/tickets
  Future<List<SupportTicketItem>> listTickets({
    String? orderId,
    String? status,
  }) async {
    final query = <String, String>{};
    if (orderId != null && orderId.isNotEmpty) query['orderId'] = orderId;
    if (status != null && status.isNotEmpty) query['status'] = status;

    final path = query.isEmpty
        ? '/support/tickets'
        : '/support/tickets?${Uri(queryParameters: query).query}';

    final response = await _apiClient.getJson(
      path,
      bearerToken: _token,
    );
    final data = response?['data'];
    final rows = data is Map<String, dynamic> ? data['tickets'] : data;
    if (rows is! List) return const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(SupportTicketItem.fromJson)
        .toList();
  }

  /// GET /support/tickets/orders/:orderId/active
  Future<SupportActiveTicketResult?> getActiveTicketForOrder(
    String orderId,
  ) async {
    final response = await _apiClient.getJson(
      '/support/tickets/orders/$orderId/active',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;
    final ticketJson = data['ticket'];
    return SupportActiveTicketResult(
      ticket: ticketJson is Map<String, dynamic>
          ? SupportTicketItem.fromJson(ticketJson)
          : null,
      canCreateNew: data['canCreateNew'] == true,
    );
  }

  Future<SupportTicketItem?> findActiveTicketForOrder(String orderId) async {
    final result = await getActiveTicketForOrder(orderId);
    return result?.ticket;
  }

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
