import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/theme/app_theme.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/routes/app_router.dart';

final _router = AppRouter.create();

class YjeekApp extends ConsumerWidget {
  const YjeekApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: AppDesign.size,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Yjeek',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
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
