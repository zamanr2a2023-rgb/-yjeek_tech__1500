import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class ChangeAddressScreen extends ConsumerStatefulWidget {
  const ChangeAddressScreen({super.key});

  @override
  ConsumerState<ChangeAddressScreen> createState() =>
      _ChangeAddressScreenState();
}

class _ChangeAddressScreenState extends ConsumerState<ChangeAddressScreen> {
  List<DeliveryAddressSnapshot> _snapshots = const [];
  List<CartDeliveryAddress> _addresses = const [];
  String? _selectedId;
  String? _vendorId;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final addresses =
        await ref.read(addressesRepositoryProvider).listAddresses();
    final cart = await ref
        .read(cartRepositoryProvider)
        .fetchCart(CartOrderType.delivery);
    if (!mounted) return;
    DeliveryAddressSnapshot? preferred;
    for (final a in addresses) {
      if (a.isDefault) {
        preferred = a;
        break;
      }
    }
    preferred ??= addresses.isEmpty ? null : addresses.first;
    final selectedId = _selectedId ?? preferred?.id;
    final mapped = addresses
        .map((a) => a.toCartAddress(selected: a.id == selectedId))
        .toList();
    setState(() {
      _snapshots = addresses;
      _addresses = mapped;
      _selectedId = selectedId;
      _vendorId = cart.vendorId;
      _loading = false;
    });
  }

  Future<void> _deliverHere() async {
    final selectedId = _selectedId;
    if (selectedId == null || _submitting) return;
    setState(() => _submitting = true);
    final repo = ref.read(addressesRepositoryProvider);
    await repo.setDefaultAddress(selectedId);
    final vendorId = _vendorId;
    if (vendorId != null && vendorId.isNotEmpty) {
      final inRange = await repo.checkInRange(
        vendorId: vendorId,
        addressId: selectedId,
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      if (!inRange) {
        DeliveryAddressSnapshot? snap;
        for (final a in _snapshots) {
          if (a.id == selectedId) {
            snap = a;
            break;
          }
        }
        final params = <String, String>{
          'id': selectedId,
          if (snap?.latitude != null) 'lat': '${snap!.latitude}',
          if (snap?.longitude != null) 'lng': '${snap!.longitude}',
        };
        final q = params.entries
            .map(
              (e) =>
                  '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
            )
            .join('&');
        context.push('${CartRoutes.outOfDelivery}?$q');
        return;
      }
    } else if (mounted) {
      setState(() => _submitting = false);
    }
    if (!mounted) return;
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: CartFlowStrings.deliveryAddress,
      subtitle: CartFlowStrings.chooseWhereToDeliver,
      lightHeader: true,
      onBack: () {
        if (context.canPop()) context.pop();
      },
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () => context.push(CartRoutes.setLocation),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFE0E6E0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE3F2EB),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: const Color(0xFFE53935),
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  CartFlowStrings.useCurrentLocation,
                                  style: AppTextStyles.labelMedium(
                                    color: AppColors.textPrimary,
                                  ).copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  CartFlowStrings.detectGpsLocation,
                                  style: AppTextStyles.labelSmall(
                                    color: AppColors.textSecondary,
                                  ).copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                            size: 22.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    CartFlowStrings.savedAddresses,
                    style: AppTextStyles.titleSmall(
                      color: AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  if (_addresses.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Text(
                        'No saved addresses yet',
                        style: AppTextStyles.labelMedium(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  for (final address in _addresses)
                    CartAddressRadioTile(
                      address: address,
                      selected: address.id == _selectedId,
                      onTap: () => setState(() => _selectedId = address.id),
                      onEdit: () async {
                        await context.push(
                          '${RouteNames.addAddress}?id=${address.id}',
                        );
                        await _load();
                      },
                    ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () async {
                      await context.push(RouteNames.addAddress);
                      await _load();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.cartTabActive,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: const Color(0xFF127036),
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Add new address',
                            style: AppTextStyles.labelMedium(
                              color: const Color(0xFF127036),
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  PrimaryGreenButton(
                    label: _submitting
                        ? 'Checking…'
                        : CartFlowStrings.deliverHere,
                    backgroundColor: AppColors.cartTabActive,
                    height: 54,
                    enabled: !_submitting,
                    onPressed: _deliverHere,
                  ),
                ],
              ),
            ),
    );
  }
}
