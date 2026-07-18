import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  String _selectedLabel = 'Home';
  bool _setDefault = true;

  static const _labelOptions = <(String, IconData)>[
    ('Home', Icons.home_outlined),
    ('Work', Icons.work_outline),
    ('Other', Icons.location_on_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(title: NavigationStrings.addAddress),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Figma: map strip #E4EAE0 · height 180 · pin.
                const _AddressMapPreview(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NavigationStrings.addressLabel,
                        style: AppTextStyles.labelSmall(
                          color: const Color(0xFF6B7B6E),
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 7.h),
                      Row(
                        children: [
                          for (var i = 0; i < _labelOptions.length; i++) ...[
                            if (i > 0) SizedBox(width: 8.w),
                            Expanded(
                              child: _AddressLabelChip(
                                label: _labelOptions[i].$1,
                                icon: _labelOptions[i].$2,
                                selected: _selectedLabel == _labelOptions[i].$1,
                                onTap: () => setState(
                                  () => _selectedLabel = _labelOptions[i].$1,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          Expanded(
                            child: AccountFormField(
                              label: NavigationStrings.area,
                              value: 'Seef',
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: AccountFormField(
                              label: NavigationStrings.block,
                              value: '428',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: AccountFormField(
                              label: NavigationStrings.road,
                              value: '6000',
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: AccountFormField(
                              label: NavigationStrings.building,
                              value: '23',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      AccountFormField(
                        label: NavigationStrings.flatOptional,
                        value: '82',
                      ),
                      SizedBox(height: 12.h),
                      AccountFormField(
                        label: NavigationStrings.deliveryNoteOptional,
                        value: 'Leave at the door',
                      ),
                      SizedBox(height: 14.h),
                      // Figma: white card · h52 · pad 13/14 · radius 12 · #E6EBE3.
                      Container(
                        width: double.infinity,
                        height: 52.h,
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE6EBE3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                NavigationStrings.setDefaultAddress,
                                style: AppTextStyles.labelMedium(
                                  color: const Color(0xFF1A1A1A),
                                ).copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Switch.adaptive(
                              value: _setDefault,
                              onChanged: (v) => setState(() => _setDefault = v),
                              activeTrackColor: const Color(0xFF4CAF50),
                              activeThumbColor: AppColors.white,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      PrimaryGreenButton(
                        label: NavigationStrings.saveAddress,
                        icon: Icons.check,
                        borderRadius: 13,
                        height: 49,
                        backgroundColor: const Color(0xFF4CAF50),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }
}

class _AddressMapPreview extends StatelessWidget {
  const _AddressMapPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180.h,
      color: const Color(0xFFE4EAE0),
      alignment: Alignment.center,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.location_on, size: 22.sp, color: AppColors.white),
      ),
    );
  }
}

class _AddressLabelChip extends StatelessWidget {
  const _AddressLabelChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Figma chips: height 36 · pad 10/13 · radius 9 · icon 16 · gap 7.
    final fg = selected ? AppColors.white : const Color(0xFF6B7B6E);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36.h,
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4CAF50) : AppColors.white,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(
            color: selected ? const Color(0xFF4CAF50) : const Color(0xFFE6EBE3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: fg),
            SizedBox(width: 7.w),
            Text(
              label,
              style: AppTextStyles.labelSmall(color: fg).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
