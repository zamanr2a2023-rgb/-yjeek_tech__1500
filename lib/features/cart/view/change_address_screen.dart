import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';

class ChangeAddressScreen extends StatefulWidget {
  const ChangeAddressScreen({super.key});

  @override
  State<ChangeAddressScreen> createState() => _ChangeAddressScreenState();
}

class _ChangeAddressScreenState extends State<ChangeAddressScreen> {
  late String _selectedId = CartFlowData.deliveryAddresses.first.id;

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: CartFlowStrings.deliveryAddress,
      subtitle: CartFlowStrings.chooseWhereToDeliver,
      lightHeader: true,
      onBack: () {
        if (context.canPop()) context.pop();
      },
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => context.push(CartRoutes.setLocation),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE0E6E0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE3F2EB),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: const Color(0xFFE53935),
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CartFlowStrings.useCurrentLocation,
                            style: AppTextStyles.labelMedium(
                              color: AppColors.textPrimary,
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            CartFlowStrings.detectGpsLocation,
                            style: AppTextStyles.labelSmall(
                              color: AppColors.textSecondary,
                            ).copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              CartFlowStrings.savedAddresses,
              style: AppTextStyles.titleSmall(
                color: AppColors.textPrimary,
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 10.h),
            for (final address in CartFlowData.deliveryAddresses)
              CartAddressRadioTile(
                address: address,
                selected: address.id == _selectedId,
                onTap: () => setState(() => _selectedId = address.id),
                onEdit: () => context.push(CartRoutes.editAddressFor(address.id)),
              ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => context.push(CartRoutes.addAddress),
              child: Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.cartTabActive, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: const Color(0xFF127036), size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Add new address',
                      style: AppTextStyles.labelMedium(
                        color: const Color(0xFF127036),
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            PrimaryGreenButton(
              label: CartFlowStrings.deliverHere,
              backgroundColor: AppColors.cartTabActive,
              height: 54,
              onPressed: () {
                if (_selectedId == 'home-adliya') {
                  context.push(CartRoutes.outOfDelivery);
                } else {
                  context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
