import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

final _savedAddressesProvider =
    FutureProvider.autoDispose<List<CustomerAddress>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  if (!storage.hasSession) return Future.value(const []);
  return ref.watch(addressesRepositoryProvider).listCustomerAddresses();
});

class SavedAddressesScreen extends ConsumerStatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  ConsumerState<SavedAddressesScreen> createState() =>
      _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends ConsumerState<SavedAddressesScreen> {
  String? _settingDefaultId;

  Future<void> _setAsDefault(CustomerAddress address) async {
    if (address.isDefault || _settingDefaultId != null) return;
    setState(() => _settingDefaultId = address.id);
    try {
      final res = await ref
          .read(addressesRepositoryProvider)
          .setDefaultAddress(address.id);
      if (!mounted) return;
      if (res.ok) {
        ref.invalidate(_savedAddressesProvider);
        ref.invalidate(userMeProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${address.displayLabel} set as default')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Could not update default')),
        );
      }
    } finally {
      if (mounted) setState(() => _settingDefaultId = null);
    }
  }

  Future<void> _showActions(CustomerAddress address) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!address.isDefault)
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Set as default'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _setAsDefault(address);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Color(0xFF9B111E)),
              title: const Text(
                'Delete address',
                style: TextStyle(color: Color(0xFF9B111E)),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('Delete address?'),
                    content: Text('Remove ${address.displayLabel}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dCtx, false),
                        child: Text(NavigationStrings.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dCtx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF9B111E),
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (ok != true || !mounted) return;
                final res = await ref
                    .read(addressesRepositoryProvider)
                    .deleteAddress(address.id);
                if (!mounted) return;
                if (res.ok) {
                  ref.invalidate(_savedAddressesProvider);
                  ref.invalidate(userMeProvider);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.message ?? 'Could not delete'),
                      backgroundColor: const Color(0xFFB42318),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_savedAddressesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(title: NavigationStrings.savedAddresses),
          Expanded(
            child: async.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (_, _) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(_savedAddressesProvider),
                  child: const Text('Retry'),
                ),
              ),
              data: (addresses) => RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  ref.invalidate(_savedAddressesProvider);
                  await ref.read(_savedAddressesProvider.future);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                  children: [
                    if (addresses.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 14.h, top: 24.h),
                        child: Text(
                          'No saved addresses yet',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelMedium(
                            color: const Color(0xFF6B7B6E),
                          ),
                        ),
                      ),
                    for (var i = 0; i < addresses.length; i++) ...[
                      if (i > 0) SizedBox(height: 14.h),
                      _AddressCard(
                        address: addresses[i],
                        isSettingDefault:
                            _settingDefaultId == addresses[i].id,
                        onTap: () => _setAsDefault(addresses[i]),
                        onEdit: () async {
                          await context.push(
                            '${RouteNames.addAddress}?id=${addresses[i].id}',
                          );
                          ref.invalidate(_savedAddressesProvider);
                          ref.invalidate(userMeProvider);
                        },
                        onLongPress: () => _showActions(addresses[i]),
                      ),
                    ],
                    SizedBox(height: 14.h),
                    GestureDetector(
                      onTap: _settingDefaultId != null
                          ? null
                          : () async {
                              await context.push(RouteNames.addAddress);
                              ref.invalidate(_savedAddressesProvider);
                              ref.invalidate(userMeProvider);
                            },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(13.r),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              size: 18.sp,
                              color: const Color(0xFF2E7D32),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              NavigationStrings.addNewAddress,
                              style: AppTextStyles.labelMedium(
                                color: const Color(0xFF2E7D32),
                              ).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onTap,
    required this.onEdit,
    required this.onLongPress,
    this.isSettingDefault = false,
  });

  final CustomerAddress address;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onLongPress;
  final bool isSettingDefault;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: isSettingDefault ? null : onTap,
        onLongPress: isSettingDefault ? null : onLongPress,
        borderRadius: BorderRadius.circular(14.r),
        child: Ink(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: address.isDefault || isSettingDefault
                  ? AppColors.primary
                  : const Color(0xFFE6EBE3),
              width: address.isDefault || isSettingDefault ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.accountIconBackground,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  address.icon,
                  size: 21.w,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.displayLabel,
                          style: AppTextStyles.labelMedium(
                            color: const Color(0xFF1A1A1A),
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5.sp,
                          ),
                        ),
                        if (address.isDefault) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accountIconBackground,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              NavigationStrings.defaultLabel,
                              style: AppTextStyles.caption(
                                color: const Color(0xFF2E7D32),
                              ).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 9.5.sp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      address.formattedLine,
                      style: AppTextStyles.labelSmall(
                        color: const Color(0xFF6B7B6E),
                      ).copyWith(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSettingDefault)
                SizedBox(
                  width: 32.w,
                  height: 32.w,
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      BoxConstraints.tightFor(width: 32.w, height: 32.w),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18.sp,
                    color: const Color(0xFF6B7B6E),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
