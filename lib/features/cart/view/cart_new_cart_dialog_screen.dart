import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';

/// Preview route for the "Start new cart?" modal from the design doc.
class CartNewCartDialogScreen extends StatelessWidget {
  const CartNewCartDialogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      showCartNewCartDialog(
        context,
        onConfirm: () => context.pop(),
      );
    });

    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox.shrink(),
    );
  }
}
