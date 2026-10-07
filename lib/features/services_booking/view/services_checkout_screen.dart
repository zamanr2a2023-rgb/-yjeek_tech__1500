import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/services_vendors_repository.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/location/provider/delivery_location_provider.dart';
import 'package:yjeek_app/features/location/utils/checkout_delivery_address.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/model/payment_methods_repository.dart';
import 'package:yjeek_app/features/cart/model/pending_checkout.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/zood_checkout_banner.dart';
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
  String _paymentId = 'benefitpay';
  CartSnapshot? _cart;
  CheckoutPaymentMethods _payments = CheckoutPaymentMethods.fallback(
    base: ServicesBookingData.paymentOptions,
  );
  String? _specialistId;
  String? _addressArea;
  String? _addressCity;
  DeliveryAddressSnapshot? _homeAddress;
  bool _loading = true;

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

      String? specialistId;
      final pending = ref.read(pendingServiceCheckoutProvider);
      specialistId = pending?.specialistId;

      DeliveryAddressSnapshot? address;
      try {
        final deliveryLoc = ref.read(deliveryLocationProvider).valueOrNull;
        address = checkoutAddressDisplay(deliveryLoc) ??
            await ref.read(addressesRepositoryProvider).defaultAddress();
      } catch (_) {}

      final vendorId = cart.vendorId;
      if (vendorId != null &&
          vendorId.isNotEmpty &&
          cart.serviceScheduledAt != null) {
        try {
          final page = await ref
              .read(servicesVendorsRepositoryProvider)
              .fetchBookingSlots(
                vendorId: vendorId,
                date: cart.serviceScheduledAt!,
                durationMin: serviceCartDurationMin(cart.items),
                staffId: specialistId,
              );
          ref.read(serviceSlotContextProvider.notifier).state =
              serviceSlotContextFrom(page);
        } catch (_) {}
      }

      if (!mounted) return;
      if (cart.hasItems && cart.serviceScheduledAt == null) {
        context.go(ServicesBookingRoutes.booking);
        return;
      }
      setState(() {
        _cart = cart;
        _payments = payments;
        _paymentId = payments.defaultId;
        _specialistId = specialistId;
        _addressArea = address?.area;
        _addressCity = address?.city;
        _homeAddress = address;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  double? _callOutFor(CartSnapshot? cart) {
    if (cart == null || cart.serviceMode != 'AT_HOME') return null;
    final context = ref.watch(serviceSlotContextProvider);
    if (context == null) return null;
    return matchedCallOutFee(
      areas: context.coveredAreas,
      area: _addressArea,
      city: _addressCity,
      slotCallOutFee: context.slotCallOutFee,
    );
  }

  Future<void> _goToReview() async {
    if (_cart?.serviceMode == 'AT_HOME') {
      final saved = await ensureSavedAddressForCheckout(context, ref);
      if (!mounted || saved == null) return;
      setState(() {
        _addressArea = saved.area;
        _addressCity = saved.city;
      });
    }
    // Booking is placed on Review (Confirm / auto-timer), not here.
    ref.read(pendingServiceCheckoutProvider.notifier).state =
        PendingServiceCheckout(
      paymentId: _paymentId,
      tipAmount: 0,
      specialistId: _specialistId,
    );
    context.pushReplacement(ServicesBookingRoutes.review);
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;
    final callOut = _callOutFor(cart);
    final deliveryFee = double.tryParse(cart?.delivery?.fee ?? '') ?? 0;
    final vendor = cart?.vendorName.isNotEmpty == true
        ? cart!.vendorName
        : ServicesBookingStrings.provider;
    final billLines = cart != null
        ? applyServiceCallOutFee(
            billLinesWithTip(cart, 0),
            callOut,
            summaryDeliveryFee: deliveryFee,
          )
        : const <BillLine>[];
    final total = cart != null
        ? applyServiceCallOutTotal(
            formatCheckoutTotal(cart, 0),
            callOut,
            summaryDeliveryFee: deliveryFee,
          )
        : 'BHD 0.000';
    final serviceName = cart != null
        ? summarizeServiceCheckoutItems(cart.items)
        : 'Service';
    final when = formatServiceAppointmentWhen(cart?.serviceScheduledAt);
    final locationLabel = cart?.serviceMode == 'AT_HOME'
        ? 'At home'
        : 'At venue · $vendor';
    final locationAddress = serviceCheckoutLocationAddress(
      cart: cart,
      homeAddress: _homeAddress,
    );

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
                  address: locationAddress,
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(ServicesBookingStrings.appointment),
                ServicesAppointmentCard(
                  serviceName: serviceName,
                  whenLabel: when,
                ),
                SizedBox(height: 14.h),
                const ZoodCheckoutBannerSlot(
                  placement: 'ABOVE_PAYMENT',
                  joinScreen: 'services_checkout',
                ),
                CartSectionTitle(ServicesBookingStrings.paymentMethod),
                CartPaymentMethodList(
                  options: _payments.options,
                  selectedId: _paymentId,
                  onSelected: (id) => setState(() => _paymentId = id),
                  showSecurityNotes: true,
                ),
                const ZoodCheckoutBannerSlot(
                  placement: 'BELOW_PAYMENT',
                  joinScreen: 'services_checkout',
                ),
                SizedBox(height: 14.h),
                const ZoodCheckoutBannerSlot(
                  placement: 'ABOVE_BILL_SUMMARY',
                  joinScreen: 'services_checkout',
                ),
                CartSectionTitle(ServicesBookingStrings.billSummary),
                BillSummaryCard(
                  lines: billLines,
                  showCashback: true,
                  cashbackAmount: cart?.cashbackPreview?.amountLabel ??
                      cart?.cashbackLabel,
                  cashbackMessage: cart?.cashbackPreview?.message,
                ),
                const ZoodCheckoutBannerSlot(
                  placement: 'BELOW_BILL_SUMMARY',
                  joinScreen: 'services_checkout',
                ),
              ],
            ),
      bottom: CartStickyFooter(
        total: total,
        buttonLabel: ServicesBookingStrings.placeBooking,
        buttonColor: AppColors.cartTabActive,
        onPressed: _loading ? () {} : _goToReview,
      ),
    );
  }
}
