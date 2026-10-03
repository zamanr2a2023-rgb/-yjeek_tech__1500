import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/maps_config.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/services/location_service.dart';
import 'package:yjeek_app/features/location/model/customer_delivery_location.dart';
import 'package:yjeek_app/features/location/provider/delivery_location_provider.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_google_map.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/model/locations_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class SetLocationScreen extends ConsumerStatefulWidget {
  const SetLocationScreen({super.key});

  @override
  ConsumerState<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends ConsumerState<SetLocationScreen>
    with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  final _locationService = const LocationService();
  Timer? _debounce;
  ReverseGeocodeResult? _location;
  List<LocationSuggestion> _suggestions = const [];
  bool _loading = true;
  bool _searching = false;
  bool _saving = false;
  bool _pinMovedByUser = false;
  bool _hasFix = false;
  bool _askingLocation = false;
  LocationPermissionOutcome? _locationBlock;
  double _lat = MapsConfig.defaultLat;
  double _lng = MapsConfig.defaultLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrentLocation());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (_hasFix || _pinMovedByUser) return;
    unawaited(_loadCurrentLocation(prompt: false));
  }

  Future<void> _loadCurrentLocation({bool prompt = true}) async {
    if (_pinMovedByUser) return;
    setState(() => _loading = true);
    final outcome = await _locationService.requestPermission();
    if (!mounted || _pinMovedByUser) return;
    if (outcome != LocationPermissionOutcome.granted) {
      setState(() {
        _loading = false;
        _locationBlock = outcome;
        _location = null;
      });
      if (prompt) await _askToEnableLocation(outcome);
      return;
    }

    final position = await _locationService.readCurrentFix();
    if (!mounted || _pinMovedByUser) return;
    if (position == null) {
      setState(() {
        _loading = false;
        _locationBlock = LocationPermissionOutcome.serviceDisabled;
        _location = null;
      });
      if (prompt) {
        await _askToEnableLocation(LocationPermissionOutcome.serviceDisabled);
      }
      return;
    }

    setState(() {
      _lat = position.lat;
      _lng = position.lng;
      _hasFix = true;
      _locationBlock = null;
    });
    await _reverse();
  }

  String _locationBlockMessage(LocationPermissionOutcome outcome) {
    return switch (outcome) {
      LocationPermissionOutcome.serviceDisabled =>
        'Turn on location to see your current position.',
      LocationPermissionOutcome.deniedForever =>
        'Location permission is blocked. Enable it in Settings.',
      LocationPermissionOutcome.denied =>
        'Allow location access to drop the pin on your current position.',
      LocationPermissionOutcome.granted =>
        'Turn on location to see your current position.',
    };
  }

  Future<void> _askToEnableLocation(LocationPermissionOutcome outcome) async {
    if (_askingLocation || !mounted) return;
    _askingLocation = true;
    final openSettings = outcome == LocationPermissionOutcome.serviceDisabled ||
        outcome == LocationPermissionOutcome.deniedForever;
    final enable = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Turn on location'),
        content: Text(_locationBlockMessage(outcome)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(openSettings ? 'Turn on' : 'Allow'),
          ),
        ],
      ),
    );
    _askingLocation = false;
    if (enable != true || !mounted) return;
    if (outcome == LocationPermissionOutcome.serviceDisabled) {
      await _locationService.openLocationSettings();
    } else if (outcome == LocationPermissionOutcome.deniedForever) {
      await _locationService.openAppSettings();
    } else {
      await _loadCurrentLocation(prompt: false);
    }
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

  void _onCameraIdle(LatLng target) {
    if (!_hasFix && !_pinMovedByUser) return;
    final moved =
        (target.latitude - _lat).abs() > 0.00005 ||
        (target.longitude - _lng).abs() > 0.00005;
    if (!moved) return;
    _pinMovedByUser = true;
    _hasFix = true;
    _lat = target.latitude;
    _lng = target.longitude;
    _reverse();
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
      _hasFix = true;
      _pinMovedByUser = true;
      _locationBlock = null;
      _location = details ??
          ReverseGeocodeResult(
            label: suggestion.title,
            area: suggestion.subtitle,
            latitude: _lat,
            longitude: _lng,
          );
      _suggestions = const [];
      _searchController.text = suggestion.title;
      _loading = false;
    });
  }

  Future<void> _confirm() async {
    if (!_hasFix && !_pinMovedByUser) {
      await _loadCurrentLocation();
      return;
    }
    final loc = _location;
    final storage = ref.read(storageServiceProvider);
    final title = loc?.label ?? CartFlowData.detectedLocation;
    final detail = [
      if (loc?.area != null && loc!.area!.isNotEmpty) loc.area,
      if (loc?.road != null && loc!.road!.isNotEmpty) loc.road,
    ].whereType<String>().join(' · ');

    await storage.saveDeliveryLocationCache(
      kind: CustomerDeliveryLocationKind.detected.name,
      latitude: _lat,
      longitude: _lng,
      displayTitle: title,
      displaySubtitle: detail.isEmpty ? null : detail,
    );

    if (!storage.hasSession) {
      await ref.read(deliveryLocationProvider.notifier).refresh(force: true);
      if (mounted) context.pop(true);
      return;
    }

    final area = (loc?.area != null && loc!.area!.trim().isNotEmpty)
        ? loc.area!.trim()
        : (loc?.label.trim().isNotEmpty == true ? loc!.label.trim() : title);
    final road = loc?.road?.trim() ?? '';
    final block = loc?.block?.trim() ?? '';
    if (area.isNotEmpty && road.isNotEmpty && block.isNotEmpty) {
      setState(() => _saving = true);
      final response = await ref.read(addressesRepositoryProvider).createAddress({
        'label': 'HOME',
        'area': area,
        'block': block,
        'road': road,
        'city': (loc?.city != null && loc!.city!.trim().isNotEmpty)
            ? loc.city!.trim()
            : 'Manama',
        'isDefault': true,
        'latitude': _lat,
        'longitude': _lng,
      });
      if (!mounted) return;
      setState(() => _saving = false);
      if (response.ok) {
        ref.invalidate(deliveryLocationProvider);
        await ref.read(deliveryLocationProvider.notifier).refresh(force: true);
        if (mounted) context.pop(true);
        return;
      }
    }

    final params = <String, String>{
      'lat': _lat.toStringAsFixed(6),
      'lng': _lng.toStringAsFixed(6),
      if (area.isNotEmpty) 'area': area,
      if (road.isNotEmpty) 'road': road,
      if (block.isNotEmpty) 'block': block,
    };
    final query = params.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');
    await context.push('${RouteNames.addAddress}?$query');
    if (mounted) context.pop(true);
  }

  Widget _locationPromptPanel() {
    final outcome = _locationBlock ?? LocationPermissionOutcome.serviceDisabled;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE0E6E0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            color: AppColors.primary,
            size: 36.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            _locationBlockMessage(outcome),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(color: AppColors.textPrimary)
                .copyWith(fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          PrimaryGreenButton(
            label: outcome == LocationPermissionOutcome.denied
                ? 'Allow location'
                : 'Turn on location',
            backgroundColor: AppColors.cartTabActive,
            height: 48,
            onPressed: () => _askToEnableLocation(outcome),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _location?.label ??
        (_loading
            ? 'Finding your location…'
            : _hasFix
                ? 'Current location'
                : 'Turn on location');
    final blocked = _locationBlock != null && !_hasFix && !_pinMovedByUser;
    final detail = blocked
        ? _locationBlockMessage(_locationBlock!)
        : [
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
              child: _hasFix || _pinMovedByUser
                  ? AppMapPicker(
                      latitude: _lat,
                      longitude: _lng,
                      onCameraIdle: _onCameraIdle,
                    )
                  : _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _locationPromptPanel(),
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
                              _loading ? 'Updating…' : title,
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
                  enabled: !_loading &&
                      !_saving &&
                      (_hasFix || _pinMovedByUser),
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
