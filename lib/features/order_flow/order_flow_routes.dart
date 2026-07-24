import 'package:yjeek_app/routes/route_names.dart';

abstract final class OrderFlowRoutes {
  static const confirmed = RouteNames.orderConfirmed;
  static const status = RouteNames.orderStatus;
  static const delivered = RouteNames.orderDelivered;
  static const receipt = RouteNames.orderReceipt;
  static const chat = RouteNames.orderChat;

  static String statusFor(String? orderId) {
    if (orderId == null || orderId.isEmpty) return status;
    return '$status?id=$orderId';
  }

  static String receiptFor(String? orderId) {
    if (orderId == null || orderId.isEmpty) return receipt;
    return '$receipt?id=$orderId';
  }

  static String deliveredFor(String? orderId) {
    if (orderId == null || orderId.isEmpty) return delivered;
    return '$delivered?id=$orderId';
  }
}
