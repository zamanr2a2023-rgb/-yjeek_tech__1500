import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/scheduled_cart/model/scheduled_cart_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class ScheduledCartBody extends StatefulWidget {
  const ScheduledCartBody({
    super.key,
    required this.onCheckout,
  });

  final VoidCallback onCheckout;

  @override
  State<ScheduledCartBody> createState() => _ScheduledCartBodyState();
}

class _ScheduledCartBodyState extends State<ScheduledCartBody> {
  final Map<int, int> _quantities = {
    for (var i = 0; i < ScheduledCartData.cartItems.length; i++) i: 1,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            children: [
              ...List.generate(ScheduledCartData.cartItems.length, (index) {
                final item = ScheduledCartData.cartItems[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: ScheduledCartItemCard(
                    item: item,
                    quantity: _quantities[index] ?? 1,
                    onQuantityChanged: (value) => setState(() => _quantities[index] = value),
                  ),
                );
              }),
              SizedBox(height: 8.h),
              Text(
                ScheduledCartStrings.addMorePrompt,
                style: AppTextStyles.titleSmall().copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 133.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ScheduledCartData.addMoreItems.length,
                  separatorBuilder: (_, _) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
                    return ScheduledAddMoreCard(
                      item: ScheduledCartData.addMoreItems[index],
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              const _PromoRow(),
              SizedBox(height: 16.h),
              BillSummaryCard(
                lines: ScheduledCartData.cartBillLines,
                showPromo: false,
              ),
            ],
          ),
        ),
        ScheduledCartFooter(onCheckout: widget.onCheckout),
      ],
    );
  }
}

class ScheduledCartItemCard extends StatelessWidget {
  const ScheduledCartItemCard({
    super.key,
    required this.item,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final ScheduledCartItem item;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.smartphone_outlined,
              color: AppColors.primary.withValues(alpha: 0.7),
              size: 28.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.subtitle,
                  style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.price,
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          ScheduledQuantityStepper(
            quantity: quantity,
            onChanged: onQuantityChanged,
          ),
        ],
      ),
    );
  }
}

class ScheduledQuantityStepper extends StatelessWidget {
  const ScheduledQuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            label: '−',
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              '$quantity',
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
          ),
          _StepButton(label: '+', onTap: () => onChanged(quantity + 1)),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: onTap != null ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class ScheduledAddMoreCard extends StatelessWidget {
  const ScheduledAddMoreCard({super.key, required this.item});

  final ScheduledAddMoreItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 90.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  gradient: LinearGradient(
                    colors: [item.gradientStart, item.gradientEnd],
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(Icons.add, size: 16.sp, color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption().copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.5.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            item.price,
            style: AppTextStyles.caption().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoRow extends StatelessWidget {
  const _PromoRow();

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
              ScheduledCartStrings.promoCode,
              style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
            ),
          ),
          Text(
            'Apply',
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

class ScheduledCartFooter extends StatelessWidget {
  const ScheduledCartFooter({super.key, required this.onCheckout});

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
        child: Row(
          children: [
            Expanded(
              child: CartOutlineButton(
                label: ScheduledCartStrings.addMore,
                onPressed: () {},
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap: onCheckout,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    ScheduledCartStrings.checkoutBtn,
                    style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduledAddressCard extends StatelessWidget {
  const ScheduledAddressCard({
    super.key,
    required this.onChange,
  });

  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return CartFlowCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ScheduledCartData.selectedAddress,
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  ScheduledCartData.selectedAddressDetail,
                  style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onChange,
            child: Text(
              'Change',
              style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduledDeliveryMethodCard extends StatelessWidget {
  const ScheduledDeliveryMethodCard({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
    this.showFreePrice = false,
  });

  final ScheduledDeliveryMethod method;
  final bool selected;
  final VoidCallback onTap;
  final bool showFreePrice;

  @override
  Widget build(BuildContext context) {
    final displayPrice = showFreePrice && method.freeAfterNoon ? 'BHD 0.000' : method.price;
    final showStrike = showFreePrice && method.freeAfterNoon;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
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
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                  if (method.subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      method.subtitle!,
                      style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  displayPrice,
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
                if (showStrike)
                  Text(
                    method.price,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 11.sp,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduledPaymentNoteBanner extends StatelessWidget {
  const ScheduledPaymentNoteBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE8D9A8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18.sp, color: const Color(0xFF8A5A12)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              ScheduledCartStrings.paymentNote,
              style: AppTextStyles.caption(color: const Color(0xFF8A5A12)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduledCashbackBanner extends StatelessWidget {
  const ScheduledCashbackBanner({super.key});

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
              ScheduledCartStrings.cashbackEarn,
              style: AppTextStyles.caption(color: const Color(0xFF7A5E12)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
          Text(
            ScheduledCartData.cashbackAmount,
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

class ScheduledReviewStatusCard extends StatelessWidget {
  const ScheduledReviewStatusCard({super.key, required this.secondsLeft});

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
            ScheduledCartStrings.placingOrder,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            ScheduledCartStrings.autoConfirmHint,
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

class ScheduledReviewSummaryCard extends StatelessWidget {
  const ScheduledReviewSummaryCard({
    super.key,
    required this.deliveryLabel,
    required this.total,
  });

  final String deliveryLabel;
  final String total;

  @override
  Widget build(BuildContext context) {
    return CartFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ScheduledCartStrings.orderSummary,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            ScheduledCartStrings.orderType,
            style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 10.h),
          _summaryRow(ScheduledCartStrings.method, deliveryLabel),
          _summaryRow(ScheduledCartStrings.deliverTo, ScheduledCartData.selectedAddress),
          _summaryRow(ScheduledCartStrings.payment, ScheduledCartStrings.cashOnDelivery),
          Divider(height: 20.h, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ScheduledCartStrings.orderTotal,
                style: AppTextStyles.labelMedium().copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                total,
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

  Widget _summaryRow(String label, String value) {
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
