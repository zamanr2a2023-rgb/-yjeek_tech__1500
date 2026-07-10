import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/scheduled_cart/model/scheduled_cart_data.dart';
import 'package:yjeek_app/features/scheduled_cart/scheduled_cart_routes.dart';
import 'package:yjeek_app/features/scheduled_cart/view/widgets/scheduled_cart_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class ScheduledCheckoutScreen extends StatefulWidget {
  const ScheduledCheckoutScreen({
    super.key,
    this.initialDeliveryId = 'same-day',
  });

  final String initialDeliveryId;

  @override
  State<ScheduledCheckoutScreen> createState() => _ScheduledCheckoutScreenState();
}

class _ScheduledCheckoutScreenState extends State<ScheduledCheckoutScreen> {
  late String _deliveryId;
  int _dropOffIndex = 0;
  int _tipIndex = 0;
  String _paymentId = 'cod';

  ScheduledDeliveryMethod get _deliveryMethod =>
      ScheduledCartData.deliveryMethods.firstWhere((m) => m.id == _deliveryId);

  double get _tipAmount {
    final option = ScheduledCartData.tipOptions[_tipIndex];
    return option.amount ?? 0;
  }

  bool get _nextDayFree => _deliveryId == 'next-day';

  String get _orderTotal => ScheduledCartData.checkoutTotalFor(
        method: _deliveryMethod,
        nextDayFree: _nextDayFree,
        tip: _tipAmount,
      );

  @override
  void initState() {
    super.initState();
    _deliveryId = widget.initialDeliveryId;
  }

  @override
  Widget build(BuildContext context) {
    final billLines = ScheduledCartData.checkoutBillLines(
      method: _deliveryMethod,
      nextDayFree: _nextDayFree,
      tip: _tipAmount,
    );

    return CartFlowScaffold(
      title: ScheduledCartStrings.checkout,
      subtitle: ScheduledCartData.vendor,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const CartSectionTitle(ScheduledCartStrings.deliveryAddress),
          ScheduledAddressCard(
            onChange: () => context.push(CartRoutes.changeAddress),
          ),
          SizedBox(height: 18.h),
          const CartSectionTitle(ScheduledCartStrings.deliveryMethod),
          ...ScheduledCartData.deliveryMethods.map(
            (method) => ScheduledDeliveryMethodCard(
              method: method,
              selected: _deliveryId == method.id,
              showFreePrice: _deliveryId == method.id && method.freeAfterNoon,
              onTap: () => setState(() => _deliveryId = method.id),
            ),
          ),
          SizedBox(height: 8.h),
          const CartSectionTitle(ScheduledCartStrings.dropOffPreferences),
          CartDropOffGrid(
            options: ScheduledCartData.dropOffOptions,
            selectedIndex: _dropOffIndex,
            onSelected: (index) => setState(() => _dropOffIndex = index),
          ),
          SizedBox(height: 18.h),
          const CartSectionTitle(ScheduledCartStrings.paymentMethod),
          const ScheduledPaymentNoteBanner(),
          SizedBox(height: 12.h),
          CartPaymentMethodList(
            options: ScheduledCartData.paymentOptions,
            selectedId: _paymentId,
            onSelected: (id) => setState(() => _paymentId = id),
          ),
          SizedBox(height: 18.h),
          const CartSectionTitle(ScheduledCartStrings.tipYourChamp),
          CartTipSelector(
            options: ScheduledCartData.tipOptions,
            selectedIndex: _tipIndex,
            onSelected: (index) => setState(() => _tipIndex = index),
          ),
          SizedBox(height: 18.h),
          const CartSectionTitle(ScheduledCartStrings.billSummary),
          BillSummaryCard(lines: billLines),
          SizedBox(height: 10.h),
          const ScheduledCashbackBanner(),
          SizedBox(height: 12.h),
          CartZoodBanner(
            onTap: () => context.push(CartRoutes.zoodWaitingList),
          ),
        ],
      ),
      bottom: CartStickyFooter(
        total: _orderTotal,
        buttonLabel: ScheduledCartStrings.placeOrder,
        onPressed: () => context.push(
          ScheduledCartRoutes.reviewWithDelivery(_deliveryId),
        ),
      ),
    );
  }
}
