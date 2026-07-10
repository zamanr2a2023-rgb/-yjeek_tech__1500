import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/services_booking/model/services_booking_data.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';
import 'package:yjeek_app/features/services_booking/view/widgets/services_booking_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class ServicesBookingScreen extends StatefulWidget {
  const ServicesBookingScreen({super.key});

  @override
  State<ServicesBookingScreen> createState() => _ServicesBookingScreenState();
}

class _ServicesBookingScreenState extends State<ServicesBookingScreen> {
  bool _atVenue = true;
  int _selectedDate = 2;
  int _selectedTime = 2;
  late Set<String> _selectedUpsells;

  @override
  void initState() {
    super.initState();
    _selectedUpsells = ServicesBookingData.upsells
        .where((item) => item.selected)
        .map((item) => item.id)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: ServicesBookingStrings.booking,
      subtitle: ServicesBookingStrings.provider,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const CartSectionTitle(ServicesBookingStrings.yourService),
          const ServicesServiceCard(),
          SizedBox(height: 14.h),
          const CartSectionTitle(ServicesBookingStrings.where),
          ServicesLocationToggle(
            atVenue: _atVenue,
            onChanged: (v) => setState(() => _atVenue = v),
          ),
          SizedBox(height: 14.h),
          const CartSectionTitle(ServicesBookingStrings.date),
          ServicesDatePicker(
            dates: ServicesBookingData.dates,
            selectedIndex: _selectedDate,
            onSelected: (i) => setState(() => _selectedDate = i),
          ),
          SizedBox(height: 14.h),
          const CartSectionTitle(ServicesBookingStrings.time),
          ServicesTimeGrid(
            slots: ServicesBookingData.timeSlots,
            selectedIndex: _selectedTime,
            onSelected: (i) => setState(() => _selectedTime = i),
          ),
          SizedBox(height: 14.h),
          const CartSectionTitle(ServicesBookingStrings.addTheseToo),
          Text(
            ServicesBookingStrings.popularWith,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF6B756E),
            ),
          ),
          SizedBox(height: 10.h),
          for (final item in ServicesBookingData.upsells)
            ServicesUpsellCard(
              item: item,
              selected: _selectedUpsells.contains(item.id),
              onToggle: () => setState(() {
                if (_selectedUpsells.contains(item.id)) {
                  _selectedUpsells.remove(item.id);
                } else {
                  _selectedUpsells.add(item.id);
                }
              }),
            ),
          SizedBox(height: 14.h),
          const ServicesPromoField(),
          SizedBox(height: 14.h),
          const CartSectionTitle(ServicesBookingStrings.billSummary),
          BillSummaryCard(lines: ServicesBookingData.bookingBillLines),
        ],
      ),
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: Row(
            children: [
              Expanded(
                child: CartOutlineButton(
                  label: ServicesBookingStrings.addMore,
                  onPressed: () => context.pop(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryGreenButton(
                  label: ServicesBookingStrings.checkoutBtn,
                  onPressed: () => context.push(ServicesBookingRoutes.checkout),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
