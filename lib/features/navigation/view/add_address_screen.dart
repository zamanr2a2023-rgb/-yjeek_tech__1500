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

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key, this.addressId, this.initialArea});

  final String? addressId;
  final String? initialArea;

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  String _selectedLabel = 'Home';
  bool _setDefault = true;
  bool _loading = false;
  bool _saving = false;

  final _areaController = TextEditingController();
  final _blockController = TextEditingController();
  final _roadController = TextEditingController();
  final _buildingController = TextEditingController();
  final _flatController = TextEditingController();
  final _noteController = TextEditingController();

  static const _labelOptions = <(String, IconData)>[
    ('Home', Icons.home_outlined),
    ('Work', Icons.work_outline),
    ('Other', Icons.location_on_outlined),
  ];

  bool get _isEdit =>
      widget.addressId != null && widget.addressId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final area = widget.initialArea?.trim();
    if (area != null && area.isNotEmpty) {
      _areaController.text = area;
    }
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  @override
  void dispose() {
    _areaController.dispose();
    _blockController.dispose();
    _roadController.dispose();
    _buildingController.dispose();
    _flatController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() => _loading = true);
    try {
      final address = await ref
          .read(addressesRepositoryProvider)
          .getAddress(widget.addressId!);
      if (!mounted || address == null) {
        setState(() => _loading = false);
        return;
      }
      setState(() {
        _selectedLabel = address.displayLabel == 'Home' ||
                address.displayLabel == 'Work'
            ? address.displayLabel
            : 'Other';
        _setDefault = address.isDefault;
        _areaController.text = address.area ?? '';
        _blockController.text = address.block ?? '';
        _roadController.text = address.road ?? '';
        _buildingController.text = address.building ?? '';
        _flatController.text = address.flat ?? '';
        _noteController.text = address.additionalDirections ?? '';
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final area = _areaController.text.trim();
    final block = _blockController.text.trim();
    final road = _roadController.text.trim();
    final building = _buildingController.text.trim();
    final flat = _flatController.text.trim();
    final note = _noteController.text.trim();

    if (block.isEmpty || road.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Block and Road are required')),
      );
      return;
    }
    if (area.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Area is required')),
      );
      return;
    }

    final body = <String, dynamic>{
      'label': CustomerAddress.apiLabelFromUi(_selectedLabel),
      'area': area,
      'block': block,
      'road': road,
      'city': 'Manama',
      'isDefault': _setDefault,
      if (building.isNotEmpty) 'building': building,
      if (flat.isNotEmpty) 'flat': flat,
      if (note.isNotEmpty) 'additionalDirections': note,
      if (note.toLowerCase().contains('leave at the door') ||
          note.toLowerCase().contains('leave at door'))
        'dropOffPreferences': ['LEAVE_AT_DOOR'],
    };

    setState(() => _saving = true);
    final repo = ref.read(addressesRepositoryProvider);
    final response = _isEdit
        ? await repo.updateAddress(widget.addressId!, body)
        : await repo.createAddress(body);
    if (!mounted) return;
    setState(() => _saving = false);

    if (response.ok) {
      ref.invalidate(userMeProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message ??
                (_isEdit ? 'Address updated' : 'Address saved'),
          ),
        ),
      );
      if (context.canPop()) context.pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? 'Could not save address'),
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
            title: _isEdit ? 'Edit address' : NavigationStrings.addAddress,
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const _AddressMapPreview(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              NavigationStrings.addressLabel,
                              style: AppTextStyles.labelSmall(
                                color: const Color(0xFF6B7B6E),
                              ).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 7.h),
                            Row(
                              children: [
                                for (var i = 0;
                                    i < _labelOptions.length;
                                    i++) ...[
                                  if (i > 0) SizedBox(width: 8.w),
                                  Expanded(
                                    child: _AddressLabelChip(
                                      label: _labelOptions[i].$1,
                                      icon: _labelOptions[i].$2,
                                      selected: _selectedLabel ==
                                          _labelOptions[i].$1,
                                      onTap: () => setState(
                                        () => _selectedLabel =
                                            _labelOptions[i].$1,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 14.h),
                            Row(
                              children: [
                                Expanded(
                                  child: AccountFormField(
                                    label: NavigationStrings.area,
                                    controller: _areaController,
                                    readOnly: false,
                                    hintText: 'Seef',
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: AccountFormField(
                                    label: NavigationStrings.block,
                                    controller: _blockController,
                                    readOnly: false,
                                    hintText: '428',
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: AccountFormField(
                                    label: NavigationStrings.road,
                                    controller: _roadController,
                                    readOnly: false,
                                    hintText: '6000',
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: AccountFormField(
                                    label: NavigationStrings.building,
                                    controller: _buildingController,
                                    readOnly: false,
                                    hintText: '23',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            AccountFormField(
                              label: NavigationStrings.flatOptional,
                              controller: _flatController,
                              readOnly: false,
                              hintText: '82',
                            ),
                            SizedBox(height: 12.h),
                            AccountFormField(
                              label: NavigationStrings.deliveryNoteOptional,
                              controller: _noteController,
                              readOnly: false,
                              hintText: 'Leave at the door',
                            ),
                            SizedBox(height: 14.h),
                            Container(
                              width: double.infinity,
                              height: 52.h,
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFFE6EBE3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      NavigationStrings.setDefaultAddress,
                                      style: AppTextStyles.labelMedium(
                                        color: const Color(0xFF1A1A1A),
                                      ).copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Switch.adaptive(
                                    value: _setDefault,
                                    onChanged: (v) =>
                                        setState(() => _setDefault = v),
                                    activeTrackColor: const Color(0xFF4CAF50),
                                    activeThumbColor: AppColors.white,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 14.h),
                            PrimaryGreenButton(
                              label: _saving
                                  ? 'Saving…'
                                  : NavigationStrings.saveAddress,
                              icon: Icons.check,
                              borderRadius: 13,
                              height: 49,
                              backgroundColor: const Color(0xFF4CAF50),
                              enabled: !_saving,
                              onPressed: _saving ? null : _save,
                            ),
                          ],
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

class _AddressMapPreview extends StatelessWidget {
  const _AddressMapPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180.h,
      color: const Color(0xFFE4EAE0),
      alignment: Alignment.center,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.location_on, size: 22.sp, color: AppColors.white),
      ),
    );
  }
}

class _AddressLabelChip extends StatelessWidget {
  const _AddressLabelChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.white : const Color(0xFF6B7B6E);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36.h,
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4CAF50) : AppColors.white,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(
            color:
                selected ? const Color(0xFF4CAF50) : const Color(0xFFE6EBE3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: fg),
            SizedBox(width: 7.w),
            Text(
              label,
              style: AppTextStyles.labelSmall(color: fg).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
