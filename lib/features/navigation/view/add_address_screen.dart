import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  String _selectedLabel = 'Home';
  bool _setDefault = true;

  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Work', 'Other'];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(title: NavigationStrings.addAddress),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              children: [
                Row(
                  children: labels.map((label) {
                    final selected = _selectedLabel == label;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: label != labels.last ? 8.w : 0),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedLabel = label),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.cartTabActive : AppColors.white,
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(
                                color: selected ? AppColors.cartTabActive : AppColors.cartTabBorder,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              label,
                              style: AppTextStyles.labelSmall(
                                color: selected ? AppColors.white : AppColors.textPrimary,
                              ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(child: AccountFormField(label: NavigationStrings.area, value: 'Al Seef')),
                    SizedBox(width: 10.w),
                    Expanded(child: AccountFormField(label: NavigationStrings.block, value: '436')),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(child: AccountFormField(label: NavigationStrings.road, value: '3649')),
                    SizedBox(width: 10.w),
                    Expanded(child: AccountFormField(label: NavigationStrings.building, value: '2732')),
                  ],
                ),
                SizedBox(height: 14.h),
                AccountFormField(label: NavigationStrings.flatOptional, value: ''),
                SizedBox(height: 14.h),
                AccountFormField(label: NavigationStrings.deliveryNoteOptional, value: ''),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        NavigationStrings.setDefaultAddress,
                        style: AppTextStyles.labelMedium().copyWith(fontSize: 14.sp),
                      ),
                    ),
                    Switch(
                      value: _setDefault,
                      onChanged: (v) => setState(() => _setDefault = v),
                      activeTrackColor: AppColors.cartTabActive,
                      activeThumbColor: AppColors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: PrimaryGreenButton(
                label: NavigationStrings.saveAddress,
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
