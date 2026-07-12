import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class CartFlowScaffold extends StatelessWidget {
  const CartFlowScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.body,
    this.bottom,
    this.bottomNavIndex = 2,
    this.onBack,
    this.trailing,
    this.lightHeader = false,
    this.showBottomNav = true,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final Widget? body;
  final Widget? bottom;
  final int bottomNavIndex;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool lightHeader;
  final bool showBottomNav;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.background;
    return Scaffold(
      backgroundColor: bg,
      body: ColoredBox(
        color: bg,
        child: Column(
          children: [
            if (lightHeader)
              _CheckoutLightHeader(
                title: title,
                subtitle: subtitle,
                onBack: onBack,
                trailing: trailing,
              )
            else
              GreenScreenHeader(
                title: title,
                subtitle: subtitle,
                onBack: onBack,
                trailing: trailing,
              ),
            Expanded(child: body ?? const SizedBox.shrink()),
            if (bottom != null) bottom!,
          ],
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? ShellBottomNavBar(currentIndex: bottomNavIndex)
          : null,
    );
  }
}

class _CheckoutLightHeader extends StatelessWidget {
  const _CheckoutLightHeader({
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 8.h),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            NavCircleBackButton(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              iconColor: AppColors.textPrimary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall().copyWith(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: AppTextStyles.labelSmall(
                        color: AppColors.textSecondary,
                      ).copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class CartSectionTitle extends StatelessWidget {
  const CartSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        title,
        style: AppTextStyles.titleSmall().copyWith(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class CartFlowCard extends StatelessWidget {
  const CartFlowCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class CartMapPlaceholder extends StatelessWidget {
  const CartMapPlaceholder({
    super.key,
    this.height,
    this.showPin = true,
    this.tint,
    this.expand = false,
  });

  final double? height;
  final bool showPin;
  final Color? tint;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final map = Container(
      height: expand ? null : (height ?? 130.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: tint ?? const Color(0xFFD1E0D4),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: showPin
          ? Center(
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: const BoxDecoration(
                  color: AppColors.cartTabActive,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.location_on,
                  color: const Color(0xFFE53935),
                  size: 18.sp,
                ),
              ),
            )
          : null,
    );
    return expand ? SizedBox.expand(child: map) : map;
  }
}

class CartDeliveryDetailsCard extends StatelessWidget {
  const CartDeliveryDetailsCard({
    super.key,
    required this.address,
    required this.onChange,
    this.addressDetail,
    this.phone,
  });

  final String address;
  final String? addressDetail;
  final String? phone;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120.h,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-0.8, -0.6),
                      end: Alignment(0.8, 0.8),
                      colors: [Color(0xFFCFD9D0), Color(0xFFAEBFAE)],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18.sp,
                  color: const Color(0xFF0F4D27),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address,
                        style: AppTextStyles.labelMedium(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                      if (addressDetail != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          addressDetail!,
                          style: AppTextStyles.labelSmall(
                            color: AppColors.textSecondary,
                          ).copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                      if (phone != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          phone!,
                          style: AppTextStyles.labelSmall(
                            color: AppColors.textSecondary,
                          ).copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onChange,
                  child: Text(
                    CartFlowStrings.change,
                    style: AppTextStyles.labelSmall(
                      color: AppColors.primary,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: const Color(0xFFE2E8DD)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
            child: Text(
              CartFlowStrings.arrivesIn,
              style: AppTextStyles.labelMedium(
                color: AppColors.textPrimary,
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartDropOffGrid extends StatelessWidget {
  const CartDropOffGrid({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    this.saveForAddress = false,
    this.onSaveChanged,
    this.showTitle = false,
  });

  final List<DropOffOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool saveForAddress;
  final ValueChanged<bool>? onSaveChanged;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return CartFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Text(
              CartFlowStrings.dropOffPreferences,
              style: AppTextStyles.titleSmall().copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
          ],
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 6.w,
              childAspectRatio: 74 / 68,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final selected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onSelected(index),
                child: Container(
                  padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1E6),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (option.iconAsset != null)
                        Image.asset(
                          option.iconAsset!,
                          width: 16.w,
                          height: 16.w,
                          fit: BoxFit.contain,
                        )
                      else
                        Icon(
                          option.icon,
                          size: 16.sp,
                          color: const Color(0xFF0F4D27),
                        ),
                      SizedBox(height: 5.h),
                      Expanded(
                        child: Text(
                          option.label,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption(
                            color: AppColors.textPrimary,
                          ).copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (onSaveChanged != null) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => onSaveChanged!(!saveForAddress),
              child: Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: saveForAddress
                          ? AppColors.primary
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: saveForAddress
                            ? AppColors.primary
                            : const Color(0xFFE2E8DD),
                        width: 1.5,
                      ),
                    ),
                    child: saveForAddress
                        ? Icon(
                            Icons.check,
                            size: 14.sp,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    CartFlowStrings.saveDropOffForAddress,
                    style: AppTextStyles.labelSmall(
                      color: AppColors.textSecondary,
                    ).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CartTipSelector extends StatelessWidget {
  const CartTipSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    this.showHeader = false,
  });

  final List<TipOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final chips = Row(
      children: List.generate(options.length, (index) {
        final selected = index == selectedIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < options.length - 1 ? 8.w : 0),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  options[index].label,
                  style: AppTextStyles.labelSmall(
                    color: selected ? AppColors.white : AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w700, fontSize: 12.sp),
                ),
              ),
            ),
          ),
        );
      }),
    );

    if (!showHeader) return chips;

    return CartFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4EBD0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sports_motorsports_outlined,
                  size: 20.sp,
                  color: const Color(0xFF8A6D1A),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CartFlowStrings.tipYourChamp,
                      style: AppTextStyles.titleSmall().copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      CartFlowStrings.tipChampSubtitle,
                      style: AppTextStyles.labelSmall(
                        color: AppColors.textSecondary,
                      ).copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          chips,
        ],
      ),
    );
  }
}

class CartPaymentMethodList extends StatelessWidget {
  const CartPaymentMethodList({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    this.showSecurityNotes = false,
  });

  final List<PaymentOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final bool showSecurityNotes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CartFlowCard(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Column(
            children: List.generate(options.length, (index) {
              final option = options[index];
              final selected = option.id == selectedId;
              return Column(
                children: [
                  if (index > 0)
                    Divider(
                      height: 1,
                      color: AppColors.border.withValues(alpha: 0.7),
                    ),
                  InkWell(
                    onTap: () => onSelected(option.id),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: option.iconAsset != null
                                ? Image.asset(
                                    option.iconAsset!,
                                    width: 22.w,
                                    height: 22.w,
                                    fit: BoxFit.contain,
                                  )
                                : Icon(
                                    option.icon,
                                    size: 22.sp,
                                    color: AppColors.textPrimary,
                                  ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              option.label,
                              style: AppTextStyles.labelMedium(
                                color: AppColors.textPrimary,
                              ).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : const Color(0xFFE2E8DD),
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
        ),
        if (showSecurityNotes) ...[
          SizedBox(height: 12.h),
          Row(
            children: [
              Image.asset(
                AppAssets.payPciShield,
                width: 16.w,
                height: 16.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  CartFlowStrings.pciProtected,
                  style: AppTextStyles.labelSmall(
                    color: const Color(0xFF3D7BD9),
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2EB),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Image.asset(
                  AppAssets.payPinkPurse,
                  width: 14.w,
                  height: 14.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    CartFlowStrings.walletComboNote,
                    style: AppTextStyles.labelSmall(
                      color: const Color(0xFF127036),
                    ).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class CartZoodPromoBanner extends StatelessWidget {
  const CartZoodPromoBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFF9B111E),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFADB73),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  CartFlowStrings.zoodBadge,
                  style: AppTextStyles.caption(
                    color: const Color(0xFF73141F),
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5.sp,
                    height: 1.24,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  CartFlowStrings.zoodPromoTitle,
                  style: AppTextStyles.labelMedium(
                    color: AppColors.white,
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: CartFlowData.zoodPromoChips
                .map(
                  (chip) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      // Soft translucent pill on deep red (matches design look).
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    child: Text(
                      chip,
                      style: AppTextStyles.caption(
                        color: AppColors.white,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                        height: 1.18,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  CartFlowStrings.zoodPromoHint,
                  style: AppTextStyles.labelSmall(
                    color: const Color(0xFFFFDBE0),
                  ).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    height: 1.25,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Text(
                    CartFlowStrings.zoodJoinWaitingList,
                    style: AppTextStyles.labelSmall(
                      color: const Color(0xFF9B111E),
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      height: 1.2,
                    ),
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

class CartZoodBanner extends StatelessWidget {
  const CartZoodBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFCE8E9),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE8B4B7)),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: CartFlowData.zoodRed,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.auto_awesome, color: AppColors.white, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                CartFlowStrings.zoodBanner,
                style: AppTextStyles.labelSmall(color: CartFlowData.zoodRed).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: CartFlowData.zoodRed, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class CartStickyFooter extends StatelessWidget {
  const CartStickyFooter({
    super.key,
    required this.total,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String total;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8DD)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TOTAL',
                  style: AppTextStyles.caption(
                    color: AppColors.textSecondary,
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
                ),
                Text(
                  total,
                  style: AppTextStyles.titleSmall(
                    color: AppColors.textPrimary,
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 149.w,
              height: 52.h,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: AppTextStyles.labelLarge().copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
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

class CartAddressRadioTile extends StatelessWidget {
  const CartAddressRadioTile({
    super.key,
    required this.address,
    required this.selected,
    required this.onTap,
    this.onEdit,
  });

  final CartDeliveryAddress address;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE3F2EB) : AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? const Color(0xFF2E9E4D) : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                address.icon ?? Icons.location_on_outlined,
                size: 18.sp,
                color: const Color(0xFF127036),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    address.subtitle,
                    style: AppTextStyles.labelSmall(
                      color: AppColors.textSecondary,
                    ).copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                    ),
                  ),
                  if (address.phone != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      address.phone!,
                      style: AppTextStyles.labelSmall(
                        color: AppColors.textSecondary,
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
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? const Color(0xFF2E9E4D) : AppColors.white,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF2E9E4D)
                          : AppColors.border,
                      width: selected ? 0 : 1.5,
                    ),
                  ),
                  child: selected
                      ? Icon(
                          Icons.check,
                          size: 14.sp,
                          color: AppColors.white,
                        )
                      : null,
                ),
                if (onEdit != null) ...[
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: onEdit,
                    child: Text(
                      'Edit',
                      style: AppTextStyles.labelSmall(
                        color: const Color(0xFF127036),
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CartAddressLabelChips extends StatelessWidget {
  const CartAddressLabelChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: labels.map((label) {
        final isSelected = label == selected;
        return GestureDetector(
          onTap: () => onSelected(label),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE3F2EB) : AppColors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.cartTabActive
                    : const Color(0xFFD9DED9),
                width: isSelected ? 1.5 : 1.2,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.labelSmall(
                color: isSelected
                    ? const Color(0xFF127036)
                    : AppColors.textSecondary,
              ).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class CartFormLabel extends StatelessWidget {
  const CartFormLabel(this.label, {super.key, this.topPadding = 0});

  final String label;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, top: topPadding.h),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.caption(color: const Color(0xFF8C948C)).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
          letterSpacing: 0.44,
        ),
      ),
    );
  }
}

class CartFormField extends StatelessWidget {
  const CartFormField({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFD9DED9)),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}

class CartFormFieldPair extends StatelessWidget {
  const CartFormFieldPair({
    super.key,
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CartFormLabel(leftLabel),
              CartFormField(value: leftValue),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CartFormLabel(rightLabel),
              CartFormField(value: rightValue),
            ],
          ),
        ),
      ],
    );
  }
}

class CartPhotoUploadRow extends StatelessWidget {
  const CartPhotoUploadRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 90.w,
          height: 90.w,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.cartTabActive, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: const Color(0xFF127036), size: 22.sp),
              SizedBox(height: 4.h),
              Text(
                CartFlowStrings.addPhoto,
                style: AppTextStyles.caption(color: const Color(0xFF127036)).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        _photoThumb(AppAssets.addressBuildingPhoto),
        SizedBox(width: 10.w),
        _photoThumb(AppAssets.addressDoorPhoto),
      ],
    );
  }

  Widget _photoThumb(String asset) {
    return Container(
      width: 90.w,
      height: 90.w,
      decoration: BoxDecoration(
        color: const Color(0xFFDBE6D6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        asset,
        width: 40.w,
        height: 40.w,
        fit: BoxFit.contain,
      ),
    );
  }
}

class CartDeleteAddressButton extends StatelessWidget {
  const CartDeleteAddressButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDB2626),
          backgroundColor: AppColors.white,
          side: const BorderSide(color: Color(0xFFEBCCCC), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, size: 18.sp, color: const Color(0xFFDB2626)),
            SizedBox(width: 8.w),
            Text(
              CartFlowStrings.deleteAddress,
              style: AppTextStyles.labelMedium(color: const Color(0xFFDB2626)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartReviewStatusCard extends StatelessWidget {
  const CartReviewStatusCard({
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
            CartFlowStrings.sendingOrder,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            CartFlowStrings.autoConfirmHint,
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

class CartReviewSummaryCard extends StatelessWidget {
  const CartReviewSummaryCard({super.key, this.onEditAddress});

  final VoidCallback? onEditAddress;

  static const Color _detailIcon = Color(0xFF0F4D27);

  @override
  Widget build(BuildContext context) {
    return CartFlowCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CartFlowData.vendor.toUpperCase(),
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 8.h),
          _itemRow(
            qty: '1×',
            name: CartFlowData.itemName,
            price: CartFlowData.itemPrice,
          ),
          SizedBox(height: 8.h),
          _itemRow(
            qty: '1×',
            name: CartFlowData.addonItemName,
            price: CartFlowData.addonItemPrice,
          ),
          SizedBox(height: 8.h),
          Divider(height: 1, thickness: 1, color: AppColors.border),
          SizedBox(height: 2.h),
          _detailRow(
            icon: Icons.location_on_outlined,
            label: CartFlowStrings.deliverToLabel,
            value: CartFlowData.reviewAddressLine,
            trailing: onEditAddress == null
                ? null
                : GestureDetector(
                    onTap: onEditAddress,
                    child: Text(
                      CartFlowStrings.edit,
                      style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
          ),
          _detailRow(
            icon: Icons.access_time,
            label: CartFlowStrings.arrivesInLabel,
            value: CartFlowStrings.standardDelivery,
          ),
          _detailRow(
            icon: Icons.payments_outlined,
            label: CartFlowStrings.paymentLabel,
            value: CartFlowStrings.cashOnDelivery,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  CartFlowStrings.orderTotalLabel,
                  style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              Text(
                CartFlowData.orderTotal,
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
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

  Widget _itemRow({
    required String qty,
    required String name,
    required String price,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.iconBackground,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            qty,
            style: AppTextStyles.labelSmall(color: AppColors.successText).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11.sp,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.5.sp,
            ),
          ),
        ),
        Text(
          price,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13.5.sp,
          ),
        ),
      ],
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: _detailIcon),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  value,
                  style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5.sp,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

class CartOutlineButton extends StatelessWidget {
  const CartOutlineButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 53.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: Color(0xFFE2E8DD), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}

void showCartNewCartDialog(BuildContext context, {VoidCallback? onConfirm}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x800F1A12),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(24.w, 26.h, 24.w, 20.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6E9C2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: const Color(0xFF9A6B12),
                  size: 26.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                CartFlowStrings.startNewCartTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 21.sp,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                CartFlowStrings.startNewCartBody,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 20.h),
              PrimaryGreenButton(
                label: CartFlowStrings.startNewCart,
                backgroundColor: AppColors.primary,
                height: 55,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  onConfirm?.call();
                },
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: AppColors.white,
                    side: const BorderSide(color: Color(0xFFE2E8DD), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    CartFlowStrings.keepCurrentCart,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showCartDeleteAddressDialog(BuildContext context, {VoidCallback? onDelete}) {
  showDialog<void>(
    context: context,
    barrierColor: const Color(0x73000000),
    builder: (dialogContext) => Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 37.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.addressDeleteTrash,
              width: 60.w,
              height: 60.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 12.h),
            Text(
              CartFlowStrings.deleteAddressTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall(color: AppColors.textPrimary).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              CartFlowStrings.deleteAddressBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 13.sp,
                height: 16 / 13,
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        backgroundColor: AppColors.white,
                        side: const BorderSide(color: Color(0xFFD9DED9), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        CartFlowStrings.cancel,
                        style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        onDelete?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDB2626),
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        CartFlowStrings.delete,
                        style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
