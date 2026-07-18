import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
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
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    return ScheduledAddMoreCard(
                      item: ScheduledCartData.addMoreItems[index],
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              const _PromoRow(),
              SizedBox(height: 14.h),
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
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE0E6E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: const Color(0xFFDBE8DE),
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Text(
              '📦',
              style: TextStyle(fontSize: 20.sp, height: 1),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.labelMedium(
                    color: const Color(0xFF1A1A1A),
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    height: 17 / 14,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.subtitle,
                  style: AppTextStyles.caption(
                    color: const Color(0xFF6B756E),
                  ).copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    height: 15 / 12,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.price,
                  style: AppTextStyles.labelMedium(
                    color: const Color(0xFF1A1A1A),
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    height: 17 / 14,
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
    // Figma: 120×133 column, image 90, gap 6 — no outer card padding.
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
                    child: Icon(
                      Icons.add,
                      size: 16.sp,
                      color: const Color(0xFF4CAF50),
                    ),
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

class _PromoRow extends StatelessWidget {
  const _PromoRow();

  @override
  Widget build(BuildContext context) {
    // Figma: input + solid green Apply button (48h).
    return SizedBox(
      height: 48.h,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE0E6E0)),
              ),
              child: Text(
                'Promo code',
                style: AppTextStyles.bodyMedium(
                  color: const Color(0xFF6B756E),
                ).copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  height: 17 / 14,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 84.w,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E9E4D),
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Apply',
                style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                  height: 18 / 15,
                ),
              ),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE0E6E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2EB),
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Text('📍', style: TextStyle(fontSize: 18.sp, height: 1)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ScheduledCartData.selectedAddress,
                  style: AppTextStyles.labelMedium(
                    color: const Color(0xFF1A1A1A),
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    height: 17 / 14,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  ScheduledCartData.selectedAddressDetail,
                  style: AppTextStyles.caption(
                    color: const Color(0xFF6B756E),
                  ).copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    height: 15 / 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onChange,
            child: Text(
              'Change',
              style: AppTextStyles.labelSmall(
                color: const Color(0xFF2E9E4D),
              ).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                height: 16 / 13,
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

  /// Asset path for line icons; null means Same Day bolt (no Frame export yet).
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

    // Figma CSS: selected / Next Day strokes #FFFFFF; Standard & Economy #0F4D27.
    final Color tint = selected || method.id == 'next-day'
        ? Colors.white
        : const Color(0xFF0F4D27);

    // Same Day — bolt (no Frame lightning export yet).
    if (asset == null) {
      return Icon(
        Icons.bolt_rounded,
        size: 22.sp,
        color: tint,
      );
    }

    return ColorFiltered(
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      child: Image.asset(
        asset,
        width: 20.w,
        height: 20.w,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayPrice =
        showFreePrice && method.freeAfterNoon ? 'BHD 0.000' : method.price;
    final showStrike = showFreePrice && method.freeAfterNoon;

    // Figma: icon left · label · price · radio right.
    // Selected: bg #E4F1E9, border 2px #4CAF50.
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
                color: selected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFDBE6D4),
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
                    style: AppTextStyles.labelMedium(
                      color: const Color(0xFF1A1A1A),
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      height: 1.28,
                    ),
                  ),
                  if (method.subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      method.subtitle!,
                      style: AppTextStyles.caption(
                        color: const Color(0xFF6B756E),
                      ).copyWith(
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
                  displayPrice,
                  style: AppTextStyles.labelMedium(
                    color: const Color(0xFF1A1A1A),
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                    height: 1.28,
                  ),
                ),
                if (showStrike)
                  Text(
                    method.price,
                    style: AppTextStyles.caption(
                      color: const Color(0xFF6B756E),
                    ).copyWith(
                      fontSize: 11.sp,
                      decoration: TextDecoration.lineThrough,
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
                      color: selected
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE0E6E0),
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
          Icon(Icons.star_outline_rounded, size: 18.sp, color: const Color(0xFF7A5E12)),
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
    final progress = (secondsLeft.clamp(0, 10)) / 10;

    // Figma: #4CAF50 card, 92px ring (track #2C6B47, fill #C9A84C), white count.
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
            ScheduledCartStrings.placingOrder,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            ScheduledCartStrings.autoConfirmHint,
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
    // Figma: "Order summary" title above card; card padding 14×16, gap 8.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ScheduledCartStrings.orderSummary,
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
                ScheduledCartStrings.orderType,
                style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 8.h),
              _summaryRow(ScheduledCartStrings.method, deliveryLabel),
              _summaryRow(
                ScheduledCartStrings.deliverTo,
                ScheduledCartData.selectedAddress,
              ),
              _summaryRow(
                ScheduledCartStrings.payment,
                ScheduledCartStrings.cashOnDelivery,
              ),
              Divider(height: 16.h, thickness: 1, color: const Color(0xFFE2E8DD)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ScheduledCartStrings.orderTotal,
                    style: AppTextStyles.labelMedium(
                      color: const Color(0xFF1A1A1A),
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    total,
                    style: AppTextStyles.titleSmall(
                      color: const Color(0xFF1A1A1A),
                    ).copyWith(
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
