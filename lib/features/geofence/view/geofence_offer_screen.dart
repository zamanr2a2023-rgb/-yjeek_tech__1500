import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/geofence/service/geofence_session_controller.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markOpened());
  }

  Future<void> _markOpened() async {
    final id = widget.triggerId?.trim() ?? '';
    if (_openedSent || id.isEmpty) return;
    _openedSent = true;
    await ref.read(geofenceRepositoryProvider).markOpened(id);
  }

  String get _expiryLabel {
    final raw = widget.expiresAt?.trim();
    if (raw == null || raw.isEmpty) return '';
    final at = DateTime.tryParse(raw)?.toLocal();
    if (at == null) return '';
    final h = at.hour.toString().padLeft(2, '0');
    final m = at.minute.toString().padLeft(2, '0');
    return 'Expires $h:$m';
  }

  Future<void> _copyCode() async {
    final code = widget.promoCode?.trim() ?? '';
    if (code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied $code')),
    );
  }

  void _useInCart() {
    final code = widget.promoCode?.trim() ?? '';
    if (code.isNotEmpty) {
      ref.read(pendingGeofencePromoProvider.notifier).state = code;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer unlocked — apply $code in cart'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    ref.read(shellProvider.notifier).setTab(2);
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.promoCode?.trim() ?? '';
    final vendor = widget.vendorName?.trim().isNotEmpty == true
        ? widget.vendorName!.trim()
        : 'Nearby store';

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
            child: ListView(
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
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.local_offer_outlined,
                              color: AppColors.primary,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vendor,
                                  style: AppTextStyles.labelMedium().copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                if (_expiryLabel.isNotEmpty) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    _expiryLabel,
                                    style: AppTextStyles.labelSmall(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'Promo code',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.textSecondary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: code.isEmpty ? null : _copyCode,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7F2),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFD8E3D4)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  code.isEmpty ? '—' : code,
                                  style: AppTextStyles.labelMedium().copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ),
                              if (code.isNotEmpty)
                                Icon(
                                  Icons.copy_rounded,
                                  size: 20.sp,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'You unlocked this offer by being near the store. Apply it in your cart before it expires.',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.textSecondary,
                        ).copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: code.isEmpty ? null : _useInCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: const Color(0xFFB7C4B5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Use in cart',
                      style: AppTextStyles.labelMedium(
                        color: AppColors.white,
                      ).copyWith(fontWeight: FontWeight.w700),
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
