import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/services_vendors_repository.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/pending_checkout.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_line_item_card.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/features/services_booking/model/services_booking_data.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';
import 'package:yjeek_app/features/services_booking/view/widgets/services_booking_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';

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
  String? _slotReason;
  Set<String> _fulfillmentModes = const {};

  int _selectedTime = 0;
  final Set<String> _busyProducts = {};
  bool _cartLineBusy = false;

  late DateTime _selectedDay = _dayOnlyStatic(DateTime.now());
  Set<String> _bookableDayKeys = const {};
  int _bookingWindowDays = 30;

  static DateTime _dayOnlyStatic(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  String _dayKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  DateTime get _calendarFirstDay => _dayOnly(DateTime.now());

  DateTime get _calendarLastDay =>
      _calendarFirstDay.add(Duration(days: _bookingWindowDays - 1));

  bool _isDaySelectable(DateTime day) {
    final d = _dayOnly(day);
    if (d.isBefore(_calendarFirstDay) || d.isAfter(_calendarLastDay)) {
      return false;
    }
    if (_bookableDayKeys.isEmpty) return true;
    return _bookableDayKeys.contains(_dayKey(d));
  }

  void _pickInitialDay({List<DateTime>? bookableDays}) {
    final scheduled = _cart.serviceScheduledAt?.toLocal();
    if (scheduled != null) {
      final local = _dayOnly(scheduled);
      if (_isDaySelectable(local)) {
        _selectedDay = local;
        return;
      }
    }
    if (bookableDays != null && bookableDays.isNotEmpty) {
      _selectedDay = _dayOnly(bookableDays.first);
      return;
    }
    _selectedDay = _calendarFirstDay;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final repo = ref.read(cartRepositoryProvider);
    try {
      final cart = await repo.fetchCart(CartOrderType.service);
      if (!mounted) return;
      setState(() {
        _cart = cart;
        _loading = false;
      });
      await _loadProviderFulfillment();
      await _loadAvailableDates();
      await _loadSlots();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _syncScheduleFromCart(CartSnapshot cart) {
    final at = cart.serviceScheduledAt;
    if (at == null) return;
    final local = _dayOnly(at.toLocal());
    if (_isDaySelectable(local)) {
      _selectedDay = local;
    }
  }

  Future<void> _loadProviderFulfillment() async {
    final vendorId = _cart.vendorId;
    if (vendorId == null || vendorId.isEmpty) return;
    try {
      final provider = await ref
          .read(servicesVendorsRepositoryProvider)
          .fetchProvider(vendorId);
      if (!mounted) return;
      setState(() {
        _fulfillmentModes = provider.fulfillmentModes.toSet();
      });
      await _syncFulfillmentMode();
    } catch (_) {}
  }

  /// Uses GET /vendors/:id/booking-slots per day (vendor panel calendar + slots).
  Future<void> _loadAvailableDates() async {
    final vendorId = _cart.vendorId;
    final today = _dayOnly(DateTime.now());
    if (vendorId == null || vendorId.isEmpty) {
      setState(() {
        _bookableDayKeys = const {};
        _pickInitialDay();
        _syncScheduleFromCart(_cart);
      });
      return;
    }

    final repo = ref.read(servicesVendorsRepositoryProvider);
    final durationMin = serviceCartDurationMin(_cart.items);

    try {
      final todayPage = await repo.fetchBookingSlots(
        vendorId: vendorId,
        date: today,
        durationMin: durationMin,
        staffId: _selectedStaffId,
      );
      final window = todayPage.bookingWindowDays;
      if (window != null && window > 0) {
        _bookingWindowDays = window;
      }
      final modes = fulfillmentModesFromBookingPage(todayPage);
      if (modes.isNotEmpty && mounted) {
        setState(() => _fulfillmentModes = {..._fulfillmentModes, ...modes});
      }
    } catch (_) {}

    final probeDays = _bookingWindowDays.clamp(1, 31);
    final candidates = List.generate(
      probeDays,
      (i) => today.add(Duration(days: i)),
    );
    final probed = await Future.wait(
      candidates.map((day) async {
        try {
          final page = await repo.fetchBookingSlots(
            vendorId: vendorId,
            date: day,
            durationMin: durationMin,
            staffId: _selectedStaffId,
          );
          if (serviceDayHasVendorSlots(page)) return day;
        } catch (_) {}
        return null;
      }),
    );
    final available = probed.whereType<DateTime>().toList()
      ..sort((a, b) => a.compareTo(b));

    final keys = available.map(_dayKey).toSet();

    if (!mounted) return;
    setState(() {
      _bookableDayKeys = keys;
      _pickInitialDay(bookableDays: available);
      _syncScheduleFromCart(_cart);
      if (!_isDaySelectable(_selectedDay)) {
        _pickInitialDay(bookableDays: available);
      }
    });
  }

  Future<void> _loadSlots() async {
    final vendorId = _cart.vendorId;
    if (vendorId == null || vendorId.isEmpty) {
      setState(() {
        _slots = const [];
        _slotReason = null;
        _selectedTime = 0;
      });
      return;
    }
    setState(() => _slotsLoading = true);
    try {
      final page = await ref
          .read(servicesVendorsRepositoryProvider)
          .fetchBookingSlots(
            vendorId: vendorId,
            date: _selectedDay,
            durationMin: serviceCartDurationMin(_cart.items),
            staffId: _selectedStaffId,
          );
      final slots = page.slots;
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

      final context = serviceSlotContextFrom(page);
      final pageModes = fulfillmentModesFromBookingPage(page);
      final window = page.bookingWindowDays;
      if (window != null && window > 0) {
        _bookingWindowDays = window;
      }
      setState(() {
        _slots = slots;
        _slotReason = serviceBookingSlotsReasonMessage(page.reason) ??
            page.reason;
        _fulfillmentModes = {
          ..._fulfillmentModes,
          ...context.fulfillmentModes,
          ...pageModes,
        };
        _selectedTime = selected;
        _slotsLoading = false;
      });
      ref.read(serviceSlotContextProvider.notifier).state = context;
      await _syncFulfillmentMode();

      if (slots.isNotEmpty && slots[selected].available) {
        await _saveSchedule();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _slots = const [];
        _slotReason = null;
        _slotsLoading = false;
      });
    }
  }

  String? get _selectedStaffId {
    final id = ref.read(pendingServiceCheckoutProvider)?.specialistId?.trim();
    if (id == null || id.isEmpty) return null;
    return id;
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

  Future<void> _syncFulfillmentMode() async {
    if (_fulfillmentModes.isEmpty) return;
    final venueOk = serviceModeAllowed(_fulfillmentModes, 'IN_SALON');
    final homeOk = serviceModeAllowed(_fulfillmentModes, 'AT_HOME');
    if (_atVenue && !venueOk && homeOk) {
      await _saveMode(false);
    } else if (!_atVenue && !homeOk && venueOk) {
      await _saveMode(true);
    }
  }

  Future<void> _saveMode(bool atVenue) async {
    final mode = atVenue ? 'IN_SALON' : 'AT_HOME';
    if (!serviceModeAllowed(_fulfillmentModes, mode)) return;
    final repo = ref.read(cartRepositoryProvider);
    try {
      final next = await repo.updatePreferences(
        type: CartOrderType.service,
        serviceMode: atVenue ? 'IN_SALON' : 'AT_HOME',
      );
      if (mounted) setState(() => _cart = next);
    } catch (_) {}
  }

  Future<void> _changeLineQuantity(CartLineItem item, int nextQty) async {
    if (_cartLineBusy) return;
    setState(() => _cartLineBusy = true);
    final repo = ref.read(cartRepositoryProvider);
    try {
      final next = nextQty < 1
          ? await repo.removeItem(type: CartOrderType.service, itemId: item.id)
          : await repo.updateItemQuantity(
              type: CartOrderType.service,
              itemId: item.id,
              quantity: nextQty,
            );
      if (!mounted) return;
      setState(() => _cart = next);
      await _loadSlots();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _cartLineBusy = false);
    }
  }

  void _editServiceLine(CartLineItem item) {
    final vendorId = _cart.vendorId;
    if (vendorId == null || vendorId.isEmpty || item.productId.isEmpty) {
      return;
    }
    context.push(
      BrowseRoutes.servicesItemDetail(
        providerId: vendorId,
        itemId: item.productId,
      ),
    );
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
      await _loadSlots();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _busyProducts.remove(upsell.productId));
    }
  }

  bool get _atVenue => _cart.serviceMode != 'AT_HOME';

  /// Upsell suggestions not yet in the cart (added ones appear under Your items).
  List<CartUpsellItem> get _pendingUpsells {
    final inCart = _cart.items.map((i) => i.productId).toSet();
    return _cart.upsell.where((u) => !inCart.contains(u.productId)).toList();
  }

  void _goToServiceCheckout() {
    if (_cart.serviceScheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a date and time first.')),
      );
      return;
    }
    context.push(ServicesBookingRoutes.checkout);
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
    final slotLabels = [for (final s in _slots) s.label];
    final slotAvailable = [for (final s in _slots) s.available];

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
                style: TextStyle(fontSize: 14.sp, color: Color(0xFF6B756E)),
              ),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              children: [
                CartSectionTitle(NavigationStrings.yourItems),
                for (final item in _cart.items)
                  CartLineItemCard(
                    item: item,
                    sideBusy: _cartLineBusy,
                    onEdit: () => _editServiceLine(item),
                    onMinus: () => _changeLineQuantity(item, item.quantity - 1),
                    onPlus: () => _changeLineQuantity(item, item.quantity + 1),
                  ),
                SizedBox(height: 6.h),
                CartSectionTitle(ServicesBookingStrings.where),
                ServicesLocationToggle(
                  atVenue: _atVenue,
                  allowVenue: serviceModeAllowed(_fulfillmentModes, 'IN_SALON'),
                  allowHome: serviceModeAllowed(_fulfillmentModes, 'AT_HOME'),
                  onChanged: (v) {
                    if (v == _atVenue) return;
                    _saveMode(v);
                  },
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(ServicesBookingStrings.date),
                ServicesBookingDateField(
                  selectedDay: _selectedDay,
                  firstDay: _calendarFirstDay,
                  lastDay: _calendarLastDay,
                  selectableDayPredicate: _isDaySelectable,
                  onDaySelected: (day) {
                    if (_sameDay(day, _selectedDay)) return;
                    setState(() => _selectedDay = _dayOnly(day));
                    _loadSlots();
                  },
                ),
                SizedBox(height: 14.h),
                CartSectionTitle(ServicesBookingStrings.time),
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
                else ...[
                  if (_slots.isEmpty &&
                      _slotReason != null &&
                      _slotReason!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        _slotReason!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B756E),
                          height: 16 / 13,
                        ),
                      ),
                    ),
                  ServicesTimeDropdown(
                    slots: slotLabels,
                    available: slotAvailable,
                    selectedIndex: _selectedTime.clamp(
                      0,
                      slotLabels.isEmpty ? 0 : slotLabels.length - 1,
                    ),
                    hint: slotLabels.isEmpty
                        ? 'No times available'
                        : ServicesBookingStrings.time,
                    onSelected: (i) {
                      setState(() => _selectedTime = i);
                      _saveSchedule();
                    },
                  ),
                ],
                if (_pendingUpsells.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  CartSectionTitle(ServicesBookingStrings.addTheseToo),
                  Text(
                    _cart.upsellSubtitle ?? ServicesBookingStrings.popularWith,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B756E),
                      height: 16 / 13,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  for (final upsell in _pendingUpsells)
                    ServicesUpsellCard(
                      item: BookingUpsellItem(
                        id: upsell.productId,
                        name: upsell.name,
                        duration: upsell.durationLabel ?? '',
                        price: upsell.priceLabel,
                        emoji: _emojiFor(upsell.name),
                      ),
                      selected: false,
                      onToggle: () => _toggleUpsell(upsell),
                    ),
                ],
                SizedBox(height: 14.h),
                if (_cart.promoCode != null &&
                    _cart.promoCode!.trim().isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF7EE),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFCDE8CF)),
                    ),
                    child: Text(
                      '${_cart.promoCode!.trim()} applied',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                ],
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
                  onPressed: !_cart.hasItems ? null : _goToServiceCheckout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
