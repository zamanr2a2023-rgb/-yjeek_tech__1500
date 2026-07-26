import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/model/payment_methods_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/pickup_cart/model/pickup_cart_data.dart';
import 'package:yjeek_app/features/pickup_cart/view/widgets/pickup_cart_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/pickup_order_flow_routes.dart';
import 'package:yjeek_app/features/scheduled_cart/view/widgets/scheduled_cart_widgets.dart';

/// Pickup checkout — layout from Figma; vendor / bill / ready time / slots from API.
class PickupCheckoutScreen extends ConsumerStatefulWidget {
  const PickupCheckoutScreen({super.key});

  @override
  ConsumerState<PickupCheckoutScreen> createState() =>
      _PickupCheckoutScreenState();
}

class _PickupCheckoutScreenState extends ConsumerState<PickupCheckoutScreen> {
  int _tipIndex = 0;
  String _paymentId = 'benefitpay';
  CartSnapshot? _cart;
  PickupSlotsSnapshot? _slots;
  CheckoutPaymentMethods _payments = CheckoutPaymentMethods.fallback(
    base: PickupCartData.paymentOptions,
  );
  bool _loading = true;
  bool _placing = false;

  double get _tipAmount => tipAmountFrom(PickupCartData.tipOptions, _tipIndex);

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
      final slots = await cartRepo.fetchPickupSlots();
      final payments = await ref
          .read(paymentMethodsRepositoryProvider)
          .fetchCheckoutMethods(
            fallback: PickupCartData.paymentOptions,
            preferredDefaultId: 'benefitpay',
          );
      if (!mounted) return;
      setState(() {
        _cart = cart;
        _slots = slots;
        _payments = payments;
        _paymentId = payments.defaultId;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _changePickupTime() async {
    final slots = _slots?.slots ?? const <PickupTimeSlot>[];
    if (slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pickup slots available')),
      );
      return;
    }

    final selected = await showModalBottomSheet<PickupTimeSlot>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final slot in slots)
                ListTile(
                  title: Text(slot.label),
                  trailing: (_slots?.selectedId == slot.id)
                      ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                      : null,
                  onTap: () => Navigator.pop(context, slot),
                ),
            ],
          ),
        );
      },
    );
    if (selected == null || !mounted) return;

    try {
      final cart = await ref.read(cartRepositoryProvider).updatePreferences(
            type: CartOrderType.pickup,
            pickupScheduledAt: selected.scheduledAt,
            clearPickupScheduledAt: selected.isAsap,
          );
      final refreshed = await ref.read(cartRepositoryProvider).fetchPickupSlots();
      if (!mounted) return;
      setState(() {
        _cart = cart;
        _slots = refreshed;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _placeOrder() async {
    if (_placing) return;
    setState(() => _placing = true);
    try {
      await ref.read(cartRepositoryProvider).checkout(
            type: CartOrderType.pickup,
            paymentMethod: paymentMethodApiValue(_paymentId),
            tipAmount: _tipAmount,
          );
      if (!mounted) return;
      context.pushReplacement(PickupOrderFlowRoutes.waiting);
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
        : 'Pickup';
    final pickup = cart?.pickup;
    final billLines = cart != null
        ? billLinesWithTip(cart, _tipAmount)
        : const <BillLine>[];
    final footerTotal = cart != null
        ? formatCheckoutTotal(cart, _tipAmount)
        : 'BHD 0.000';

    final selectedSlot = _slots?.slots
        .where((s) => s.id == _slots!.selectedId)
        .cast<PickupTimeSlot?>()
        .firstWhere((_) => true, orElse: () => null);
    final timeLabel = selectedSlot?.label ??
        formatPickupTimeLabel(
          pickup?.scheduledAt,
          readyLabel: pickup?.readyLabel,
        );

    return CartFlowScaffold(
      title: PickupCartStrings.checkout,
      subtitle: vendor,
      lightHeader: true,
      backgroundColor: const Color(0xFFF2F7F2),
      body: _loading
          ? const Center(
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
                const CartSectionTitle(PickupCartStrings.pickupTime),
                PickupTimeCard(
                  timeLabel: timeLabel,
                  onChange: _changePickupTime,
                ),
                SizedBox(height: 10.h),
                PickupPolicyBanner(
                  policyText:
                      pickup?.noShowPolicy ?? PickupCartStrings.policyWarning,
                ),
                SizedBox(height: 14.h),
                const CartSectionTitle(PickupCartStrings.paymentMethod),
                CartPaymentMethodList(
                  options: _payments.options,
                  selectedId: _paymentId,
                  onSelected: (id) => setState(() => _paymentId = id),
                  showSecurityNotes: true,
                ),
                SizedBox(height: 14.h),
                CartTipSelector(
                  showHeader: true,
                  options: PickupCartData.tipOptions,
                  selectedIndex: _tipIndex,
                  onSelected: (index) => setState(() => _tipIndex = index),
                ),
                SizedBox(height: 14.h),
                CartZoodPromoBanner(
                  onTap: () => context.push(CartRoutes.zoodWaitingList),
                ),
                SizedBox(height: 14.h),
                const CartSectionTitle(PickupCartStrings.billSummary),
                BillSummaryCard(lines: billLines),
                SizedBox(height: 10.h),
                ScheduledCashbackBanner(amount: cart?.cashbackLabel),
              ],
            ),
      bottom: CartStickyFooter(
        total: footerTotal,
        buttonLabel: _placing ? '…' : PickupCartStrings.placeOrder,
        onPressed: _placing || _loading ? () {} : _placeOrder,
      ),
    );
  }
}
