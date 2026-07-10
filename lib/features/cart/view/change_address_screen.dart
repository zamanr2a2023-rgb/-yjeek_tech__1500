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
      body: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          children: [
            GestureDetector(
              onTap: () => context.push(CartRoutes.setLocation),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.my_location, color: AppColors.primary, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      CartFlowStrings.useCurrentLocation,
                      style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            for (final address in CartFlowData.deliveryAddresses)
              GestureDetector(
                onLongPress: () => context.push(CartRoutes.editAddressFor(address.id)),
                child: CartAddressRadioTile(
                  address: address,
                  selected: address.id == _selectedId,
                  onTap: () => setState(() => _selectedId = address.id),
                ),
              ),
            GestureDetector(
              onTap: () => context.push(CartRoutes.addAddress),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  CartFlowStrings.addNewAddress,
                  style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: PrimaryGreenButton(
            label: CartFlowStrings.deliverHere,
            onPressed: () {
              if (_selectedId == 'home-adliya') {
                context.push(CartRoutes.outOfDelivery);
              } else {
                context.pop();
              }
            },
          ),
        ),
      ),
    );
  }
}
