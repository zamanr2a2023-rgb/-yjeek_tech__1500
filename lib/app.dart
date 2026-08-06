import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/theme/app_theme.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/l10n/app_locales.dart';
import 'package:yjeek_app/l10n/locale_controller.dart';
import 'package:yjeek_app/routes/app_router.dart';

final _router = AppRouter.create();

class YjeekApp extends ConsumerWidget {
  const YjeekApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeControllerProvider);

    return ScreenUtilInit(
      designSize: AppDesign.size,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Yjeek',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: localeState.locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
          builder: (context, child) {
            SystemChrome.setSystemUIOverlayStyle(
              const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
            );
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
