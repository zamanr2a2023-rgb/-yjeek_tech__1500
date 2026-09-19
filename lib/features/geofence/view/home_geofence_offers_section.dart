import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/geofence/model/active_geofence_order_context.dart';
import 'package:yjeek_app/features/geofence/model/geofence_models.dart';
import 'package:yjeek_app/features/geofence/service/geofence_session_controller.dart';

/// Starts a geofence-gated order for [vendor] from [offer].
void startGeofenceVendorOrder(
  BuildContext context,
  WidgetRef ref, {
  required ActiveGeofenceOffer offer,
  required GeofenceVendorCard vendor,
}) {
  if (!offer.isActive) {
    ref.read(activeGeofenceOffersProvider.notifier).refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This offer has expired')),
    );
    return;
  }

  final allowed = ActiveGeofenceOrderContext.intersectOrderTypes(
    offer.applicableOrderTypes,
    vendor.orderTypes,
  );
  if (allowed.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No matching order type for this vendor and offer'),
      ),
    );
    return;
  }

  final ctx = ActiveGeofenceOrderContext(
    geofenceTriggerId: offer.triggerId,
    campaignId: offer.campaignId,
    vendorId: vendor.vendorId,
    allowedOrderTypes: allowed,
    expiresAt: offer.expiresAt,
    discountBadge: offer.badgeLabel,
  );
  ref.read(activeGeofenceOrderContextProvider.notifier).state = ctx;

  final cartType = ctx.resolveCartType();
  if (cartType == 'dine_in') {
    context.push(BrowseRoutes.dineInMenu(restaurantId: vendor.vendorId));
  } else if (cartType == 'service') {
    context.push(
      BrowseRoutes.servicesProvider(providerId: vendor.vendorId),
    );
  } else {
    context.push(
      BrowseRoutes.vendorMenu(
        vendorId: vendor.vendorId,
        cartType: cartType,
      ),
    );
  }
}

String formatGeofenceCountdown(Duration remaining) {
  final total = remaining.inSeconds.clamp(0, 24 * 3600);
  final m = (total ~/ 60).toString().padLeft(2, '0');
  final s = (total % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Shows geofence unlocks as a modal popup (not an inline Home section).
class GeofenceOfferPopupHost extends ConsumerStatefulWidget {
  const GeofenceOfferPopupHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GeofenceOfferPopupHost> createState() =>
      _GeofenceOfferPopupHostState();
}

class _GeofenceOfferPopupHostState extends ConsumerState<GeofenceOfferPopupHost> {
  final Set<String> _shownTriggerIds = {};
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(activeGeofenceOffersProvider.notifier).refresh().then((_) {
          if (!mounted) return;
          _maybeShowPopup(ref.read(activeGeofenceOffersProvider));
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<ActiveGeofenceOffer>>(activeGeofenceOffersProvider, (
      prev,
      next,
    ) {
      _maybeShowPopup(next);
    });

    ref.listen<GeofenceEnterResult?>(geofenceLastUnlockProvider, (prev, next) {
      if (next == null || next.alreadyTriggered) return;
      final offers = ref.read(activeGeofenceOffersProvider);
      ActiveGeofenceOffer? match;
      for (final o in offers) {
        if (o.triggerId == next.trigger.id || o.campaignId == next.campaignId) {
          match = o;
          break;
        }
      }
      if (match != null) {
        _shownTriggerIds.remove(match.triggerId);
        _maybeShowPopup([match]);
      }
      ref.read(geofenceLastUnlockProvider.notifier).state = null;
    });

    return widget.child;
  }

  void _maybeShowPopup(List<ActiveGeofenceOffer> offers) {
    if (!mounted || _dialogOpen) return;
    final active = offers.where((o) => o.isActive).toList(growable: false);
    if (active.isEmpty) return;

    ActiveGeofenceOffer? pending;
    for (final o in active) {
      if (!_shownTriggerIds.contains(o.triggerId)) {
        pending = o;
        break;
      }
    }
    if (pending == null) return;

    final offer = pending;
    _shownTriggerIds.add(offer.triggerId);
    _dialogOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        _dialogOpen = false;
        return;
      }
      final hostContext = context;
      await showGeofenceOfferPopup(hostContext, ref, offer: offer);
      if (mounted) _dialogOpen = false;
    });
  }
}

Future<void> showGeofenceOfferPopup(
  BuildContext hostContext,
  WidgetRef ref, {
  required ActiveGeofenceOffer offer,
}) {
  return showDialog<void>(
    context: hostContext,
    barrierDismissible: true,
    builder: (dialogContext) {
      return _GeofenceOfferPopupDialog(
        offer: offer,
        hostContext: hostContext,
      );
    },
  );
}

class _GeofenceOfferPopupDialog extends ConsumerStatefulWidget {
  const _GeofenceOfferPopupDialog({
    required this.offer,
    required this.hostContext,
  });

  final ActiveGeofenceOffer offer;
  final BuildContext hostContext;

  @override
  ConsumerState<_GeofenceOfferPopupDialog> createState() =>
      _GeofenceOfferPopupDialogState();
}

class _GeofenceOfferPopupDialogState
    extends ConsumerState<_GeofenceOfferPopupDialog> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (!widget.offer.isActive) {
        Navigator.of(context).maybePop();
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final remaining = offer.remainingDuration();
    final countdown = formatGeofenceCountdown(remaining);
    final title = offer.title?.trim().isNotEmpty == true
        ? offer.title!.trim()
        : offer.notificationTitle?.trim().isNotEmpty == true
            ? offer.notificationTitle!.trim()
            : 'Nearby offer';
    final body = offer.notificationBody?.trim();

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.78),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nearby offer',
                      style: AppTextStyles.labelMedium().copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8F5E9), Color(0xFFF7FBF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFC8E6C9)),
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
                                  offer.modesLabel.toUpperCase(),
                                  style: AppTextStyles.labelSmall(
                                    color: AppColors.successText,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            title,
                            style: AppTextStyles.labelMedium().copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 17.sp,
                            ),
                          ),
                          if (body != null && body.isNotEmpty) ...[
                            SizedBox(height: 6.h),
                            Text(
                              body,
                              style: AppTextStyles.labelSmall(
                                color: AppColors.textSecondary,
                              ).copyWith(height: 1.35),
                            ),
                          ],
                          SizedBox(height: 10.h),
                          Text(
                            'Order within $countdown',
                            style: AppTextStyles.labelMedium().copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'Participating stores',
                      style: AppTextStyles.labelMedium().copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...offer.participatingVendors.map(
                      (vendor) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Material(
                          color: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            side: const BorderSide(color: Color(0xFFE2E8DD)),
                          ),
                          child: ListTile(
                            onTap: () {
                              final host = widget.hostContext;
                              Navigator.of(context).pop();
                              if (!host.mounted) return;
                              startGeofenceVendorOrder(
                                host,
                                ref,
                                offer: offer,
                                vendor: vendor,
                              );
                            },
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
                              style: AppTextStyles.labelMedium().copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(offer.badgeLabel),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
