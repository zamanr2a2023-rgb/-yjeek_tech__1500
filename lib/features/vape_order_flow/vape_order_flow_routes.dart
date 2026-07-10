import 'package:yjeek_app/routes/route_names.dart';

abstract final class VapeOrderFlowRoutes {
  static const waiting = RouteNames.vapeOrderWaiting;
  static const pay = RouteNames.vapeOrderPay;
  static const confirmed = RouteNames.vapeOrderConfirmed;
  static const status = RouteNames.vapeOrderStatus;
  static const receipt = RouteNames.vapeOrderReceipt;
}
