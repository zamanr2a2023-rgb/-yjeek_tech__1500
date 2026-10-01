import 'package:yjeek_app/core/constants/home_strings.dart';
import 'package:yjeek_app/features/home/model/home_feed.dart';
import 'package:yjeek_app/features/location/model/customer_delivery_location.dart';

/// Header label: resolver first, then home API fallback.
String deliveryLocationHeaderLabel({
  required CustomerDeliveryLocation? location,
  HomeFeed? homeFeed,
  required bool loggedIn,
}) {
  final fromResolver = location?.displayTitle.trim();
  if (fromResolver != null && fromResolver.isNotEmpty) {
    return fromResolver;
  }
  if (loggedIn) {
    final api = homeFeed?.deliverToLabel;
    if (api != null && api.isNotEmpty && api != HomeStrings.chooseLocation) {
      return api;
    }
  } else if (homeFeed?.deliverTo?.label.isNotEmpty ?? false) {
    return homeFeed!.deliverToLabel;
  }
  return HomeStrings.chooseLocation;
}
