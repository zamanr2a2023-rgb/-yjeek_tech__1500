import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/maps_config.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_google_map.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class OutOfDeliveryScreen extends ConsumerStatefulWidget {
  const OutOfDeliveryScreen({
    super.key,
    this.addressId,
    this.latitude,
    this.longitude,
  });

  final String? addressId;
  final double? latitude;
  final double? longitude;

  @override
  ConsumerState<OutOfDeliveryScreen> createState() =>
      _OutOfDeliveryScreenState();
}

class _OutOfDeliveryScreenState extends ConsumerState<OutOfDeliveryScreen> {
  double _lat = MapsConfig.defaultLat;
  double _lng = MapsConfig.defaultLng;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _lat = widget.latitude ?? MapsConfig.defaultLat;
    _lng = widget.longitude ?? MapsConfig.defaultLng;
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    final id = widget.addressId;
    if (id == null || id.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final address =
        await ref.read(addressesRepositoryProvider).getAddress(id);
    if (!mounted) return;
    setState(() {
      if (address?.latitude != null) _lat = address!.latitude!;
      if (address?.longitude != null) _lng = address!.longitude!;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GreenScreenHeader(title: CartFlowStrings.deliveryAddress),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: _loading
                        ? const ColoredBox(
                            color: Color(0xFFF5E6D3),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              return AppMapPreview(
                                latitude: _lat,
                                longitude: _lng,
                                height: constraints.maxHeight,
                                borderRadius: BorderRadius.circular(16.r),
                              );
                            },
                          ),
                  ),
                  // Soft wash so the warning card stays readable.
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      child: CartFlowCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF3CD),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: const Color(0xFFE6A700),
                                size: 26.sp,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              CartFlowStrings.outOfRangeTitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.titleSmall().copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 17.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              CartFlowStrings.outOfRangeBody,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall(
                                color: AppColors.textSecondary,
                              ).copyWith(
                                fontSize: 13.sp,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: PrimaryGreenButton(
                label: CartFlowStrings.chooseAnotherAddress,
                onPressed: () => context.go(CartRoutes.changeAddress),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 2),
    );
  }
}
