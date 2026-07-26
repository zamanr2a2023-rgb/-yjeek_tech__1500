import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/vape_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/vape_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class VapeBrowseScreen extends ConsumerStatefulWidget {
  const VapeBrowseScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  ConsumerState<VapeBrowseScreen> createState() => _VapeBrowseScreenState();
}

class _VapeBrowseScreenState extends ConsumerState<VapeBrowseScreen> {
  List<VapeStore> _stores = const [];
  bool _loading = true;
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final stores = await ref
          .read(vapeVendorsRepositoryProvider)
          .fetchStores(query: _query);
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stores = const [];
        _loading = false;
      });
    }
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrowseTopBar(
                  title: VapeData.homeTitle,
                  onCart: () => context.goHome(tab: 2),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
                  child: const VapeAgeBanner(),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: BrowseSearchBar(
                    hint: VapeData.searchHint,
                    value: _query,
                    autofocus: false,
                    onChanged: _onQueryChanged,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
                  child: Text(
                    VapeData.storesSectionTitle,
                    style: AppTextStyles.titleSmall().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_stores.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No vape stores found',
                  style: AppTextStyles.bodyMedium(
                    color: const Color(0xFF737873),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              sliver: SliverList.separated(
                itemCount: _stores.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final store = _stores[index];
                  return VapeStoreListCard(
                    store: store,
                    onTap: () => context.push(
                      BrowseRoutes.vapeStore(storeId: store.id),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
