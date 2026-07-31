import 'package:yjeek_app/l10n/l10n.dart';
abstract final class AppStrings {
  static String get appName => L10n.tr('Yjeek');
  static String get lifestyle => L10n.tr('Lifestyle');
  static String get arabic => L10n.tr('عربي');

  // Welcome
  static String get welcomeTitle => L10n.tr('Welcome to Yjeek');
  static String get welcomeSubtitle => L10n.tr('Your everyday lifestyle app — order, dine, book, and discover across Bahrain.');
  static String get browseAsGuest => L10n.tr('Browse as a guest');
  static String get loginOrSignUp => L10n.tr('Login or sign up');

  // Phone login
  static String get enterPhoneTitle => L10n.tr('Enter your phone number');
  static String get enterPhoneSubtitle => L10n.tr('We will send a one-time code by SMS to verify your number.');
  static String get countryCode => L10n.tr('+973');
  static String get countryLabel => L10n.tr('BH');
  static String get termsAgreement => L10n.tr('I agree to the Terms & Conditions & Privacy Policy');
  static String get sendCode => L10n.tr('Send code');
  static String get orContinueWith => L10n.tr('or continue with');
  static String get continueWithGoogle => L10n.tr('Continue with Google');
  static String get continueWithApple => L10n.tr('Continue with Apple');

  // OTP
  static String get verifyTitle => L10n.tr('Verify your number');
  static String verifySubtitle(String phone) =>
      L10n.trParams('Enter the 4-digit code sent to {phone}.', {'phone': phone});
  static String get resendCodeIn => L10n.tr('Resend code in');
  static String get resendCode => L10n.tr('Resend code');
  static String get changeNumber => L10n.tr('Change number');
  static String get verifyAndContinue => L10n.tr('Verify & continue');
  static String get tryAgain => L10n.tr('Try again');
  static String get verify => L10n.tr('Verify');
  static String incorrectCode(int attempts) => L10n.trParams(
        'Incorrect code. {attempts} attempts left.',
        {'attempts': '$attempts'},
      );
  static String get newCodeSent => L10n.tr('A new code has been sent.');
  static String get tooManyAttempts => L10n.tr('Too many attempts. For your security, please try again in');
  static String get correctOtp => L10n.tr('5240');
  static String get wrongOtpDemo => L10n.tr('5291');

  // Terms
  static String get termsTitle => L10n.tr('Terms & Conditions');
  static String get termsCompany => L10n.tr('Yjeek Technologies W.L.L · Bahrain · 2026');
  static String get termsIntro => L10n.tr('By using the Yjeek platform you agree to be bound by these Terms.');
  static String get article1Title => L10n.tr('ARTICLE 1 — ABOUT YJEEK');
  static String get article1Body => L10n.tr('Yjeek is a multi-category on-demand delivery and lifestyle platform operated by Yjeek Technologies W.L.L (CR 110111-3), Al Seef, Kingdom of Bahrain. Governed by the laws of Bahrain.');
  static String get article2Title => L10n.tr('ARTICLE 2 — ELIGIBILITY & REGISTRATION');
  static String get article2Body => L10n.tr('You must be 18+, capable of entering contracts, and a resident or visitor in Bahrain. You are responsible for the security of your account credentials.');
  static String get article3Title => L10n.tr('ARTICLE 3 — ORDERS, CATEGORIES & PRICING');
  static String get article3Body => L10n.tr('Yjeek is a technology intermediary; vendors are solely responsible for their products. In-app prices must equal or be lower than in-store prices.');
  static String get article4Title => L10n.tr('ARTICLE 4 — PAYMENT');
  static String get article4Body => L10n.tr('Accepted: Visa/Mastercard, BenefitPay, and Yjeek Wallet credits. Payments are processed via PCI-DSS compliant gateways. All prices in BHD; VAT 10% where applicable.');
  static String get article5Title => L10n.tr('ARTICLE 5 — YJEEK WALLET & CASHBACK');
  static String get article5Body => L10n.tr('Cashback (min 3% of order value) is valid for 6 months from the credit date (rolling expiry). Withdrawals need a min BHD 10 balance; the customer receives 70% and Yjeek retains a 30% processing fee. Processing takes 3–7 working days.');
  static String get iAgree => L10n.tr('I Agree');
  static String get close => L10n.tr('Close');

  // Checkout login
  static String get yourBasket => L10n.tr('Your Basket');
  static String get checkoutLoginTitle => L10n.tr('Log in to place your order');
  static String get checkoutLoginSubtitle => L10n.tr('Your cart is saved. Sign in with your phone number to checkout — it only takes a moment.');
  static String get continueWithPhone => L10n.tr('Continue with phone');
  static String get keepBrowsing => L10n.tr('Keep browsing');
}
