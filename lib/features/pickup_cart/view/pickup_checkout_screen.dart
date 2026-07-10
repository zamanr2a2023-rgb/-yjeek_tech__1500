import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/pickup_cart/model/pickup_cart_data.dart';
import 'package:yjeek_app/features/pickup_cart/pickup_cart_routes.dart';
import 'package:yjeek_app/features/pickup_cart/view/widgets/pickup_cart_widgets.dart';

class PickupCheckoutScreen extends StatefulWidget {
  const PickupCheckoutScreen({super.key});

  @override
  State<PickupCheckoutScreen> createState() => _PickupCheckoutScreenState();
}

class _PickupCheckoutScreenState extends State<PickupCheckoutScreen> {
  String _paymentId = 'benefitpay';
  bool _walletSelected = false;

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: PickupCartStrings.checkout,
      subtitle: PickupCartData.vendor,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const CartSectionTitle(PickupCartStrings.pickupDetails),
          const PickupDetailsCard(),
          SizedBox(height: 18.h),
          const CartSectionTitle(PickupCartStrings.pickupTime),
          const PickupTimeCard(),
          SizedBox(height: 14.h),
          const PickupPolicyBanner(),
          SizedBox(height: 18.h),
          const CartSectionTitle(PickupCartStrings.paymentMethod),
          CartPaymentMethodList(
            options: PickupCartData.paymentOptions,
            selectedId: _paymentId,
            onSelected: (id) => setState(() => _paymentId = id),
          ),
          PickupWalletPaymentTile(
            selected: _walletSelected,
            onTap: () => setState(() => _walletSelected = !_walletSelected),
          ),
          SizedBox(height: 12.h),
          const PickupPaymentNoteBanner(),
          SizedBox(height: 18.h),
          const CartSectionTitle(PickupCartStrings.billSummary),
          const PickupBillSummaryCard(),
          SizedBox(height: 12.h),
          CartZoodBanner(
            onTap: () => context.push(CartRoutes.zoodWaitingList),
          ),
        ],
      ),
      bottom: CartStickyFooter(
        total: PickupCartData.orderTotal,
        buttonLabel: PickupCartStrings.placeOrder,
        onPressed: () => context.push(PickupCartRoutes.review),
      ),
    );
  }
}
