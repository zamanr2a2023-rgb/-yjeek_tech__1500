import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/services_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';

class ServicesItemDetailScreen extends StatefulWidget {
  const ServicesItemDetailScreen({
    super.key,
    required this.providerId,
    required this.itemId,
    this.bottomNavIndex = 0,
  });

  final String providerId;
  final String itemId;
  final int bottomNavIndex;

  @override
  State<ServicesItemDetailScreen> createState() => _ServicesItemDetailScreenState();
}

class _ServicesItemDetailScreenState extends State<ServicesItemDetailScreen> {
  int _quantity = 1;
  int _selectedOption = 0;
  String _selectedSpecialist = ServicesData.specialists.first;
  final Set<int> _selectedAddons = {};

  ServiceProvider get _provider => ServicesData.providerById(widget.providerId);
  ServiceMenuItem get _item => ServicesData.menuItemById(widget.itemId);

  String get _displayPrice {
    final base = double.tryParse(_item.price) ?? 8;
    final optionExtra = _selectedOption == 1 ? 4.0 : 0.0;
    var addonTotal = 0.0;
    for (final index in _selectedAddons) {
      addonTotal += double.tryParse(ServicesData.haircutAddons[index].price) ?? 0;
    }
    return ((base + optionExtra + addonTotal) * _quantity).toStringAsFixed(3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: 260.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_provider.gradientStart, _provider.gradientEnd],
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  left: 16.w,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '‹',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 8.h),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _item.name,
                        style: AppTextStyles.titleMedium().copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 24.sp,
                        ),
                      ),
                    ),
                    Text(
                      'BHD ${_item.price}',
                      style: AppTextStyles.titleSmall(color: AppColors.primary).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  '🕒 ${_item.duration} · with a senior stylist',
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  ServicesData.haircutDescription,
                  style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                    fontSize: 14.sp,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'CHOOSE OPTION',
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 10.h),
                for (var i = 0; i < ServicesData.haircutOptions.length; i++) ...[
                  if (i > 0) SizedBox(height: 8.h),
                  ServicesOptionCard(
                    option: ServicesData.haircutOptions[i],
                    selected: _selectedOption == i,
                    onTap: () => setState(() => _selectedOption = i),
                  ),
                ],
                SizedBox(height: 18.h),
                Text(
                  'SELECT SPECIALIST',
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 10.h),
                ServicesSpecialistChips(
                  options: ServicesData.specialists,
                  selected: _selectedSpecialist,
                  onSelected: (v) => setState(() => _selectedSpecialist = v),
                ),
                SizedBox(height: 18.h),
                Text(
                  'ADD-ONS',
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
                for (var i = 0; i < ServicesData.haircutAddons.length; i++)
                  ServicesAddonRow(
                    addon: ServicesData.haircutAddons[i],
                    checked: _selectedAddons.contains(i),
                    onChanged: (v) => setState(() {
                      if (v) {
                        _selectedAddons.add(i);
                      } else {
                        _selectedAddons.remove(i);
                      }
                    }),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      _qtyButton(Icons.remove, () {
                        if (_quantity > 1) setState(() => _quantity--);
                      }),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Text(
                          '$_quantity',
                          style: AppTextStyles.labelMedium().copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                      _qtyButton(Icons.add, () => setState(() => _quantity++)),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push(ServicesBookingRoutes.booking),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Add to booking · BHD $_displayPrice',
                        style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Icon(icon, size: 18.sp, color: AppColors.textPrimary),
      ),
    );
  }
}
