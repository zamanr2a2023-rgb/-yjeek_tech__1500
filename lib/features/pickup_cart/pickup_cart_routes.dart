import 'package:yjeek_app/routes/route_names.dart';

abstract final class PickupCartRoutes {
  static const checkout = RouteNames.pickupCartCheckout;
  static const review = RouteNames.pickupCartReview;

  static String reviewFor({
    required String paymentId,
    double tipAmount = 0,
  }) {
    final tip = tipAmount.toStringAsFixed(3);
    return '$review?payment=${Uri.encodeQueryComponent(paymentId)}&tip=$tip';
  }
}
