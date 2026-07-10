import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _dropOffIndex = 0;
  int _tipIndex = 0;
  String _paymentId = 'cod';

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: CartFlowStrings.checkout,
      subtitle: CartFlowData.vendor,
      body: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          children: [
            const CartSectionTitle(CartFlowStrings.deliveryDetails),
            CartDeliveryDetailsCard(
              address: CartFlowData.selectedAddress,
              onChange: () => context.push(CartRoutes.changeAddress),
            ),
            SizedBox(height: 18.h),
            const CartSectionTitle(CartFlowStrings.dropOffPreferences),
            CartDropOffGrid(
              options: CartFlowData.dropOffOptions,
              selectedIndex: _dropOffIndex,
              onSelected: (index) => setState(() => _dropOffIndex = index),
            ),
            SizedBox(height: 18.h),
            const CartSectionTitle(CartFlowStrings.tipYourChamp),
            CartTipSelector(
              options: CartFlowData.tipOptions,
              selectedIndex: _tipIndex,
              onSelected: (index) => setState(() => _tipIndex = index),
            ),
            SizedBox(height: 18.h),
            const CartSectionTitle(CartFlowStrings.paymentMethod),
            CartPaymentMethodList(
              options: CartFlowData.paymentOptions,
              selectedId: _paymentId,
              onSelected: (id) => setState(() => _paymentId = id),
            ),
            SizedBox(height: 18.h),
            const CartSectionTitle(CartFlowStrings.billSummary),
            BillSummaryCard(
              lines: CartFlowData.billLines,
              showCashback: true,
            ),
            SizedBox(height: 12.h),
            CartZoodBanner(
              onTap: () => context.push(CartRoutes.zoodWaitingList),
            ),
          ],
        ),
      bottom: CartStickyFooter(
        total: CartFlowData.orderTotal,
        buttonLabel: CartFlowStrings.placeOrder,
        onPressed: () => context.push(CartRoutes.review),
      ),
    );
  }
}
