import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/vape_cart/model/vape_cart_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class VapeCartBody extends StatefulWidget {
  const VapeCartBody({
    super.key,
    required this.onCheckout,
  });

  final VoidCallback onCheckout;

  @override
  State<VapeCartBody> createState() => _VapeCartBodyState();
}

class _VapeCartBodyState extends State<VapeCartBody> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final item = VapeCartData.cartItems.first;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            children: [
              Text(
                VapeCartStrings.yourItems,
                style: AppTextStyles.titleSmall().copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),
              VapeCartItemCard(
                item: item,
                quantity: _quantity,
                onQuantityChanged: (v) => setState(() => _quantity = v),
              ),
              SizedBox(height: 18.h),
              Text(
                VapeCartStrings.youMightAlsoLike,
                style: AppTextStyles.titleSmall().copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 130.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: VapeCartData.upsellItems.length,
                  separatorBuilder: (_, _) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
                    return VapeUpsellCard(item: VapeCartData.upsellItems[index]);
                  },
                ),
              ),
              SizedBox(height: 16.h),
              const VapePromoRow(),
              SizedBox(height: 16.h),
              BillSummaryCard(
                lines: VapeCartData.cartBillLines,
                showPromo: false,
                showCashback: true,
              ),
            ],
          ),
        ),
        VapeCartFooter(onCheckout: widget.onCheckout),
      ],
    );
  }
}

class VapeCartItemCard extends StatelessWidget {
  const VapeCartItemCard({
    super.key,
    required this.item,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final VapeCartItem item;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
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
                  item.name,
                  style: AppTextStyles.titleSmall().copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.subtitle,
                  style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    VapeCartStrings.edit,
                    style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 82.w,
                height: 82.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2129),
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              SizedBox(height: 8.h),
              _QuantityStepper(
                quantity: quantity,
                onChanged: onQuantityChanged,
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.price,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (item.originalPrice != null) ...[
                    SizedBox(width: 4.w),
                    Text(
                      item.originalPrice!,
                      style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                        fontSize: 11.sp,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(
            label: '−',
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              '$quantity',
              style: AppTextStyles.labelMedium().copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _QtyBtn(label: '+', onTap: () => onChanged(quantity + 1)),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.label, this.onTap});

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

class VapeUpsellCard extends StatelessWidget {
  const VapeUpsellCard({super.key, required this.item});

  final VapeUpsellItem item;

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

class VapePromoRow extends StatelessWidget {
  const VapePromoRow({super.key});

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
              VapeCartStrings.promoCode,
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

class VapeCartFooter extends StatelessWidget {
  const VapeCartFooter({super.key, required this.onCheckout});

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
            Expanded(child: CartOutlineButton(label: VapeCartStrings.addMore, onPressed: () {})),
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
                    VapeCartStrings.checkoutBtn,
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

class VapeIdVerifiedCard extends StatelessWidget {
  const VapeIdVerifiedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CartFlowCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2EB),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              VapeCartStrings.verified,
              style: AppTextStyles.caption(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 11.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              VapeCartStrings.verifiedNote,
              style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
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

class VapeDeliveryMethodCard extends StatelessWidget {
  const VapeDeliveryMethodCard({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final VapeDeliveryMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            Text(
              method.price,
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VapeCashbackBanner extends StatelessWidget {
  const VapeCashbackBanner({super.key});

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
              VapeCartStrings.cashbackEarn,
              style: AppTextStyles.caption(color: const Color(0xFF7A5E12)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
          Text(
            VapeCartData.cashbackAmount,
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

class VapeReviewStatusCard extends StatelessWidget {
  const VapeReviewStatusCard({super.key, required this.secondsLeft});

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
            VapeCartStrings.placingOrder,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            VapeCartStrings.autoConfirmHint,
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

class VapeReviewSummaryCard extends StatelessWidget {
  const VapeReviewSummaryCard({
    super.key,
    required this.deliveryLabel,
  });

  final String deliveryLabel;

  @override
  Widget build(BuildContext context) {
    return CartFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            VapeCartStrings.orderSummary,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            VapeCartStrings.orderType,
            style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 10.h),
          _row(VapeCartStrings.method, deliveryLabel),
          _row(VapeCartStrings.deliverTo, VapeCartData.selectedAddress),
          _row(VapeCartStrings.payment, VapeCartStrings.cashOnDelivery),
          Divider(height: 20.h, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                VapeCartStrings.orderTotal,
                style: AppTextStyles.labelMedium().copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                VapeCartData.orderTotal,
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

class VapeAgeVerifyDialog extends StatelessWidget {
  const VapeAgeVerifyDialog({
    super.key,
    required this.onVerify,
    required this.onDismiss,
  });

  final VoidCallback onVerify;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⚠', style: TextStyle(fontSize: 28.sp, color: const Color(0xFFE68C1A))),
            SizedBox(height: 12.h),
            Text(
              VapeCartStrings.verifyTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall().copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              VapeCartStrings.verifyBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                fontSize: 12.5.sp,
                height: 1.35,
              ),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: onVerify,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF4DAD4F),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  VapeCartStrings.goToVerification,
                  style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: onDismiss,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  VapeCartStrings.notNow,
                  style: AppTextStyles.labelMedium(color: AppColors.textSecondary).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
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
