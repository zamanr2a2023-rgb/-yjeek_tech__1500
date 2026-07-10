import 'package:flutter/material.dart';
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
  });

  final Widget body;
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget? bottom;
  final int bottomNavIndex;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (showHeader && title != null)
            GreenScreenHeader(
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
      bottomNavigationBar: ShellBottomNavBar(currentIndex: bottomNavIndex),
    );
  }
}

class OrderSuccessIcon extends StatelessWidget {
  const OrderSuccessIcon({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? 72.w;
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check, color: AppColors.white, size: iconSize * 0.45),
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        children: [
          _row(OrderFlowStrings.items, OrderFlowData.itemCount),
          SizedBox(height: 10.h),
          _row(OrderFlowStrings.deliverTo, OrderFlowData.deliveryAddress),
          SizedBox(height: 10.h),
          _row(OrderFlowStrings.arrivesIn, OrderFlowData.arrivalWindow),
          SizedBox(height: 10.h),
          _row(OrderFlowStrings.orderTotal, OrderFlowData.orderTotal, bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
              fontSize: 13.sp,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium().copyWith(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            fontSize: bold ? 15.sp : 13.sp,
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
        border: Border.all(color: AppColors.border),
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
      height: height ?? 180.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECE8),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.accountIconBackground,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

class OrderArrivalCard extends StatelessWidget {
  const OrderArrivalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              OrderFlowStrings.estimatedArrival,
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
          Text(
            OrderFlowData.arrivalWindow,
            style: AppTextStyles.titleSmall().copyWith(
              fontWeight: FontWeight.w800,
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
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;
          final done = step.completed;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: done ? AppColors.primary : AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: done ? AppColors.primary : AppColors.border,
                        width: done ? 0 : 1.5,
                      ),
                    ),
                    child: done
                        ? Icon(Icons.check, color: AppColors.white, size: 14.sp)
                        : null,
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 28.h,
                      color: done ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border,
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 18.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.label,
                          style: AppTextStyles.labelMedium().copyWith(
                            fontWeight: step.active ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 14.sp,
                            color: done ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        step.time ?? '--',
                        style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                          fontSize: 12.sp,
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

class OrderVendorSummaryCard extends StatelessWidget {
  const OrderVendorSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.accountIconBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.restaurant_outlined, color: AppColors.primary, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  OrderFlowData.vendor,
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  OrderFlowData.itemCount,
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            OrderFlowData.orderTotal,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderChampCard extends StatelessWidget {
  const OrderChampCard({
    super.key,
    this.onCall,
    this.onChat,
  });

  final VoidCallback? onCall;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.accountIconBackground,
                child: Icon(Icons.person_outline, color: AppColors.primary, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      OrderFlowData.driverSubtitle,
                      style: AppTextStyles.labelMedium().copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      OrderFlowData.driverMeta,
                      style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                        fontSize: 12.sp,
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
                  icon: Icons.chat_bubble_outline,
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
  const OrderPaymentRow({super.key, this.onChange});

  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Row(
        children: [
          Icon(Icons.payments_outlined, size: 22.sp, color: AppColors.textPrimary),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              OrderFlowData.paymentMethod,
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
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
                  style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.primary, size: 18.sp),
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
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        padding: EdgeInsets.symmetric(vertical: 16.h),
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
            style: AppTextStyles.labelMedium().copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class OrderStarRatingCard extends StatefulWidget {
  const OrderStarRatingCard({
    super.key,
    required this.title,
    this.initialRating = 4,
  });

  final String title;
  final int initialRating;

  @override
  State<OrderStarRatingCard> createState() => _OrderStarRatingCardState();
}

class _OrderStarRatingCardState extends State<OrderStarRatingCard> {
  late int _rating = widget.initialRating;

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: List.generate(5, (index) {
              final filled = index < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: Icon(
                    filled ? Icons.star : Icons.star_border,
                    color: filled ? const Color(0xFFE6B800) : AppColors.border,
                    size: 28.sp,
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
  const OrderReceiptPaper({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.accountIconBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              OrderFlowStrings.orderConfirmedBadge,
              style: AppTextStyles.caption(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 10.sp,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            OrderFlowData.vendorLocation,
            style: AppTextStyles.titleSmall().copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            OrderFlowData.vendorAddress,
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 14.h),
          _metaRow('Order #', OrderFlowData.orderIdDisplay),
          _metaRow('Date', OrderFlowData.orderDate),
          _metaRow('Type', OrderFlowStrings.typeDelivery),
          _metaRow('Deliver to', OrderFlowData.deliveryAddress),
          Divider(height: 24.h, color: AppColors.border),
          for (final item in OrderFlowData.receiptItems) ...[
            _itemRow(item.name, item.price),
            SizedBox(height: 8.h),
          ],
          Divider(height: 24.h, color: AppColors.border),
          for (final line in OrderFlowData.receiptBillLines) ...[
            _billRow(line),
            if (!line.isBold) SizedBox(height: 8.h),
          ],
          SizedBox(height: 8.h),
          _metaRow(OrderFlowStrings.paid, OrderFlowData.paymentMethod),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
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
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(String name, String price) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.labelMedium().copyWith(fontSize: 13.sp),
          ),
        ),
        Text(
          price,
          style: AppTextStyles.labelMedium().copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }

  Widget _billRow(BillLine line) {
    return Row(
      children: [
        Expanded(
          child: Text(
            line.label,
            style: AppTextStyles.labelSmall(
              color: line.isBold ? AppColors.textPrimary : AppColors.textSecondary,
            ).copyWith(
              fontWeight: line.isBold ? FontWeight.w800 : FontWeight.w500,
              fontSize: line.isBold ? 16.sp : 13.sp,
            ),
          ),
        ),
        Text(
          line.value,
          style: AppTextStyles.labelMedium(
            color: line.isDiscount ? AppColors.error : AppColors.textPrimary,
          ).copyWith(
            fontWeight: line.isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: line.isBold ? 18.sp : 13.sp,
          ),
        ),
      ],
    );
  }
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
          color: isUser ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isUser ? 16.r : 4.r),
            bottomRight: Radius.circular(isUser ? 4.r : 16.r),
          ),
          border: isUser ? null : Border.all(color: AppColors.border),
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
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                reply,
                style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
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
                color: AppColors.primary,
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
    required this.icon,
    this.outlined = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool outlined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: outlined ? AppColors.white : AppColors.primary,
          borderRadius: BorderRadius.circular(28.r),
          border: outlined ? Border.all(color: AppColors.border, width: 1.5) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: outlined ? AppColors.textPrimary : AppColors.white,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTextStyles.labelMedium(
                color: outlined ? AppColors.textPrimary : AppColors.white,
              ).copyWith(fontWeight: FontWeight.w700, fontSize: 14.sp),
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
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          OrderFlowStrings.contactSupport,
          style: AppTextStyles.labelMedium().copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
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
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.refresh, color: AppColors.primary, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            NavigationStrings.reorder,
            style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
