import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yjeek_app/core/theme/app_theme.dart';
import 'package:yjeek_app/routes/app_routes.dart';
import 'package:yjeek_app/routes/route_names.dart';

class YjeekApp extends StatelessWidget {
  const YjeekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yjeek',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: RouteNames.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
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
  }
}
