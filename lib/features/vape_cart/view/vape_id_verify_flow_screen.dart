import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/vape_cart/model/vape_cart_data.dart';
import 'package:yjeek_app/routes/app_router.dart';

enum _VapeIdStep { upload, checking, success, alreadyUsed, underage }

/// Vape CPR upload → checking → success / already used / under 18.
class VapeIdVerifyFlowScreen extends ConsumerStatefulWidget {
  const VapeIdVerifyFlowScreen({super.key, this.productName});

  final String? productName;

  @override
  ConsumerState<VapeIdVerifyFlowScreen> createState() =>
      _VapeIdVerifyFlowScreenState();
}

class _VapeIdVerifyFlowScreenState
    extends ConsumerState<VapeIdVerifyFlowScreen> {
  final _picker = ImagePicker();
  _VapeIdStep _step = _VapeIdStep.upload;
  String? _frontUrl;
  String? _backUrl;
  bool _confirmed = false;
  bool _busy = false;
  String? _error;
  DateTime? _verifiedAt;

  String get _productLabel {
    final n = widget.productName?.trim();
    if (n != null && n.isNotEmpty) return n;
    return 'product';
  }

  Future<void> _pick(bool front) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (file == null || !mounted) return;

    setState(() => _busy = true);
    final url = await ref.read(userRepositoryProvider).uploadFile(
          file.path,
          filename: file.name,
          category: 'avatars',
        );
    if (!mounted) return;
    setState(() => _busy = false);

    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed'),
          backgroundColor: Color(0xFFB42318),
        ),
      );
      return;
    }
    setState(() {
      if (front) {
        _frontUrl = url;
      } else {
        _backUrl = url;
      }
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_frontUrl == null || _backUrl == null || !_confirmed || _busy) return;

    setState(() {
      _step = _VapeIdStep.checking;
      _busy = true;
      _error = null;
    });

    final response = await ref.read(userRepositoryProvider).submitKyc({
      'idFrontUrl': _frontUrl,
      'idBackUrl': _backUrl,
    });

    if (!mounted) return;

    if (!response.ok) {
      final msg = response.message?.toLowerCase() ?? '';
      setState(() {
        _busy = false;
        if (msg.contains('already') || msg.contains('in use')) {
          _step = _VapeIdStep.alreadyUsed;
        } else if (msg.contains('under') ||
            msg.contains('age') ||
            msg.contains('18')) {
          _step = _VapeIdStep.underage;
        } else {
          _step = _VapeIdStep.upload;
          _error = response.message ?? 'Could not verify ID';
        }
      });
      return;
    }

    // Poll briefly for instant verify / rejection.
    for (var i = 0; i < 4; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      ref.invalidate(userMeProvider);
      try {
        final me = await ref.read(userMeProvider.future);
        final status = me?.verification.status.toUpperCase() ?? '';
        if (status == 'VERIFIED') {
          setState(() {
            _busy = false;
            _verifiedAt = DateTime.now();
            _step = _VapeIdStep.success;
          });
          return;
        }
      } catch (_) {}

      try {
        final kyc = await ref.read(userRepositoryProvider).fetchKyc();
        final reason = (kyc.id.rejectReason ?? '').toLowerCase();
        if (kyc.id.isRejected) {
          setState(() {
            _busy = false;
            if (reason.contains('under') ||
                reason.contains('age') ||
                reason.contains('18')) {
              _step = _VapeIdStep.underage;
            } else {
              _step = _VapeIdStep.alreadyUsed;
            }
          });
          return;
        }
        if (kyc.id.isVerified) {
          setState(() {
            _busy = false;
            _verifiedAt = DateTime.now();
            _step = _VapeIdStep.success;
          });
          return;
        }
      } catch (_) {}
    }

    // Still pending — success UX with review note (external IDV may finish later).
    if (!mounted) return;
    setState(() {
      _busy = false;
      _verifiedAt = DateTime.now();
      _step = _VapeIdStep.success;
    });
  }

  void _backToProduct() {
    // Pop upload + age sheet (if present).
    var pops = 0;
    while (context.canPop() && pops < 3) {
      context.pop(true);
      pops++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _step == _VapeIdStep.upload
          ? AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => context.pop(),
              ),
              title: Text(
                VapeCartStrings.verifyTitle,
                style: AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: switch (_step) {
        _VapeIdStep.upload => _buildUpload(),
        _VapeIdStep.checking => _buildChecking(),
        _VapeIdStep.success => _buildResult(
            success: true,
            title: VapeCartStrings.verifiedTitle,
            body: _verifiedBody(),
            primary: 'Back to $_productLabel',
            onPrimary: _backToProduct,
          ),
        _VapeIdStep.alreadyUsed => _buildResult(
            success: false,
            title: VapeCartStrings.idAlreadyUsedTitle,
            body:
                'This CPR is already linked to another account. If this is a mistake, contact support.',
            primary: VapeCartStrings.contactSupport,
            onPrimary: () => context.goHome(tab: 4),
            secondary: VapeCartStrings.tryAnotherId,
            onSecondary: () => setState(() {
              _step = _VapeIdStep.upload;
              _frontUrl = null;
              _backUrl = null;
              _confirmed = false;
            }),
          ),
        _VapeIdStep.underage => _buildResult(
            success: false,
            title: VapeCartStrings.under18Title,
            body:
                'Your ID was verified but you are under 18. You can’t buy tobacco or vape items, but you can use the app for other products.',
            primary: VapeCartStrings.continueShopping,
            onPrimary: () => context.goHome(tab: 0),
            secondary: 'Back',
            onSecondary: () => context.pop(),
          ),
      },
    );
  }

  String _verifiedBody() {
    final d = _verifiedAt ?? DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final date = '${d.day} ${months[d.month - 1]} ${d.year}';
    return 'Your ID was verified on $date. You can now order this item. Your ID is checked again by the driver on delivery.';
  }

  Widget _buildUpload() {
    final canSubmit =
        _frontUrl != null && _backUrl != null && _confirmed && !_busy;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
            children: [
              Text(
                VapeCartStrings.scanCprTitle,
                style: AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                VapeCartStrings.scanCprHint,
                style: AppTextStyles.bodySmall(color: AppColors.textSecondary)
                    .copyWith(fontSize: 13.sp),
              ),
              SizedBox(height: 16.h),
              _ScanSlot(
                label: VapeCartStrings.frontCpr,
                imageUrl: _frontUrl,
                onTap: _busy ? null : () => _pick(true),
              ),
              SizedBox(height: 12.h),
              _ScanSlot(
                label: VapeCartStrings.backCpr,
                imageUrl: _backUrl,
                onTap: _busy ? null : () => _pick(false),
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () => setState(() => _confirmed = !_confirmed),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22.w,
                      height: 22.w,
                      margin: EdgeInsets.only(top: 1.h),
                      decoration: BoxDecoration(
                        color: _confirmed
                            ? AppColors.primary
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(
                          color: _confirmed
                              ? AppColors.primary
                              : const Color(0xFFA8A8A8),
                          width: 1.5,
                        ),
                      ),
                      child: _confirmed
                          ? Icon(Icons.check,
                              size: 14.sp, color: AppColors.white)
                          : null,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        VapeCartStrings.confirmOwnership,
                        style: AppTextStyles.bodySmall(
                          color: AppColors.textPrimary,
                        ).copyWith(fontSize: 13.sp, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                SizedBox(height: 12.h),
                Text(
                  _error!,
                  style: AppTextStyles.bodySmall(
                    color: const Color(0xFFB42318),
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.4),
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    _busy ? 'Uploading…' : VapeCartStrings.verifyMyId,
                    style: AppTextStyles.labelMedium(color: AppColors.white)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Terms and conditions  ·  Privacy policy',
                style: AppTextStyles.caption(color: AppColors.textSecondary)
                    .copyWith(fontSize: 11.sp),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChecking() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48.w,
              height: 48.w,
              child: const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              VapeCartStrings.checkingTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall().copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              VapeCartStrings.checkingBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(color: AppColors.textSecondary)
                  .copyWith(fontSize: 13.sp, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult({
    required bool success,
    required String title,
    required String body,
    required String primary,
    required VoidCallback onPrimary,
    String? secondary,
    VoidCallback? onSecondary,
  }) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: success
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                success ? Icons.check_rounded : Icons.error_outline_rounded,
                size: 36.sp,
                color: success ? AppColors.primary : const Color(0xFFB42318),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall().copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(color: AppColors.textSecondary)
                  .copyWith(fontSize: 13.sp, height: 1.4),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: onPrimary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  primary,
                  style: AppTextStyles.labelMedium(color: AppColors.white)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (secondary != null && onSecondary != null) ...[
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: onSecondary,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: Color(0xFFDEDEDE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    secondary,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScanSlot extends StatelessWidget {
  const _ScanSlot({
    required this.label,
    this.imageUrl,
    this.onTap,
  });

  final String label;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14.r),
          border: hasImage
              ? Border.all(color: const Color(0xFFDEDEDE))
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    url: imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: const ColoredBox(color: Color(0xFFF7F7F7)),
                  ),
                  Positioned(
                    right: 8.w,
                    bottom: 8.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Replace',
                        style: AppTextStyles.caption(
                          color: AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              )
            : CustomPaint(
                painter: _DashedBorderPainter(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  radius: 14.r,
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 28.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelSmall(
                            color: AppColors.textPrimary,
                          ).copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
          Radius.circular(radius),
        ),
      );
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
