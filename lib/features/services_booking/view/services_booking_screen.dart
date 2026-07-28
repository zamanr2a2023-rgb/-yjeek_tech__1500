import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/services_vendors_repository.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/services_booking/model/services_booking_data.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';
import 'package:yjeek_app/features/services_booking/view/widgets/services_booking_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class ServicesBookingScreen extends ConsumerStatefulWidget {
  const ServicesBookingScreen({super.key});

  @override
  ConsumerState<ServicesBookingScreen> createState() =>
      _ServicesBookingScreenState();
}

class _ServicesBookingScreenState extends ConsumerState<ServicesBookingScreen> {
  bool _loading = true;
  bool _slotsLoading = false;
  CartSnapshot _cart = CartSnapshot.empty(CartOrderType.service);
  List<ServiceBookingSlot> _slots = const [];

  int _selectedDate = 0;
  int _selectedTime = 0;
  final TextEditingController _promoController = TextEditingController();
  bool _applyingPromo = false;
  final Set<String> _busyProducts = {};

  late final List<DateTime> _dates = List.generate(5, (i) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: i));
  });

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(cartRepositoryProvider);
    try {
      final cart = await repo.fetchCart(CartOrderType.service);
      if (!mounted) return;
      setState(() {
        _cart = cart;
        _loading = false;
        _syncScheduleFromCart(cart);
      });
      await _loadSlots();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _syncScheduleFromCart(CartSnapshot cart) {
    final at = cart.serviceScheduledAt;
    if (at == null) return;
    final local = at.toLocal();
    for (var i = 0; i < _dates.length; i++) {
      final d = _dates[i];
      if (d.year == local.year &&
          d.month == local.month &&
          d.day == local.day) {
        _selectedDate = i;
        break;
      }
    }
  }

  Future<void> _loadSlots() async {
    final vendorId = _cart.vendorId;
    if (vendorId == null || vendorId.isEmpty) {
      setState(() {
        _slots = const [];
        _selectedTime = 0;
      });
      return;
    }
    setState(() => _slotsLoading = true);
    try {
      final slots = await ref
          .read(servicesVendorsRepositoryProvider)
          .fetchBookingSlots(
            vendorId: vendorId,
            date: _dates[_selectedDate],
          );
      if (!mounted) return;

      var selected = _selectedTime;
      final scheduled = _cart.serviceScheduledAt?.toLocal();
      if (scheduled != null) {
        final match = slots.indexWhere(
          (s) =>
              s.startAt.hour == scheduled.hour &&
              s.startAt.minute == scheduled.minute,
        );
        if (match >= 0) selected = match;
      }
      if (selected >= slots.length) selected = 0;
      if (slots.isNotEmpty &&
          (selected >= slots.length || !slots[selected].available)) {
        final firstAvailable = slots.indexWhere((s) => s.available);
        selected = firstAvailable >= 0 ? firstAvailable : 0;
      }

      setState(() {
        _slots = slots;
        _selectedTime = selected;
        _slotsLoading = false;
      });

      if (slots.isNotEmpty && slots[selected].available) {
        await _saveSchedule();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _slots = const [];
        _slotsLoading = false;
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (_slots.isEmpty || _selectedTime >= _slots.length) return;
    final slot = _slots[_selectedTime];
    if (!slot.available) return;
    final repo = ref.read(cartRepositoryProvider);
    try {
      final next = await repo.updatePreferences(
        type: CartOrderType.service,
        serviceScheduledAt: slot.startAt,
      );
      if (mounted) setState(() => _cart = next);
    } catch (_) {}
  }

  Future<void> _saveMode(bool atVenue) async {
    final repo = ref.read(cartRepositoryProvider);
    try {
      final next = await repo.updatePreferences(
        type: CartOrderType.service,
        serviceMode: atVenue ? 'IN_SALON' : 'AT_HOME',
      );
      if (mounted) setState(() => _cart = next);
    } catch (_) {}
  }

  Future<void> _toggleUpsell(CartUpsellItem upsell) async {
    if (_busyProducts.contains(upsell.productId)) return;
    setState(() => _busyProducts.add(upsell.productId));
    final repo = ref.read(cartRepositoryProvider);
    try {
      CartLineItem? existing;
      for (final item in _cart.items) {
        if (item.productId == upsell.productId) {
          existing = item;
          break;
        }
      }
      final next = existing != null
          ? await repo.removeItem(
              type: CartOrderType.service,
              itemId: existing.id,
            )
          : await repo.addProduct(
              type: CartOrderType.service,
              productId: upsell.productId,
            );
      if (mounted) setState(() => _cart = next);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _busyProducts.remove(upsell.productId));
    }
  }

  Future<void> _applyPromo() async {
    final code = _promoController.text.trim();
    if (code.isEmpty || _applyingPromo) return;
    setState(() => _applyingPromo = true);
    final repo = ref.read(cartRepositoryProvider);
    try {
      final next = await repo.applyPromo(
        type: CartOrderType.service,
        code: code,
      );
      if (!mounted) return;
      setState(() => _cart = next);
      _promoController.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid promo code')),
      );
    } finally {
      if (mounted) setState(() => _applyingPromo = false);
    }
  }

  bool get _atVenue => _cart.serviceMode != 'AT_HOME';

  /// Services shown as "Your service" cards: items that aren't suggested
  /// add-ons (those stay in the "Add these too?" list with a check mark).
  List<CartLineItem> get _mainServices {
    final upsellIds = _cart.upsell.map((u) => u.productId).toSet();
    final main =
        _cart.items.where((i) => !upsellIds.contains(i.productId)).toList();
    return main.isEmpty ? _cart.items : main;
  }

  String _emojiFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('blow')) return '💨';
    if (lower.contains('mask') || lower.contains('treatment')) return '🧴';
    if (lower.contains('massage')) return '💆';
    if (lower.contains('gloss') || lower.contains('shine')) return '✨';
    if (lower.contains('color')) return '🎨';
    if (lower.contains('manicure') || lower.contains('nail')) return '💅';
    if (lower.contains('makeup')) return '💄';
    if (lower.contains('facial') || lower.contains('glow')) return '🌟';
    return '✂';
  }

  @override
  Widget build(BuildContext context) {
    final dateOptions = [
      for (final d in _dates)
        BookingDateOption(day: _weekdays[d.weekday - 1], date: d.day),
    ];
    final slotLabels = _slots.isEmpty
        ? ServicesBookingData.timeSlots
        : [for (final s in _slots) s.label];
    final slotAvailable =
        _slots.isEmpty ? null : [for (final s in _slots) s.available];

    return CartFlowScaffold(
      title: ServicesBookingStrings.booking,
      subtitle: _cart.vendorName.isNotEmpty
          ? _cart.vendorName
          : ServicesBookingStrings.provider,
      lightHeader: true,
      bottomNavIndex: 0,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : !_cart.hasItems
              ? Center(
                  child: Text(
                    'Your booking is empty.\nPick a service to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B756E),
                    ),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                  children: [
                    const CartSectionTitle(ServicesBookingStrings.yourService),
                    for (final item in _mainServices) ...[
                      ServicesServiceCard(
                        name: item.name,
                        durationLabel:
                            '🕒 ${item.durationLabel ?? '45 min'}',
                        priceLabel: item.unitPriceLabel,
                      ),
                      SizedBox(height: 8.h),
                    ],
                    SizedBox(height: 6.h),
                    const CartSectionTitle(ServicesBookingStrings.where),
                    ServicesLocationToggle(
                      atVenue: _atVenue,
                      onChanged: (v) {
                        if (v == _atVenue) return;
                        _saveMode(v);
                      },
                    ),
                    SizedBox(height: 14.h),
                    const CartSectionTitle(ServicesBookingStrings.date),
                    ServicesDatePicker(
                      dates: dateOptions,
                      selectedIndex: _selectedDate,
                      onSelected: (i) {
                        setState(() => _selectedDate = i);
                        _loadSlots();
                      },
                    ),
                    SizedBox(height: 14.h),
                    const CartSectionTitle(ServicesBookingStrings.time),
                    if (_slotsLoading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    else
                      ServicesTimeGrid(
                        slots: slotLabels,
                        available: slotAvailable,
                        selectedIndex: _selectedTime.clamp(
                          0,
                          slotLabels.isEmpty ? 0 : slotLabels.length - 1,
                        ),
                        onSelected: (i) {
                          setState(() => _selectedTime = i);
                          _saveSchedule();
                        },
                      ),
                    if (_cart.upsell.isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      const CartSectionTitle(
                        ServicesBookingStrings.addTheseToo,
                      ),
                      Text(
                        _cart.upsellSubtitle ??
                            ServicesBookingStrings.popularWith,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B756E),
                          height: 16 / 13,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      for (final upsell in _cart.upsell)
                        ServicesUpsellCard(
                          item: BookingUpsellItem(
                            id: upsell.productId,
                            name: upsell.name,
                            duration: upsell.durationLabel ?? '30 min',
                            price: upsell.priceLabel,
                            emoji: _emojiFor(upsell.name),
                          ),
                          selected: _cart.items
                              .any((i) => i.productId == upsell.productId),
                          onToggle: () => _toggleUpsell(upsell),
                        ),
                    ],
                    SizedBox(height: 14.h),
                    const CartSectionTitle(ServicesBookingStrings.promoCode),
                    ServicesPromoField(
                      controller: _promoController,
                      applying: _applyingPromo,
                      appliedCode: _cart.promoCode,
                      onApply: _applyPromo,
                    ),
                    SizedBox(height: 14.h),
                    const CartSectionTitle(ServicesBookingStrings.billSummary),
                    BillSummaryCard(lines: _cart.billLines),
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
                      side: const BorderSide(
                        color: Color(0xFFE2E8DD),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                    ),
                    child: Text(
                      ServicesBookingStrings.addMore,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: PrimaryGreenButton(
                  label: ServicesBookingStrings.checkoutBtn,
                  backgroundColor: AppColors.cartTabActive,
                  height: 52,
                  onPressed: !_cart.hasItems
                      ? null
                      : () => context.push(ServicesBookingRoutes.checkout),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
