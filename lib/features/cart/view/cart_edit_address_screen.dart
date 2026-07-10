import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class CartEditAddressScreen extends StatefulWidget {
  const CartEditAddressScreen({super.key, this.addressId});

  final String? addressId;

  @override
  State<CartEditAddressScreen> createState() => _CartEditAddressScreenState();
}

class _CartEditAddressScreenState extends State<CartEditAddressScreen> {
  String _selectedLabel = 'Home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(
            title: CartFlowStrings.editAddress,
            subtitle: CartFlowStrings.updatePlaceSubtitle,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              children: [
                const CartMapPlaceholder(),
                SizedBox(height: 16.h),
                const CartFormLabel(CartFlowStrings.addressLabel),
                CartAddressLabelChips(
                  labels: CartFlowData.addressLabels,
                  selected: _selectedLabel,
                  onSelected: (label) => setState(() => _selectedLabel = label),
                ),
                const CartFormLabel(CartFlowStrings.areaBlock),
                const CartFormField(value: 'Adliya - Block 318'),
                const CartFormLabel(CartFlowStrings.road),
                const CartFormField(value: 'Road 1705'),
                const CartFormLabel(CartFlowStrings.building),
                const CartFormField(value: 'Building 12'),
                const CartFormLabel(CartFlowStrings.flatFloor),
                const CartFormField(value: 'Flat 4'),
                const CartFormLabel(CartFlowStrings.additionalDirections),
                const CartFormField(value: 'Near Adliya Post Office'),
                const CartFormLabel(CartFlowStrings.locationPhotos),
                const CartPhotoUploadRow(),
                const CartFormLabel(CartFlowStrings.phoneNumber),
                const CartFormField(value: CartFlowData.userPhone),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
              child: PrimaryGreenButton(
                label: CartFlowStrings.saveChanges,
                onPressed: () => context.pop(),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: GestureDetector(
                onTap: () => showCartDeleteAddressDialog(
                  context,
                  onDelete: () => context.pop(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error, size: 18.sp),
                    SizedBox(width: 6.w),
                    Text(
                      CartFlowStrings.deleteAddress,
                      style: AppTextStyles.labelMedium(color: AppColors.error).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 2),
    );
  }
}
