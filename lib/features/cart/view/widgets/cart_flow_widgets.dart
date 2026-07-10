import 'package:flutter/material.dart';
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
  });

  final String title;
  final String? subtitle;
  final Widget? body;
  final Widget? bottom;
  final int bottomNavIndex;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
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
      bottomNavigationBar: ShellBottomNavBar(currentIndex: bottomNavIndex),
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
      height: expand ? null : (height ?? 180.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: tint ?? const Color(0xFFE3F2EB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: showPin
          ? Center(
              child: Icon(
                Icons.location_on,
                color: const Color(0xFFE53935),
                size: 36.sp,
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
  });

  final String address;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return CartFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: const CartMapPlaceholder(height: 120, showPin: false),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address,
                      style: AppTextStyles.labelMedium().copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      CartFlowStrings.arrivalEstimate,
                      style: AppTextStyles.labelSmall(
                        color: AppColors.textSecondary,
                      ).copyWith(fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onChange,
                child: Text(
                  CartFlowStrings.change,
                  style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
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

class CartDropOffGrid extends StatelessWidget {
  const CartDropOffGrid({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<DropOffOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
        childAspectRatio: 0.85,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final selected = index == selectedIndex;
        return GestureDetector(
          onTap: () => onSelected(index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: selected ? AppColors.accountIconBackground : AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  option.icon,
                  size: 20.sp,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                SizedBox(height: 6.h),
                Text(
                  option.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 9.sp,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CartTipSelector extends StatelessWidget {
  const CartTipSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<TipOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (index) {
        final selected = index == selectedIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < options.length - 1 ? 8.w : 0),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
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
  }
}

class CartPaymentMethodList extends StatelessWidget {
  const CartPaymentMethodList({
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                    fontSize: 11.sp,
                  ),
                ),
                Text(
                  total,
                  style: AppTextStyles.titleSmall().copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: PrimaryGreenButton(
                label: buttonLabel,
                onPressed: onPressed,
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
  });

  final CartDeliveryAddress address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    address.subtitle,
                    style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                      fontSize: 12.sp,
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
    return Row(
      children: labels.map((label) {
        final isSelected = label == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: label != labels.last ? 8.w : 0),
            child: GestureDetector(
              onTap: () => onSelected(label),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall(
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class CartFormLabel extends StatelessWidget {
  const CartFormLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, top: 12.h),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
          letterSpacing: 0.5,
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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        value,
        style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
      ),
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
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary, width: 1.5, style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.primary, size: 22.sp),
              Text(
                CartFlowStrings.addPhoto,
                style: AppTextStyles.caption(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2EB),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.image_outlined, color: AppColors.primary, size: 24.sp),
        ),
        SizedBox(width: 10.w),
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0D9),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.image_outlined, color: AppColors.primary, size: 24.sp),
        ),
      ],
    );
  }
}

class CartReviewStatusCard extends StatelessWidget {
  const CartReviewStatusCard({super.key, required this.secondsLeft});

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
      child: Row(
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
                  CartFlowStrings.sendingOrder,
                  style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  CartFlowStrings.autoConfirmHint,
                  style: AppTextStyles.caption(color: AppColors.white.withValues(alpha: 0.9)).copyWith(
                    fontSize: 11.sp,
                    height: 1.35,
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

class CartReviewSummaryCard extends StatelessWidget {
  const CartReviewSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CartFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CartFlowStrings.orderSummary,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          _row('1×', CartFlowData.vendor),
          _row('1×', 'Iced Americano + Choc Muffin', 'BHD 3.700'),
          Divider(height: 20.h, color: AppColors.border),
          _row('Deliver to', CartFlowData.selectedAddress),
          _row('Arrival', CartFlowStrings.standardDelivery),
          _row('Payment', CartFlowStrings.cashOnDelivery),
        ],
      ),
    );
  }

  Widget _row(String label, String value, [String? trailing]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72.w,
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
          if (trailing != null)
            Text(
              trailing,
              style: AppTextStyles.labelSmall().copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
              ),
            ),
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
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        padding: EdgeInsets.symmetric(vertical: 16.h),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

void showCartNewCartDialog(BuildContext context, {VoidCallback? onConfirm}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.accountIconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 28.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              CartFlowStrings.startNewCartTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall().copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              CartFlowStrings.startNewCartBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            PrimaryGreenButton(
              label: CartFlowStrings.startNewCart,
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void showCartDeleteAddressDialog(BuildContext context, {VoidCallback? onDelete}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFCE8EA),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline, color: AppColors.error, size: 24.sp),
            ),
            SizedBox(height: 14.h),
            Text(
              CartFlowStrings.deleteAddressTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall().copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 17.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              CartFlowStrings.deleteAddressBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(CartFlowStrings.cancel),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(CartFlowStrings.delete),
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
