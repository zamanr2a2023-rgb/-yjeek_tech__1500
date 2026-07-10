import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/vape_cart/model/vape_cart_data.dart';
import 'package:yjeek_app/features/vape_cart/vape_cart_routes.dart';
import 'package:yjeek_app/features/vape_cart/view/widgets/vape_cart_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

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
  bool _saveDropOff = false;

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
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const CartSectionTitle(VapeCartStrings.deliveryDetails),
          const VapeDeliveryDetailsCard(),
          SizedBox(height: 14.h),
          const VapeIdVerifiedCard(),
          SizedBox(height: 18.h),
          const CartSectionTitle(VapeCartStrings.deliveryMethod),
          ...VapeCartData.deliveryMethods.map(
            (method) => VapeDeliveryMethodCard(
              method: method,
              selected: _deliveryId == method.id,
              onTap: () => setState(() => _deliveryId = method.id),
            ),
          ),
          SizedBox(height: 8.h),
          const CartSectionTitle(VapeCartStrings.dropOffPreferences),
          CartDropOffGrid(
            options: VapeCartData.dropOffOptions,
            selectedIndex: _dropOffIndex,
            onSelected: (index) => setState(() => _dropOffIndex = index),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              SizedBox(
                width: 22.w,
                height: 22.w,
                child: Checkbox(
                  value: _saveDropOff,
                  activeColor: AppColors.primary,
                  onChanged: (value) => setState(() => _saveDropOff = value ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Save these for this address',
                  style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                    fontSize: 12.5.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          const CartSectionTitle(VapeCartStrings.tipYourChamp),
          CartTipSelector(
            options: VapeCartData.tipOptions,
            selectedIndex: _tipIndex,
            onSelected: (index) => setState(() => _tipIndex = index),
          ),
          SizedBox(height: 18.h),
          const CartSectionTitle(VapeCartStrings.paymentMethod),
          CartPaymentMethodList(
            options: VapeCartData.paymentOptions,
            selectedId: _paymentId,
            onSelected: (id) => setState(() => _paymentId = id),
          ),
          SizedBox(height: 18.h),
          const CartSectionTitle(VapeCartStrings.billSummary),
          BillSummaryCard(lines: billLines),
          SizedBox(height: 10.h),
          const VapeCashbackBanner(),
          SizedBox(height: 12.h),
          CartZoodBanner(
            onTap: () => context.push(CartRoutes.zoodWaitingList),
          ),
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

class VapeDeliveryDetailsCard extends StatelessWidget {
  const VapeDeliveryDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CartFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: const CartMapPlaceholder(height: 120, showPin: false),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      VapeCartData.selectedAddress,
                      style: AppTextStyles.labelMedium().copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      VapeCartStrings.arrivesIn,
                      style: AppTextStyles.labelSmall(
                        color: AppColors.textSecondary,
                      ).copyWith(fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push(CartRoutes.changeAddress),
                child: Text(
                  CartFlowStrings.change,
                  style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
