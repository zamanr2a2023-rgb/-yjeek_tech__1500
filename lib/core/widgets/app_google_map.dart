import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/maps_config.dart';
import 'package:yjeek_app/core/utils/responsive.dart';

/// Interactive map with a fixed center pin (move map to drop pin).
class AppMapPicker extends StatefulWidget {
  const AppMapPicker({
    super.key,
    required this.latitude,
    required this.longitude,
    this.onCameraIdle,
    this.borderRadius,
  });

  final double latitude;
  final double longitude;
  final ValueChanged<LatLng>? onCameraIdle;
  final BorderRadius? borderRadius;

  @override
  State<AppMapPicker> createState() => _AppMapPickerState();
}

class _AppMapPickerState extends State<AppMapPicker> {
  GoogleMapController? _controller;
  LatLng? _cameraTarget;
  bool _ready = false;
  bool _failed = false;
  bool _programmaticMove = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted || _ready || _failed) return;
      setState(() {
        _failed = true;
        _ready = true;
      });
    });
  }

  @override
  void didUpdateWidget(covariant AppMapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.latitude - widget.latitude).abs() > 0.00001 ||
        (oldWidget.longitude - widget.longitude).abs() > 0.00001) {
      _programmaticMove = true;
      _controller?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.latitude, widget.longitude),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(16.r);
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasSize = constraints.maxWidth.isFinite &&
            constraints.maxHeight.isFinite &&
            constraints.maxWidth > 0 &&
            constraints.maxHeight > 0;

        if (!hasSize) {
          return ClipRRect(
            borderRadius: radius,
            child: AppStaticMapImage(
              latitude: widget.latitude,
              longitude: widget.longitude,
              height: 220.h,
            ),
          );
        }

        return ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_failed)
                  AppStaticMapImage(
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                    height: constraints.maxHeight,
                  )
                else
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.latitude, widget.longitude),
                      zoom: MapsConfig.defaultZoom,
                    ),
                    onMapCreated: (controller) {
                      _controller = controller;
                      if (mounted) setState(() => _ready = true);
                    },
                    onCameraMove: (position) {
                      _cameraTarget = position.target;
                    },
                    onCameraIdle: () {
                      if (_programmaticMove) {
                        _programmaticMove = false;
                        return;
                      }
                      final target = _cameraTarget;
                      if (target == null || widget.onCameraIdle == null) {
                        return;
                      }
                      widget.onCameraIdle!(target);
                    },
                    gestureRecognizers:
                        <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                if (!_ready && !_failed)
                  const ColoredBox(
                    color: Color(0xFFD1E0D4),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: const BoxDecoration(
                        color: AppColors.cartTabActive,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.location_on,
                        color: const Color(0xFFE53935),
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Interactive live tracking map (driver + optional drop-off).
class AppLiveTrackingMap extends StatefulWidget {
  const AppLiveTrackingMap({
    super.key,
    required this.driverLatitude,
    required this.driverLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.height,
    this.borderRadius,
  });

  final double driverLatitude;
  final double driverLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  State<AppLiveTrackingMap> createState() => _AppLiveTrackingMapState();
}

class _AppLiveTrackingMapState extends State<AppLiveTrackingMap> {
  GoogleMapController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (!mounted || _ready || _failed) return;
      setState(() {
        _failed = true;
        _ready = true;
      });
    });
  }

  @override
  void didUpdateWidget(covariant AppLiveTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final moved =
        (oldWidget.driverLatitude - widget.driverLatitude).abs() > 0.00005 ||
            (oldWidget.driverLongitude - widget.driverLongitude).abs() > 0.00005;
    if (moved) {
      _controller?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.driverLatitude, widget.driverLongitude),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Set<Marker> get _markers {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(widget.driverLatitude, widget.driverLongitude),
        infoWindow: const InfoWindow(title: 'Champ'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };
    final dLat = widget.dropoffLatitude;
    final dLng = widget.dropoffLongitude;
    if (dLat != null && dLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(dLat, dLng),
          infoWindow: const InfoWindow(title: 'Delivery'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final h = heightOrDefault;
    final radius = widget.borderRadius ?? BorderRadius.circular(16.r);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_failed)
              AppStaticMapImage(
                latitude: widget.driverLatitude,
                longitude: widget.driverLongitude,
                height: h,
              )
            else
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.driverLatitude,
                    widget.driverLongitude,
                  ),
                  zoom: MapsConfig.defaultZoom,
                ),
                markers: _markers,
                onMapCreated: (controller) {
                  _controller = controller;
                  if (mounted) setState(() => _ready = true);
                },
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                liteModeEnabled: false,
              ),
            if (!_ready && !_failed)
              const ColoredBox(
                color: Color(0xFFD1E0D4),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double get heightOrDefault => widget.height ?? 196.h;
}

/// Non-interactive map preview — uses Static Maps (reliable inside ListViews).
class AppMapPreview extends StatelessWidget {
  const AppMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height,
    this.borderRadius,
  });

  final double latitude;
  final double longitude;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final h = height ?? 180.h;
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        height: h,
        width: double.infinity,
        child: AppStaticMapImage(
          latitude: latitude,
          longitude: longitude,
          height: h,
        ),
      ),
    );
  }
}

/// Google Static Maps image — no PlatformView, works in scrollable checkout.
class AppStaticMapImage extends StatelessWidget {
  const AppStaticMapImage({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height,
  });

  final double latitude;
  final double longitude;
  final double? height;

  String _url(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 2.0);
    final logicalW = MediaQuery.sizeOf(context).width;
    final w = (logicalW * dpr).round().clamp(200, 640);
    final h = ((height ?? 180) * dpr).round().clamp(120, 640);
    return MapsConfig.staticMapUrl(
      latitude: latitude,
      longitude: longitude,
      width: w,
      height: h,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _url(context),
      fit: BoxFit.cover,
      width: double.infinity,
      height: height,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return ColoredBox(
          color: const Color(0xFFD1E0D4),
          child: SizedBox(
            height: height,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => ColoredBox(
        color: const Color(0xFFD1E0D4),
        child: SizedBox(
          height: height,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map_outlined,
                  color: AppColors.cartTabActive,
                  size: 28.sp,
                ),
                SizedBox(height: 6.h),
                Text(
                  'Map unavailable',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
