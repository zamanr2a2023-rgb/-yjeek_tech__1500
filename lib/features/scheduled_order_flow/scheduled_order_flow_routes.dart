import 'package:yjeek_app/routes/route_names.dart';

abstract final class ScheduledOrderFlowRoutes {
  static const waiting = RouteNames.scheduledOrderWaiting;
  static const pay = RouteNames.scheduledOrderPay;
  static const confirmed = RouteNames.scheduledOrderConfirmed;
  static const status = RouteNames.scheduledOrderStatus;
  static const receipt = RouteNames.scheduledOrderReceipt;

  static String _withIds(String path, List<String>? orderIds) {
    if (orderIds == null || orderIds.isEmpty) return path;
    if (orderIds.length == 1) return '$path?id=${orderIds.first}';
    return '$path?id=${orderIds.first}&ids=${orderIds.join(',')}';
  }

  static String waitingFor(List<String>? orderIds) => _withIds(waiting, orderIds);
  static String payFor(List<String>? orderIds) => _withIds(pay, orderIds);
  static String confirmedFor(List<String>? orderIds) =>
      _withIds(confirmed, orderIds);
  static String statusFor(List<String>? orderIds) => _withIds(status, orderIds);
  static String receiptFor(List<String>? orderIds) =>
      _withIds(receipt, orderIds);
}
