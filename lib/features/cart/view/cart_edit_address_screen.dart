import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';

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
    return CartFlowScaffold(
      title: CartFlowStrings.editAddress,
      subtitle: CartFlowStrings.updatePlaceSubtitle,
      lightHeader: true,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        children: [
          const CartMapPlaceholder(height: 130),
          SizedBox(height: 14.h),
          const CartFormLabel(CartFlowStrings.addressLabel),
          CartAddressLabelChips(
            labels: CartFlowData.addressLabels,
            selected: _selectedLabel,
            onSelected: (label) => setState(() => _selectedLabel = label),
          ),
          SizedBox(height: 14.h),
          const CartFormFieldPair(
            leftLabel: CartFlowStrings.areaBlock,
            leftValue: 'Adliya · Block 338',
            rightLabel: CartFlowStrings.road,
            rightValue: 'Road 1705',
          ),
          SizedBox(height: 12.h),
          const CartFormFieldPair(
            leftLabel: CartFlowStrings.building,
            leftValue: 'Building 12',
            rightLabel: CartFlowStrings.flatFloor,
            rightValue: 'Flat 4',
          ),
          SizedBox(height: 12.h),
          const CartFormLabel(CartFlowStrings.additionalDirections),
          const CartFormField(value: 'Near Adliya Post Office'),
          SizedBox(height: 12.h),
          const CartFormLabel(CartFlowStrings.locationPhotos),
          SizedBox(height: 4.h),
          Text(
            CartFlowStrings.locationPhotosHint,
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 10.h),
          const CartPhotoUploadRow(),
          SizedBox(height: 12.h),
          const CartFormLabel(CartFlowStrings.phoneNumber),
          const CartFormField(value: CartFlowData.userPhone),
          SizedBox(height: 14.h),
          PrimaryGreenButton(
            label: CartFlowStrings.saveChanges,
            backgroundColor: AppColors.cartTabActive,
            height: 54,
            onPressed: () => context.pop(),
          ),
          SizedBox(height: 12.h),
          CartDeleteAddressButton(
            onPressed: () => showCartDeleteAddressDialog(
              context,
              onDelete: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }
}
