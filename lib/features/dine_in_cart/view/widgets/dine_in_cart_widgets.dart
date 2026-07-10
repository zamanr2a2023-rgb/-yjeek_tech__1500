import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/dine_in_cart/model/dine_in_cart_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class DineInBasketBody extends StatefulWidget {
  const DineInBasketBody({
    super.key,
    required this.onCheckout,
  });

  final VoidCallback onCheckout;

  @override
  State<DineInBasketBody> createState() => _DineInBasketBodyState();
}

class _DineInBasketBodyState extends State<DineInBasketBody> {
  int _mainQty = 1;
  int _partySize = DineInCartData.defaultPartySize;
  DineInSeating _seating = DineInSeating.indoor;
  bool _specialOccasion = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            children: [
              Text(
                DineInCartStrings.yourItems,
                style: AppTextStyles.titleSmall().copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 10.h),
              ...DineInCartData.cartItems.map((item) {
                if (item.isMain) {
                  return _MainItemCard(
                    item: item,
                    quantity: _mainQty,
                    onQuantityChanged: (v) => setState(() => _mainQty = v),
                  );
                }
                return _SecondaryItemRow(item: item);
              }),
              SizedBox(height: 16.h),
              Text(
                DineInCartStrings.makeItCombo,
                style: AppTextStyles.titleSmall().copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 120.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: DineInCartData.comboItems.length,
                  separatorBuilder: (_, _) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
                    final combo = DineInCartData.comboItems[index];
                    return _ComboCard(combo: combo);
                  },
                ),
              ),
              SizedBox(height: 16.h),
              _PromoRow(),
              SizedBox(height: 16.h),
              Text(
                DineInCartStrings.dineInPreferences,
                style: AppTextStyles.titleSmall().copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 10.h),
              DineInPreferencesCard(
                partySize: _partySize,
                seating: _seating,
                specialOccasion: _specialOccasion,
                onPartySizeChanged: (v) => setState(() => _partySize = v),
                onSeatingChanged: (v) => setState(() => _seating = v),
                onSpecialOccasionChanged: (v) => setState(() => _specialOccasion = v),
              ),
              SizedBox(height: 16.h),
              BillSummaryCard(
                lines: DineInCartData.billLines,
                showCashback: true,
              ),
            ],
          ),
        ),
        _BasketFooter(onCheckout: widget.onCheckout),
      ],
    );
  }
}

class DineInPreferencesCard extends StatelessWidget {
  const DineInPreferencesCard({
    super.key,
    required this.partySize,
    required this.seating,
    required this.specialOccasion,
    required this.onPartySizeChanged,
    required this.onSeatingChanged,
    required this.onSpecialOccasionChanged,
  });

  final int partySize;
  final DineInSeating seating;
  final bool specialOccasion;
  final ValueChanged<int> onPartySizeChanged;
  final ValueChanged<DineInSeating> onSeatingChanged;
  final ValueChanged<bool> onSpecialOccasionChanged;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  DineInCartStrings.partySize,
                  style: AppTextStyles.labelMedium().copyWith(fontSize: 14.sp),
                ),
              ),
              Text(
                'Table for $partySize',
                style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(width: 10.w),
              _RoundBtn(
                icon: Icons.remove,
                onTap: partySize > DineInCartData.minPartySize
                    ? () => onPartySizeChanged(partySize - 1)
                    : null,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  '$partySize',
                  style: AppTextStyles.labelMedium().copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _RoundBtn(
                icon: Icons.add,
                onTap: partySize < DineInCartData.maxPartySize
                    ? () => onPartySizeChanged(partySize + 1)
                    : null,
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            DineInCartStrings.seating,
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _SeatingChip(
                label: DineInCartStrings.indoor,
                selected: seating == DineInSeating.indoor,
                onTap: () => onSeatingChanged(DineInSeating.indoor),
              ),
              SizedBox(width: 8.w),
              _SeatingChip(
                label: DineInCartStrings.outdoor,
                selected: seating == DineInSeating.outdoor,
                onTap: () => onSeatingChanged(DineInSeating.outdoor),
              ),
              SizedBox(width: 8.w),
              _SeatingChip(
                label: DineInCartStrings.any,
                selected: seating == DineInSeating.any,
                onTap: () => onSeatingChanged(DineInSeating.any),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DineInCartStrings.specialOccasion,
                      style: AppTextStyles.labelMedium().copyWith(fontSize: 14.sp),
                    ),
                    Text(
                      DineInCartStrings.specialOccasionHint,
                      style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: specialOccasion,
                onChanged: onSpecialOccasionChanged,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          Divider(height: 20.h, color: AppColors.border),
          Row(
            children: [
              Expanded(
                child: Text(
                  DineInCartStrings.noteForKitchen,
                  style: AppTextStyles.labelMedium().copyWith(fontSize: 14.sp),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20.sp),
            ],
          ),
        ],
      ),
    );
  }
}

class DineInPrepOptionCard extends StatelessWidget {
  const DineInPrepOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: selected ? AppColors.accountIconBackground : AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 12.sp,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 6 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DineInInfoBanner extends StatelessWidget {
  const DineInInfoBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE6D9A8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: const Color(0xFFC9A84C), size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.labelSmall(color: const Color(0xFF8A6D1A)).copyWith(
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

class DineInWalletNoteBanner extends StatelessWidget {
  const DineInWalletNoteBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFB8D4E8)),
      ),
      child: Text(
        DineInCartStrings.walletComboNote,
        style: AppTextStyles.labelSmall(color: const Color(0xFF2A5F7A)).copyWith(
          fontSize: 12.sp,
          height: 1.35,
        ),
      ),
    );
  }
}

class DineInPaymentList extends StatelessWidget {
  const DineInPaymentList({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  final List<PaymentOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return CartFlowCard(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: List.generate(options.length, (index) {
          final option = options[index];
          final selected = option.id == selectedId;
          return Column(
            children: [
              if (index > 0) Divider(height: 1, color: AppColors.border.withValues(alpha: 0.7)),
              InkWell(
                onTap: () => onSelected(option.id),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  child: Row(
                    children: [
                      if (option.icon != null)
                        Icon(option.icon, size: 22.sp, color: AppColors.textPrimary),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          option.label,
                          style: AppTextStyles.labelMedium().copyWith(fontSize: 14.sp),
                        ),
                      ),
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? AppColors.primary : AppColors.border,
                            width: selected ? 6 : 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class DineInReviewStatusCard extends StatelessWidget {
  const DineInReviewStatusCard({super.key, required this.secondsLeft});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$secondsLeft',
                  style: AppTextStyles.titleMedium(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DineInCartStrings.sendingOrder,
                      style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      DineInCartStrings.autoConfirmHint,
                      style: AppTextStyles.caption(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ).copyWith(fontSize: 11.sp, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: secondsLeft / 10,
              minHeight: 4.h,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class DineInReviewSummaryCard extends StatelessWidget {
  const DineInReviewSummaryCard({
    super.key,
    required this.prepMode,
  });

  final DineInPrepMode prepMode;

  @override
  Widget build(BuildContext context) {
    final diningOption = prepMode == DineInPrepMode.prepareNow
        ? DineInCartStrings.payPrepNow
        : 'Prepare on arrival';
    final time = prepMode == DineInPrepMode.prepareOnArrival
        ? DineInCartData.dineInTime
        : DineInCartStrings.tableReadyIn;

    return CartFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DineInCartStrings.orderSummary,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          _row(DineInCartStrings.restaurant, DineInCartData.vendorFull),
          _row(DineInCartStrings.items, 'Mixed Grill Platter + 2 more'),
          _row(DineInCartStrings.diningOptionLabel, diningOption),
          _row(DineInCartStrings.time, time),
          _row(DineInCartStrings.payment, DineInCartStrings.yjeekWallet),
          Divider(height: 20.h, color: AppColors.border),
          _row(DineInCartStrings.orderTotal, DineInCartData.orderTotal, bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                fontSize: 12.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                fontSize: bold ? 15.sp : 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainItemCard extends StatelessWidget {
  const _MainItemCard({
    required this.item,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final DineInCartItem item;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
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
                  style: AppTextStyles.titleSmall().copyWith(fontSize: 15.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.subtitle,
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    if (item.originalPrice != null) ...[
                      Text(
                        item.originalPrice!,
                        style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Text(
                      item.price,
                      style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2EB),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.restaurant, color: AppColors.primary, size: 28.sp),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _RoundBtn(
                    icon: Icons.remove,
                    onTap: quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text('$quantity', style: AppTextStyles.labelMedium()),
                  ),
                  _RoundBtn(
                    icon: Icons.add,
                    onTap: () => onQuantityChanged(quantity + 1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecondaryItemRow extends StatelessWidget {
  const _SecondaryItemRow({required this.item});

  final DineInCartItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.quantity > 1 ? '${item.name}  ×${item.quantity}' : item.name,
              style: AppTextStyles.labelMedium().copyWith(fontSize: 14.sp),
            ),
          ),
          Text(
            item.price,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComboCard extends StatelessWidget {
  const _ComboCard({required this.combo});

  final DineInComboItem combo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.w,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: combo.color,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.fastfood_outlined, size: 22.sp, color: AppColors.primary),
          ),
          SizedBox(height: 6.h),
          Text(
            combo.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption().copyWith(fontWeight: FontWeight.w600, fontSize: 10.sp),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                combo.price,
                style: AppTextStyles.caption(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 9.sp,
                ),
              ),
              Container(
                width: 20.w,
                height: 20.w,
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

class _PromoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              DineInCartStrings.promoCode,
              style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.iconBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            DineInCartStrings.submit,
            style: AppTextStyles.labelSmall(color: AppColors.successText).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SeatingChip extends StatelessWidget {
  const _SeatingChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelSmall(
              color: selected ? AppColors.white : AppColors.textPrimary,
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
          ),
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          color: AppColors.white,
        ),
        child: Icon(icon, size: 16.sp, color: AppColors.textPrimary),
      ),
    );
  }
}

class _BasketFooter extends StatelessWidget {
  const _BasketFooter({required this.onCheckout});

  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(
                  DineInCartStrings.addMore,
                  style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(DineInCartStrings.checkoutBtn, style: AppTextStyles.labelLarge()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
