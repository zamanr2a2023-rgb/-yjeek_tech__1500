import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/notifications/model/customer_notification.dart';

void main() {
  test('parses grouped customer notification inbox', () {
    final inbox = NotificationsInbox.fromJson({
      'success': true,
      'data': {
        'today': [
          {
            'id': 'n_1',
            'orderId': 'ord_1',
            'type': 'ORDER_UPDATE',
            'title': 'Order confirmed!',
            'body': 'Order #YJK-1 sent to VEERA.',
            'isRead': false,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          },
        ],
        'earlier': [
          {
            'id': 'n_2',
            'type': 'PROMO',
            'title': 'Weekend offer',
            'body': 'Get 10% off.',
            'isRead': true,
            'createdAt': DateTime.now()
                .subtract(const Duration(days: 2))
                .toUtc()
                .toIso8601String(),
          },
        ],
        'unreadCount': 1,
      },
    });

    expect(inbox.today, hasLength(1));
    expect(inbox.today.first.orderId, 'ord_1');
    expect(inbox.earlier, hasLength(1));
    expect(inbox.unreadCount, 1);
    expect(inbox.markRead('n_1').unreadCount, 0);
    expect(inbox.markAllRead().hasUnread, isFalse);
  });

  test('parses unread count aliases', () {
    final fromCount = NotificationsInbox.fromJson({
      'data': {'today': [], 'earlier': [], 'count': 4},
    });
    expect(fromCount.unreadCount, 4);
  });
}
