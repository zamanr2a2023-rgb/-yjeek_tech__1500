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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            children: [
              const PickupDetailsCard(),
              SizedBox(height: 14.h),
              const _PickupSectionHeader(title: PickupCartStrings.yourItems),
              SizedBox(height: 10.h),
              const PickupItemsCard(),
              SizedBox(height: 14.h),
              const _PickupSectionHeader(title: PickupCartStrings.youMightAlsoLike),
              SizedBox(height: 10.h),
              SizedBox(
                height: 133.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: PickupCartData.upsellItems.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
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

class _PickupSectionHeader extends StatelessWidget {
  const _PickupSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // Figma: 4×15 #4CAF50 rail.
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 15.h,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 7.w),
        Text(
          title,
          style: AppTextStyles.titleSmall(color: const Color(0xFF1A1A1A)).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class PickupDetailsCard extends StatelessWidget {
  const PickupDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma PK2: map 64 · copy · Ready chip · full-width Map button.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EAE0),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 26.w,
                  height: 26.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_on, size: 16.sp, color: AppColors.white),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${PickupCartStrings.pickupFrom} ${PickupCartData.vendor}',
                      style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      PickupCartData.pickupAddress,
                      style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBEFE0),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 12.sp, color: const Color(0xFFE08A1E)),
                          SizedBox(width: 4.w),
                          Text(
                            PickupCartData.readyIn,
                            style: AppTextStyles.caption(color: const Color(0xFFE08A1E)).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5.sp,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 33.h,
              padding: EdgeInsets.symmetric(horizontal: 11.w),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE6EBE3)),
                borderRadius: BorderRadius.circular(9.r),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Figma: near-me navigation arrow (#2E7D32), left-aligned with label.
                  Icon(Icons.near_me, size: 15.sp, color: const Color(0xFF2E7D32)),
                  SizedBox(width: 6.w),
                  Text(
                    PickupCartStrings.map,
                    style: AppTextStyles.labelSmall(color: const Color(0xFF2E7D32)).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5.sp,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PickupItemsCard extends StatelessWidget {
  const PickupItemsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma: single white card · #E6EBE3 · rows with qty mint badges.
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < PickupCartData.cartItems.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: Color(0xFFE6EBE3)),
            PickupCartItemRow(item: PickupCartData.cartItems[i]),
          ],
        ],
      ),
    );
  }
}

class PickupCartItemRow extends StatelessWidget {
  const PickupCartItemRow({
    super.key,
    required this.item,
  });

  final PickupCartItem item;

  @override
  Widget build(BuildContext context) {
    // Figma row: qty badge · name/options · price 12.5/700 right (#1A1A1A).
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DE),
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}×',
              style: AppTextStyles.caption(color: const Color(0xFF2E7D32)).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    height: 1.3,
                  ),
                ),
                if (item.subtitle != null) ...[
                  SizedBox(height: 1.h),
                  Text(
                    item.subtitle!,
                    style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            item.price,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              height: 1.3,
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

/// Figma checkout: one white card — title + PICKUP badge row, then map/store row.
class PickupCheckoutDetailsSection extends StatelessWidget {
  const PickupCheckoutDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  PickupCartStrings.pickupDetails,
                  style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5.sp,
                    height: 1.3,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.takeout_dining_outlined, size: 12.sp, color: const Color(0xFF2E7D32)),
                    SizedBox(width: 4.w),
                    Text(
                      PickupCartData.pickupBadge,
                      style: AppTextStyles.caption(color: const Color(0xFF2E7D32)).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EAE0),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 26.w,
                  height: 26.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_on, size: 16.sp, color: AppColors.white),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PickupCartData.vendorLocation,
                      style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      PickupCartData.checkoutAddress,
                      style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14.sp, color: const Color(0xFFE08A1E)),
                        SizedBox(width: 6.w),
                        Text(
                          PickupCartData.readyIn,
                          style: AppTextStyles.caption(color: const Color(0xFFE08A1E)).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 11.sp,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PickupTimeCard extends StatelessWidget {
  const PickupTimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma checkout ptime: white · #E2E8DD · radius 18 · dark clock · Change.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: const Color(0xFF0F4D27), size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PickupCartStrings.pickupTimeLabel,
                  style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                    height: 1.28,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  PickupCartData.pickupTime,
                  style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    height: 1.28,
                  ),
                ),
              ],
            ),
          ),
          Text(
            PickupCartStrings.change,
            style: AppTextStyles.labelSmall(color: const Color(0xFF4CAF50)).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              height: 1.28,
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
    // Figma note: #FCF0D4 · warning + #996B0D copy.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF0D4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 16.sp, color: const Color(0xFF996B0D)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              PickupCartStrings.policyWarning,
              style: AppTextStyles.caption(color: const Color(0xFF996B0D)).copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12.5.sp,
                height: 1.2,
              ),
            ),
          ),
        ],
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
