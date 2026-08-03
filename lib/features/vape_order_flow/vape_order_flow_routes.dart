import 'package:yjeek_app/routes/route_names.dart';

abstract final class VapeOrderFlowRoutes {
  static const waiting = RouteNames.vapeOrderWaiting;
  static const pay = RouteNames.vapeOrderPay;
  static const confirmed = RouteNames.vapeOrderConfirmed;
  static const status = RouteNames.vapeOrderStatus;
  static const receipt = RouteNames.vapeOrderReceipt;

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
