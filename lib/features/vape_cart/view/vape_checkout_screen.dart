import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/vape_cart/model/vape_cart_data.dart';
import 'package:yjeek_app/features/vape_cart/vape_cart_routes.dart';
import 'package:yjeek_app/features/vape_cart/view/widgets/vape_cart_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

/// Vape checkout mirrors Electronics (scheduled) layout; adds map delivery
/// details + ID verification blocks that are vape-specific.
class VapeCheckoutScreen extends StatefulWidget {
  const VapeCheckoutScreen({
    super.key,
    this.initialDeliveryId = 'same-day',
  });

  final String initialDeliveryId;

  @override
  State<VapeCheckoutScreen> createState() => _VapeCheckoutScreenState();
}

class _VapeCheckoutScreenState extends State<VapeCheckoutScreen> {
  late String _deliveryId;
  int _dropOffIndex = 0;
  int _tipIndex = 0;
  String _paymentId = 'benefitpay';

  VapeDeliveryMethod get _deliveryMethod =>
      VapeCartData.deliveryMethods.firstWhere((m) => m.id == _deliveryId);

  double get _tipAmount {
    final option = VapeCartData.tipOptions[_tipIndex];
    return option.amount ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _deliveryId = widget.initialDeliveryId;
  }

  void _placeOrder() {
    if (!VapeCartData.isAgeVerified) {
      context.push(VapeCartRoutes.ageVerify);
      return;
    }
    context.push(VapeCartRoutes.reviewWithDelivery(_deliveryId));
  }

  @override
  Widget build(BuildContext context) {
    final billLines = VapeCartData.checkoutBillLines(
      method: _deliveryMethod,
      tip: _tipAmount,
    );

    return CartFlowScaffold(
      title: VapeCartStrings.checkout,
      subtitle: VapeCartData.vendor,
      lightHeader: true,
      backgroundColor: const Color(0xFFF2F7F2),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        children: [
          const CartSectionTitle(VapeCartStrings.deliveryDetails),
          CartDeliveryDetailsCard(
            address: VapeCartData.selectedAddress,
            addressDetail: VapeCartData.selectedAddressDetail,
            phone: VapeCartStrings.phone,
            arrivesLabel: VapeCartStrings.arrivesIn,
            onChange: () => context.push(CartRoutes.changeAddress),
          ),
          SizedBox(height: 14.h),
          if (VapeCartData.isAgeVerified) ...[
            const VapeIdVerifiedCard(),
            SizedBox(height: 14.h),
          ],
          const CartSectionTitle(VapeCartStrings.deliveryMethod),
          ...VapeCartData.deliveryMethods.map(
            (method) => VapeDeliveryMethodCard(
              method: method,
              selected: _deliveryId == method.id,
              onTap: () => setState(() => _deliveryId = method.id),
            ),
          ),
          SizedBox(height: 8.h),
          CartDropOffGrid(
            showTitle: true,
            options: VapeCartData.dropOffOptions,
            selectedIndex: _dropOffIndex,
            onSelected: (index) => setState(() => _dropOffIndex = index),
          ),
          SizedBox(height: 14.h),
          const CartSectionTitle(VapeCartStrings.paymentMethod),
          const VapePaymentNoteBanner(),
          SizedBox(height: 12.h),
          CartPaymentMethodList(
            options: VapeCartData.paymentOptions,
            selectedId: _paymentId,
            onSelected: (id) => setState(() => _paymentId = id),
            showSecurityNotes: true,
          ),
          SizedBox(height: 14.h),
          CartTipSelector(
            showHeader: true,
            options: VapeCartData.tipOptions,
            selectedIndex: _tipIndex,
            onSelected: (index) => setState(() => _tipIndex = index),
          ),
          SizedBox(height: 14.h),
          CartZoodPromoBanner(
            onTap: () => context.push(CartRoutes.zoodWaitingList),
          ),
          SizedBox(height: 14.h),
          const CartSectionTitle(VapeCartStrings.billSummary),
          BillSummaryCard(lines: billLines),
          SizedBox(height: 10.h),
          const VapeCashbackBanner(),
        ],
      ),
      bottom: CartStickyFooter(
        total: VapeCartData.checkoutTotalFor(
          method: _deliveryMethod,
          tip: _tipAmount,
        ),
        buttonLabel: VapeCartStrings.placeOrder,
        onPressed: _placeOrder,
      ),
    );
  }
}
