import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class IdVerificationScreen extends StatelessWidget {
  const IdVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(
            title: NavigationStrings.idVerification,
            subtitle: NavigationStrings.cprBankDetails,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              children: [
                _VerificationSection(
                  title: NavigationStrings.cprIdCard,
                  badge: NavigationStrings.verified,
                  verified: true,
                  uploadSlots: const ['Front', 'Back'],
                  uploadsVerified: true,
                  fields: const [
                    _FieldData('CPR number', '•••• 8821'),
                    _FieldData('Expiry date', '12 / 2030'),
                  ],
                  note: NavigationStrings.cprExpiryNote,
                ),
                SizedBox(height: 14.h),
                _VerificationSection(
                  title: NavigationStrings.bankIban,
                  badge: NavigationStrings.pending,
                  verified: false,
                  uploadSlots: const ['IBAN certificate — upload'],
                  uploadsVerified: false,
                  fields: const [
                    _FieldData('IBAN number', 'BH•• •••• 4421'),
                    _FieldData('Account name', 'Asmaa Ilsaey'),
                  ],
                ),
                SizedBox(height: 14.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F5E8),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE6E8E6)),
                  ),
                  child: Text(
                    NavigationStrings.idVerificationInfo,
                    style: AppTextStyles.labelSmall(
                      color: const Color(0xFF2E6633),
                    ).copyWith(fontSize: 12.sp, height: 1.25),
                  ),
                ),
                SizedBox(height: 14.h),
                PrimaryGreenButton(
                  label: NavigationStrings.save,
                  height: 48,
                  borderRadius: 14,
                  backgroundColor: const Color(0xFF4DB04F),
                  onPressed: () => context.push(
                    '${RouteNames.withdrawBank}?verified=1',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }
}

class _FieldData {
  const _FieldData(this.label, this.value);
  final String label;
  final String value;
}

class _VerificationSection extends StatelessWidget {
  const _VerificationSection({
    required this.title,
    required this.badge,
    required this.verified,
    required this.uploadSlots,
    required this.uploadsVerified,
    required this.fields,
    this.note,
  });

  final String title;
  final String badge;
  final bool verified;
  final List<String> uploadSlots;
  final bool uploadsVerified;
  final List<_FieldData> fields;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE6E8E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTextStyles.labelMedium(
                  color: const Color(0xFF1A1F1A),
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp),
              ),
              const Spacer(),
              StatusBadge(label: badge, verified: verified),
            ],
          ),
          SizedBox(height: 10.h),
          if (uploadSlots.length == 2)
            Row(
              children: uploadSlots
                  .map(
                    (slot) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: slot == uploadSlots.first ? 10.w : 0,
                        ),
                        child: _UploadBox(
                          label: slot,
                          verified: uploadsVerified,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            _UploadBox(
              label: uploadSlots.first,
              fullWidth: true,
              verified: uploadsVerified,
            ),
          SizedBox(height: 10.h),
          ...fields.map(
            (field) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _KeyValueRow(label: field.label, value: field.value),
            ),
          ),
          if (note != null)
            Text(
              note!,
              style: AppTextStyles.caption(
                color: const Color(0xFF737873),
              ).copyWith(fontSize: 11.sp, height: 1.2),
            ),
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall(
            color: const Color(0xFF737873),
          ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w400),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.labelSmall(
            color: const Color(0xFF1A1F1A),
          ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({
    required this.label,
    this.fullWidth = false,
    required this.verified,
  });

  final String label;
  final bool fullWidth;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final borderColor = verified ? const Color(0xFF4DB04F) : const Color(0xFFBFC4BF);
    final bgColor = verified ? const Color(0xFFE6F5E8) : const Color(0xFFF7F7F7);
    final labelColor = verified ? const Color(0xFF4DB04F) : const Color(0xFF1A1F1A);
    final height = verified ? 67.h : 74.h;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: borderColor,
            radius: 12.r,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (verified)
                Container(
                  width: 22.w,
                  height: 15.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB04F),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '✓',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.photo_camera_outlined,
                  size: 22.sp,
                  color: const Color(0xFF7A7D7A),
                ),
              SizedBox(height: 5.h),
              Text(
                label,
                style: AppTextStyles.caption(color: labelColor).copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final inset = paint.strokeWidth / 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2),
          Radius.circular(radius),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
