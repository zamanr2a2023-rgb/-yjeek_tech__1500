import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/routes/app_router.dart';

class NavBackHeader extends StatelessWidget {
  const NavBackHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.titleColor = AppColors.textPrimary,
    this.backIconColor = AppColors.primary,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Color titleColor;
  final Color backIconColor;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            NavCircleBackButton(
              onTap: onBack ?? () => context.pop(),
              iconColor: backIconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall(color: titleColor).copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 1.h),
                    Text(
                      subtitle!,
                      style: AppTextStyles.labelSmall(
                        color: const Color(0xFF6B756E),
                      ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w400),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavCircleBackButton extends StatelessWidget {
  const NavCircleBackButton({super.key, this.onTap, this.iconColor = AppColors.primary});

  final VoidCallback? onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_back,
          size: 18.sp,
          color: iconColor,
        ),
      ),
    );
  }
}

class PillSegmentBar extends StatelessWidget {
  const PillSegmentBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  labels[index],
                  style: AppTextStyles.labelMedium(
                    color: active ? AppColors.successText : AppColors.textSecondary,
                  ).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class HorizontalFilterChips extends StatelessWidget {
  const HorizontalFilterChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.style = FilterChipStyle.category,
    this.spacing = 8,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final FilterChipStyle style;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: style == FilterChipStyle.offers ? 31 : 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final active = index == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: _FilterChip(
              label: labels[index],
              active: active,
              style: style,
            ),
          );
        },
      ),
    );
  }
}

enum FilterChipStyle { offers, category }

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.style,
  });

  final String label;
  final bool active;
  final FilterChipStyle style;

  @override
  Widget build(BuildContext context) {
    if (style == FilterChipStyle.offers) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE3F2EB) : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? const Color(0xFF2E9E4D) : const Color(0xFFE0E6E0),
            width: active ? 1.5 : 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            color: active ? const Color(0xFF127036) : const Color(0xFF6B756E),
          ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.5, height: 1),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(
          color: active ? AppColors.white : AppColors.textPrimary,
        ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.5),
      ),
    );
  }
}

class OfferBadge extends StatelessWidget {
  const OfferBadge({super.key, required this.label});

  final String label;

  ({Color background, Color foreground}) get _colors {
    final upper = label.toUpperCase();
    if (RegExp(r'\d+\s*FOR\s*\d+').hasMatch(upper)) {
      return (
        background: AppColors.offerBadgeGreenBg,
        foreground: AppColors.offerBadgeGreenText,
      );
    }
    if (upper.contains('B1G1') ||
        upper.startsWith('SAVE') ||
        upper == '50% OFF') {
      return (
        background: AppColors.offerBadgeRedBg,
        foreground: AppColors.offerBadgeRedText,
      );
    }
    return (
      background: AppColors.offerBadgeOrangeBg,
      foreground: AppColors.offerBadgeOrangeText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(color: colors.foreground).copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}

class ExclusiveOfferListCard extends StatelessWidget {
  const ExclusiveOfferListCard({
    super.key,
    required this.offer,
    this.onAdd,
  });

  final BrowseOffer offer;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE0E6E0)),
      ),
      child: Row(
        children: [
          AppPlaceholderImage(
            color: offer.imageColor,
            width: 76.w,
            height: 76.w,
            icon: Icons.fastfood_outlined,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        offer.name,
                        style: AppTextStyles.labelMedium(
                          color: AppColors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                    if (offer.badge != null) ...[
                      SizedBox(width: 6.w),
                      OfferBadge(label: offer.badge!),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  offer.vendor,
                  style: AppTextStyles.labelSmall(
                    color: const Color(0xFF6B756E),
                  ).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      offer.price,
                      style: AppTextStyles.labelMedium(
                        color: const Color(0xFF127036),
                      ).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    if (offer.originalPrice != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        offer.originalPrice!,
                        style: AppTextStyles.labelSmall(
                          color: const Color(0xFF6B756E),
                        ).copyWith(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF2E9E4D),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                '+',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartCategoryTabs extends StatefulWidget {
  const CartCategoryTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  State<CartCategoryTabs> createState() => _CartCategoryTabsState();
}

class _CartCategoryTabsState extends State<CartCategoryTabs> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _tabKeys =
      List.generate(CartTab.values.length, (_) => GlobalKey());

  static const _labels = [
    NavigationStrings.cartTabOrders,
    NavigationStrings.cartTabDineIn,
    NavigationStrings.cartTabPickup,
    NavigationStrings.cartTabServices,
  ];

  static const _tabMinWidths = [70.0, 73.0, 70.0, 81.0];

  @override
  void didUpdateWidget(CartCategoryTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _tabKeys[widget.selectedIndex].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = (52.h - 8.h - 31.h) / 2;

    return SizedBox(
      height: 52.h,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(20.w, topInset, 20.w, 8.h),
        itemCount: _labels.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final active = index == widget.selectedIndex;
          return GestureDetector(
            key: _tabKeys[index],
            onTap: () => widget.onChanged(index),
            child: Container(
              height: 31.h,
              constraints: BoxConstraints(minWidth: _tabMinWidths[index].w),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.cartTabActive : AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: active ? AppColors.cartTabActive : AppColors.cartTabBorder,
                  width: 1,
                ),
              ),
              child: Text(
                _labels[index],
                style: AppTextStyles.labelSmall(
                  color: active ? AppColors.white : AppColors.textPrimary,
                ).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5.sp,
                  height: 15 / 12.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EmptyCartBody extends StatelessWidget {
  const EmptyCartBody({
    super.key,
    required this.onBrowse,
    this.tab = CartTab.orders,
  });

  final VoidCallback onBrowse;
  final CartTab tab;

  String get _title => switch (tab) {
        CartTab.orders => NavigationStrings.cartEmptyTitle,
        CartTab.dineIn => NavigationStrings.cartDineInEmptyTitle,
        CartTab.pickup => NavigationStrings.cartPickupEmptyTitle,
        CartTab.services => NavigationStrings.cartServicesEmptyTitle,
      };

  String get _subtitle => switch (tab) {
        CartTab.orders => NavigationStrings.cartEmptySubtitle,
        CartTab.dineIn => NavigationStrings.cartDineInEmptySubtitle,
        CartTab.pickup => NavigationStrings.cartPickupEmptySubtitle,
        CartTab.services => NavigationStrings.cartServicesEmptySubtitle,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 567.h,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: const BoxDecoration(
                    color: AppColors.iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    tab.emptyIcon,
                    color: AppColors.primary,
                    size: 44.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayMedium().copyWith(fontSize: 23.sp),
                ),
                SizedBox(height: 16.h),
                Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 55.h,
                  child: ElevatedButton(
                    onPressed: onBrowse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 17.h,
                      ),
                    ),
                    child: Text(
                      NavigationStrings.browseVendors,
                      style: AppTextStyles.labelLarge(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.label});

  final String label;

  Color get _background {
    final lower = label.toLowerCase();
    if (lower.contains('delivery')) return const Color(0xFFD9EFE0);
    if (lower.contains('deliver') || lower.contains('complet')) {
      return const Color(0xFFE3F2EB);
    }
    if (lower.contains('upcoming')) return const Color(0xFFFFF2D9);
    if (lower.contains('progress')) return const Color(0xFFFCF0D4);
    return const Color(0xFFE3F2EB);
  }

  Color get _foreground {
    final lower = label.toLowerCase();
    if (lower.contains('delivery')) return AppColors.primary;
    if (lower.contains('deliver') || lower.contains('complet')) {
      return AppColors.successText;
    }
    if (lower.contains('upcoming')) return const Color(0xFFD98C1A);
    if (lower.contains('progress')) return const Color(0xFF996B0D);
    return AppColors.successText;
  }

  double get _fontSize => label.toLowerCase().contains('delivery') ? 10 : 11;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(color: _foreground).copyWith(
          fontWeight: FontWeight.w700,
          fontSize: _fontSize.sp,
          height: 13 / _fontSize,
        ),
      ),
    );
  }
}

class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({
    super.key,
    required this.order,
    this.onAction,
    this.onTap,
  });

  final OrderHistoryItem order;
  final ValueChanged<String>? onAction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isActiveDelivery = order.arrivalText != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
                Expanded(
                  child: Text(
                    order.vendor,
                    style: AppTextStyles.titleSmall().copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (order.badge != null) ...[
                  SizedBox(width: 8.w),
                  OrderStatusBadge(label: order.badge!),
                ],
                SizedBox(width: 8.w),
                Text(
                  '›',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B756E),
                    height: 22 / 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              order.subtitle,
              style: AppTextStyles.labelSmall(
                color: const Color(0xFF6B756E),
              ).copyWith(fontSize: 12.5.sp),
            ),
            if (isActiveDelivery) ...[
              SizedBox(height: 10.h),
              Text(
                order.arrivalText!,
                style: AppTextStyles.labelMedium(
                  color: AppColors.successText,
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: const LinearProgressIndicator(
                  value: 0.65,
                  minHeight: 4,
                  backgroundColor: Color(0xFFE3F2EB),
                  color: Color(0xFF2E9E4D),
                ),
              ),
            ] else ...[
              SizedBox(height: 8.h),
              Text(
                order.price,
                style: AppTextStyles.labelMedium(
                  color: AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 15.sp),
              ),
            ],
            if (order.actions.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  for (var i = 0; i < order.actions.length; i++) ...[
                    if (i > 0) SizedBox(width: 8.w),
                    _OrderActionButton(
                      label: order.actions[i],
                      onTap: () => onAction?.call(order.actions[i]),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderActionButton extends StatelessWidget {
  const _OrderActionButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  bool get _isPrimary => label == NavigationStrings.trackOrder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: _isPrimary ? AppColors.cartTabActive : AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _isPrimary ? AppColors.cartTabActive : AppColors.cartTabBorder,
            width: 1.3,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            color: _isPrimary ? AppColors.white : AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class BillSummaryCard extends StatelessWidget {
  const BillSummaryCard({
    super.key,
    required this.lines,
    this.showPromo = false,
    this.showCashback = false,
    this.cashbackAmount,
  });

  final List<BillLine> lines;
  final bool showPromo;
  final bool showCashback;
  final String? cashbackAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showPromo) ...[
            const PromoCodeField(),
            const SizedBox(height: 14),
          ],
          ...lines.map((line) {
            final bool mutedValue = line.value.startsWith('—');
            final Color labelColor = line.isDiscount
                ? AppColors.primary
                : line.isBold
                    ? AppColors.textPrimary
                    : AppColors.textSecondary;
            final Color valueColor = line.isDiscount
                ? AppColors.primary
                : line.isBold
                    ? AppColors.textPrimary
                    : mutedValue
                        ? AppColors.textSecondary
                        : AppColors.textPrimary;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      line.label,
                      style: AppTextStyles.labelSmall(color: labelColor)
                          .copyWith(
                        fontWeight:
                            line.isBold ? FontWeight.w700 : FontWeight.w500,
                        fontSize: line.isBold ? 16 : 14,
                      ),
                    ),
                  ),
                  Text(
                    line.value,
                    style: AppTextStyles.labelSmall(color: valueColor).copyWith(
                      fontWeight:
                          line.isBold ? FontWeight.w700 : FontWeight.w600,
                      fontSize: line.isBold ? 18 : 14,
                      decoration: line.isStrikethrough
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: valueColor,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (showCashback) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F0DC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_border,
                    color: Color(0xFFC9A84C),
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      NavigationStrings.cashbackBanner,
                      style: AppTextStyles.labelSmall(
                        color: const Color(0xFF7A5E12),
                      ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                  Text(
                    cashbackAmount ?? NavigationStrings.cashbackBannerAmount,
                    style: AppTextStyles.labelSmall(
                      color: const Color(0xFF7A5E12),
                    ).copyWith(fontWeight: FontWeight.w700, fontSize: 12.5),
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

class PromoCodeField extends StatelessWidget {
  const PromoCodeField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_activity_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              NavigationStrings.enterPromoCode,
              style: AppTextStyles.bodyMedium().copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            NavigationStrings.submit,
            style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    this.icon,
    this.iconAsset,
    this.iconSize,
    required this.title,
    this.trailing,
    this.badge,
    this.onTap,
    this.destructive = false,
  }) : assert(icon != null || iconAsset != null);

  final IconData? icon;
  final String? iconAsset;
  final double? iconSize;
  final String title;
  final String? trailing;
  final String? badge;
  final VoidCallback? onTap;
  final bool destructive;

  Color get _accentColor =>
      destructive ? const Color(0xFF9B111E) : AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: destructive
                      ? AppColors.white
                      : AppColors.accountIconBackground,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: iconAsset != null
                    ? Image.asset(
                        iconAsset!,
                        width: (iconSize ?? 20).w,
                        height: (iconSize ?? 20).w,
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        icon,
                        size: (iconSize ?? 20).w,
                        color: _accentColor,
                      ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium(color: _accentColor).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5.sp,
                  ),
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7E3E0),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: const Color(0xFFF0D4D0)),
                  ),
                  child: Text(
                    badge!,
                    style: AppTextStyles.caption(color: AppColors.error).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 9.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              if (trailing != null)
                Text(
                  trailing!,
                  style: AppTextStyles.labelSmall(
                    color: AppColors.textSecondary,
                  ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w500),
                ),
              SizedBox(width: 4.w),
              Text(
                '›',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: destructive
                      ? const Color(0xFF9B111E)
                      : const Color(0xFF6B7B6E),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            title,
            style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class ShellBottomNavBar extends StatelessWidget {
  const ShellBottomNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return HomeBottomNavBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goHome(tab: index);
          }
          return;
        }
        context.goHome(tab: index);
      },
    );
  }
}
