import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';

class CartAddAddressScreen extends StatefulWidget {
  const CartAddAddressScreen({super.key});

  @override
  State<CartAddAddressScreen> createState() => _CartAddAddressScreenState();
}

class _CartAddAddressScreenState extends State<CartAddAddressScreen> {
  String _selectedLabel = 'Apartment';

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: CartFlowStrings.addNewAddressTitle,
      subtitle: CartFlowStrings.savePlaceSubtitle,
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
            leftValue: 'Seef · Block 428',
            rightLabel: CartFlowStrings.road,
            rightValue: 'Road 6000',
          ),
          SizedBox(height: 12.h),
          const CartFormFieldPair(
            leftLabel: CartFlowStrings.building,
            leftValue: 'Bldg 23',
            rightLabel: CartFlowStrings.flatFloor,
            rightValue: 'Flat 82',
          ),
          SizedBox(height: 12.h),
          const CartFormLabel(CartFlowStrings.additionalDirections),
          const CartFormField(value: 'Near City Centre, gate 2'),
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
            label: CartFlowStrings.saveAddress,
            backgroundColor: AppColors.cartTabActive,
            height: 54,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
