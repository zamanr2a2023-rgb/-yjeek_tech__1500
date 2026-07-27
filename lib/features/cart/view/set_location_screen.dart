import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/model/locations_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Default pin near Manama / Seef when device GPS is unavailable.
const _defaultLat = 26.2361;
const _defaultLng = 50.5358;

class SetLocationScreen extends ConsumerStatefulWidget {
  const SetLocationScreen({super.key});

  @override
  ConsumerState<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends ConsumerState<SetLocationScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  ReverseGeocodeResult? _location;
  List<LocationSuggestion> _suggestions = const [];
  bool _loading = true;
  bool _searching = false;
  double _lat = _defaultLat;
  double _lng = _defaultLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reverse());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reverse() async {
    setState(() => _loading = true);
    final result = await ref.read(locationsRepositoryProvider).reverse(
          lat: _lat,
          lng: _lng,
        );
    if (!mounted) return;
    setState(() {
      _location = result;
      _loading = false;
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      if (value.trim().isEmpty) {
        setState(() => _suggestions = const []);
        return;
      }
      setState(() => _searching = true);
      final results =
          await ref.read(locationsRepositoryProvider).search(value);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _searching = false;
      });
    });
  }

  Future<void> _selectSuggestion(LocationSuggestion suggestion) async {
    ReverseGeocodeResult? details;
    if (suggestion.latitude != null && suggestion.longitude != null) {
      _lat = suggestion.latitude!;
      _lng = suggestion.longitude!;
      details = await ref.read(locationsRepositoryProvider).reverse(
            lat: _lat,
            lng: _lng,
          );
    } else {
      details = await ref
          .read(locationsRepositoryProvider)
          .placeDetails(suggestion.id);
      if (details?.latitude != null) _lat = details!.latitude!;
      if (details?.longitude != null) _lng = details!.longitude!;
    }
    if (!mounted) return;
    setState(() {
      _location = details ??
          ReverseGeocodeResult(
            label: suggestion.title,
            area: suggestion.subtitle,
            latitude: _lat,
            longitude: _lng,
          );
      _suggestions = const [];
      _searchController.text = suggestion.title;
    });
  }

  Future<void> _confirm() async {
    final loc = _location;
    if (loc == null) {
      context.pop();
      return;
    }
    // Open add-address with detected area prefilled via query when possible.
    final area = Uri.encodeQueryComponent(loc.area ?? loc.label);
    await context.push('${RouteNames.addAddress}?area=$area');
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final title = _location?.label ?? CartFlowData.detectedLocation;
    final detail = [
      if (_location?.area != null && _location!.area!.isNotEmpty)
        _location!.area,
      if (_location?.road != null && _location!.road!.isNotEmpty)
        'Road ${_location!.road}',
      if (_location?.block != null && _location!.block!.isNotEmpty)
        'Block ${_location!.block}',
    ].whereType<String>().join(' · ');

    return CartFlowScaffold(
      title: CartFlowStrings.setYourLocation,
      subtitle: CartFlowStrings.moveMapPin,
      lightHeader: true,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
        child: Column(
          children: [
            Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE0E6E0)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 18.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: CartFlowStrings.searchAreaHint,
                        hintStyle: AppTextStyles.bodySmall(
                          color: AppColors.textSecondary,
                        ).copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 13.sp,
                        ),
                      ),
                      style: AppTextStyles.bodySmall(
                        color: AppColors.textPrimary,
                      ).copyWith(fontSize: 13.sp),
                    ),
                  ),
                  if (_searching)
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            if (_suggestions.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                constraints: BoxConstraints(maxHeight: 160.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE0E6E0)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Color(0xFFE0E6E0)),
                  itemBuilder: (_, i) {
                    final s = _suggestions[i];
                    return ListTile(
                      dense: true,
                      title: Text(s.title),
                      subtitle: s.subtitle == null ? null : Text(s.subtitle!),
                      onTap: () => _selectSuggestion(s),
                    );
                  },
                ),
              ),
            ],
            SizedBox(height: 14.h),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1E0D4),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  if (_loading)
                    const CircularProgressIndicator(color: AppColors.primary)
                  else
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: const BoxDecoration(
                        color: AppColors.cartTabActive,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.location_on,
                        color: const Color(0xFFE53935),
                        size: 22.sp,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE0E6E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CartFlowStrings.detectedLocationLabel,
                    style: AppTextStyles.labelSmall(
                      color: AppColors.textSecondary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                      letterSpacing: 0.44,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE3F2EB),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.location_on,
                          color: const Color(0xFFE53935),
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.labelMedium(
                                color: AppColors.textPrimary,
                              ).copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              detail.isEmpty
                                  ? CartFlowData.detectedLocationDetail
                                  : detail,
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
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: PrimaryGreenButton(
                  label: CartFlowStrings.confirmLocation,
                  backgroundColor: AppColors.cartTabActive,
                  height: 54,
                  enabled: !_loading,
                  onPressed: _confirm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
