import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/country_flag_icon.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class CountryRegionScreen extends StatefulWidget {
  const CountryRegionScreen({super.key});

  @override
  State<CountryRegionScreen> createState() => _CountryRegionScreenState();
}

class _CountryRegionScreenState extends State<CountryRegionScreen> {
  late String _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = WalletData.countries
        .firstWhere((country) => country.selected, orElse: () => WalletData.countries.first)
        .name;
  }

  @override
  Widget build(BuildContext context) {
    final countries = WalletData.countries;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(title: NavigationStrings.countryRegionTitle),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 6.h, bottom: 24.h),
              children: [
                for (var i = 0; i < countries.length; i++) ...[
                  _CountryRow(
                    country: countries[i],
                    selected: countries[i].name == _selectedCountry,
                    onTap: () => setState(() => _selectedCountry = countries[i].name),
                  ),
                  if (i < countries.length - 1)
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
  });

  final CountryOption country;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
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
