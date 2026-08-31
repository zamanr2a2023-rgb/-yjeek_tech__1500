import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_strings.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/auth/view/widgets/auth_widgets.dart';
import 'package:yjeek_app/features/notifications/service/push_notification_service.dart';
import 'package:yjeek_app/l10n/locale_controller.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/routes/route_names.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  int _activeDot = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    for (var i = 0; i < 3; i++) {
      if (!mounted) return;
      setState(() => _activeDot = i);
      await Future<void>.delayed(const Duration(milliseconds: 700));
    }

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final storage = ref.read(storageServiceProvider);
    if (storage.hasSession) {
      try {
        final me = await ref.read(userRepositoryProvider).fetchMe();
        final lang = me?.profile.language;
        if (lang != null && lang.isNotEmpty) {
          await ref.read(localeControllerProvider.notifier).setLanguage(lang);
        } else {
          await ref
              .read(localeControllerProvider.notifier)
              .ensureTranslationsLoaded(force: true);
        }
      } catch (_) {
        await ref
            .read(localeControllerProvider.notifier)
            .ensureTranslationsLoaded(force: true);
      }
      if (!mounted) return;
      context.goHome();
      PushNotificationService.instance.syncToken();
      PushNotificationService.instance.consumePendingOpen();
    } else {
      await ref
          .read(localeControllerProvider.notifier)
          .ensureTranslationsLoaded(force: true);
      // Stale "logged in" flag without a token causes 401s on /orders and /cart.
      if (storage.isLoggedIn) {
        await storage.clearSession();
      }
      if (!mounted) return;
      context.go(RouteNames.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SizedBox.expand(
        child: Column(
          children: [
            const Spacer(flex: 4),
            const YjeekLogo(),
            const SizedBox(height: 18),
            Text(
              AppStrings.lifestyle,
              style: AppTextStyles.bodyMedium(color: AppColors.lifestyle),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                  child: _Dot(
                    color: index == _activeDot
                        ? AppColors.dotGold
                        : AppColors.white.withValues(alpha: 0.4),
                  ),
                );
              }),
            ),
            const Spacer(flex: 5),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
