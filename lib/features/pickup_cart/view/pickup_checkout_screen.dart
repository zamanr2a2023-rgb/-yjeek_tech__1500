import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/model/checkout_payment_visibility.dart';
import 'package:yjeek_app/features/cart/model/payment_methods_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/zood_checkout_banner.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/pickup_cart/model/pickup_cart_data.dart';
import 'package:yjeek_app/features/pickup_cart/pickup_cart_routes.dart';
import 'package:yjeek_app/features/pickup_cart/view/widgets/pickup_cart_widgets.dart';
import 'package:yjeek_app/features/scheduled_cart/view/widgets/scheduled_cart_widgets.dart';

/// Pickup checkout. Ready time is the longest item prep; the customer does not pick a slot.
class PickupCheckoutScreen extends ConsumerStatefulWidget {
  const PickupCheckoutScreen({super.key});

  @override
  ConsumerState<PickupCheckoutScreen> createState() =>
      _PickupCheckoutScreenState();
}

class _PickupCheckoutScreenState extends ConsumerState<PickupCheckoutScreen> {
  String _paymentId =
      CheckoutPaymentVisibility.preferredCheckoutDefaultId();
  CartSnapshot? _cart;
  CheckoutPaymentMethods _payments = CheckoutPaymentMethods.fallback(
    base: PickupCartData.paymentOptions,
    includeCod: false,
  );
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cartRepo = ref.read(cartRepositoryProvider);
      final cart = await cartRepo.fetchCart(CartOrderType.pickup);
      final payments = await ref
          .read(paymentMethodsRepositoryProvider)
          .fetchCheckoutMethods(
            fallback: PickupCartData.paymentOptions,
            includeCod: false,
            preferredDefaultId:
                CheckoutPaymentVisibility.preferredCheckoutDefaultId(),
          );
      if (!mounted) return;
      setState(() {
        _cart = cart;
        _payments = payments;
        _paymentId = payments.defaultId;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _goToReview() {
    if (_cart == null || !_cart!.hasItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your pickup cart is empty')),
      );
      return;
    }
    // Order is placed on Review (Confirm / auto-timer), not here.
    context.pushReplacement(
      PickupCartRoutes.reviewFor(paymentId: _paymentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;
    final vendor = cart?.vendorName.isNotEmpty == true
        ? cart!.vendorName
        : 'Pickup';
    final pickup = cart?.pickup;
    final billLines = cart?.billLines ?? const <BillLine>[];
    final footerTotal = cart != null
        ? formatCheckoutTotal(cart, 0)
        : 'BHD 0.000';

    final timeLabel = pickup != null && pickup.readyLabel.trim().isNotEmpty
        ? pickup.readyLabel
        : 'Ready soon';

    return CartFlowScaffold(
      title: PickupCartStrings.checkout,
      subtitle: vendor,
      lightHeader: true,
      backgroundColor: const Color(0xFFF2F7F2),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              children: [
                PickupCheckoutDetailsSection(
                  vendorLabel: pickup?.vendorLabel ?? vendor,
                  address: pickup?.address ?? '',
                  readyLabel: pickup?.readyLabel ?? '',
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(PickupCartStrings.pickupTime),
                PickupTimeCard(
                  timeLabel: timeLabel,
                ),
                SizedBox(height: 10.h),
                PickupPolicyBanner(
                  policyText:
                      pickup?.noShowPolicy ?? PickupCartStrings.policyWarning,
                ),
                SizedBox(height: 14.h),
                const ZoodCheckoutBannerSlot(
                  placement: 'ABOVE_PAYMENT',
                  joinScreen: 'pickup_checkout',
                ),
                CartSectionTitle(PickupCartStrings.paymentMethod),
                CartPaymentMethodList(
                  options: _payments.options,
                  selectedId: _paymentId,
                  onSelected: (id) => setState(() => _paymentId = id),
                  showSecurityNotes: true,
                ),
                const ZoodCheckoutBannerSlot(
                  placement: 'BELOW_PAYMENT',
                  joinScreen: 'pickup_checkout',
                ),
                SizedBox(height: 14.h),
                const ZoodCheckoutBannerSlot(
                  placement: 'ABOVE_BILL_SUMMARY',
                  joinScreen: 'pickup_checkout',
                ),
                CartSectionTitle(PickupCartStrings.billSummary),
                BillSummaryCard(lines: billLines),
                const ZoodCheckoutBannerSlot(
                  placement: 'BELOW_BILL_SUMMARY',
                  joinScreen: 'pickup_checkout',
                ),
                SizedBox(height: 10.h),
                ScheduledCashbackBanner(amount: cart?.cashbackLabel),
              ],
            ),
      bottom: CartStickyFooter(
        total: footerTotal,
        buttonLabel: PickupCartStrings.placeOrder,
        onPressed: _loading ? () {} : _goToReview,
      ),
    );
  }
}
