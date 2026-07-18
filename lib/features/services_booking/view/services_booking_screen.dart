import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
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
      lightHeader: true,
      bottomNavIndex: 0,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
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
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B756E),
              height: 16 / 13,
            ),
          ),
          SizedBox(height: 8.h),
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
          const CartSectionTitle(ServicesBookingStrings.promoCode),
          const ServicesPromoField(),
          SizedBox(height: 14.h),
          const CartSectionTitle(ServicesBookingStrings.billSummary),
          BillSummaryCard(lines: ServicesBookingData.bookingBillLines),
        ],
      ),
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52.h,
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: AppColors.white,
                      side: const BorderSide(color: Color(0xFFE2E8DD), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                    ),
                    child: Text(
                      ServicesBookingStrings.addMore,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        height: 1.28,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryGreenButton(
                  label: ServicesBookingStrings.checkoutBtn,
                  backgroundColor: AppColors.primary,
                  height: 52,
                  onPressed: () => context.push(ServicesBookingRoutes.review),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
