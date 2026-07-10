import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/services_widgets.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class ServicesProviderScreen extends StatefulWidget {
  const ServicesProviderScreen({
    super.key,
    required this.providerId,
    this.bottomNavIndex = 0,
  });

  final String providerId;
  final int bottomNavIndex;

  @override
  State<ServicesProviderScreen> createState() => _ServicesProviderScreenState();
}

class _ServicesProviderScreenState extends State<ServicesProviderScreen> {
  String _selectedSection = ServicesData.glowBeautySections.first;
  int _bookingCount = 0;
  String _bookingTotal = '0.000';

  ServiceProvider get _provider => ServicesData.providerById(widget.providerId);

  List<ServiceMenuItem> get _items => ServicesData.glowBeautyMenu
      .where((item) => item.section == _selectedSection)
      .toList();

  void _addService(ServiceMenuItem item) {
    setState(() {
      _bookingCount++;
      _bookingTotal = item.price;
    });
    context.push(
      BrowseRoutes.servicesItemDetail(
        providerId: widget.providerId,
        itemId: item.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ServicesProviderHero(provider: _provider),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
              children: [
                BrowseSearchBar(hint: 'Search services…', onTap: () {}),
                SizedBox(height: 12.h),
                ServicesProviderInfoCard(provider: _provider),
                SizedBox(height: 14.h),
                BrowseFilterChips(
                  options: ServicesData.glowBeautySections,
                  selected: _selectedSection,
                  onSelected: (v) => setState(() => _selectedSection = v),
                ),
                SizedBox(height: 8.h),
                Text(
                  _selectedSection.toUpperCase(),
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    letterSpacing: 0.5,
                  ),
                ),
                ..._items.map(
                  (item) => ServicesMenuItemRow(
                    item: item,
                    onAdd: () => _addService(item),
                    onTap: () => context.push(
                      BrowseRoutes.servicesItemDetail(
                        providerId: widget.providerId,
                        itemId: item.id,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_bookingCount > 0)
            ServicesBookingBar(
              itemCount: _bookingCount,
              total: _bookingTotal,
              onTap: () => context.push(ServicesBookingRoutes.booking),
            ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
