import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/dine_in_cart/model/dine_in_cart_data.dart';
import 'package:yjeek_app/features/dine_in_cart/view/widgets/dine_in_cart_widgets.dart';
import 'package:yjeek_app/features/dine_in_order_flow/dine_in_order_flow_routes.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class DineInCheckoutScreen extends ConsumerStatefulWidget {
  const DineInCheckoutScreen({
    super.key,
    this.initialMode = DineInPrepMode.prepareNow,
  });

  final DineInPrepMode initialMode;

  @override
  ConsumerState<DineInCheckoutScreen> createState() =>
      _DineInCheckoutScreenState();
}

class _DineInCheckoutScreenState extends ConsumerState<DineInCheckoutScreen> {
  late DineInPrepMode _prepMode;
  String _paymentId = 'wallet';
  CartSnapshot? _cart;
  DineInSlotsSnapshot? _slots;
  List<PaymentOption> _paymentOptions = DineInCartData.paymentOptions;
  bool _loading = true;
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _prepMode = widget.initialMode;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cartRepo = ref.read(cartRepositoryProvider);
      final cart = await cartRepo.fetchCart(CartOrderType.dineIn);
      final slots = await cartRepo.fetchDineInSlots();
      final payments = await ref
          .read(paymentMethodsRepositoryProvider)
          .fetchCheckoutMethods(
            includeCod: false,
            preferredDefaultId: 'wallet',
          );
      if (!mounted) return;

      final mapped = payments.options
          .where((o) => o.id != 'cod')
          .map(
            (o) => PaymentOption(
              id: o.id,
              label: o.label.contains(' · ')
                  ? o.label.split(' · ').first
                  : o.label,
              subtitle: o.label.contains(' · ')
                  ? o.label.split(' · ').sublist(1).join(' · ')
                  : null,
              iconAsset: o.iconAsset,
              selected: o.id == payments.defaultId,
            ),
          )
          .toList();

      final prep = cart.dineInPrepMode == 'PREPARE_ON_ARRIVAL'
          ? DineInPrepMode.prepareOnArrival
          : (cart.dineInPrepMode == 'PREPARE_NOW'
              ? DineInPrepMode.prepareNow
              : _prepMode);

      setState(() {
        _cart = cart;
        _slots = slots;
        if (mapped.isNotEmpty) {
          _paymentOptions = mapped;
          _paymentId = payments.defaultId;
        }
        _prepMode = prep;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _setPrepMode(DineInPrepMode mode) async {
    setState(() => _prepMode = mode);
    try {
      final isArrival = mode == DineInPrepMode.prepareOnArrival;
      DateTime? scheduledAt;
      if (isArrival) {
        final selected = _slots?.slots
            .where((s) => s.id == _slots!.selectedId)
            .cast<DineInTimeSlot?>()
            .firstWhere((_) => true, orElse: () => null);
        scheduledAt = selected?.scheduledAt ??
            _cart?.scheduledDineInAt ??
            (_slots?.slots.isNotEmpty == true
                ? _slots!.slots.first.scheduledAt
                : DateTime.now().add(const Duration(hours: 1)));
      }

      final cart = await ref.read(cartRepositoryProvider).updatePreferences(
            type: CartOrderType.dineIn,
            dineInPrepMode:
                isArrival ? 'PREPARE_ON_ARRIVAL' : 'PREPARE_NOW',
            scheduledDineInAt: scheduledAt,
            clearScheduledDineInAt: !isArrival,
          );
      final slots = await ref.read(cartRepositoryProvider).fetchDineInSlots();
      if (!mounted) return;
      setState(() {
        _cart = cart;
        _slots = slots;
      });
    } catch (_) {}
  }

  Future<void> _changeDineInTime() async {
    final slots = _slots?.slots ?? const <DineInTimeSlot>[];
    if (slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No dine-in slots available')),
      );
      return;
    }

    final selected = await showModalBottomSheet<DineInTimeSlot>(
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
                  trailing: (_slots?.selectedId == slot.id ||
                          _cart?.scheduledDineInAt == slot.scheduledAt)
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
            type: CartOrderType.dineIn,
            dineInPrepMode: 'PREPARE_ON_ARRIVAL',
            scheduledDineInAt: selected.scheduledAt,
          );
      final refreshed =
          await ref.read(cartRepositoryProvider).fetchDineInSlots();
      if (!mounted) return;
      setState(() {
        _prepMode = DineInPrepMode.prepareOnArrival;
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
      final isArrival = _prepMode == DineInPrepMode.prepareOnArrival;
      await ref.read(cartRepositoryProvider).updatePreferences(
            type: CartOrderType.dineIn,
            dineInPrepMode:
                isArrival ? 'PREPARE_ON_ARRIVAL' : 'PREPARE_NOW',
            scheduledDineInAt: isArrival ? _cart?.scheduledDineInAt : null,
            clearScheduledDineInAt: !isArrival,
          );
      await ref.read(cartRepositoryProvider).checkout(
            type: CartOrderType.dineIn,
            paymentMethod: paymentMethodApiValue(_paymentId),
          );
      if (!mounted) return;
      context.pushReplacement(DineInOrderFlowRoutes.waiting);
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
    final isPrepareNow = _prepMode == DineInPrepMode.prepareNow;
    final cart = _cart;
    final vendor = cart?.vendorName.isNotEmpty == true
        ? cart!.vendorName
        : 'Dine-in';
    final billLines = cart != null ? cart.billLines : const <BillLine>[];
    final total = cart?.totalLabel ?? 'BHD 0.000';
    final readyLabel = formatDineInReadyLabel(
      dineIn: cart?.dineIn,
      eta: cart?.deliveryEta,
      fallback: DineInCartStrings.tableReadyValue,
    );

    final selectedSlot = _slots?.slots
        .where((s) => s.id == _slots!.selectedId)
        .cast<DineInTimeSlot?>()
        .firstWhere((_) => true, orElse: () => null);
    final dineInTime = selectedSlot?.label ??
        formatPickupTimeLabel(
          cart?.scheduledDineInAt ?? cart?.dineIn?.scheduledAt,
          readyLabel: readyLabel,
        );

    return CartFlowScaffold(
      title: DineInCartStrings.checkout,
      subtitle: vendor,
      lightHeader: true,
      backgroundColor: const Color(0xFF8BAE9A),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
              children: [
                const CartSectionTitle(DineInCartStrings.diningOption),
                DineInPrepOptionCard(
                  title: DineInCartStrings.prepareNow,
                  subtitle: formatDineInPrepareNowHint(readyLabel),
                  icon: Icons.local_fire_department,
                  iconBackground: AppColors.primary,
                  iconColor: AppColors.white,
                  selected: isPrepareNow,
                  onTap: () => _setPrepMode(DineInPrepMode.prepareNow),
                ),
                SizedBox(height: 10.h),
                DineInPrepOptionCard(
                  title: DineInCartStrings.prepareOnArrival,
                  subtitle: DineInCartStrings.prepareOnArrivalHint,
                  icon: Icons.location_on,
                  iconBackground: const Color(0xFFEBC34A),
                  iconColor: AppColors.white,
                  selected: !isPrepareNow,
                  onTap: () => _setPrepMode(DineInPrepMode.prepareOnArrival),
                ),
                SizedBox(height: 14.h),
                if (isPrepareNow) ...[
                  DineInTableReadyCard(readyLabel: readyLabel),
                  SizedBox(height: 10.h),
                  DineInInfoBanner(
                    message: formatDineInPrepareNowBanner(readyLabel),
                  ),
                ] else ...[
                  CartFlowCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DineInCartStrings.dineInTime,
                                style: AppTextStyles.labelSmall(
                                  color: AppColors.textSecondary,
                                ).copyWith(fontSize: 12.sp),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                dineInTime,
                                style: AppTextStyles.labelMedium().copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _changeDineInTime,
                          child: Text(
                            'Change',
                            style: AppTextStyles.labelSmall(
                              color: AppColors.primary,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  const DineInInfoBanner(
                    message: DineInCartStrings.arrivalBanner,
                  ),
                ],
                SizedBox(height: 18.h),
                const CartSectionTitle(DineInCartStrings.paymentMethod),
                DineInPaymentList(
                  options: _paymentOptions,
                  selectedId: _paymentId,
                  onSelected: (id) => setState(() => _paymentId = id),
                ),
                SizedBox(height: 10.h),
                const DineInWalletNoteBanner(),
                SizedBox(height: 18.h),
                Text(
                  DineInCartStrings.billSummary,
                  style: AppTextStyles.titleSmall(
                    color: AppColors.textPrimary,
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    height: 1.28,
                  ),
                ),
                SizedBox(height: 10.h),
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
        buttonLabel: _placing ? '…' : DineInCartStrings.placeOrder,
        onPressed: _placing || _loading ? () {} : _placeOrder,
      ),
    );
  }
}
