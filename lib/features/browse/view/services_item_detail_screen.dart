import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/services_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';

class ServicesItemDetailScreen extends ConsumerStatefulWidget {
  const ServicesItemDetailScreen({
    super.key,
    required this.providerId,
    required this.itemId,
    this.bottomNavIndex = 0,
  });

  final String providerId;
  final String itemId;
  final int bottomNavIndex;

  @override
  ConsumerState<ServicesItemDetailScreen> createState() =>
      _ServicesItemDetailScreenState();
}

class _ServicesItemDetailScreenState
    extends ConsumerState<ServicesItemDetailScreen> {
  int _quantity = 1;
  int _selectedOption = 0;
  String _selectedSpecialist = ServicesData.specialists.first;
  final Set<int> _selectedAddons = {};

  ServiceMenuItem _item = ServicesData.glowBeautyMenu.first;
  String _description = ServicesData.haircutDescription;
  List<ServiceOption> _options = ServicesData.haircutOptions;
  List<ServiceAddon> _addons = ServicesData.haircutAddons;
  List<String> _specialists = ServicesData.specialists;
  bool _loading = true;
  bool _adding = false;

  static const Color _muted = Color(0xFF6B7A6E);
  static const Color _green = Color(0xFF2E9E4D);
  static const Color _mint = Color(0xFFE3F2EB);
  static const Color _border = Color(0xFFE0E6E0);

  @override
  void initState() {
    super.initState();
    _item = ServicesData.menuItemById(widget.itemId);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final detail = await ref
          .read(servicesVendorsRepositoryProvider)
          .fetchProductDetail(
            providerId: widget.providerId,
            itemId: widget.itemId,
          );
      if (!mounted) return;
      setState(() {
        _item = detail.item;
        _description = detail.description;
        _options = detail.options;
        _addons = detail.addons;
        _specialists = detail.specialists;
        _selectedSpecialist = _specialists.first;
        _selectedOption = 0;
        _selectedAddons.clear();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String get _displayPrice {
    final base = double.tryParse(_item.price) ?? 8;
    final option = _selectedOption >= 0 && _selectedOption < _options.length
        ? _options[_selectedOption]
        : null;
    final optionExtra = double.tryParse(option?.extraPrice ?? '') ?? 0.0;
    var addonTotal = 0.0;
    for (final index in _selectedAddons) {
      if (index >= 0 && index < _addons.length) {
        addonTotal += double.tryParse(_addons[index].price) ?? 0;
      }
    }
    return ((base + optionExtra + addonTotal) * _quantity).toStringAsFixed(3);
  }

  Future<void> _addToBooking({bool replaceCart = false}) async {
    if (_adding) return;
    setState(() => _adding = true);

    final optionIds = <String>[];
    if (_selectedOption >= 0 &&
        _selectedOption < _options.length &&
        _options[_selectedOption].id != null) {
      optionIds.add(_options[_selectedOption].id!);
    }
    final addonIds = <String>[];
    for (final index in _selectedAddons) {
      if (index >= 0 &&
          index < _addons.length &&
          _addons[index].id != null) {
        addonIds.add(_addons[index].id!);
      }
    }

    final result = await ref.read(servicesVendorsRepositoryProvider).addToCart(
          productId: widget.itemId,
          quantity: _quantity,
          optionIds: optionIds,
          addonIds: addonIds,
          replaceCart: replaceCart,
        );

    if (!mounted) return;
    setState(() => _adding = false);

    if (result.ok) {
      context.push(ServicesBookingRoutes.booking);
      return;
    }

    if (result.vendorConflict) {
      showCartNewCartDialog(
        context,
        onConfirm: () => _addToBooking(replaceCart: true),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Could not add to booking')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    // Design hero is 260; scale with width so title stays on-screen (260.h was too tall).
    final heroHeight = topInset + 200.w;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: heroHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: _mint),
                Positioned(
                  top: topInset + 12.w,
                  left: 16.w,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '‹',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          height: 1,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 18.w, 20.w, 8.w),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              _item.name,
                              style:
                                  AppTextStyles.titleMedium(
                                    color: AppColors.textPrimary,
                                  ).copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24.sp,
                                    height: 29 / 24,
                                  ),
                            ),
                          ),
                          Text(
                            'BHD ${_item.price}',
                            style: AppTextStyles.titleSmall(color: _green)
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18.sp,
                                  height: 22 / 18,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.w),
                      Text(
                        '🕒 ${_item.duration} · with a senior stylist',
                        style: AppTextStyles.labelSmall(color: _muted).copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                          height: 16 / 13,
                        ),
                      ),
                      SizedBox(height: 12.w),
                      Text(
                        _description,
                        style: AppTextStyles.bodySmall(color: _muted).copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          height: 17 / 14,
                        ),
                      ),
                      SizedBox(height: 18.w),
                      Text(
                        'CHOOSE OPTION',
                        style: AppTextStyles.labelSmall(color: _muted).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          height: 15 / 12,
                        ),
                      ),
                      SizedBox(height: 10.w),
                      for (var i = 0; i < _options.length; i++) ...[
                        if (i > 0) SizedBox(height: 8.w),
                        ServicesOptionCard(
                          option: _options[i],
                          selected: _selectedOption == i,
                          onTap: () => setState(() => _selectedOption = i),
                        ),
                      ],
                      SizedBox(height: 18.w),
                      Text(
                        'SELECT SPECIALIST',
                        style: AppTextStyles.labelSmall(color: _muted).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          height: 15 / 12,
                        ),
                      ),
                      SizedBox(height: 10.w),
                      ServicesSpecialistChips(
                        options: _specialists,
                        selected: _selectedSpecialist,
                        onSelected: (v) =>
                            setState(() => _selectedSpecialist = v),
                      ),
                      SizedBox(height: 18.w),
                      Text(
                        'ADD-ONS',
                        style: AppTextStyles.labelSmall(color: _muted).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          height: 15 / 12,
                        ),
                      ),
                      for (var i = 0; i < _addons.length; i++)
                        ServicesAddonRow(
                          addon: _addons[i],
                          checked: _selectedAddons.contains(i),
                          onChanged: (v) => setState(() {
                            if (v) {
                              _selectedAddons.add(i);
                            } else {
                              _selectedAddons.remove(i);
                            }
                          }),
                        ),
                    ],
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 15.w, 20.w, 15.w),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                // Design qty: #F2F7F2 bg, green − / +, black count, 92×46, radius 12
                Container(
                  width: 92.w,
                  height: 46.w,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F7F2),
                    border: Border.all(color: _border),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_quantity > 1) setState(() => _quantity--);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Text(
                              '−',
                              style: TextStyle(
                                color: _green,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                height: 27 / 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '$_quantity',
                        style:
                            AppTextStyles.labelMedium(
                              color: AppColors.textPrimary,
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              height: 19 / 16,
                            ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _quantity++),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Text(
                              '+',
                              style: TextStyle(
                                color: _green,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                height: 27 / 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: _adding ? null : () => _addToBooking(),
                    child: Container(
                      height: 55.w,
                      decoration: BoxDecoration(
                        color: _green,
                        // Design CSS: border-radius 14
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _adding
                            ? 'Adding…'
                            : 'Add to booking · BHD $_displayPrice',
                        style:
                            AppTextStyles.labelMedium(
                              color: AppColors.white,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              height: 19 / 16,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(
        currentIndex: widget.bottomNavIndex,
      ),
    );
  }
}
