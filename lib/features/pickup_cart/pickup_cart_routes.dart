import 'package:yjeek_app/routes/route_names.dart';

abstract final class PickupCartRoutes {
  static const checkout = RouteNames.pickupCartCheckout;
  static const review = RouteNames.pickupCartReview;

  static String reviewFor({required String paymentId}) {
    return '$review?payment=${Uri.encodeQueryComponent(paymentId)}';
  }
}
