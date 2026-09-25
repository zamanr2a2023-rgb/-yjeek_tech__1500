import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/features/vape_cart/vape_cart_routes.dart';
import 'package:yjeek_app/features/vape_cart/view/widgets/vape_cart_widgets.dart';

/// Dimmed overlay + bottom sheet intro for age verification.
class VapeAgeVerifyScreen extends StatelessWidget {
  const VapeAgeVerifyScreen({super.key, this.productName});

  final String? productName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.45),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: VapeAgeVerifyDialog(
          onVerify: () {
            context.push(
              VapeCartRoutes.idVerify(productName: productName),
            );
          },
          onDismiss: () => context.pop(),
        ),
      ),
    );
  }
}
