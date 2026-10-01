import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';

class MarketingOptInTile extends ConsumerStatefulWidget {
  const MarketingOptInTile({super.key, required this.initialValue});

  final bool initialValue;

  @override
  ConsumerState<MarketingOptInTile> createState() => _MarketingOptInTileState();
}

class _MarketingOptInTileState extends ConsumerState<MarketingOptInTile> {
  late bool _value;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  Future<void> _onChanged(bool next) async {
    setState(() {
      _value = next;
      _saving = true;
    });
    final res = await ref.read(userRepositoryProvider).updateProfile({
      'marketingOptIn': next,
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (!res.ok) {
      setState(() => _value = !next);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? 'Could not update preference')),
      );
      return;
    }
    ref.invalidate(userMeProvider);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        'Marketing notifications',
        style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
            .copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Offers, rewards reminders, and promotions. Order updates always stay on.',
        style: AppTextStyles.labelSmall(color: AppColors.textSecondary),
      ),
      value: _value,
      onChanged: _saving ? null : _onChanged,
    );
  }
}
