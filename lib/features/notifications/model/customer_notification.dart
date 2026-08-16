class CustomerNotification {
  const CustomerNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.orderId,
    this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final String? orderId;
  final DateTime? createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  String get displayTime {
    final at = createdAt;
    if (at == null) return '';

    final now = DateTime.now();
    final local = at.toLocal();
    final diff = now.difference(local);
    if (diff.inSeconds < 60) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24 && _isSameDay(now, local)) {
      return '${diff.inHours}h';
    }
    if (_isYesterday(now, local)) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${local.day}/${local.month}';
  }

  bool get hasOrder => orderId != null && orderId!.trim().isNotEmpty;

  CustomerNotification copyWith({bool? isRead}) {
    return CustomerNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      orderId: orderId,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata,
    );
  }

  factory CustomerNotification.fromJson(Map<String, dynamic> json) {
    return CustomerNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ??
          json['message']?.toString() ??
          json['description']?.toString() ??
          '',
      type: json['type']?.toString() ?? '',
      orderId: _optionalString(json['orderId'] ?? json['order_id']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      isRead: json['isRead'] == true ||
          json['read'] == true ||
          json['is_read'] == true,
      metadata: _asMap(json['metadata']),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool _isYesterday(DateTime now, DateTime at) {
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    return _isSameDay(yesterday, at);
  }

  static String? _optionalString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}

class NotificationsInbox {
  const NotificationsInbox({
    required this.today,
    required this.earlier,
    required this.unreadCount,
  });

  final List<CustomerNotification> today;
  final List<CustomerNotification> earlier;
  final int unreadCount;

  bool get isEmpty => today.isEmpty && earlier.isEmpty;

  bool get hasUnread => unreadCount > 0;

  List<CustomerNotification> get all => [...today, ...earlier];

  factory NotificationsInbox.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final map = data is Map ? Map<String, dynamic>.from(data) : json;

    final parsedToday = _parseList(map['today']);
    final parsedEarlier = _parseList(map['earlier']);
    final flat = _parseList(map['items'] ?? map['notifications']);
    final combined = [
      ...parsedToday,
      ...parsedEarlier,
      if (parsedToday.isEmpty && parsedEarlier.isEmpty) ...flat,
    ];

    final grouped = _groupByLocalDay(combined);
    final unreadCount = _asInt(map['unreadCount'] ?? map['count']) ??
        grouped.all.where((item) => !item.isRead).length;

    if (combined.isNotEmpty && combined.every((item) => item.createdAt == null)) {
      return NotificationsInbox(
        today: parsedToday,
        earlier: parsedEarlier.isNotEmpty ? parsedEarlier : flat,
        unreadCount: unreadCount,
      );
    }

    return NotificationsInbox(
      today: grouped.today,
      earlier: grouped.earlier,
      unreadCount: unreadCount,
    );
  }

  NotificationsInbox markRead(String id) {
    final nextToday = today
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList(growable: false);
    final nextEarlier = earlier
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList(growable: false);
    return NotificationsInbox(
      today: nextToday,
      earlier: nextEarlier,
      unreadCount: [...nextToday, ...nextEarlier]
          .where((item) => !item.isRead)
          .length,
    );
  }

  NotificationsInbox markAllRead() {
    return NotificationsInbox(
      today: today
          .map((item) => item.copyWith(isRead: true))
          .toList(growable: false),
      earlier: earlier
          .map((item) => item.copyWith(isRead: true))
          .toList(growable: false),
      unreadCount: 0,
    );
  }

  static List<CustomerNotification> _parseList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (item) => CustomerNotification.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static NotificationsInbox _groupByLocalDay(List<CustomerNotification> items) {
    final startOfToday = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final today = <CustomerNotification>[];
    final earlier = <CustomerNotification>[];
    for (final item in items) {
      final at = item.createdAt?.toLocal();
      if (at != null && !at.isBefore(startOfToday)) {
        today.add(item);
      } else {
        earlier.add(item);
      }
    }
    return NotificationsInbox(
      today: List<CustomerNotification>.unmodifiable(today),
      earlier: List<CustomerNotification>.unmodifiable(earlier),
      unreadCount: items.where((item) => !item.isRead).length,
    );
  }
}
