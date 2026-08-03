import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/model/payment_methods_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/services_booking/model/services_booking_data.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';
import 'package:yjeek_app/features/services_booking/view/widgets/services_booking_widgets.dart';

class ServicesCheckoutScreen extends ConsumerStatefulWidget {
  const ServicesCheckoutScreen({super.key});

  @override
  ConsumerState<ServicesCheckoutScreen> createState() =>
      _ServicesCheckoutScreenState();
}

class _ServicesCheckoutScreenState
    extends ConsumerState<ServicesCheckoutScreen> {
  int _tipIndex = 1;
  String _paymentId = 'benefitpay';
  CartSnapshot? _cart;
  CheckoutPaymentMethods _payments = CheckoutPaymentMethods.fallback(
    base: ServicesBookingData.paymentOptions,
  );
  String? _specialistName;
  String? _specialistId;
  bool _loading = true;
  bool _placing = false;

  double get _tipAmount =>
      tipAmountFrom(ServicesBookingData.tipOptions, _tipIndex);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cart = await ref
          .read(cartRepositoryProvider)
          .fetchCart(CartOrderType.service);
      final payments = await ref
          .read(paymentMethodsRepositoryProvider)
          .fetchCheckoutMethods(
            fallback: ServicesBookingData.paymentOptions,
            includeCod: false,
            preferredDefaultId: 'benefitpay',
          );

      String? specialistName;
      String? specialistId;
      final vendorId = cart.vendorId;
      if (vendorId != null && vendorId.isNotEmpty) {
        try {
          final staffResponse = await ref.read(apiClientProvider).getJson(
                '/vendors/$vendorId/staff',
                bearerToken: ref.read(storageServiceProvider).token,
              );
          final data = staffResponse?['data'];
          final staffList = data is Map<String, dynamic> ? data['staff'] : null;
          if (staffList is List && staffList.isNotEmpty) {
            final first = staffList.first;
            if (first is Map<String, dynamic>) {
              specialistId = first['id']?.toString();
              specialistName = first['name']?.toString();
            }
          }
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _cart = cart;
        _payments = payments;
        _paymentId = payments.defaultId;
        _specialistName = specialistName;
        _specialistId = specialistId;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_placing) return;
    setState(() => _placing = true);
    try {
      final cart = _cart;
      final duration = cart?.items
          .map((i) => int.tryParse(i.durationLabel?.replaceAll(RegExp(r'\D'), '') ?? '') ?? 0)
          .fold<int>(0, (a, b) => a + b);
      final result = await ref.read(cartRepositoryProvider).checkout(
            type: CartOrderType.service,
            paymentMethod: paymentMethodApiValue(_paymentId),
            tipAmount: _tipAmount,
            serviceFulfillmentMode: cart?.serviceMode ?? 'IN_SALON',
            serviceStaffId: _specialistId,
            servicePeopleCount: cart?.partySize ?? 1,
            serviceDurationMin:
                (duration != null && duration >= 15) ? duration : 45,
          );
      if (!mounted) return;
      final orderId = result?['id']?.toString() ??
          result?['orderId']?.toString() ??
          (result?['order'] is Map
              ? (result!['order'] as Map)['id']?.toString()
              : null);
      context.pushReplacement(ServicesBookingRoutes.reviewFor(orderId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;
    final vendor = cart?.vendorName.isNotEmpty == true
        ? cart!.vendorName
        : ServicesBookingStrings.provider;
    final billLines = cart != null
        ? billLinesWithTip(cart, _tipAmount)
        : const <BillLine>[];
    final total = cart != null
        ? formatCheckoutTotal(cart, _tipAmount)
        : 'BHD 0.000';
    final serviceName = cart?.items.isNotEmpty == true
        ? cart!.items.first.name
        : 'Service';
    final when = cart?.serviceScheduledAt != null
        ? formatPickupTimeLabel(cart!.serviceScheduledAt)
        : 'Choose a time';
    final locationLabel = cart?.serviceMode == 'AT_HOME'
        ? 'At home'
        : 'At venue · $vendor';

    return CartFlowScaffold(
      title: ServicesBookingStrings.checkout,
      subtitle: vendor,
      lightHeader: true,
      bottomNavIndex: 0,
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
              children: [
                CartSectionTitle(ServicesBookingStrings.serviceLocation),
                ServicesLocationCard(
                  locationLabel: locationLabel,
                  address: cart?.pickup?.address,
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(ServicesBookingStrings.appointment),
                ServicesAppointmentCard(
                  serviceName: serviceName,
                  whenLabel: when,
                  specialistName: _specialistName ?? 'Any available',
                  peopleLabel: (cart?.partySize ?? 1) == 1
                      ? '1 person'
                      : '${cart!.partySize} people',
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(ServicesBookingStrings.tipSpecialist),
                ServicesTipSelector(
                  options: ServicesBookingData.tipOptions,
                  selectedIndex: _tipIndex,
                  onSelected: (i) => setState(() => _tipIndex = i),
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(ServicesBookingStrings.paymentMethod),
                CartPaymentMethodList(
                  options: _payments.options,
                  selectedId: _paymentId,
                  onSelected: (id) => setState(() => _paymentId = id),
                  showSecurityNotes: true,
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(ServicesBookingStrings.billSummary),
                CartZoodPromoBanner(
                  onTap: () => context.push(CartRoutes.zoodWaitingList),
                ),
                SizedBox(height: 12.h),
                BillSummaryCard(
                  lines: billLines,
                  showCashback: true,
                  cashbackAmount: cart?.cashbackLabel,
                ),
              ],
            ),
      bottom: CartStickyFooter(
        total: total,
        buttonLabel: _placing ? '…' : ServicesBookingStrings.placeBooking,
        buttonColor: AppColors.cartTabActive,
        onPressed: _placing || _loading ? () {} : _placeOrder,
      ),
    );
  }
}
