import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/features/location/provider/delivery_location_provider.dart';

/// Starts location detection on app launch and refreshes on resume (throttled).
class DeliveryLocationBootstrap extends ConsumerStatefulWidget {
  const DeliveryLocationBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DeliveryLocationBootstrap> createState() =>
      _DeliveryLocationBootstrapState();
}

class _DeliveryLocationBootstrapState extends ConsumerState<DeliveryLocationBootstrap>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Location resolves via [deliveryLocationProvider.build] on first watch.
    // Avoid a redundant force refresh here (it caused duplicate top-picks fetches).
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(deliveryLocationProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
