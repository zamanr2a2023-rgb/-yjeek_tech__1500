import 'package:yjeek_app/routes/route_names.dart';

abstract final class CartRoutes {
  static const checkout = RouteNames.cartCheckout;
  static const review = RouteNames.cartReview;
  static const changeAddress = RouteNames.cartChangeAddress;
  static const setLocation = RouteNames.cartSetLocation;
  static const addAddress = RouteNames.cartAddAddress;
  static const editAddress = RouteNames.cartEditAddress;
  static const outOfDelivery = RouteNames.cartOutOfDelivery;
  static const zoodWaitingList = RouteNames.cartZoodWaitingList;
  static const newCartDialog = RouteNames.cartNewCartDialog;

  static String editAddressFor(String id) => '$editAddress?id=$id';
}
