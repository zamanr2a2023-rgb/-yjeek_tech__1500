import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';

class OrderFlowScaffold extends StatelessWidget {
  const OrderFlowScaffold({
    super.key,
    required this.body,
    this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.bottom,
    this.bottomNavIndex = 1,
    this.showHeader = true,
    this.lightHeader = false,
    this.backgroundColor,
  });

  final Widget body;
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget? bottom;
  final int bottomNavIndex;
  final bool showHeader;
  final bool lightHeader;
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
            if (showHeader && title != null)
              lightHeader
                  ? _OrderLightHeader(
                      title: title!,
                      subtitle: subtitle,
                      onBack: onBack,
                      trailing: trailing,
                    )
                  : GreenScreenHeader(
                      title: title!,
                      subtitle: subtitle,
                      onBack: onBack,
                      trailing: trailing,
                    )
            else if (showHeader)
              SizedBox(height: MediaQuery.paddingOf(context).top),
            Expanded(child: body),
            if (bottom != null) bottom!,
          ],
        ),
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: bottomNavIndex),
    );
  }
}

class _OrderLightHeader extends StatelessWidget {
  const _OrderLightHeader({
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
    // Figma light header: padding 4/20/8, gap 12, title 20/700, subtitle #6B756E.
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.left,
                    style: AppTextStyles.titleSmall(
                      color: const Color(0xFF1A1A1A),
                    ).copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      height: 24 / 20,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 1.h),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.left,
                      style: AppTextStyles.labelSmall(
                        color: const Color(0xFF6B756E),
                      ).copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        height: 15 / 12,
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

class OrderSuccessIcon extends StatelessWidget {
  const OrderSuccessIcon({super.key, this.size});

  /// Optional width; height scales to the design pill ratio (72×41).
  final double? size;

  @override
  Widget build(BuildContext context) {
    final width = size ?? 72.w;
    final height = size != null ? size! * (41 / 72) : 41.h;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2EB),
        borderRadius: BorderRadius.circular(36.r),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.check,
        color: const Color(0xFF127036),
        size: (size != null ? size! * 0.38 : 28.sp),
      ),
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        children: [
          _row(OrderFlowStrings.items, OrderFlowData.itemCount),
          SizedBox(height: 10.h),
          _row(OrderFlowStrings.deliverTo, OrderFlowData.deliveryAddress),
          SizedBox(height: 10.h),
          _row(OrderFlowStrings.arrivesIn, OrderFlowData.arrivalWindow),
          SizedBox(height: 10.h),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E6E0)),
          SizedBox(height: 10.h),
          _row(
            OrderFlowStrings.orderTotal,
            OrderFlowData.orderTotal,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelSmall(
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ).copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              fontSize: isTotal ? 15.sp : 13.sp,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            fontSize: isTotal ? 16.sp : 13.sp,
          ),
        ),
      ],
    );
  }
}

class OrderFlowCard extends StatelessWidget {
  const OrderFlowCard({super.key, required this.child, this.padding});

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
        border: Border.all(color: const Color(0xFFE0E6E0)),
      ),
      child: child,
    );
  }
}

class OrderMapPlaceholder extends StatelessWidget {
  const OrderMapPlaceholder({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 196.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD1E0D4),
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2EB),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(color: const Color(0xFF127036)).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}

class OrderArrivalCard extends StatelessWidget {
  const OrderArrivalCard({super.key, this.arrivalWindow});

  final String? arrivalWindow;

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              OrderFlowStrings.estimatedArrival,
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
              ),
            ),
          ),
          Text(
            arrivalWindow ?? OrderFlowData.arrivalWindow,
            style: AppTextStyles.titleSmall(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.steps});

  final List<OrderTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            OrderFlowStrings.statusLabel,
            style: AppTextStyles.labelSmall(color: const Color(0xFF8C948C)).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 10.h),
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _TimelineRow(step: steps[i]),
          ],
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step});

  final OrderTimelineStep step;

  @override
  Widget build(BuildContext context) {
    final done = step.completed;
    return Row(
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: done ? AppColors.cartTabActive : AppColors.white,
            shape: BoxShape.circle,
            border: done
                ? null
                : Border.all(color: const Color(0xFFD9DED9), width: 1.5),
          ),
          alignment: Alignment.center,
          child: done
              ? Icon(Icons.check, color: AppColors.white, size: 12.sp)
              : null,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            step.label,
            style: AppTextStyles.labelMedium(
              color: done || step.active
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ),
        Text(
          step.time ?? '--',
          style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}

class OrderVendorSummaryCard extends StatelessWidget {
  const OrderVendorSummaryCard({
    super.key,
    this.vendor,
    this.itemCount,
    this.orderTotal,
  });

  final String? vendor;
  final String? itemCount;
  final String? orderTotal;

  @override
  Widget build(BuildContext context) {
    // Figma: two rows — vendor (#6B756E) · items | Order total · BHD (no leading icon).
    return OrderFlowCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  vendor ?? OrderFlowData.vendor,
                  style: AppTextStyles.labelMedium(color: const Color(0xFF6B756E)).copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    height: 1.23,
                  ),
                ),
              ),
              Text(
                itemCount ?? OrderFlowData.itemCount,
                style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                  height: 1.23,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  OrderFlowStrings.orderTotal,
                  style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    height: 1.2,
                  ),
                ),
              ),
              Text(
                orderTotal ?? OrderFlowData.orderTotal,
                style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderChampCard extends StatelessWidget {
  const OrderChampCard({
    super.key,
    this.subtitle,
    this.meta,
    this.onCall,
    this.onChat,
  });

  final String? subtitle;
  final String? meta;
  final VoidCallback? onCall;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    // Figma champ card: mint avatar · meta · Call outline + Chat #2E9E4D (+ chat.png).
    return OrderFlowCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2EB),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.person_outline, color: AppColors.primary, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle ?? OrderFlowData.driverSubtitle,
                      style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      meta ?? OrderFlowData.driverMeta,
                      style: AppTextStyles.labelSmall(color: const Color(0xFF6B756E)).copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: OrderFlowStrings.call,
                  icon: Icons.phone_outlined,
                  outlined: true,
                  onTap: onCall,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ActionButton(
                  label: OrderFlowStrings.chat,
                  iconAsset: AppAssets.orderChat,
                  onTap: onChat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderPaymentRow extends StatelessWidget {
  const OrderPaymentRow({
    super.key,
    this.paymentMethod,
    this.onChange,
  });

  final String? paymentMethod;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    // Figma change-pay: mint 40 tile · cash · Change #2E9E4D · chevron #6B756E.
    return OrderFlowCard(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 16.w, 14.h),
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
            child: Image.asset(
              AppAssets.payCashStack,
              width: 18.w,
              height: 18.w,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              paymentMethod ?? OrderFlowData.paymentMethod,
              style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                height: 1.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: onChange,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  OrderFlowStrings.change,
                  style: AppTextStyles.labelSmall(color: const Color(0xFF2E9E4D)).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    height: 1.23,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(Icons.chevron_right, color: const Color(0xFF6B756E), size: 18.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderOutlineButton extends StatelessWidget {
  const OrderOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.white,
          side: const BorderSide(color: Color(0xFFE0E6E0), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18.sp),
              SizedBox(width: 8.w),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
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

class OrderStarRatingCard extends StatefulWidget {
  const OrderStarRatingCard({
    super.key,
    required this.title,
    this.initialRating = 4,
    this.onChanged,
  });

  final String title;
  final int initialRating;
  final ValueChanged<int>? onChanged;

  @override
  State<OrderStarRatingCard> createState() => _OrderStarRatingCardState();
}

class _OrderStarRatingCardState extends State<OrderStarRatingCard> {
  late int _rating = widget.initialRating;

  static const Color _starFilled = Color(0xFFD98C1A);
  static const Color _starEmpty = Color(0xFFE0E6E0);

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              textAlign: TextAlign.left,
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                height: 17 / 14,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(5, (index) {
              final filled = index < _rating;
              return GestureDetector(
                onTap: () {
                  setState(() => _rating = index + 1);
                  widget.onChanged?.call(_rating);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: index < 4 ? 6.w : 0),
                  child: Icon(
                    Icons.star_rounded,
                    color: filled ? _starFilled : _starEmpty,
                    size: 26.sp,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class OrderReceiptPaper extends StatelessWidget {
  const OrderReceiptPaper({
    super.key,
    this.badgeLabel,
    this.vendorLocation,
    this.vendorAddress,
    this.orderNumber,
    this.orderDate,
    this.typeLabel,
    this.deliverTo,
    this.items,
    this.billLines,
    this.paymentMethod,
  });

  final String? badgeLabel;
  final String? vendorLocation;
  final String? vendorAddress;
  final String? orderNumber;
  final String? orderDate;
  final String? typeLabel;
  final String? deliverTo;
  final List<OrderReceiptItem>? items;
  final List<BillLine>? billLines;
  final String? paymentMethod;

  static const Color _labelGrey = Color(0xFF6B756E);
  static const Color _dashColor = Color(0xFFC7CCC7);

  @override
  Widget build(BuildContext context) {
    final receiptItems = items ?? OrderFlowData.receiptItems;
    final lines = billLines ?? OrderFlowData.receiptBillLines;
    return OrderFlowCard(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2EB),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  badgeLabel ?? OrderFlowStrings.orderConfirmedBadge,
                  style: AppTextStyles.caption(color: const Color(0xFF127036)).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    height: 13 / 11,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                vendorLocation ?? OrderFlowData.vendorLocation,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleSmall(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  height: 19 / 16,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                vendorAddress ?? OrderFlowData.vendorAddress,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall(color: _labelGrey).copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  height: 15 / 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const _ReceiptDashedDivider(color: _dashColor),
          SizedBox(height: 12.h),
          _metaRow('Order #', orderNumber ?? OrderFlowData.orderId),
          SizedBox(height: 8.h),
          _metaRow('Date', orderDate ?? OrderFlowData.orderDate),
          SizedBox(height: 8.h),
          _metaRow('Type', typeLabel ?? OrderFlowStrings.typeDelivery),
          SizedBox(height: 8.h),
          _metaRow('Deliver to', deliverTo ?? OrderFlowData.deliveryAddress),
          SizedBox(height: 12.h),
          const _ReceiptDashedDivider(color: _dashColor),
          SizedBox(height: 12.h),
          _columnHeader(OrderFlowStrings.itemColumn, OrderFlowStrings.priceColumn),
          SizedBox(height: 8.h),
          for (var i = 0; i < receiptItems.length; i++) ...[
            if (i > 0) SizedBox(height: 8.h),
            _itemRow(
              receiptItems[i].name,
              receiptItems[i].price,
            ),
          ],
          SizedBox(height: 12.h),
          const _ReceiptDashedDivider(color: _dashColor),
          SizedBox(height: 12.h),
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) SizedBox(height: 8.h),
            _billRow(lines[i]),
          ],
          SizedBox(height: 8.h),
          _metaRow(
            OrderFlowStrings.paid,
            paymentMethod ?? OrderFlowData.paymentMethod,
          ),
        ],
      ),
    );
  }

  Widget _columnHeader(String left, String right) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: AppTextStyles.labelSmall(color: _labelGrey).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 16 / 13,
            ),
          ),
        ),
        Text(
          right,
          style: AppTextStyles.labelSmall(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
            height: 16 / 13,
          ),
        ),
      ],
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelSmall(color: _labelGrey).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 16 / 13,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
            height: 16 / 13,
          ),
        ),
      ],
    );
  }

  Widget _itemRow(String name, String price) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 16 / 13,
            ),
          ),
        ),
        Text(
          price,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
            height: 16 / 13,
          ),
        ),
      ],
    );
  }

  Widget _billRow(BillLine line) {
    final isBold = line.isBold;
    return Row(
      children: [
        Expanded(
          child: Text(
            line.label,
            style: AppTextStyles.labelSmall(
              color: isBold ? AppColors.textPrimary : _labelGrey,
            ).copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              fontSize: isBold ? 15.sp : 13.sp,
              height: isBold ? 18 / 15 : 16 / 13,
            ),
          ),
        ),
        Text(
          line.value,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            fontSize: isBold ? 16.sp : 13.sp,
            height: isBold ? 19 / 16 : 16 / 13,
          ),
        ),
      ],
    );
  }
}

class _ReceiptDashedDivider extends StatelessWidget {
  const _ReceiptDashedDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(
        painter: _DashedLinePainter(color: color),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset((x + dashWidth).clamp(0, size.width), y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => oldDelegate.color != color;
}

class DriverChatBubble extends StatelessWidget {
  const DriverChatBubble({super.key, required this.message});

  final DriverChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 280.w),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isUser ? AppColors.cartTabActive : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isUser ? 16.r : 4.r),
            bottomRight: Radius.circular(isUser ? 4.r : 16.r),
          ),
          border: isUser ? null : Border.all(color: const Color(0xFFE0E6E0)),
        ),
        child: Text(
          message.text,
          style: AppTextStyles.bodySmall(
            color: isUser ? AppColors.white : AppColors.textPrimary,
          ).copyWith(fontSize: 13.sp, height: 1.35),
        ),
      ),
    );
  }
}

class DriverChatQuickReplies extends StatelessWidget {
  const DriverChatQuickReplies({super.key, required this.replies});

  final List<String> replies;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: replies
          .map(
            (reply) => Container(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFE0E6E0), width: 1.2),
              ),
              child: Text(
                reply,
                style: AppTextStyles.labelSmall(color: const Color(0xFF127036)).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5.sp,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class DriverChatInputBar extends StatelessWidget {
  const DriverChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  OrderFlowStrings.messageAhmed,
                  style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                color: AppColors.cartTabActive,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded, color: AppColors.white, size: 20.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    this.icon,
    this.iconAsset,
    this.outlined = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final String? iconAsset;
  final bool outlined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = outlined ? const Color(0xFF1A1A1A) : AppColors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: outlined ? AppColors.white : const Color(0xFF2E9E4D),
          borderRadius: BorderRadius.circular(28.r),
          border: outlined
              ? Border.all(color: const Color(0xFFE0E6E0), width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconAsset != null) ...[
              Image.asset(iconAsset!, width: 18.w, height: 18.w, fit: BoxFit.contain),
              SizedBox(width: 8.w),
            ] else if (icon != null) ...[
              Icon(icon, size: 18.sp, color: color),
              SizedBox(width: 8.w),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium(color: color).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: outlined ? 15.sp : 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderContactSupportButton extends StatelessWidget {
  const OrderContactSupportButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: const Color(0xFFE0E6E0), width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          OrderFlowStrings.contactSupport,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }
}

class OrderReorderButton extends StatelessWidget {
  const OrderReorderButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.white,
          side: const BorderSide(color: Color(0xFFE0E6E0), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, color: AppColors.textPrimary, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              NavigationStrings.reorder,
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
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
