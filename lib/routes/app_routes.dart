import 'package:flutter/material.dart';
import 'package:yjeek_app/features/auth/view/otp_verify_screen.dart';
import 'package:yjeek_app/features/auth/view/phone_login_screen.dart';
import 'package:yjeek_app/features/auth/view/splash_screen.dart';
import 'package:yjeek_app/features/auth/view/welcome_screen.dart';
import 'package:yjeek_app/features/auth/view/widgets/checkout_login_sheet.dart';
import 'package:yjeek_app/features/home/view/home_screen.dart';
import 'package:yjeek_app/routes/route_names.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _page(const SplashScreen(), settings);
      case RouteNames.welcome:
        return _page(const WelcomeScreen(), settings);
      case RouteNames.phoneLogin:
        return _page(const PhoneLoginScreen(), settings);
      case RouteNames.otpVerify:
        final phone = settings.arguments as String? ?? '+973 3300 0000';
        return _page(OtpVerifyScreen(phoneNumber: phone), settings);
      case RouteNames.home:
        return _page(const HomeScreen(), settings);
      case RouteNames.checkoutLogin:
        return _page(
          const Scaffold(
            body: BasketPreviewBackground(child: CheckoutLoginSheet()),
          ),
          settings,
        );
      default:
        return _page(const SplashScreen(), settings);
    }
  }

  static MaterialPageRoute<T> _page<T>(Widget child, RouteSettings settings) {
    return MaterialPageRoute<T>(
      settings: settings,
      builder: (_) => child,
    );
  }
}
