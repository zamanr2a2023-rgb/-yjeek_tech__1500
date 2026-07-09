import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/features/auth/view/otp_verify_screen.dart';
import 'package:yjeek_app/features/auth/view/phone_login_screen.dart';
import 'package:yjeek_app/features/auth/view/splash_screen.dart';
import 'package:yjeek_app/features/auth/view/welcome_screen.dart';
import 'package:yjeek_app/features/auth/view/widgets/checkout_login_sheet.dart';
import 'package:yjeek_app/features/home/view/categories_screen.dart';
import 'package:yjeek_app/features/home/view/main_shell.dart';
import 'package:yjeek_app/features/navigation/view/about_policies_screen.dart';
import 'package:yjeek_app/features/navigation/view/about_yjeek_screen.dart';
import 'package:yjeek_app/features/navigation/view/add_address_screen.dart';
import 'package:yjeek_app/features/navigation/view/cashback_screen.dart';
import 'package:yjeek_app/features/navigation/view/country_region_screen.dart';
import 'package:yjeek_app/features/navigation/view/edit_personal_info_screen.dart';
import 'package:yjeek_app/features/navigation/view/edit_profile_screen.dart';
import 'package:yjeek_app/features/navigation/view/exclusive_offers_screen.dart';
import 'package:yjeek_app/features/navigation/view/id_verification_screen.dart';
import 'package:yjeek_app/features/navigation/view/language_screen.dart';
import 'package:yjeek_app/features/navigation/view/order_details_screen.dart';
import 'package:yjeek_app/features/navigation/view/personal_info_screen.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/help/view/help_issue_screen.dart';
import 'package:yjeek_app/features/help/view/help_support_screen.dart';
import 'package:yjeek_app/features/help/view/order_help_screen.dart';
import 'package:yjeek_app/features/navigation/view/policy_document_screen.dart';
import 'package:yjeek_app/features/navigation/view/refunds_credits_screen.dart';
import 'package:yjeek_app/features/navigation/view/saved_addresses_screen.dart';
import 'package:yjeek_app/features/navigation/view/wallet_screen.dart';
import 'package:yjeek_app/features/navigation/view/withdraw_bank_screen.dart';
import 'package:yjeek_app/routes/route_names.dart';

class AppRouter {
  static GoRouter create() {
    return GoRouter(
      initialLocation: RouteNames.splash,
      routes: [
        GoRoute(
          path: RouteNames.splash,
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: RouteNames.welcome,
          builder: (_, _) => const WelcomeScreen(),
        ),
        GoRoute(
          path: RouteNames.phoneLogin,
          builder: (_, _) => const PhoneLoginScreen(),
        ),
        GoRoute(
          path: RouteNames.otpVerify,
          builder: (context, state) {
            final phone = state.uri.queryParameters['phone'] ?? '+973 3300 0000';
            return OtpVerifyScreen(phoneNumber: phone);
          },
        ),
        GoRoute(
          path: RouteNames.home,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            final cart = state.uri.queryParameters['cart'] == '1';
            return MainShell(initialIndex: tab, cartHasItems: cart);
          },
        ),
        GoRoute(
          path: RouteNames.categories,
          builder: (_, _) => const CategoriesScreen(),
        ),
        GoRoute(
          path: RouteNames.exclusiveOffers,
          builder: (_, _) => const ExclusiveOffersScreen(),
        ),
        GoRoute(
          path: RouteNames.orderDetails,
          builder: (_, state) {
            final orderId = state.uri.queryParameters['id'];
            return OrderDetailsScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: RouteNames.wallet,
          builder: (_, _) => const WalletScreen(),
        ),
        GoRoute(
          path: RouteNames.walletCashback,
          builder: (_, _) => const CashbackScreen(),
        ),
        GoRoute(
          path: RouteNames.walletRefunds,
          builder: (_, _) => const RefundsCreditsScreen(),
        ),
        GoRoute(
          path: RouteNames.withdrawBank,
          builder: (_, state) {
            final verified = state.uri.queryParameters['verified'] == '1';
            return WithdrawBankScreen(verified: verified);
          },
        ),
        GoRoute(
          path: RouteNames.editProfile,
          builder: (_, _) => const EditProfileScreen(),
        ),
        GoRoute(
          path: RouteNames.personalInfo,
          builder: (_, _) => const PersonalInfoScreen(),
        ),
        GoRoute(
          path: RouteNames.editPersonalInfo,
          builder: (_, _) => const EditPersonalInfoScreen(),
        ),
        GoRoute(
          path: RouteNames.savedAddresses,
          builder: (_, _) => const SavedAddressesScreen(),
        ),
        GoRoute(
          path: RouteNames.addAddress,
          builder: (_, _) => const AddAddressScreen(),
        ),
        GoRoute(
          path: RouteNames.language,
          builder: (_, _) => const LanguageScreen(),
        ),
        GoRoute(
          path: RouteNames.countryRegion,
          builder: (_, _) => const CountryRegionScreen(),
        ),
        GoRoute(
          path: RouteNames.idVerification,
          builder: (_, _) => const IdVerificationScreen(),
        ),
        GoRoute(
          path: RouteNames.aboutPolicies,
          builder: (_, _) => const AboutPoliciesScreen(),
        ),
        GoRoute(
          path: RouteNames.aboutYjeek,
          builder: (_, _) => const AboutYjeekScreen(),
        ),
        GoRoute(
          path: RouteNames.policyDocument,
          builder: (_, state) {
            final type = PolicyTypeX.fromQuery(state.uri.queryParameters['type']);
            return PolicyDocumentScreen(type: type);
          },
        ),
        GoRoute(
          path: RouteNames.helpSupport,
          builder: (_, _) => const HelpSupportScreen(),
        ),
        GoRoute(
          path: RouteNames.orderHelp,
          builder: (_, state) {
            final orderId =
                state.uri.queryParameters['orderId'] ?? HelpData.defaultOrderId;
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return OrderHelpScreen(orderId: orderId, bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.helpIssue,
          builder: (_, state) {
            final type = HelpIssueTypeX.fromQuery(state.uri.queryParameters['type']);
            final orderId =
                state.uri.queryParameters['orderId'] ?? HelpData.defaultOrderId;
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return HelpIssueScreen(
              type: type,
              orderId: orderId,
              bottomNavIndex: tab,
            );
          },
        ),
        GoRoute(
          path: RouteNames.checkoutLogin,
          builder: (_, _) => const Scaffold(
            body: BasketPreviewBackground(child: CheckoutLoginSheet()),
          ),
        ),
      ],
    );
  }
}

extension AppNavigation on BuildContext {
  void goHome({int tab = 0, bool cartHasItems = false}) {
    go(
      '${RouteNames.home}?tab=$tab${cartHasItems ? '&cart=1' : ''}',
    );
  }
}
