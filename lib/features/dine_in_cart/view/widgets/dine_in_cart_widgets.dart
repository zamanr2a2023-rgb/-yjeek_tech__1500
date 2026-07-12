import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
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
    final mainItem = DineInCartData.cartItems.firstWhere((i) => i.isMain);
    final sideItems = DineInCartData.cartItems.where((i) => !i.isMain).toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
            children: [
              Text(
                DineInCartStrings.yourItems,
                style: AppTextStyles.titleSmall(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  height: 1.28,
                ),
              ),
              SizedBox(height: 14.h),
              _YourItemsCard(
                mainItem: mainItem,
                sideItems: sideItems,
                quantity: _mainQty,
                onQuantityChanged: (v) => setState(() => _mainQty = v),
              ),
              SizedBox(height: 14.h),
              Text(
                DineInCartStrings.makeItCombo,
                style: AppTextStyles.titleSmall(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  height: 1.28,
                ),
              ),
              SizedBox(height: 14.h),
              SizedBox(
                height: 133.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: DineInCartData.comboItems.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    return _ComboCard(combo: DineInCartData.comboItems[index]);
                  },
                ),
              ),
              SizedBox(height: 14.h),
              const _PromoRow(),
              SizedBox(height: 14.h),
              DineInPreferencesCard(
                partySize: _partySize,
                seating: _seating,
                specialOccasion: _specialOccasion,
                onPartySizeChanged: (v) => setState(() => _partySize = v),
                onSeatingChanged: (v) => setState(() => _seating = v),
                onSpecialOccasionChanged: (v) => setState(() => _specialOccasion = v),
              ),
              SizedBox(height: 14.h),
              Text(
                DineInCartStrings.billSummary,
                style: AppTextStyles.titleSmall(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  height: 1.28,
                ),
              ),
              SizedBox(height: 10.h),
              BillSummaryCard(
                lines: DineInCartData.billLines,
                showCashback: true,
                cashbackAmount: DineInCartData.cashbackAmount,
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DineInCartStrings.dineInPreferences,
            style: AppTextStyles.titleSmall(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 1.28,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DineInCartStrings.partySize,
                      style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Table for $partySize',
                      style: AppTextStyles.caption(color: const Color(0xFF69706E)).copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
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
                  style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              _RoundBtn(
                icon: Icons.add,
                filled: true,
                onTap: partySize < DineInCartData.maxPartySize
                    ? () => onPartySizeChanged(partySize + 1)
                    : null,
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            DineInCartStrings.seating,
            style: AppTextStyles.labelSmall(color: const Color(0xFF69706E)).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
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
              Icon(Icons.card_giftcard_outlined, size: 22.sp, color: const Color(0xFF0F4D27)),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DineInCartStrings.specialOccasion,
                      style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        height: 1.28,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      DineInCartStrings.specialOccasionHint,
                      style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        height: 1.28,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: specialOccasion,
                onChanged: onSpecialOccasionChanged,
                activeTrackColor: AppColors.cartTabActive,
                activeThumbColor: AppColors.white,
                inactiveTrackColor: const Color(0xFFC5CCBE),
                inactiveThumbColor: AppColors.white,
              ),
            ],
          ),
          Divider(height: 20.h, color: const Color(0xFFE2E8DD)),
          Row(
            children: [
              Icon(Icons.chat_bubble_outline, size: 22.sp, color: const Color(0xFF0F4D27)),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DineInCartStrings.noteForKitchen,
                      style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        height: 1.28,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      DineInCartStrings.noteForKitchenHint,
                      style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        height: 1.28,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '›',
                style: TextStyle(
                  color: const Color(0xFF6B7B6E),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.28,
                ),
              ),
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
    this.iconBackground,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackground;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = iconBackground ??
        (selected ? AppColors.primary : AppColors.accountIconBackground);
    final fg = iconColor ?? (selected ? AppColors.white : AppColors.primary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? AppColors.cartTabActive : const Color(0xFFD9DED9),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: fg, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      height: 1.28,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5.sp,
                      height: 1.28,
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
                color: selected ? AppColors.cartTabActive : AppColors.white,
                border: Border.all(
                  color: selected ? AppColors.cartTabActive : const Color(0xFFD9DED9),
                  width: selected ? 6.5 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DineInTableReadyCard extends StatelessWidget {
  const DineInTableReadyCard({super.key});

  @override
  Widget build(BuildContext context) {
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
          Icon(Icons.schedule, size: 22.sp, color: const Color(0xFF0F4D27)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DineInCartStrings.tableReadyLabel,
                  style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                    height: 1.28,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  DineInCartStrings.tableReadyValue,
                  style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    height: 1.28,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E9C2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        message,
        style: AppTextStyles.labelSmall(color: const Color(0xFF8A6D1E)).copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 12.sp,
          height: 1.28,
        ),
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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2EB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.payPinkPurse,
            width: 16.w,
            height: 16.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              DineInCartStrings.walletComboNote,
              style: AppTextStyles.labelSmall(color: const Color(0xFF127036)).copyWith(
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
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Row(
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1E6),
                          borderRadius: BorderRadius.circular(9.r),
                        ),
                        alignment: Alignment.center,
                        child: option.iconAsset != null
                            ? Image.asset(
                                option.iconAsset!,
                                width: 18.w,
                                height: 18.w,
                                fit: BoxFit.contain,
                              )
                            : Icon(
                                option.icon ?? Icons.payment_outlined,
                                size: 18.sp,
                                color: const Color(0xFF0F4D27),
                              ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                                  .copyWith(
                                fontWeight: option.subtitle != null
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 14.sp,
                                height: 1.28,
                              ),
                            ),
                            if (option.subtitle != null) ...[
                              SizedBox(height: 2.h),
                              Text(
                                option.subtitle!,
                                style: AppTextStyles.caption(
                                  color: const Color(0xFF6B7B6E),
                                ).copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.5.sp,
                                  height: 1.28,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? AppColors.primary : const Color(0xFFE2E8DD),
                            width: selected ? 6.5 : 1.5,
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
  const DineInReviewStatusCard({
    super.key,
    required this.secondsLeft,
    this.totalSeconds = 10,
  });

  final int secondsLeft;
  final int totalSeconds;

  static const Color _ringTrack = Color(0xFF2C6B47);
  static const Color _ringProgress = Color(0xFFC9A84C);
  static const Color _hint = Color(0xFFCFE8D8);

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds <= 0
        ? 0.0
        : (secondsLeft / totalSeconds).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
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
                    backgroundColor: _ringTrack,
                    color: _ringProgress,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$secondsLeft',
                  style: AppTextStyles.titleMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 38.sp,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            DineInCartStrings.sendingOrder,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            DineInCartStrings.autoConfirmHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: _hint).copyWith(
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
              backgroundColor: _ringTrack,
              color: _ringProgress,
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

    return CartFlowCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DineInCartStrings.orderSummary,
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 12.h),
          _row(DineInCartStrings.restaurant, DineInCartData.vendorFull),
          _row(DineInCartStrings.items, 'Mixed Grill Platter + 2 more'),
          _row(DineInCartStrings.diningOptionLabel, diningOption),
          _row(DineInCartStrings.time, DineInCartData.dineInTime),
          _row(DineInCartStrings.payment, DineInCartStrings.yjeekWallet),
          Divider(height: 20.h, color: const Color(0xFFE2E8DD)),
          _row(DineInCartStrings.orderTotal, DineInCartData.orderTotal, bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall(color: const Color(0xFF6B7B6E)).copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
              height: 1.3,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                fontSize: bold ? 15.sp : 13.sp,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YourItemsCard extends StatelessWidget {
  const _YourItemsCard({
    required this.mainItem,
    required this.sideItems,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final DineInCartItem mainItem;
  final List<DineInCartItem> sideItems;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
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
                      mainItem.name,
                      style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                        height: 1.28,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      mainItem.subtitle,
                      style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        height: 1.28,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 14.sp, color: AppColors.primary),
                        SizedBox(width: 5.w),
                        Text(
                          'Edit',
                          style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                            height: 1.28,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          mainItem.price,
                          style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                            height: 1.28,
                          ),
                        ),
                        if (mainItem.originalPrice != null) ...[
                          SizedBox(width: 8.w),
                          Text(
                            mainItem.originalPrice!,
                            style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp,
                              height: 1.28,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
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
                        begin: Alignment(-0.6, -1),
                        end: Alignment(0.6, 1),
                        colors: [Color(0xFF8A3B2A), Color(0xFF15302B)],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 31.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFE2E8DD)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: quantity > 1
                              ? () => onQuantityChanged(quantity - 1)
                              : null,
                          child: Icon(
                            Icons.delete_outline,
                            size: 15.sp,
                            color: const Color(0xFFC0392B),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 11.w),
                          child: Text(
                            '$quantity',
                            style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                                .copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                              height: 1.28,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onQuantityChanged(quantity + 1),
                          child: Icon(Icons.add, size: 15.sp, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8DD)),
          SizedBox(height: 6.h),
          for (final item in sideItems) _SecondaryItemRow(item: item),
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
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFFDCE7D4),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '${item.quantity}×',
              style: AppTextStyles.caption(color: const Color(0xFF0F4D27)).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
                height: 1.28,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              item.name,
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.5.sp,
                height: 1.28,
              ),
            ),
          ),
          Text(
            item.price,
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.5.sp,
              height: 1.28,
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
    return SizedBox(
      width: 120.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 120.w,
                height: 90.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  gradient: LinearGradient(
                    begin: const Alignment(-0.6, -1),
                    end: const Alignment(0.6, 1),
                    colors: [combo.gradientStart, combo.gradientEnd],
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
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8DD)),
                  ),
                  child: Icon(Icons.add, size: 16.sp, color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            combo.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.5.sp,
              height: 1.28,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            combo.price,
            style: AppTextStyles.caption(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
              height: 1.28,
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
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_outlined, size: 18.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              DineInCartStrings.promoCode,
              style: AppTextStyles.bodySmall(color: const Color(0xFF6B7B6E)).copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                height: 1.28,
              ),
            ),
          ),
          Text(
            DineInCartStrings.submit,
            style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              height: 1.28,
            ),
          ),
        ],
      ),
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
          padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 14.w),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE3F2EB) : AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selected ? AppColors.cartTabActive : const Color(0xFFD9DED9),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelSmall(
              color: selected ? const Color(0xFF127036) : AppColors.textPrimary,
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
          ),
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({
    required this.icon,
    this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.cartTabActive : AppColors.white,
          border: filled
              ? null
              : Border.all(color: const Color(0xFFD9DED9), width: 1.5),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: filled ? AppColors.white : const Color(0xFF69706E),
        ),
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
