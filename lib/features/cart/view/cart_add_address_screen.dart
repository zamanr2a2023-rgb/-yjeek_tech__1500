import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class CartAddAddressScreen extends StatefulWidget {
  const CartAddAddressScreen({super.key});

  @override
  State<CartAddAddressScreen> createState() => _CartAddAddressScreenState();
}

class _CartAddAddressScreenState extends State<CartAddAddressScreen> {
  String _selectedLabel = 'Apartment';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(
            title: CartFlowStrings.addNewAddressTitle,
            subtitle: CartFlowStrings.savePlaceSubtitle,
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
                const CartFormField(value: 'Seef - Block 428'),
                const CartFormLabel(CartFlowStrings.road),
                const CartFormField(value: 'Road 6000'),
                const CartFormLabel(CartFlowStrings.building),
                const CartFormField(value: 'Bldg 23'),
                const CartFormLabel(CartFlowStrings.flatFloor),
                const CartFormField(value: 'Flat 82'),
                const CartFormLabel(CartFlowStrings.additionalDirections),
                const CartFormField(value: 'Near City Centre, gate 2'),
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
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: PrimaryGreenButton(
                label: CartFlowStrings.saveAddress,
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 2),
    );
  }
}
