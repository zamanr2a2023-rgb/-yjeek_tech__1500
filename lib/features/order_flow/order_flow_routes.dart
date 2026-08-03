import 'package:yjeek_app/routes/route_names.dart';

abstract final class OrderFlowRoutes {
  static const waiting = RouteNames.orderWaiting;
  static const pay = RouteNames.orderPay;
  static const confirmed = RouteNames.orderConfirmed;
  static const status = RouteNames.orderStatus;
  static const delivered = RouteNames.orderDelivered;
  static const receipt = RouteNames.orderReceipt;
  static const chat = RouteNames.orderChat;

  static String _withId(String path, String? orderId) {
    if (orderId == null || orderId.isEmpty) return path;
    return '$path?id=$orderId';
  }

  static String waitingFor(String? orderId) => _withId(waiting, orderId);
  static String payFor(String? orderId) => _withId(pay, orderId);
  static String confirmedFor(String? orderId) => _withId(confirmed, orderId);
  static String statusFor(String? orderId) => _withId(status, orderId);
  static String receiptFor(String? orderId) => _withId(receipt, orderId);
  static String deliveredFor(String? orderId) => _withId(delivered, orderId);
  static String chatFor(String? orderId) => _withId(chat, orderId);
}
