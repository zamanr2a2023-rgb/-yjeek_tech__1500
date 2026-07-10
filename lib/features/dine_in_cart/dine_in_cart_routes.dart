import 'package:yjeek_app/features/dine_in_cart/model/dine_in_cart_data.dart';
import 'package:yjeek_app/routes/route_names.dart';

abstract final class DineInCartRoutes {
  static const checkout = RouteNames.dineInCartCheckout;
  static const review = RouteNames.dineInCartReview;

  static String checkoutWithMode(DineInPrepMode mode) {
    final value = mode == DineInPrepMode.prepareOnArrival ? 'arrival' : 'now';
    return '$checkout?mode=$value';
  }
}
