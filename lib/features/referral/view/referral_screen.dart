import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/referral/model/referral_models.dart';

class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  final _phoneController = TextEditingController();
  ReferralMe? _me;
  List<ReferralInviteRow> _invites = const [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(referralRepositoryProvider);
      final me = await repo.fetchMe();
      final invites = await repo.fetchInvites();
      if (!mounted) return;
      setState(() {
        _me = me;
        _invites = invites;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _invite() async {
    final me = _me;
    if (me == null || !me.programmeEnabled) return;
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      final result =
          await ref.read(referralRepositoryProvider).sendInvite(phone: phone);
      if (!mounted) return;
      await _load();
      await _openShare(result.share);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _openShare(ReferralSharePayload share) async {
    final wa = share.whatsAppText?.trim();
    if (wa != null && wa.isNotEmpty) {
      final uri = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(wa)}',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    final sms = share.smsBody?.trim();
    if (sms != null && sms.isNotEmpty) {
      final uri = Uri(scheme: 'sms', queryParameters: {'body': sms});
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = _me;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const NavBackHeader(
            title: 'Invite a friend',
            backIconColor: AppColors.textPrimary,
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                    children: [
                      if (me != null) ...[
                        Text(
                          'You earn BHD ${me.inviterRewardAmount} · They earn BHD ${me.inviteeRewardAmount}',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Invites left today: ${me.remainingDay} · this month: ${me.remainingMonth}',
                          style: AppTextStyles.labelSmall(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Friend\'s phone (local digits)',
                            border: OutlineInputBorder(),
                          ),
                          enabled: me.programmeEnabled && me.remainingDay > 0,
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: me.programmeEnabled && !_sending ? _invite : null,
                            child: _sending
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Invite & share'),
                          ),
                        ),
                        if (!me.programmeEnabled)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              'Referral programme is not available right now.',
                              style: AppTextStyles.labelSmall(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                      SizedBox(height: 24.h),
                      Text(
                        'Your invites',
                        style: AppTextStyles.labelMedium(
                          color: AppColors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 10.h),
                      if (_invites.isEmpty)
                        Text(
                          'No invites yet',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        ..._invites.map(_inviteTile),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _inviteTile(ReferralInviteRow row) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(row.phone, style: AppTextStyles.labelMedium()),
          SizedBox(height: 4.h),
          Text(
            row.status,
            style: AppTextStyles.labelSmall(color: AppColors.primary),
          ),
          if (row.status.toUpperCase() == 'REJECTED' &&
              row.reason != null &&
              row.reason!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              row.reason!,
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
