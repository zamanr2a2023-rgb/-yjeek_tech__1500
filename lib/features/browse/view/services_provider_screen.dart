import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
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
  // Design provider frame shows booking bar with 1 × Haircut already selected.
  int _bookingCount = 1;
  String _bookingTotal = '8.000';

  ServiceProvider get _provider => ServicesData.providerById(widget.providerId);

  List<ServiceMenuItem> get _items => ServicesData.glowBeautyMenu
      .where((item) => item.section == _selectedSection)
      .toList();

  void _addService(ServiceMenuItem item) {
    setState(() {
      _bookingCount = (_bookingCount <= 0 ? 0 : _bookingCount) + 1;
      _bookingTotal = item.price;
    });
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
              // Design body: padding 16 20, gap 14
              padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
              children: [
                BrowseSearchBar(hint: 'Search services…', onTap: () {}),
                SizedBox(height: 14.w),
                ServicesProviderInfoCard(provider: _provider),
                SizedBox(height: 14.w),
                ServicesSectionChips(
                  options: ServicesData.glowBeautySections,
                  selected: _selectedSection,
                  onSelected: (v) => setState(() => _selectedSection = v),
                ),
                SizedBox(height: 14.w),
                for (var i = 0; i < _items.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, thickness: 1, color: const Color(0xFFE0E6E0)),
                  ServicesMenuItemRow(
                    item: _items[i],
                    onAdd: () => _addService(_items[i]),
                    onTap: () => context.push(
                      BrowseRoutes.servicesItemDetail(
                        providerId: widget.providerId,
                        itemId: _items[i].id,
                      ),
                    ),
                  ),
                ],
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
