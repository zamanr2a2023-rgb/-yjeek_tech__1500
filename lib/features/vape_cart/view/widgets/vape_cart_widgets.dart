import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
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
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 10.h),
              VapeCartItemCard(
                item: item,
                quantity: _quantity,
                onQuantityChanged: (v) => setState(() => _quantity = v < 1 ? 1 : v),
              ),
              SizedBox(height: 18.h),
              Text(
                VapeCartStrings.youMightAlsoLike,
                style: AppTextStyles.titleSmall().copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 133.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: VapeCartData.upsellItems.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    return VapeUpsellCard(item: VapeCartData.upsellItems[index]);
                  },
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                VapeCartStrings.promoCode,
                style: AppTextStyles.titleSmall().copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 10.h),
              const VapePromoRow(),
              SizedBox(height: 16.h),
              Text(
                VapeCartStrings.billSummary,
                style: AppTextStyles.titleSmall().copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 10.h),
              BillSummaryCard(
                lines: VapeCartData.cartBillLines,
                showPromo: false,
                showCashback: true,
                cashbackAmount: VapeCartData.cashbackAmount,
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
    // Figma: white card · #E2E8DD · radius 18 · image right · prices bottom-left · qty under image.
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        height: 1.28,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      item.subtitle,
                      style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.28,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined, size: 14.sp, color: const Color(0xFF4CAF50)),
                          SizedBox(width: 5.w),
                          Text(
                            VapeCartStrings.edit,
                            style: AppTextStyles.labelSmall(color: const Color(0xFF4CAF50)).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                              height: 1.28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                children: [
                  Container(
                    width: 82.w,
                    height: 82.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      gradient: const LinearGradient(
                        begin: Alignment(-0.8, -0.6),
                        end: Alignment(0.8, 0.8),
                        colors: [Color(0xFF7A4A22), Color(0xFF15302B)],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _QuantityStepper(
                    quantity: quantity,
                    onChanged: onQuantityChanged,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Text(
                item.price,
                style: AppTextStyles.labelMedium(color: const Color(0xFF4CAF50)).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  height: 1.28,
                ),
              ),
              if (item.originalPrice != null) ...[
                SizedBox(width: 8.w),
                Text(
                  item.originalPrice!,
                  style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: const Color(0xFF6B7B6E),
                    height: 1.28,
                  ),
                ),
              ],
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
      height: 31.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFE2E8DD)),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : () {},
            child: Icon(
              quantity > 1 ? Icons.remove : Icons.delete_outline,
              size: 15.sp,
              color: quantity > 1 ? const Color(0xFF1A1A1A) : const Color(0xFFC0392B),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 11.w),
            child: Text(
              '$quantity',
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(quantity + 1),
            child: Icon(Icons.add, size: 15.sp, color: const Color(0xFF4CAF50)),
          ),
        ],
      ),
    );
  }
}

class VapeUpsellCard extends StatelessWidget {
  const VapeUpsellCard({super.key, required this.item});

  final VapeUpsellItem item;

  @override
  Widget build(BuildContext context) {
    // Figma: 120×133 · image 90 · + white circle on image · no outer padding.
    return SizedBox(
      width: 120.w,
      height: 133.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            height: 90.h,
            child: Stack(
              children: [
                Container(
                  width: 120.w,
                  height: 90.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: LinearGradient(
                      begin: const Alignment(-0.8, -0.6),
                      end: const Alignment(0.8, 0.8),
                      colors: [item.gradientStart, item.gradientEnd],
                    ),
                  ),
                ),
                Positioned(
                  right: 6.w,
                  bottom: 6.h,
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFE2E8DD)),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.add, size: 16.sp, color: const Color(0xFF4CAF50)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            height: 16.h,
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(color: const Color(0xFF1A1A1A)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.5.sp,
                height: 1,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            height: 15.h,
            child: Text(
              item.price,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(color: const Color(0xFF1A1A1A)).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
                height: 1,
              ),
            ),
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
    // Figma: ticket icon · "Enter promo code" · Submit · #4CAF50 accents.
    return Container(
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_activity_outlined, size: 18.sp, color: const Color(0xFF4CAF50)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              VapeCartStrings.enterPromoCode,
              style: AppTextStyles.bodyMedium(color: const Color(0xFF6B7B6E)).copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            VapeCartStrings.submit,
            style: AppTextStyles.labelSmall(color: const Color(0xFF4CAF50)).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
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
    // Figma idcard: white · #E0E6E0 · radius 16 · title + mint VERIFIED pill.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE0E6E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                VapeCartStrings.idVerification,
                style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  height: 17 / 14,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2EB),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  VapeCartStrings.verified,
                  style: AppTextStyles.caption(color: const Color(0xFF127036)).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5.sp,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            VapeCartStrings.verifiedNote,
            style: AppTextStyles.caption(color: const Color(0xFF697A6E)).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              height: 15 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class VapePaymentNoteBanner extends StatelessWidget {
  const VapePaymentNoteBanner({super.key});

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
              VapeCartStrings.paymentNote,
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

  static String? _assetFor(String id) {
    return switch (id) {
      'next-day' => AppAssets.deliveryNextDay,
      'standard' => AppAssets.deliveryStandard,
      'economy' => AppAssets.deliveryEconomy,
      _ => null,
    };
  }

  Widget _methodIcon({required bool selected}) {
    final asset = _assetFor(method.id);
    final Color tint = selected || method.id == 'next-day'
        ? Colors.white
        : const Color(0xFF0F4D27);

    if (asset == null) {
      return Icon(Icons.bolt_rounded, size: 22.sp, color: tint);
    }

    return ColorFiltered(
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      child: Image.asset(asset, width: 20.w, height: 20.w, fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Same card chrome as Electronics scheduled checkout.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE4F1E9) : AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? const Color(0xFF4CAF50) : const Color(0xFFE2E8DD),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF4CAF50) : const Color(0xFFDBE6D4),
                borderRadius: BorderRadius.circular(11.r),
              ),
              alignment: Alignment.center,
              child: _methodIcon(selected: selected),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      height: 1.28,
                    ),
                  ),
                  if (method.subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      method.subtitle!,
                      style: AppTextStyles.caption(color: const Color(0xFF6B756E)).copyWith(
                        fontWeight: FontWeight.w400,
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
                  method.price,
                  style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                    height: 1.28,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    border: Border.all(
                      color: selected ? const Color(0xFF4CAF50) : const Color(0xFFE0E6E0),
                      width: selected ? 6.5 : 1.5,
                    ),
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
          Icon(Icons.star_border, size: 15.sp, color: const Color(0xFFC9A84C)),
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
    final progress = (secondsLeft.clamp(0, 10)) / 10;

    // Same as Electronics: #4CAF50 card, gold ring / white count.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 92.w,
            height: 92.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 92.w,
                  height: 92.w,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    backgroundColor: const Color(0xFF2C6B47),
                    color: const Color(0xFFC9A84C),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$secondsLeft',
                  style: AppTextStyles.titleMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 38.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            VapeCartStrings.placingOrder,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            VapeCartStrings.autoConfirmHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: const Color(0xFFCFE8D8)).copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12.5.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
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
    required this.total,
  });

  final String deliveryLabel;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          VapeCartStrings.orderSummary,
          style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            height: 1.3,
          ),
        ),
        SizedBox(height: 8.h),
        CartFlowCard(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                VapeCartStrings.orderType,
                style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 8.h),
              _summaryRow(VapeCartStrings.method, deliveryLabel),
              _summaryRow(VapeCartStrings.deliverTo, VapeCartData.selectedAddress),
              _summaryRow(VapeCartStrings.payment, VapeCartStrings.cashOnDelivery),
              Divider(height: 16.h, thickness: 1, color: const Color(0xFFE2E8DD)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    VapeCartStrings.orderTotal,
                    style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    total,
                    style: AppTextStyles.titleSmall(color: const Color(0xFF1A1A1A)).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall(color: const Color(0xFF6B7B6E)).copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
              height: 1.3,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                height: 1.3,
              ),
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
