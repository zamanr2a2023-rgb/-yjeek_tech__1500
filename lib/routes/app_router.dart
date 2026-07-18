import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/features/auth/view/otp_verify_screen.dart';
import 'package:yjeek_app/features/auth/view/phone_login_screen.dart';
import 'package:yjeek_app/features/auth/view/splash_screen.dart';
import 'package:yjeek_app/features/auth/view/welcome_screen.dart';
import 'package:yjeek_app/features/auth/view/widgets/checkout_login_sheet.dart';
import 'package:yjeek_app/features/browse/view/dine_in_browse_screen.dart';
import 'package:yjeek_app/features/browse/view/dine_in_item_detail_screen.dart';
import 'package:yjeek_app/features/browse/view/dine_in_menu_screen.dart';
import 'package:yjeek_app/features/browse/view/dine_in_order_again_screen.dart';
import 'package:yjeek_app/features/browse/view/services_browse_screen.dart';
import 'package:yjeek_app/features/browse/view/services_category_screen.dart';
import 'package:yjeek_app/features/browse/view/services_item_detail_screen.dart';
import 'package:yjeek_app/features/browse/view/services_provider_screen.dart';
import 'package:yjeek_app/features/browse/view/electronics_browse_screen.dart';
import 'package:yjeek_app/features/browse/view/electronics_product_detail_screen.dart';
import 'package:yjeek_app/features/browse/view/electronics_store_screen.dart';
import 'package:yjeek_app/features/home/view/home_screen.dart';
import 'package:yjeek_app/features/vape_cart/view/vape_age_verify_screen.dart';
import 'package:yjeek_app/features/vape_cart/view/vape_checkout_screen.dart';
import 'package:yjeek_app/features/vape_cart/view/vape_review_screen.dart';
import 'package:yjeek_app/features/vape_order_flow/view/vape_confirmed_screen.dart';
import 'package:yjeek_app/features/vape_order_flow/view/vape_pay_screen.dart';
import 'package:yjeek_app/features/vape_order_flow/view/vape_receipt_screen.dart';
import 'package:yjeek_app/features/vape_order_flow/view/vape_status_screen.dart';
import 'package:yjeek_app/features/vape_order_flow/view/vape_waiting_screen.dart';
import 'package:yjeek_app/features/browse/view/pickup_browse_screen.dart';
import 'package:yjeek_app/features/browse/view/pickup_categories_screen.dart';
import 'package:yjeek_app/features/pickup_cart/view/pickup_checkout_screen.dart';
import 'package:yjeek_app/features/pickup_cart/view/pickup_review_screen.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/pickup_confirmed_screen.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/pickup_pay_screen.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/pickup_receipt_screen.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/pickup_status_screen.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/pickup_waiting_screen.dart';
import 'package:yjeek_app/features/browse/view/vape_browse_screen.dart';
import 'package:yjeek_app/features/browse/view/vape_product_detail_screen.dart';
import 'package:yjeek_app/features/browse/view/vape_store_screen.dart';
import 'package:yjeek_app/features/browse/view/food_browse_screen.dart';
import 'package:yjeek_app/features/browse/view/food_search_screen.dart';
import 'package:yjeek_app/features/browse/view/item_detail_screen.dart';
import 'package:yjeek_app/features/browse/view/vendor_menu_screen.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/cart/view/cart_add_address_screen.dart';
import 'package:yjeek_app/features/cart/view/cart_edit_address_screen.dart';
import 'package:yjeek_app/features/cart/view/cart_new_cart_dialog_screen.dart';
import 'package:yjeek_app/features/cart/view/change_address_screen.dart';
import 'package:yjeek_app/features/cart/view/checkout_screen.dart';
import 'package:yjeek_app/features/cart/view/out_of_delivery_screen.dart';
import 'package:yjeek_app/features/cart/view/review_confirm_screen.dart';
import 'package:yjeek_app/features/cart/view/set_location_screen.dart';
import 'package:yjeek_app/features/cart/view/zood_waiting_list_screen.dart';
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
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/view/help_chat_screen.dart';
import 'package:yjeek_app/features/help/view/help_faq_screen.dart';
import 'package:yjeek_app/features/help/view/help_flow_screen.dart';
import 'package:yjeek_app/features/help/view/help_issue_screen.dart';
import 'package:yjeek_app/features/help/view/help_policies_legal_screen.dart';
import 'package:yjeek_app/features/help/view/help_support_screen.dart';
import 'package:yjeek_app/features/help/view/order_help_screen.dart';
import 'package:yjeek_app/features/navigation/view/policy_document_screen.dart';
import 'package:yjeek_app/features/navigation/view/refunds_credits_screen.dart';
import 'package:yjeek_app/features/navigation/view/saved_addresses_screen.dart';
import 'package:yjeek_app/features/navigation/view/wallet_screen.dart';
import 'package:yjeek_app/features/navigation/view/withdraw_bank_screen.dart';
import 'package:yjeek_app/features/dine_in_cart/view/dine_in_checkout_screen.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/dine_in_confirmed_screen.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/dine_in_complete_screen.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/dine_in_pay_screen.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/dine_in_receipt_screen.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/dine_in_status_screen.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/dine_in_waiting_screen.dart';
import 'package:yjeek_app/features/services_booking/view/services_booking_screen.dart';
import 'package:yjeek_app/features/services_booking/view/services_checkout_screen.dart';
import 'package:yjeek_app/features/services_booking/view/services_review_screen.dart';
import 'package:yjeek_app/features/services_order_flow/view/services_confirmed_screen.dart';
import 'package:yjeek_app/features/services_order_flow/view/services_complete_screen.dart';
import 'package:yjeek_app/features/services_order_flow/view/services_pay_screen.dart';
import 'package:yjeek_app/features/services_order_flow/view/services_receipt_screen.dart';
import 'package:yjeek_app/features/services_order_flow/view/services_status_screen.dart';
import 'package:yjeek_app/features/services_order_flow/view/services_waiting_screen.dart';
import 'package:yjeek_app/features/dine_in_cart/view/dine_in_review_screen.dart';
import 'package:yjeek_app/features/scheduled_cart/view/scheduled_checkout_screen.dart';
import 'package:yjeek_app/features/scheduled_cart/view/scheduled_review_screen.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/scheduled_confirmed_screen.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/scheduled_pay_screen.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/scheduled_receipt_screen.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/scheduled_status_screen.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/scheduled_waiting_screen.dart';
import 'package:yjeek_app/features/dine_in_cart/model/dine_in_cart_data.dart';
import 'package:yjeek_app/features/order_flow/view/delivered_rate_screen.dart';
import 'package:yjeek_app/features/order_flow/view/driver_chat_screen.dart';
import 'package:yjeek_app/features/order_flow/view/order_confirmed_screen.dart';
import 'package:yjeek_app/features/order_flow/view/order_receipt_screen.dart';
import 'package:yjeek_app/features/order_flow/view/order_status_screen.dart';
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
          path: RouteNames.splash,
          builder: (_, _) => const HomeScreen(),
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
            final digits = state.uri.queryParameters['digits'] ?? '';
            final expiresInSeconds =
                int.tryParse(state.uri.queryParameters['expires'] ?? '') ?? 300;
            return OtpVerifyScreen(
              phoneNumber: phone,
              phoneDigits: digits,
              expiresInSeconds: expiresInSeconds,
            );
          },
        ),
        GoRoute(
          path: RouteNames.home,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            final cart = state.uri.queryParameters['cart'] == '1';
            final emptyCart = state.uri.queryParameters['empty'] == '1';
            final dineIn = state.uri.queryParameters['dinein'] == '1';
            final scheduled = state.uri.queryParameters['scheduled'] == '1';
            final pickup = state.uri.queryParameters['pickup'] == '1';
            final vape = state.uri.queryParameters['vape'] == '1';
            return MainShell(
              initialIndex: tab,
              cartHasItems: cart,
              emptyCart: emptyCart,
              dineInHasItems: dineIn,
              scheduledHasItems: scheduled,
              pickupHasItems: pickup,
              vapeHasItems: vape,
            );
          },
        ),
        GoRoute(
          path: RouteNames.categories,
          builder: (_, _) => const CategoriesScreen(),
        ),
        GoRoute(
          path: RouteNames.foodBrowse,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return FoodBrowseScreen(bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.foodSearch,
          builder: (_, state) {
            final query = state.uri.queryParameters['q'] ?? '';
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return FoodSearchScreen(initialQuery: query, bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.vendorMenu,
          builder: (_, state) {
            final vendorId =
                state.uri.queryParameters['id'] ?? BrowseRoutes.defaultVendorId;
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return VendorMenuScreen(vendorId: vendorId, bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.itemDetail,
          builder: (_, state) {
            final vendorId =
                state.uri.queryParameters['vendor'] ?? BrowseRoutes.defaultVendorId;
            final itemId =
                state.uri.queryParameters['item'] ?? BrowseRoutes.defaultItemId;
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return ItemDetailScreen(
              vendorId: vendorId,
              itemId: itemId,
              bottomNavIndex: tab,
            );
          },
        ),
        GoRoute(
          path: RouteNames.dineInBrowse,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return DineInBrowseScreen(bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.dineInMenu,
          builder: (_, state) {
            final restaurantId =
                state.uri.queryParameters['id'] ?? BrowseRoutes.defaultDineInRestaurantId;
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return DineInMenuScreen(restaurantId: restaurantId, bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.dineInItemDetail,
          builder: (_, state) {
            final restaurantId = state.uri.queryParameters['restaurant'] ??
                BrowseRoutes.defaultDineInRestaurantId;
            final itemId =
                state.uri.queryParameters['item'] ?? BrowseRoutes.defaultDineInItemId;
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return DineInItemDetailScreen(
              restaurantId: restaurantId,
              itemId: itemId,
              bottomNavIndex: tab,
            );
          },
        ),
        GoRoute(
          path: RouteNames.dineInOrderAgain,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return DineInOrderAgainScreen(bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.servicesBrowse,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return ServicesBrowseScreen(bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.servicesCategory,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            final categoryId = state.uri.queryParameters['id'] ?? 'salon-beauty';
            return ServicesCategoryScreen(
              categoryId: categoryId,
              bottomNavIndex: tab,
            );
          },
        ),
        GoRoute(
          path: RouteNames.servicesProvider,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            final providerId =
                state.uri.queryParameters['id'] ?? BrowseRoutes.defaultServicesProviderId;
            return ServicesProviderScreen(
              providerId: providerId,
              bottomNavIndex: tab,
            );
          },
        ),
        GoRoute(
          path: RouteNames.servicesItemDetail,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            final providerId =
                state.uri.queryParameters['provider'] ?? BrowseRoutes.defaultServicesProviderId;
            final itemId =
                state.uri.queryParameters['item'] ?? BrowseRoutes.defaultServicesItemId;
            return ServicesItemDetailScreen(
              providerId: providerId,
              itemId: itemId,
              bottomNavIndex: tab,
            );
          },
        ),
        GoRoute(
          path: RouteNames.electronicsBrowse,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return ElectronicsBrowseScreen(bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.electronicsStore,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            final storeId =
                state.uri.queryParameters['id'] ?? BrowseRoutes.defaultElectronicsStoreId;
            return ElectronicsStoreScreen(
              storeId: storeId,
              bottomNavIndex: tab,
            );
          },
        ),
        GoRoute(
          path: RouteNames.electronicsProductDetail,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            final storeId =
                state.uri.queryParameters['store'] ?? BrowseRoutes.defaultElectronicsStoreId;
            final productId =
                state.uri.queryParameters['product'] ?? BrowseRoutes.defaultElectronicsProductId;
            return ElectronicsProductDetailScreen(
              storeId: storeId,
              productId: productId,
              bottomNavIndex: tab,
            );
          },
        ),
        GoRoute(
          path: RouteNames.vapeBrowse,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return VapeBrowseScreen(bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.pickupBrowse,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return PickupBrowseScreen(bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.pickupCategories,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return PickupCategoriesScreen(bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.vapeStore,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            final storeId =
                state.uri.queryParameters['id'] ?? BrowseRoutes.defaultVapeStoreId;
            return VapeStoreScreen(
              storeId: storeId,
              bottomNavIndex: tab,
            );
          },
        ),
        GoRoute(
          path: RouteNames.vapeProductDetail,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            final storeId =
                state.uri.queryParameters['store'] ?? BrowseRoutes.defaultVapeStoreId;
            final productId =
                state.uri.queryParameters['product'] ?? BrowseRoutes.defaultVapeProductId;
            return VapeProductDetailScreen(
              storeId: storeId,
              productId: productId,
              bottomNavIndex: tab,
            );
          },
        ),
        GoRoute(
          path: RouteNames.servicesBooking,
          builder: (_, _) => const ServicesBookingScreen(),
        ),
        GoRoute(
          path: RouteNames.servicesBookingCheckout,
          builder: (_, _) => const ServicesCheckoutScreen(),
        ),
        GoRoute(
          path: RouteNames.servicesBookingReview,
          builder: (_, _) => const ServicesReviewScreen(),
        ),
        GoRoute(
          path: RouteNames.servicesOrderWaiting,
          builder: (_, _) => const ServicesWaitingScreen(),
        ),
        GoRoute(
          path: RouteNames.servicesOrderPay,
          builder: (_, _) => const ServicesPayScreen(),
        ),
        GoRoute(
          path: RouteNames.servicesOrderConfirmed,
          builder: (_, _) => const ServicesConfirmedScreen(),
        ),
        GoRoute(
          path: RouteNames.servicesOrderStatus,
          builder: (_, _) => const ServicesStatusScreen(),
        ),
        GoRoute(
          path: RouteNames.servicesOrderComplete,
          builder: (_, _) => const ServicesCompleteScreen(),
        ),
        GoRoute(
          path: RouteNames.servicesOrderReceipt,
          builder: (_, _) => const ServicesReceiptScreen(),
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
          path: RouteNames.helpChat,
          builder: (_, state) {
            final variant =
                HelpChatVariantX.fromQuery(state.uri.queryParameters['variant']);
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return HelpChatScreen(variant: variant, bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.helpFaq,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return HelpFaqScreen(bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.helpPoliciesLegal,
          builder: (_, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return HelpPoliciesLegalScreen(bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.helpFlow,
          builder: (_, state) {
            final flow = HelpFlowTypeX.fromQuery(state.uri.queryParameters['flow']);
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return HelpFlowScreen(flow: flow, bottomNavIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.checkoutLogin,
          builder: (_, _) => const Scaffold(
            body: BasketPreviewBackground(child: CheckoutLoginSheet()),
          ),
        ),
        GoRoute(
          path: RouteNames.cartCheckout,
          builder: (_, _) => const CheckoutScreen(),
        ),
        GoRoute(
          path: RouteNames.cartReview,
          builder: (_, _) => const ReviewConfirmScreen(),
        ),
        GoRoute(
          path: RouteNames.cartChangeAddress,
          builder: (_, _) => const ChangeAddressScreen(),
        ),
        GoRoute(
          path: RouteNames.cartSetLocation,
          builder: (_, _) => const SetLocationScreen(),
        ),
        GoRoute(
          path: RouteNames.cartAddAddress,
          builder: (_, _) => const CartAddAddressScreen(),
        ),
        GoRoute(
          path: RouteNames.cartEditAddress,
          builder: (_, state) => CartEditAddressScreen(
            addressId: state.uri.queryParameters['id'],
          ),
        ),
        GoRoute(
          path: RouteNames.cartOutOfDelivery,
          builder: (_, _) => const OutOfDeliveryScreen(),
        ),
        GoRoute(
          path: RouteNames.cartZoodWaitingList,
          builder: (_, _) => const ZoodWaitingListScreen(),
        ),
        GoRoute(
          path: RouteNames.cartNewCartDialog,
          builder: (_, _) => const CartNewCartDialogScreen(),
        ),
        GoRoute(
          path: RouteNames.orderConfirmed,
          builder: (_, _) => const OrderConfirmedScreen(),
        ),
        GoRoute(
          path: RouteNames.orderStatus,
          builder: (_, state) => OrderStatusScreen(
            orderId: state.uri.queryParameters['id'],
          ),
        ),
        GoRoute(
          path: RouteNames.orderDelivered,
          builder: (_, _) => const DeliveredRateScreen(),
        ),
        GoRoute(
          path: RouteNames.orderReceipt,
          builder: (_, state) => OrderReceiptScreen(
            orderId: state.uri.queryParameters['id'],
          ),
        ),
        GoRoute(
          path: RouteNames.orderChat,
          builder: (_, _) => const DriverChatScreen(),
        ),
        GoRoute(
          path: RouteNames.dineInCartCheckout,
          builder: (_, state) {
            final mode = state.uri.queryParameters['mode'] == 'arrival'
                ? DineInPrepMode.prepareOnArrival
                : DineInPrepMode.prepareNow;
            return DineInCheckoutScreen(initialMode: mode);
          },
        ),
        GoRoute(
          path: RouteNames.dineInCartReview,
          builder: (_, state) {
            final mode = state.uri.queryParameters['mode'] == 'arrival'
                ? DineInPrepMode.prepareOnArrival
                : DineInPrepMode.prepareNow;
            return DineInReviewScreen(prepMode: mode);
          },
        ),
        GoRoute(
          path: RouteNames.scheduledCartCheckout,
          builder: (_, state) {
            final deliveryId = state.uri.queryParameters['delivery'] ?? 'same-day';
            return ScheduledCheckoutScreen(initialDeliveryId: deliveryId);
          },
        ),
        GoRoute(
          path: RouteNames.scheduledCartReview,
          builder: (_, state) {
            final deliveryId = state.uri.queryParameters['delivery'] ?? 'same-day';
            return ScheduledReviewScreen(deliveryId: deliveryId);
          },
        ),
        GoRoute(
          path: RouteNames.pickupCartCheckout,
          builder: (_, _) => const PickupCheckoutScreen(),
        ),
        GoRoute(
          path: RouteNames.pickupCartReview,
          builder: (_, _) => const PickupReviewScreen(),
        ),
        GoRoute(
          path: RouteNames.pickupOrderWaiting,
          builder: (_, _) => const PickupWaitingScreen(),
        ),
        GoRoute(
          path: RouteNames.pickupOrderPay,
          builder: (_, _) => const PickupPayScreen(),
        ),
        GoRoute(
          path: RouteNames.pickupOrderConfirmed,
          builder: (_, _) => const PickupConfirmedScreen(),
        ),
        GoRoute(
          path: RouteNames.pickupOrderStatus,
          builder: (_, _) => const PickupStatusScreen(),
        ),
        GoRoute(
          path: RouteNames.pickupOrderReceipt,
          builder: (_, _) => const PickupReceiptScreen(),
        ),
        GoRoute(
          path: RouteNames.vapeCartCheckout,
          builder: (_, state) {
            final deliveryId = state.uri.queryParameters['delivery'] ?? 'same-day';
            return VapeCheckoutScreen(initialDeliveryId: deliveryId);
          },
        ),
        GoRoute(
          path: RouteNames.vapeCartReview,
          builder: (_, state) {
            final deliveryId = state.uri.queryParameters['delivery'] ?? 'same-day';
            return VapeReviewScreen(deliveryId: deliveryId);
          },
        ),
        GoRoute(
          path: RouteNames.vapeCartAgeVerify,
          builder: (_, _) => const VapeAgeVerifyScreen(),
        ),
        GoRoute(
          path: RouteNames.vapeOrderWaiting,
          builder: (_, _) => const VapeWaitingScreen(),
        ),
        GoRoute(
          path: RouteNames.vapeOrderPay,
          builder: (_, _) => const VapePayScreen(),
        ),
        GoRoute(
          path: RouteNames.vapeOrderConfirmed,
          builder: (_, _) => const VapeConfirmedScreen(),
        ),
        GoRoute(
          path: RouteNames.vapeOrderStatus,
          builder: (_, _) => const VapeStatusScreen(),
        ),
        GoRoute(
          path: RouteNames.vapeOrderReceipt,
          builder: (_, _) => const VapeReceiptScreen(),
        ),
        GoRoute(
          path: RouteNames.scheduledOrderWaiting,
          builder: (_, _) => const ScheduledWaitingScreen(),
        ),
        GoRoute(
          path: RouteNames.scheduledOrderPay,
          builder: (_, _) => const ScheduledPayScreen(),
        ),
        GoRoute(
          path: RouteNames.scheduledOrderConfirmed,
          builder: (_, _) => const ScheduledConfirmedScreen(),
        ),
        GoRoute(
          path: RouteNames.scheduledOrderStatus,
          builder: (_, _) => const ScheduledStatusScreen(),
        ),
        GoRoute(
          path: RouteNames.scheduledOrderReceipt,
          builder: (_, _) => const ScheduledReceiptScreen(),
        ),
        GoRoute(
          path: RouteNames.dineInOrderWaiting,
          builder: (_, _) => const DineInWaitingScreen(),
        ),
        GoRoute(
          path: RouteNames.dineInOrderPay,
          builder: (_, _) => const DineInPayScreen(),
        ),
        GoRoute(
          path: RouteNames.dineInOrderConfirmed,
          builder: (_, _) => const DineInConfirmedScreen(),
        ),
        GoRoute(
          path: RouteNames.dineInOrderStatus,
          builder: (_, _) => const DineInStatusScreen(),
        ),
        GoRoute(
          path: RouteNames.dineInOrderComplete,
          builder: (_, _) => const DineInCompleteScreen(),
        ),
        GoRoute(
          path: RouteNames.dineInOrderReceipt,
          builder: (_, _) => const DineInReceiptScreen(),
        ),
      ],
    );
  }
}

extension AppNavigation on BuildContext {
  void goHome({
    int tab = 0,
    bool cartHasItems = false,
    bool emptyCart = false,
    bool dineInCart = false,
    bool scheduledCart = false,
    bool pickupCart = false,
    bool vapeCart = false,
  }) {
    // Remember where we came from so Cart back can restore that screen.
    if (tab == 2) {
      final current = GoRouterState.of(this).uri.toString();
      if (!current.startsWith(RouteNames.home)) {
        ProviderScope.containerOf(this)
            .read(shellProvider.notifier)
            .setCartReturnPath(current);
      }
    }

    final params = <String>['tab=$tab'];
    if (cartHasItems) params.add('cart=1');
    if (emptyCart) params.add('empty=1');
    if (dineInCart) params.add('dinein=1');
    if (scheduledCart) params.add('scheduled=1');
    if (pickupCart) params.add('pickup=1');
    if (vapeCart) params.add('vape=1');
    go('${RouteNames.home}?${params.join('&')}');
  }
}
