import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/features/vape_cart/view/widgets/vape_cart_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class VapeAgeVerifyScreen extends StatelessWidget {
  const VapeAgeVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.45),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: VapeAgeVerifyDialog(
            onVerify: () => context.push(RouteNames.idVerification),
            onDismiss: () => context.pop(),
          ),
        ),
      ),
    );
  }
}
