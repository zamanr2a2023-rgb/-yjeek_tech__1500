import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/user_repository.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/country_flag_icon.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class CountryRegionScreen extends ConsumerStatefulWidget {
  const CountryRegionScreen({super.key});

  @override
  ConsumerState<CountryRegionScreen> createState() =>
      _CountryRegionScreenState();
}

class _CountryRegionScreenState extends ConsumerState<CountryRegionScreen> {
  bool _loading = true;
  bool _saving = false;
  List<DeliveryCountry> _countries = DeliveryCountry.fallback;
  String _selectedCode = 'BH';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(userRepositoryProvider);
      final countries = await repo.fetchDeliveryCountries();
      final me = await repo.fetchMe();
      if (!mounted) return;
      setState(() {
        _countries = countries;
        _selectedCode = (me?.profile.country ?? 'BH').toUpperCase();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _select(DeliveryCountry country) async {
    if (_saving || country.code == _selectedCode) return;
    if (!country.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${country.name} is not available yet')),
      );
      return;
    }

    setState(() {
      _saving = true;
      _selectedCode = country.code;
    });

    final response = await ref.read(userRepositoryProvider).updateProfile({
      'country': country.code,
    });
    if (!mounted) return;
    setState(() => _saving = false);

    if (response.ok) {
      ref.invalidate(userMeProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delivery country set to ${country.name}')),
      );
      if (context.canPop()) context.pop();
      return;
    }

    // Revert selection on failure.
    final me = ref.read(userMeProvider).valueOrNull;
    setState(() {
      _selectedCode = (me?.profile.country ?? 'BH').toUpperCase();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? 'Could not update country'),
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
          GreenScreenHeader(title: NavigationStrings.countryRegionTitle),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: EdgeInsets.only(top: 6.h, bottom: 24.h),
                    children: [
                      for (var i = 0; i < _countries.length; i++) ...[
                        _CountryRow(
                          country: _countries[i],
                          selected: _countries[i].code == _selectedCode,
                          enabled: !_saving,
                          onTap: () => _select(_countries[i]),
                        ),
                        if (i < _countries.length - 1)
                          const Divider(height: 1, color: Color(0xFFE8E8E8)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }
}

class _CountryRow extends StatelessWidget {
  const _CountryRow({
    required this.country,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final DeliveryCountry country;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: EdgeInsets.fromLTRB(22.w, 15.h, 24.w, 15.h),
          child: Row(
            children: [
              CountryFlagIcon(countryName: country.name),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  country.name,
                  style: AppTextStyles.bodyMedium(
                    color: const Color(0xFF1F2121),
                  ).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                    height: 1.2,
                  ),
                ),
              ),
              if (selected) const _CountrySelectedBadge(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountrySelectedBadge extends StatelessWidget {
  const _CountrySelectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26.w,
      height: 26.w,
      decoration: const BoxDecoration(
        color: Color(0xFFF58C1A),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '✓',
        style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
          height: 1,
        ),
      ),
    );
  }
}
