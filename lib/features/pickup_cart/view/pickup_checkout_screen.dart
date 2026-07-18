import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/pickup_cart/model/pickup_cart_data.dart';
import 'package:yjeek_app/features/pickup_cart/view/widgets/pickup_cart_widgets.dart';
import 'package:yjeek_app/features/scheduled_cart/scheduled_cart_routes.dart';
import 'package:yjeek_app/features/scheduled_cart/view/widgets/scheduled_cart_widgets.dart';

/// Pickup checkout: Pickup details + Pickup time (Figma);
/// Payment list → tip / Zood / bill match Electronics; Place order → scheduled review.
class PickupCheckoutScreen extends StatefulWidget {
  const PickupCheckoutScreen({super.key});

  @override
  State<PickupCheckoutScreen> createState() => _PickupCheckoutScreenState();
}

class _PickupCheckoutScreenState extends State<PickupCheckoutScreen> {
  int _tipIndex = 0;
  String _paymentId = 'benefitpay';

  double get _tipAmount {
    final option = PickupCartData.tipOptions[_tipIndex];
    return option.amount ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final billLines = PickupCartData.checkoutBillLines(tip: _tipAmount);

    return CartFlowScaffold(
      title: PickupCartStrings.checkout,
      subtitle: PickupCartData.vendor,
      lightHeader: true,
      backgroundColor: const Color(0xFFF2F7F2),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        children: [
          const PickupCheckoutDetailsSection(),
          SizedBox(height: 14.h),
          const CartSectionTitle(PickupCartStrings.pickupTime),
          const PickupTimeCard(),
          SizedBox(height: 10.h),
          const PickupPolicyBanner(),
          SizedBox(height: 14.h),
          // Figma: title → payment card directly (no Electronics “won’t be charged” banner).
          const CartSectionTitle(PickupCartStrings.paymentMethod),
          CartPaymentMethodList(
            options: PickupCartData.paymentOptions,
            selectedId: _paymentId,
            onSelected: (id) => setState(() => _paymentId = id),
            showSecurityNotes: true,
          ),
          SizedBox(height: 14.h),
          CartTipSelector(
            showHeader: true,
            options: PickupCartData.tipOptions,
            selectedIndex: _tipIndex,
            onSelected: (index) => setState(() => _tipIndex = index),
          ),
          SizedBox(height: 14.h),
          CartZoodPromoBanner(
            onTap: () => context.push(CartRoutes.zoodWaitingList),
          ),
          SizedBox(height: 14.h),
          const CartSectionTitle(PickupCartStrings.billSummary),
          BillSummaryCard(lines: billLines),
          SizedBox(height: 10.h),
          const ScheduledCashbackBanner(),
        ],
      ),
      bottom: CartStickyFooter(
        total: PickupCartData.checkoutTotalFor(tip: _tipAmount),
        buttonLabel: PickupCartStrings.placeOrder,
        onPressed: () => context.push(
          ScheduledCartRoutes.reviewWithDelivery('same-day'),
        ),
      ),
    );
  }
}
