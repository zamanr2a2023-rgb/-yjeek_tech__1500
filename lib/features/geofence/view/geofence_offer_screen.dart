import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/geofence/model/geofence_models.dart';
import 'package:yjeek_app/features/geofence/service/geofence_session_controller.dart';
import 'package:yjeek_app/features/geofence/view/home_geofence_offers_section.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class GeofenceOfferScreen extends ConsumerStatefulWidget {
  const GeofenceOfferScreen({
    super.key,
    this.triggerId,
    this.promoCode,
    this.campaignId,
    this.vendorName,
    this.expiresAt,
  });

  final String? triggerId;
  final String? promoCode;
  final String? campaignId;
  final String? vendorName;
  final String? expiresAt;

  @override
  ConsumerState<GeofenceOfferScreen> createState() =>
      _GeofenceOfferScreenState();
}

class _GeofenceOfferScreenState extends ConsumerState<GeofenceOfferScreen> {
  bool _openedSent = false;
  bool _loading = true;
  ActiveGeofenceOffer? _offer;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      final offer = _offer;
      if (offer != null && !offer.isActive) {
        ref.read(activeGeofenceOffersProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _loadOffer();
    await _markOpened();
  }

  Future<void> _loadOffer() async {
    setState(() => _loading = true);
    await ref.read(activeGeofenceOffersProvider.notifier).refresh();
    if (!mounted) return;
    final offers = ref.read(activeGeofenceOffersProvider);
    final trigger = widget.triggerId?.trim() ?? '';
    final campaign = widget.campaignId?.trim() ?? '';
    ActiveGeofenceOffer? matched;
    for (final o in offers) {
      if (trigger.isNotEmpty && o.triggerId == trigger) {
        matched = o;
        break;
      }
      if (campaign.isNotEmpty && o.campaignId == campaign) {
        matched = o;
        break;
      }
    }
    matched ??= offers.isNotEmpty ? offers.first : null;
    setState(() {
      _offer = matched;
      _loading = false;
    });
  }

  Future<void> _markOpened() async {
    final id = (_offer?.triggerId ?? widget.triggerId)?.trim() ?? '';
    if (_openedSent || id.isEmpty) return;
    _openedSent = true;
    await ref.read(geofenceRepositoryProvider).markOpened(id);
  }

  @override
  Widget build(BuildContext context) {
    final offer = _offer;
    final remaining =
        offer?.remainingDuration() ?? Duration.zero;
    final countdown = formatGeofenceCountdown(remaining);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(
            title: 'Geofence offer',
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.home);
              }
            },
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : offer == null || !offer.isActive
                    ? ListView(
                        padding: EdgeInsets.all(20.w),
                        children: [
                          Text(
                            'This offer is no longer available.',
                            style: AppTextStyles.labelMedium(),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => context.go(RouteNames.home),
                            child: const Text('Back to home'),
                          ),
                        ],
                      )
                    : ListView(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: const Color(0xFFE6EBE3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(20.r),
                                      ),
                                      child: Text(
                                        offer.badgeLabel,
                                        style: AppTextStyles.labelSmall(
                                          color: AppColors.white,
                                        ).copyWith(fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        offer.modesLabel,
                                        style: AppTextStyles.labelSmall(
                                          color: AppColors.textSecondary,
                                        ).copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    Text(
                                      countdown,
                                      style: AppTextStyles.labelMedium()
                                          .copyWith(fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  offer.title?.trim().isNotEmpty == true
                                      ? offer.title!.trim()
                                      : offer.notificationTitle ?? 'Nearby offer',
                                  style: AppTextStyles.labelMedium().copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                if (offer.notificationBody != null &&
                                    offer.notificationBody!.trim().isNotEmpty) ...[
                                  SizedBox(height: 8.h),
                                  Text(
                                    offer.notificationBody!,
                                    style: AppTextStyles.labelSmall(
                                      color: AppColors.textSecondary,
                                    ).copyWith(height: 1.4),
                                  ),
                                ],
                                SizedBox(height: 8.h),
                                Text(
                                  'Order within $countdown — discount only from this offer.',
                                  style: AppTextStyles.labelSmall(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Participating stores',
                            style: AppTextStyles.labelMedium()
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 10.h),
                          ...offer.participatingVendors.map(
                            (vendor) => Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: ListTile(
                                onTap: () => startGeofenceVendorOrder(
                                  context,
                                  ref,
                                  offer: offer,
                                  vendor: vendor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  side: const BorderSide(color: Color(0xFFE2E8DD)),
                                ),
                                tileColor: AppColors.white,
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.iconBackground,
                                  backgroundImage: vendor.logoUrl != null &&
                                          vendor.logoUrl!.isNotEmpty
                                      ? NetworkImage(vendor.logoUrl!)
                                      : null,
                                  child: vendor.logoUrl == null ||
                                          vendor.logoUrl!.isEmpty
                                      ? Icon(
                                          Icons.storefront,
                                          color: AppColors.primary,
                                          size: 20.sp,
                                        )
                                      : null,
                                ),
                                title: Text(
                                  vendor.name,
                                  style: AppTextStyles.labelMedium()
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text(offer.badgeLabel),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

/// Builds `/geofence-offer?...` from unlock / push payload fields.
String geofenceOfferLocation({
  String? triggerId,
  String? promoCode,
  String? campaignId,
  String? vendorName,
  String? expiresAt,
}) {
  final params = <String, String>{
    if (triggerId != null && triggerId.isNotEmpty) 'triggerId': triggerId,
    if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
    if (campaignId != null && campaignId.isNotEmpty) 'campaignId': campaignId,
    if (vendorName != null && vendorName.isNotEmpty) 'vendorName': vendorName,
    if (expiresAt != null && expiresAt.isNotEmpty) 'expiresAt': expiresAt,
  };
  if (params.isEmpty) return RouteNames.geofenceOffer;
  final query = params.entries
      .map(
        (e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
      )
      .join('&');
  return '${RouteNames.geofenceOffer}?$query';
}
