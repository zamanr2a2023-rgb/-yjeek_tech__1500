import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/location/provider/delivery_location_provider.dart';

Future<void> openDeliveryLocationPicker(
  BuildContext context,
  WidgetRef ref,
) async {
  final loggedIn = ref.read(storageServiceProvider).hasSession;
  if (loggedIn) {
    await context.push(CartRoutes.changeAddress);
    ref.invalidate(homeFeedProvider);
  } else {
    await context.push(CartRoutes.setLocation);
  }
  if (!context.mounted) return;
  await ref.read(deliveryLocationProvider.notifier).refresh(force: true);
}
