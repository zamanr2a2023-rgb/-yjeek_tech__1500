abstract final class AppStrings {
  static const String appName = 'Yjeek';
  static const String lifestyle = 'Lifestyle';
  static const String arabic = 'عربي';

  // Welcome
  static const String welcomeTitle = 'Welcome to Yjeek';
  static const String welcomeSubtitle =
      'Your everyday lifestyle app — order, dine, book, and discover across Bahrain.';
  static const String browseAsGuest = 'Browse as a guest';
  static const String loginOrSignUp = 'Login or sign up';

  // Phone login
  static const String enterPhoneTitle = 'Enter your phone number';
  static const String enterPhoneSubtitle =
      'We will send a one-time code by SMS to verify your number.';
  static const String countryCode = '+973';
  static const String countryLabel = 'BH';
  static const String termsAgreement =
      'I agree to the Terms & Conditions & Privacy Policy';
  static const String sendCode = 'Send code';
  static const String orContinueWith = 'or continue with';
  static const String continueWithGoogle = 'Continue with Google';
  static const String continueWithApple = 'Continue with Apple';

  // OTP
  static const String verifyTitle = 'Verify your number';
  static String verifySubtitle(String phone) =>
      'Enter the 4-digit code sent to $phone.';
  static const String resendCodeIn = 'Resend code in';
  static const String resendCode = 'Resend code';
  static const String changeNumber = 'Change number';
  static const String verifyAndContinue = 'Verify & continue';
  static const String tryAgain = 'Try again';
  static const String verify = 'Verify';
  static String incorrectCode(int attempts) =>
      'Incorrect code. $attempts attempts left.';
  static const String newCodeSent = 'A new code has been sent.';
  static const String tooManyAttempts =
      'Too many attempts. For your security, please try again in';
  static const String correctOtp = '5240';
  static const String wrongOtpDemo = '5291';

  // Terms
  static const String termsTitle = 'Terms & Conditions';
  static const String termsCompany =
      'Yjeek Technologies W.L.L · Bahrain · 2026';
  static const String termsIntro =
      'By using the Yjeek platform you agree to be bound by these Terms.';
  static const String article1Title = 'ARTICLE 1 — ABOUT YJEEK';
  static const String article1Body =
      'Yjeek is a multi-category on-demand delivery and lifestyle platform operated by Yjeek Technologies W.L.L (CR 110111-3), Al Seef, Kingdom of Bahrain. Governed by the laws of Bahrain.';
  static const String article2Title = 'ARTICLE 2 — ELIGIBILITY & REGISTRATION';
  static const String article2Body =
      'You must be 18+, capable of entering contracts, and a resident or visitor in Bahrain. You are responsible for the security of your account credentials.';
  static const String article3Title = 'ARTICLE 3 — ORDERS, CATEGORIES & PRICING';
  static const String article3Body =
      'Yjeek is a technology intermediary; vendors are solely responsible for their products. In-app prices must equal or be lower than in-store prices.';
  static const String article4Title = 'ARTICLE 4 — PAYMENT';
  static const String article4Body =
      'Accepted: Visa/Mastercard, BenefitPay, and Yjeek Wallet credits. Payments are processed via PCI-DSS compliant gateways. All prices in BHD; VAT 10% where applicable.';
  static const String article5Title = 'ARTICLE 5 — YJEEK WALLET & CASHBACK';
  static const String article5Body =
      'Cashback (min 3% of order value) is valid for 6 months from the credit date (rolling expiry). Withdrawals need a min BHD 10 balance; the customer receives 70% and Yjeek retains a 30% processing fee. Processing takes 3–7 working days.';
  static const String iAgree = 'I Agree';
  static const String close = 'Close';

  // Checkout login
  static const String yourBasket = 'Your Basket';
  static const String checkoutLoginTitle = 'Log in to place your order';
  static const String checkoutLoginSubtitle =
      'Your cart is saved. Sign in with your phone number to checkout — it only takes a moment.';
  static const String continueWithPhone = 'Continue with phone';
  static const String keepBrowsing = 'Keep browsing';
}
