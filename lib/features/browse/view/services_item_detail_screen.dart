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

  static const Color _muted = Color(0xFF6B7A6E);
  static const Color _green = Color(0xFF2E9E4D);
  static const Color _mint = Color(0xFFE3F2EB);
  static const Color _border = Color(0xFFE0E6E0);

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
    final topInset = MediaQuery.paddingOf(context).top;
    // Design hero is 260; scale with width so title stays on-screen (260.h was too tall).
    final heroHeight = topInset + 200.w;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: heroHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: _mint),
                Positioned(
                  top: topInset + 12.w,
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
                          color: AppColors.textPrimary,
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
              padding: EdgeInsets.fromLTRB(20.w, 18.w, 20.w, 8.w),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _item.name,
                        style: AppTextStyles.titleMedium(color: AppColors.textPrimary).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 24.sp,
                          height: 29 / 24,
                        ),
                      ),
                    ),
                    Text(
                      'BHD ${_item.price}',
                      style: AppTextStyles.titleSmall(color: _green).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        height: 22 / 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.w),
                Text(
                  '🕒 ${_item.duration} · with a senior stylist',
                  style: AppTextStyles.labelSmall(color: _muted).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                    height: 16 / 13,
                  ),
                ),
                SizedBox(height: 12.w),
                Text(
                  ServicesData.haircutDescription,
                  style: AppTextStyles.bodySmall(color: _muted).copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    height: 17 / 14,
                  ),
                ),
                SizedBox(height: 18.w),
                Text(
                  'CHOOSE OPTION',
                  style: AppTextStyles.labelSmall(color: _muted).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    height: 15 / 12,
                  ),
                ),
                SizedBox(height: 10.w),
                for (var i = 0; i < ServicesData.haircutOptions.length; i++) ...[
                  if (i > 0) SizedBox(height: 8.w),
                  ServicesOptionCard(
                    option: ServicesData.haircutOptions[i],
                    selected: _selectedOption == i,
                    onTap: () => setState(() => _selectedOption = i),
                  ),
                ],
                SizedBox(height: 18.w),
                Text(
                  'SELECT SPECIALIST',
                  style: AppTextStyles.labelSmall(color: _muted).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    height: 15 / 12,
                  ),
                ),
                SizedBox(height: 10.w),
                ServicesSpecialistChips(
                  options: ServicesData.specialists,
                  selected: _selectedSpecialist,
                  onSelected: (v) => setState(() => _selectedSpecialist = v),
                ),
                SizedBox(height: 18.w),
                Text(
                  'ADD-ONS',
                  style: AppTextStyles.labelSmall(color: _muted).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    height: 15 / 12,
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
            padding: EdgeInsets.fromLTRB(20.w, 15.w, 20.w, 15.w),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                // Design qty: #F2F7F2 bg, green − / +, black count, 92×46, radius 12
                Container(
                  width: 92.w,
                  height: 46.w,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F7F2),
                    border: Border.all(color: _border),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_quantity > 1) setState(() => _quantity--);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Text(
                              '−',
                              style: TextStyle(
                                color: _green,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                height: 27 / 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '$_quantity',
                        style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          height: 19 / 16,
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _quantity++),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Text(
                              '+',
                              style: TextStyle(
                                color: _green,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                height: 27 / 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push(ServicesBookingRoutes.booking),
                    child: Container(
                      height: 55.w,
                      decoration: BoxDecoration(
                        color: _green,
                        // Design CSS: border-radius 14
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Add to booking · BHD $_displayPrice',
                        style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          height: 19 / 16,
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
}
