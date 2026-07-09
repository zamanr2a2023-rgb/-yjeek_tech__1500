import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({super.key, this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
        children: [
          NavBackHeader(
            title: NavigationStrings.orderDetails,
            subtitle: orderId ?? NavigationData.orderId,
            backIconColor: AppColors.textPrimary,
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2EB),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              NavigationStrings.deliveredToday,
              style: AppTextStyles.labelMedium(
                color: AppColors.successText,
              ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.5.sp),
            ),
          ),
          SizedBox(height: 14.h),
          _OrderDetailCard(
            child: Row(
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBE8DE),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '🍽️',
                    style: TextStyle(fontSize: 20.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'The Green Kitchen',
                        style: AppTextStyles.titleSmall().copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        NavigationStrings.onDemandDelivery,
                        style: AppTextStyles.labelSmall(
                          color: const Color(0xFF6B756E),
                        ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          _SectionTitle(NavigationStrings.items),
          SizedBox(height: 10.h),
          _OrderDetailCard(
            child: Column(
              children: [
                for (var i = 0; i < NavigationData.orderDetailItems.length; i++) ...[
                  if (i > 0) SizedBox(height: 10.h),
                  _DetailRow(
                    label: NavigationData.orderDetailItems[i].name,
                    value: NavigationData.orderDetailItems[i].price,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 14.h),
          _SectionTitle(NavigationStrings.billSummary),
          SizedBox(height: 10.h),
          _OrderDetailCard(
            child: Column(
              children: [
                for (var i = 0; i < NavigationData.orderDetailBillSummary.length; i++) ...[
                  if (NavigationData.orderDetailBillSummary[i].isBold && i > 0)
                    Divider(color: AppColors.cartTabBorder, height: 20.h),
                  _DetailRow(
                    label: NavigationData.orderDetailBillSummary[i].label,
                    value: NavigationData.orderDetailBillSummary[i].value,
                    isDiscount:
                        NavigationData.orderDetailBillSummary[i].isDiscount,
                    isBold: NavigationData.orderDetailBillSummary[i].isBold,
                  ),
                  if (i < NavigationData.orderDetailBillSummary.length - 1 &&
                      !NavigationData.orderDetailBillSummary[i].isBold)
                    SizedBox(height: 10.h),
                ],
              ],
            ),
          ),
          SizedBox(height: 14.h),
          _OrderDetailCard(
            child: Column(
              children: [
                _DetailRow(
                  label: NavigationStrings.deliveredTo,
                  value: NavigationStrings.apartmentSeef,
                ),
                SizedBox(height: 10.h),
                _DetailRow(
                  label: NavigationStrings.champ,
                  value: NavigationStrings.ahmedVerified,
                ),
                SizedBox(height: 10.h),
                _DetailRow(
                  label: NavigationStrings.payment,
                  value: NavigationStrings.yjeekWalletPayment,
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cartTabActive,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.r),
                ),
              ),
              child: Text(
                '↻ ${NavigationStrings.reorder}',
                style: AppTextStyles.labelLarge().copyWith(fontSize: 16.sp),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _OutlineActionButton(label: NavigationStrings.receipt),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _OutlineActionButton(label: NavigationStrings.rate),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _OutlineActionButton(
                  label: NavigationStrings.getHelp,
                  onTap: () => context.push(
                    HelpRoutes.orderHelp(
                      orderId: orderId ?? HelpData.defaultOrderId,
                      tab: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) {
            context.pop();
            return;
          }
          context.goHome(tab: index);
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleSmall().copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _OrderDetailCard extends StatelessWidget {
  const _OrderDetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cartTabBorder),
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isDiscount;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelSmall(
              color: isBold
                  ? AppColors.textPrimary
                  : const Color(0xFF6B756E),
            ).copyWith(
              fontSize: isBold ? 15.sp : 13.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelSmall(
            color: isDiscount
                ? AppColors.cartTabActive
                : AppColors.textPrimary,
          ).copyWith(
            fontSize: isBold ? 16.sp : 13.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(26.r),
          border: Border.all(color: AppColors.cartTabBorder, width: 1.5),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            color: AppColors.textPrimary,
          ).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }
}
