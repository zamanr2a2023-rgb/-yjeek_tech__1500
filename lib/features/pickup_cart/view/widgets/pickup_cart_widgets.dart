import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/pickup_cart/model/pickup_cart_data.dart';

class PickupCartBody extends StatefulWidget {
  const PickupCartBody({
    super.key,
    required this.onCheckout,
  });

  final VoidCallback onCheckout;

  @override
  State<PickupCartBody> createState() => _PickupCartBodyState();
}

class _PickupCartBodyState extends State<PickupCartBody> {
  final Map<int, int> _quantities = {
    for (var i = 0; i < PickupCartData.cartItems.length; i++)
      i: PickupCartData.cartItems[i].quantity,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            children: [
              const PickupDetailsCard(),
              SizedBox(height: 16.h),
              Text(
                PickupCartStrings.yourItems,
                style: AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 10.h),
              ...List.generate(PickupCartData.cartItems.length, (index) {
                final item = PickupCartData.cartItems[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: PickupCartItemRow(
                    item: item,
                    quantity: _quantities[index] ?? item.quantity,
                    onQuantityChanged: (value) => setState(() => _quantities[index] = value),
                  ),
                );
              }),
              SizedBox(height: 12.h),
              Text(
                PickupCartStrings.youMightAlsoLike,
                style: AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 130.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: PickupCartData.upsellItems.length,
                  separatorBuilder: (_, _) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
                    return PickupUpsellCard(item: PickupCartData.upsellItems[index]);
                  },
                ),
              ),
              SizedBox(height: 16.h),
              const PickupPromoRow(),
              SizedBox(height: 16.h),
              const PickupBillSummaryCard(),
            ],
          ),
        ),
        PickupCartFooter(onCheckout: widget.onCheckout),
      ],
    );
  }
}

class PickupDetailsCard extends StatelessWidget {
  const PickupDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CartFlowCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.storefront_outlined, color: AppColors.primary, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${PickupCartStrings.pickupFrom} ${PickupCartData.vendor}',
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  PickupCartData.pickupAddress,
                  style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBEFE0),
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                  child: Text(
                    PickupCartData.readyIn,
                    style: AppTextStyles.caption(color: const Color(0xFFD98C1A)).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                PickupCartStrings.map,
                style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PickupCartItemRow extends StatelessWidget {
  const PickupCartItemRow({
    super.key,
    required this.item,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final PickupCartItem item;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${quantity}x ${item.name}',
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                if (item.subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    item.subtitle!,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            item.price,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class PickupUpsellCard extends StatelessWidget {
  const PickupUpsellCard({super.key, required this.item});

  final PickupUpsellItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption().copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.price,
                style: AppTextStyles.caption(color: const Color(0xFF216B2E)).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                ),
              ),
              Container(
                width: 22.w,
                height: 22.w,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: AppColors.white, size: 14.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PickupPromoRow extends StatelessWidget {
  const PickupPromoRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              PickupCartStrings.promoCode,
              style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
            ),
          ),
          Text(
            'Submit',
            style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class PickupBillSummaryCard extends StatelessWidget {
  const PickupBillSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line(PickupCartData.cartBillLines[0]),
          _line(PickupCartData.cartBillLines[1]),
          _deliveryLine(),
          _line(PickupCartData.cartBillLines[3]),
          _line(PickupCartData.cartBillLines[4]),
          SizedBox(height: 8.h),
          const PickupCashbackBanner(),
        ],
      ),
    );
  }

  Widget _line(BillLine line) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              line.label,
              style: AppTextStyles.labelSmall(
                color: line.isBold ? AppColors.textPrimary : AppColors.textSecondary,
              ).copyWith(
                fontWeight: line.isBold ? FontWeight.w700 : FontWeight.w500,
                fontSize: line.isBold ? 16.sp : 13.sp,
              ),
            ),
          ),
          Text(
            line.value,
            style: AppTextStyles.labelSmall(
              color: line.isDiscount ? AppColors.error : AppColors.textPrimary,
            ).copyWith(
              fontWeight: line.isBold ? FontWeight.w700 : FontWeight.w600,
              fontSize: line.isBold ? 16.sp : 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryLine() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Delivery',
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                fontSize: 13.sp,
              ),
            ),
          ),
          Text(
            'BHD 0.500',
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}

class PickupCashbackBanner extends StatelessWidget {
  const PickupCashbackBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F0DC),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.savings_outlined, size: 16.sp, color: const Color(0xFF7A5E12)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              PickupCartStrings.cashbackEarn,
              style: AppTextStyles.caption(color: const Color(0xFF7A5E12)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
          Text(
            PickupCartData.cashbackAmount,
            style: AppTextStyles.caption(color: const Color(0xFF7A5E12)).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12.5.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class PickupCartFooter extends StatelessWidget {
  const PickupCartFooter({super.key, required this.onCheckout});

  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: onCheckout,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: Row(
              children: [
                Text(
                  PickupCartStrings.goToCheckout,
                  style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
                const Spacer(),
                Text(
                  PickupCartData.checkoutTotal,
                  style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PickupTimeCard extends StatelessWidget {
  const PickupTimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CartFlowCard(
      child: Row(
        children: [
          Icon(Icons.schedule_outlined, color: AppColors.primary, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PickupCartStrings.pickupTimeLabel,
                  style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  PickupCartData.pickupTime,
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            PickupCartStrings.change,
            style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class PickupPolicyBanner extends StatelessWidget {
  const PickupPolicyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE8D9A8)),
      ),
      child: Text(
        PickupCartStrings.policyWarning,
        style: AppTextStyles.caption(color: const Color(0xFF8A5A12)).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
          height: 1.35,
        ),
      ),
    );
  }
}

class PickupPaymentNoteBanner extends StatelessWidget {
  const PickupPaymentNoteBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1E6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        PickupCartStrings.paymentNote,
        style: AppTextStyles.caption(color: const Color(0xFF0F4D27)).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
          height: 1.35,
        ),
      ),
    );
  }
}

class PickupWalletPaymentTile extends StatelessWidget {
  const PickupWalletPaymentTile({
    super.key,
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1E6),
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yjeek Wallet',
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    PickupCartData.walletBalance,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : AppColors.white,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Icon(Icons.check, size: 14.sp, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class PickupReviewStatusCard extends StatelessWidget {
  const PickupReviewStatusCard({super.key, required this.secondsLeft});

  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$secondsLeft',
              style: AppTextStyles.titleMedium(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 38.sp,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            PickupCartStrings.placingOrder,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            PickupCartStrings.autoConfirmHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: const Color(0xFFCFE8D8)).copyWith(
              fontSize: 12.5.sp,
              height: 1.35,
            ),
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: LinearProgressIndicator(
              value: secondsLeft / 10,
              minHeight: 6.h,
              backgroundColor: const Color(0xFF2C6B47),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFC9A84C)),
            ),
          ),
        ],
      ),
    );
  }
}

class PickupReviewSummaryCard extends StatelessWidget {
  const PickupReviewSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CartFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PickupCartStrings.orderSummary,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            PickupCartStrings.orderType,
            style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 10.h),
          _row(PickupCartStrings.method, PickupCartStrings.pickupMethod),
          _row(PickupCartStrings.collectAt, PickupCartData.collectAt),
          _row(PickupCartStrings.payment, PickupCartStrings.applePay),
          Divider(height: 20.h, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                PickupCartStrings.orderTotal,
                style: AppTextStyles.labelMedium().copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                PickupCartData.orderTotal,
                style: AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
              fontSize: 13.sp,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
