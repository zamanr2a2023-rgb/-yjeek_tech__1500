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
      subtitle: '${DineInCartData.vendorSubtitle} · ${DineInCartData.dineInTime}',
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const CartSectionTitle(DineInCartStrings.diningOption),
          DineInPrepOptionCard(
            title: DineInCartStrings.prepareNow,
            subtitle: DineInCartStrings.prepareNowHint,
            icon: Icons.local_fire_department_outlined,
            selected: isPrepareNow,
            onTap: () => setState(() => _prepMode = DineInPrepMode.prepareNow),
          ),
          SizedBox(height: 10.h),
          DineInPrepOptionCard(
            title: DineInCartStrings.prepareOnArrival,
            subtitle: DineInCartStrings.prepareOnArrivalHint,
            icon: Icons.location_on_outlined,
            iconColor: const Color(0xFFE6A700),
            selected: !isPrepareNow,
            onTap: () => setState(() => _prepMode = DineInPrepMode.prepareOnArrival),
          ),
          SizedBox(height: 14.h),
          if (isPrepareNow) ...[
            Text(
              DineInCartStrings.tableReadyIn,
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
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
          const DineInWalletNoteBanner(),
          SizedBox(height: 12.h),
          DineInPaymentList(
            options: DineInCartData.paymentOptions,
            selectedId: _paymentId,
            onSelected: (id) => setState(() => _paymentId = id),
          ),
          SizedBox(height: 18.h),
          const CartSectionTitle(DineInCartStrings.billSummary),
          CartZoodBanner(onTap: () => context.push(CartRoutes.zoodWaitingList)),
          SizedBox(height: 12.h),
          BillSummaryCard(lines: DineInCartData.billLines, showCashback: true),
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
