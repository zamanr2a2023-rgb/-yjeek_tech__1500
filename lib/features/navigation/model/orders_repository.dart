import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

class OrdersRepository {
  const OrdersRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /orders?status=&orderType=
  Future<List<OrderHistoryItem>> listOrders({
    String status = 'all',
    OrderCategoryFilter? category,
  }) async {
    final params = <String, String>{'status': status};
    final orderType = _orderTypeForCategory(category);
    if (orderType != null) params['orderType'] = orderType;

    final qs = params.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}='
              '${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');

    final response = await _apiClient.getJson(
      '/orders?$qs',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! List) return const [];

    final items = <OrderHistoryItem>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = orderHistoryItemFromJson(raw);
      if (mapped != null) items.add(mapped);
    }
    return items;
  }

  /// GET /orders/:id
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    final response = await _apiClient.getJson(
      '/orders/$orderId',
      bearerToken: _token,
    );
    final data = response?['data'];
    return data is Map<String, dynamic> ? data : null;
  }

  /// GET /orders/:id/track
  Future<Map<String, dynamic>?> trackOrder(String orderId) async {
    final response = await _apiClient.getJson(
      '/orders/$orderId/track',
      bearerToken: _token,
    );
    final data = response?['data'];
    return data is Map<String, dynamic> ? data : null;
  }

  /// GET /orders/:id/receipt
  Future<Map<String, dynamic>?> getReceipt(String orderId) async {
    final response = await _apiClient.getJson(
      '/orders/$orderId/receipt',
      bearerToken: _token,
    );
    final data = response?['data'];
    return data is Map<String, dynamic> ? data : null;
  }

  /// POST /orders/:id/reorder
  Future<bool> reorder(String orderId) async {
    final response = await _apiClient.postJson(
      '/orders/$orderId/reorder',
      const {},
      bearerToken: _token,
    );
    return response.ok;
  }

  /// POST /orders/:id/cancel
  Future<bool> cancel(String orderId, {String? reason}) async {
    final response = await _apiClient.postJson(
      '/orders/$orderId/cancel',
      {if (reason != null && reason.isNotEmpty) 'reason': reason},
      bearerToken: _token,
    );
    return response.ok;
  }

  /// POST /orders/:orderId/reviews
  Future<bool> submitReview(
    String orderId, {
    int? orderRating,
    int? driverRating,
    int? foodRating,
    String? comment,
  }) async {
    final body = <String, dynamic>{
      if (orderRating != null) 'orderRating': orderRating,
      if (driverRating != null) 'driverRating': driverRating,
      if (foodRating != null) 'foodRating': foodRating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    final response = await _apiClient.postJson(
      '/orders/$orderId/reviews',
      body,
      bearerToken: _token,
    );
    return response.ok;
  }

  /// GET /support/issue-types
  Future<List<Map<String, dynamic>>> fetchIssueTypes() async {
    final response = await _apiClient.getJson(
      '/support/issue-types',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['issueTypes'] ?? data['types'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  /// POST /support/tickets
  Future<bool> createSupportTicket({
    required String subject,
    String? remark,
    String? orderId,
    String? issueType,
  }) async {
    final response = await _apiClient.postJson(
      '/support/tickets',
      {
        'subject': subject,
        if (remark != null) 'remark': remark,
        if (orderId != null) 'orderId': orderId,
        if (issueType != null) 'issueType': issueType,
      },
      bearerToken: _token,
    );
    return response.ok;
  }
}

String? _orderTypeForCategory(OrderCategoryFilter? category) {
  return switch (category) {
    OrderCategoryFilter.orders => 'DELIVERY',
    OrderCategoryFilter.services => 'SERVICE',
    OrderCategoryFilter.dineIn => 'DINE_IN',
    OrderCategoryFilter.pickup => 'PICKUP',
    OrderCategoryFilter.all || null => null,
  };
}

const _activeStatuses = {
  'PLACED',
  'PENDING_VENDOR_ACCEPT',
  'VENDOR_ACCEPTED',
  'AWAITING_PAYMENT',
  'PENDING_CONFIRMATION',
  'CONFIRMED',
  'PREPARING',
  'SEARCHING_DRIVER',
  'AWAITING_DRIVER_CONFIRM',
  'DRIVER_ASSIGNED',
  'ARRIVED_AT_PICKUP',
  'PICKED_UP',
  'IN_TRANSIT',
  'ON_THE_WAY',
  'ARRIVED_AT_CUSTOMER',
  'READY_FOR_PICKUP',
  'READY_FOR_YOU',
  'CUSTOMER_ARRIVED',
  'IN_PROGRESS',
  'READY',
  'UPCOMING',
  'SEATED',
};

OrderHistoryItem? orderHistoryItemFromJson(Map<String, dynamic> json) {
  final id = json['id']?.toString();
  if (id == null || id.isEmpty) return null;

  final vendor = json['vendor'];
  final vendorName = vendor is Map<String, dynamic>
      ? (vendor['name'] as String? ?? 'Vendor')
      : 'Vendor';

  final statusRaw = (json['status'] as String?)?.toUpperCase() ?? '';
  final orderType = (json['orderType'] as String?)?.toUpperCase() ?? 'DELIVERY';
  final fulfillment = (json['fulfillmentType'] as String?)?.toUpperCase();
  final isActive = _activeStatuses.contains(statusRaw);

  final total = json['totalAmount'];
  final price = total is num
      ? 'BHD ${total.toStringAsFixed(3)}'
      : 'BHD ${total?.toString() ?? '0.000'}';

  final itemCount = (json['itemCount'] as num?)?.toInt() ?? 0;
  final createdAt = json['createdAt'] ?? json['relativeVisitAt'];
  final whenLabel = _formatWhen(createdAt);
  final typeLabel = _typeLabel(orderType, fulfillment);
  final subtitle = itemCount > 0
      ? '$typeLabel · $whenLabel · $itemCount ${itemCount == 1 ? 'Item' : 'items'}'
      : '$typeLabel · $whenLabel';

  final etaMin = (json['estimatedArrivalMin'] as num?)?.toInt() ??
      (json['estimatedReadyMin'] as num?)?.toInt();
  final arrivalText = isActive && etaMin != null && etaMin > 0
      ? 'Arriving in $etaMin min'
      : null;

  final category = switch (orderType) {
    'SERVICE' => OrderCategoryFilter.services,
    'DINE_IN' => OrderCategoryFilter.dineIn,
    'PICKUP' => OrderCategoryFilter.pickup,
    _ => OrderCategoryFilter.orders,
  };

  final badge = _badgeFor(statusRaw, orderType, isActive);
  final status = _mapStatus(statusRaw, isActive);
  final actions = isActive
      ? const [NavigationStrings.trackOrder, NavigationStrings.getHelp]
      : const [
          NavigationStrings.receipt,
          NavigationStrings.rate,
          NavigationStrings.reorder,
          NavigationStrings.getHelp,
        ];

  return OrderHistoryItem(
    id: id,
    vendor: vendorName,
    subtitle: subtitle,
    price: price,
    status: status,
    category: category,
    isActive: isActive,
    actions: actions,
    badge: badge,
    arrivalText: arrivalText,
  );
}

OrderStatus _mapStatus(String status, bool isActive) {
  if (status == 'DELIVERED' || status == 'COLLECTED' || status == 'COMPLETED') {
    return OrderStatus.delivered;
  }
  if (status.contains('SCHEDULE') || status == 'CONFIRMED' && isActive) {
    return OrderStatus.upcoming;
  }
  if (isActive) return OrderStatus.active;
  return OrderStatus.inProgress;
}

String _badgeFor(String status, String orderType, bool isActive) {
  if (!isActive) {
    if (status == 'COLLECTED') return 'Collected';
    if (status == 'COMPLETED') return 'Completed';
    return 'Delivered';
  }
  if (status == 'ON_THE_WAY' || status == 'PICKED_UP' || status == 'ARRIVED') {
    return orderType == 'PICKUP' ? 'PICKUP' : 'DELIVERY';
  }
  if (status.contains('PENDING') || status == 'PLACED') return 'Upcoming';
  if (status == 'PREPARING' || status == 'CONFIRMED') return 'Preparing';
  return 'Active';
}

String _typeLabel(String orderType, String? fulfillment) {
  return switch (orderType) {
    'DINE_IN' => 'Dine-in',
    'PICKUP' => 'Pickup',
    'SERVICE' => 'Service',
    _ => fulfillment == 'SCHEDULED' ? 'Scheduled' : 'On-demand',
  };
}

String _formatWhen(dynamic value) {
  if (value == null) return 'Recently';
  final dt = DateTime.tryParse(value.toString())?.toLocal();
  if (dt == null) return 'Recently';
  final now = DateTime.now();
  final tod =
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dt.year, dt.month, dt.day);
  if (day == today) return 'Today $tod';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday $tod';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${dt.day} ${months[dt.month - 1]} $tod';
}
