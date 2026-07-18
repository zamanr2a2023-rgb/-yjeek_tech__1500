import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/services_booking/model/services_booking_data.dart';
import 'package:yjeek_app/features/services_booking/view/widgets/services_booking_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/services_order_flow_routes.dart';

class ServicesCheckoutScreen extends StatefulWidget {
  const ServicesCheckoutScreen({super.key});

  @override
  State<ServicesCheckoutScreen> createState() => _ServicesCheckoutScreenState();
}

class _ServicesCheckoutScreenState extends State<ServicesCheckoutScreen> {
  int _tipIndex = 1;
  String _paymentId = 'benefitpay';

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: ServicesBookingStrings.checkout,
      subtitle: ServicesBookingStrings.provider,
      lightHeader: true,
      bottomNavIndex: 0,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
        children: [
          const CartSectionTitle(ServicesBookingStrings.serviceLocation),
          const ServicesLocationCard(),
          SizedBox(height: 14.h),
          const CartSectionTitle(ServicesBookingStrings.appointment),
          const ServicesAppointmentCard(),
          SizedBox(height: 14.h),
          const CartSectionTitle(ServicesBookingStrings.tipSpecialist),
          ServicesTipSelector(
            options: ServicesBookingData.tipOptions,
            selectedIndex: _tipIndex,
            onSelected: (i) => setState(() => _tipIndex = i),
          ),
          SizedBox(height: 14.h),
          const CartSectionTitle(ServicesBookingStrings.paymentMethod),
          CartPaymentMethodList(
            options: ServicesBookingData.paymentOptions,
            selectedId: _paymentId,
            onSelected: (id) => setState(() => _paymentId = id),
            showSecurityNotes: true,
          ),
          SizedBox(height: 14.h),
          const CartSectionTitle(ServicesBookingStrings.billSummary),
          CartZoodPromoBanner(
            onTap: () => context.push(CartRoutes.zoodWaitingList),
          ),
          SizedBox(height: 12.h),
          BillSummaryCard(
            lines: ServicesBookingData.checkoutBillLines,
            showCashback: true,
          ),
        ],
      ),
      bottom: CartStickyFooter(
        total: ServicesBookingData.checkoutTotal,
        buttonLabel: ServicesBookingStrings.placeBooking,
        buttonColor: AppColors.cartTabActive,
        onPressed: () =>
            context.pushReplacement(ServicesOrderFlowRoutes.waiting),
      ),
    );
  }
}
