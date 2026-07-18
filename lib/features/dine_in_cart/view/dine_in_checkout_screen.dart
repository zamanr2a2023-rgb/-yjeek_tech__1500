import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/dine_in_cart/dine_in_cart_routes.dart';
import 'package:yjeek_app/features/dine_in_cart/model/dine_in_cart_data.dart';
import 'package:yjeek_app/features/dine_in_cart/view/widgets/dine_in_cart_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class DineInCheckoutScreen extends StatefulWidget {
  const DineInCheckoutScreen({
    super.key,
    this.initialMode = DineInPrepMode.prepareNow,
  });

  final DineInPrepMode initialMode;

  @override
  State<DineInCheckoutScreen> createState() => _DineInCheckoutScreenState();
}

class _DineInCheckoutScreenState extends State<DineInCheckoutScreen> {
  late DineInPrepMode _prepMode;
  String _paymentId = 'wallet';

  @override
  void initState() {
    super.initState();
    _prepMode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    final isPrepareNow = _prepMode == DineInPrepMode.prepareNow;

    return CartFlowScaffold(
      title: DineInCartStrings.checkout,
      subtitle: DineInCartData.checkoutSubtitle,
      lightHeader: true,
      // Figma dine-in: rgba(44, 107, 71, 0.55) over white → sage #8BAE9A.
      backgroundColor: const Color(0xFF8BAE9A),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
        children: [
          const CartSectionTitle(DineInCartStrings.diningOption),
          DineInPrepOptionCard(
            title: DineInCartStrings.prepareNow,
            subtitle: DineInCartStrings.prepareNowHint,
            icon: Icons.local_fire_department,
            iconBackground: AppColors.primary,
            iconColor: AppColors.white,
            selected: isPrepareNow,
            onTap: () => setState(() => _prepMode = DineInPrepMode.prepareNow),
          ),
          SizedBox(height: 10.h),
          DineInPrepOptionCard(
            title: DineInCartStrings.prepareOnArrival,
            subtitle: DineInCartStrings.prepareOnArrivalHint,
            icon: Icons.location_on,
            iconBackground: const Color(0xFFEBC34A),
            iconColor: AppColors.white,
            selected: !isPrepareNow,
            onTap: () => setState(() => _prepMode = DineInPrepMode.prepareOnArrival),
          ),
          SizedBox(height: 14.h),
          if (isPrepareNow) ...[
            const DineInTableReadyCard(),
            SizedBox(height: 10.h),
            const DineInInfoBanner(message: DineInCartStrings.prepareNowBanner),
          ] else ...[
            CartFlowCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DineInCartStrings.dineInTime,
                          style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          DineInCartData.dineInTime,
                          style: AppTextStyles.labelMedium().copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Change',
                    style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            const DineInInfoBanner(message: DineInCartStrings.arrivalBanner),
          ],
          SizedBox(height: 18.h),
          const CartSectionTitle(DineInCartStrings.paymentMethod),
          DineInPaymentList(
            options: DineInCartData.paymentOptions,
            selectedId: _paymentId,
            onSelected: (id) => setState(() => _paymentId = id),
          ),
          SizedBox(height: 10.h),
          const DineInWalletNoteBanner(),
          SizedBox(height: 18.h),
          Text(
            DineInCartStrings.billSummary,
            style: AppTextStyles.titleSmall(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 1.28,
            ),
          ),
          SizedBox(height: 10.h),
          CartZoodPromoBanner(onTap: () => context.push(CartRoutes.zoodWaitingList)),
          SizedBox(height: 12.h),
          BillSummaryCard(
            lines: DineInCartData.billLines,
            showCashback: true,
            cashbackAmount: DineInCartData.cashbackAmount,
          ),
        ],
      ),
      bottom: CartStickyFooter(
        total: DineInCartData.orderTotal,
        buttonLabel: DineInCartStrings.placeOrder,
        onPressed: () => context.push(
          '${DineInCartRoutes.review}?mode=${isPrepareNow ? 'now' : 'arrival'}',
        ),
      ),
    );
  }
}
