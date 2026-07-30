import 'package:yjeek_app/routes/route_names.dart';

abstract final class ServicesBookingRoutes {
  static const booking = RouteNames.servicesBooking;
  static const checkout = RouteNames.servicesBookingCheckout;
  static const review = RouteNames.servicesBookingReview;

  static String _withId(String path, String? orderId) {
    if (orderId == null || orderId.isEmpty) return path;
    return '$path?id=$orderId';
  }

  static String reviewFor(String? orderId) => _withId(review, orderId);
}
