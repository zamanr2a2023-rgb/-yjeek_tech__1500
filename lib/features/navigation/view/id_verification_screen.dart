import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/kyc_models.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class IdVerificationScreen extends ConsumerStatefulWidget {
  const IdVerificationScreen({super.key});

  @override
  ConsumerState<IdVerificationScreen> createState() =>
      _IdVerificationScreenState();
}

class _IdVerificationScreenState extends ConsumerState<IdVerificationScreen> {
  bool _loading = true;
  bool _saving = false;
  KycStatus _kyc = KycStatus.empty;

  final _cprController = TextEditingController();
  final _ibanController = TextEditingController();
  final _accountController = TextEditingController();

  String? _idFrontUrl;
  String? _idBackUrl;
  String? _ibanCertUrl;
  DateTime? _cprExpiry;
  bool _cprDirty = false;
  bool _ibanDirty = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _cprController.dispose();
    _ibanController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final kyc = await ref.read(userRepositoryProvider).fetchKyc();
      if (!mounted) return;
      _hydrate(kyc);
      setState(() {
        _kyc = kyc;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _hydrate(KycStatus kyc) {
    _idFrontUrl = kyc.id.frontUrl;
    _idBackUrl = kyc.id.backUrl;
    _ibanCertUrl = kyc.bank.certificateUrl;
    _cprExpiry = kyc.id.cprExpiry;
    _cprDirty = false;
    _ibanDirty = false;
    // Masked CPR from API — leave blank for re-entry unless user already typed.
    if (!_cprDirty) _cprController.text = '';
    if (!_ibanDirty) {
      _ibanController.text = '';
      _accountController.text = kyc.bank.accountName ?? '';
    }
  }

  String _formatExpiry(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.month.toString().padLeft(2, '0')} / ${dt.year}';
  }

  String _displayCpr() {
    if (_cprController.text.trim().isNotEmpty) {
      final digits = _cprController.text.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 4) return '•••• ${digits.substring(digits.length - 4)}';
      return digits;
    }
    final masked = _kyc.id.cprNumber;
    if (masked == null || masked.isEmpty) return '—';
    // API: •••••8821 → UI: •••• 8821
    final digits = masked.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) return '•••• ${digits.substring(digits.length - 4)}';
    return masked;
  }

  String _displayIban() {
    if (_ibanController.text.trim().isNotEmpty) {
      final raw = _ibanController.text.replaceAll(' ', '').toUpperCase();
      if (raw.length >= 6) {
        return '${raw.substring(0, 2)}•• •••• ${raw.substring(raw.length - 4)}';
      }
      return raw;
    }
    return _kyc.bank.ibanMasked ?? '—';
  }

  Future<void> _pickUpload({
    required Future<void> Function(String url) onUploaded,
  }) async {
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

    final url = await ref.read(userRepositoryProvider).uploadFile(
          file.path,
          filename: file.name,
          // Prefer documents once backend allows CUSTOMER; avatars is allowed today.
          category: 'avatars',
        );
    if (!mounted) return;
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed'),
          backgroundColor: Color(0xFFB42318),
        ),
      );
      return;
    }
    await onUploaded(url);
    if (mounted) setState(() {});
  }

  Future<void> _editCprFields() async {
    final cprCtrl = TextEditingController(text: _cprController.text);
    DateTime? pickedExpiry = _cprExpiry;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'CPR details',
                    style: AppTextStyles.titleSmall().copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cprCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                    decoration: const InputDecoration(
                      labelText: 'CPR number (9 digits)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final selected = await showDatePicker(
                        context: ctx,
                        initialDate: pickedExpiry ?? DateTime(now.year + 5),
                        firstDate: now,
                        lastDate: DateTime(now.year + 30),
                      );
                      if (selected != null) {
                        setModal(() => pickedExpiry = selected);
                      }
                    },
                    child: Text(
                      pickedExpiry == null
                          ? 'Pick expiry date'
                          : 'Expiry: ${_formatExpiry(pickedExpiry)}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Done'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    if (ok == true) {
      setState(() {
        _cprController.text = cprCtrl.text.trim();
        _cprExpiry = pickedExpiry;
        _cprDirty = true;
      });
    }
    cprCtrl.dispose();
  }

  Future<void> _editBankFields() async {
    final ibanCtrl = TextEditingController(text: _ibanController.text);
    final nameCtrl = TextEditingController(text: _accountController.text);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bank details',
                style: AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ibanCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'IBAN number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Account name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
    if (ok == true) {
      setState(() {
        _ibanController.text = ibanCtrl.text.trim();
        _accountController.text = nameCtrl.text.trim();
        _ibanDirty = true;
      });
    }
    ibanCtrl.dispose();
    nameCtrl.dispose();
  }

  Future<void> _save() async {
    final body = <String, dynamic>{};

    if (_idFrontUrl != null &&
        _idFrontUrl!.isNotEmpty &&
        _idFrontUrl != _kyc.id.frontUrl) {
      body['idFrontUrl'] = _idFrontUrl;
    }
    if (_idBackUrl != null &&
        _idBackUrl!.isNotEmpty &&
        _idBackUrl != _kyc.id.backUrl) {
      body['idBackUrl'] = _idBackUrl;
    }
    if (_ibanCertUrl != null &&
        _ibanCertUrl!.isNotEmpty &&
        _ibanCertUrl != _kyc.bank.certificateUrl) {
      body['ibanCertificateUrl'] = _ibanCertUrl;
    }

    final cprDigits = _cprController.text.replaceAll(RegExp(r'\D'), '');
    if (cprDigits.length == 9) {
      body['cprNumber'] = cprDigits;
    }
    if (_cprExpiry != null && (_cprDirty || body.containsKey('cprNumber'))) {
      body['cprExpiry'] = _cprExpiry!.toUtc().toIso8601String();
    }

    final iban = _ibanController.text.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    if (iban.length >= 8) body['iban'] = iban;
    final account = _accountController.text.trim();
    if (account.length >= 2) body['accountName'] = account;

    // First-time: if docs present but never submitted fields, include existing URLs.
    if (body.isEmpty) {
      if (_idFrontUrl != null && _idFrontUrl!.isNotEmpty) {
        body['idFrontUrl'] = _idFrontUrl;
      }
      if (_idBackUrl != null && _idBackUrl!.isNotEmpty) {
        body['idBackUrl'] = _idBackUrl;
      }
      if (_ibanCertUrl != null && _ibanCertUrl!.isNotEmpty) {
        body['ibanCertificateUrl'] = _ibanCertUrl;
      }
      if (cprDigits.length == 9) body['cprNumber'] = cprDigits;
      if (_cprExpiry != null) {
        body['cprExpiry'] = _cprExpiry!.toUtc().toIso8601String();
      }
      if (iban.length >= 8) body['iban'] = iban;
      if (account.length >= 2) body['accountName'] = account;
    }

    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add CPR/bank details or upload documents')),
      );
      return;
    }

    setState(() => _saving = true);
    final response = await ref.read(userRepositoryProvider).submitKyc(body);
    if (!mounted) return;
    setState(() => _saving = false);

    if (response.ok) {
      ref.invalidate(userMeProvider);
      ref.invalidate(walletSnapshotProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message ?? 'Submitted for review',
          ),
        ),
      );
      if (context.canPop()) {
        context.pop();
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? 'Could not save verification'),
        backgroundColor: const Color(0xFFB42318),
      ),
    );
  }

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
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                    children: [
                      _VerificationSection(
                        title: NavigationStrings.cprIdCard,
                        badge: _kyc.id.badgeLabel,
                        verified: _kyc.id.isVerified,
                        pending: _kyc.id.isPending,
                        uploadSlots: [
                          _UploadSlot(
                            label: 'Front',
                            hasFile: _idFrontUrl != null && _idFrontUrl!.isNotEmpty,
                            onTap: _kyc.id.isVerified
                                ? null
                                : () => _pickUpload(
                                      onUploaded: (url) async {
                                        _idFrontUrl = url;
                                      },
                                    ),
                          ),
                          _UploadSlot(
                            label: 'Back',
                            hasFile: _idBackUrl != null && _idBackUrl!.isNotEmpty,
                            onTap: _kyc.id.isVerified
                                ? null
                                : () => _pickUpload(
                                      onUploaded: (url) async {
                                        _idBackUrl = url;
                                      },
                                    ),
                          ),
                        ],
                        fields: [
                          _FieldData('CPR number', _displayCpr()),
                          _FieldData('Expiry date', _formatExpiry(_cprExpiry)),
                        ],
                        note: NavigationStrings.cprExpiryNote,
                        onEditFields:
                            _kyc.id.isVerified ? null : _editCprFields,
                      ),
                      SizedBox(height: 14.h),
                      _VerificationSection(
                        title: NavigationStrings.bankIban,
                        badge: _kyc.bank.badgeLabel,
                        verified: _kyc.bank.isVerified,
                        pending: _kyc.bank.isPending,
                        uploadSlots: [
                          _UploadSlot(
                            label: 'IBAN certificate — upload',
                            hasFile:
                                _ibanCertUrl != null && _ibanCertUrl!.isNotEmpty,
                            fullWidth: true,
                            onTap: _kyc.bank.isVerified
                                ? null
                                : () => _pickUpload(
                                      onUploaded: (url) async {
                                        _ibanCertUrl = url;
                                      },
                                    ),
                          ),
                        ],
                        fields: [
                          _FieldData('IBAN number', _displayIban()),
                          _FieldData(
                            'Account name',
                            _accountController.text.trim().isNotEmpty
                                ? _accountController.text.trim()
                                : (_kyc.bank.accountName ?? '—'),
                          ),
                        ],
                        onEditFields:
                            _kyc.bank.isVerified ? null : _editBankFields,
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
                        label: _saving ? 'Saving…' : NavigationStrings.save,
                        height: 48,
                        borderRadius: 14,
                        backgroundColor: const Color(0xFF4DB04F),
                        enabled: !_saving,
                        onPressed: _saving ? null : _save,
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

class _UploadSlot {
  const _UploadSlot({
    required this.label,
    required this.hasFile,
    this.fullWidth = false,
    this.onTap,
  });

  final String label;
  final bool hasFile;
  final bool fullWidth;
  final VoidCallback? onTap;
}

class _VerificationSection extends StatelessWidget {
  const _VerificationSection({
    required this.title,
    required this.badge,
    required this.verified,
    required this.pending,
    required this.uploadSlots,
    required this.fields,
    this.note,
    this.onEditFields,
  });

  final String title;
  final String badge;
  final bool verified;
  final bool pending;
  final List<_UploadSlot> uploadSlots;
  final List<_FieldData> fields;
  final String? note;
  final VoidCallback? onEditFields;

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
              StatusBadge(
                label: badge,
                verified: verified,
                pending: pending,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (uploadSlots.length == 2)
            Row(
              children: [
                for (var i = 0; i < uploadSlots.length; i++) ...[
                  if (i > 0) SizedBox(width: 10.w),
                  Expanded(
                    child: _UploadBox(slot: uploadSlots[i]),
                  ),
                ],
              ],
            )
          else
            _UploadBox(slot: uploadSlots.first),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: onEditFields,
            child: Column(
              children: [
                for (final field in fields)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: _KeyValueRow(
                      label: field.label,
                      value: field.value,
                      editable: onEditFields != null,
                    ),
                  ),
              ],
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
  const _KeyValueRow({
    required this.label,
    required this.value,
    this.editable = false,
  });

  final String label;
  final String value;
  final bool editable;

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
        if (editable) ...[
          SizedBox(width: 4.w),
          Icon(Icons.edit_outlined, size: 14.sp, color: const Color(0xFF737873)),
        ],
      ],
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.slot});

  final _UploadSlot slot;

  @override
  Widget build(BuildContext context) {
    final verified = slot.hasFile;
    final borderColor =
        verified ? const Color(0xFF4DB04F) : const Color(0xFFBFC4BF);
    final bgColor =
        verified ? const Color(0xFFE6F5E8) : const Color(0xFFF7F7F7);
    final labelColor =
        verified ? const Color(0xFF4DB04F) : const Color(0xFF1A1F1A);
    final height = verified ? 67.h : 74.h;

    return GestureDetector(
      onTap: slot.onTap,
      child: SizedBox(
        width: slot.fullWidth ? double.infinity : null,
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
                  slot.label,
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
          Rect.fromLTWH(
            inset,
            inset,
            size.width - inset * 2,
            size.height - inset * 2,
          ),
          Radius.circular(radius),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
