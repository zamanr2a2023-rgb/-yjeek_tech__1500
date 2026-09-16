/// Google / Apple Sign-In client configuration for the customer app.
///
/// Must match `GOOGLE_*` audiences accepted by `POST /auth/google` on the backend.
abstract final class SocialAuthConfig {
  /// Web OAuth client ID — required as [GoogleSignIn.serverClientId] so Android
  /// returns a verifiable ID token (aud = this client).
  static const String googleWebClientId =
      '345308459087-op3q79nbttqorio6rij5tkkff00u2d5n.apps.googleusercontent.com';

  /// iOS customer OAuth client (also listed in GoogleService-Info).
  static const String googleIosClientId =
      '345308459087-uuskhgtblkuggulv315mjfelu6ofdmfa.apps.googleusercontent.com';

  /// Apple Services ID for Android / web Sign in with Apple.
  /// Leave empty until Apple Developer → Identifiers → Services ID is set up.
  /// Example: `com.yjeek.customer.signin`
  static const String appleServicesId = '';

  /// HTTPS redirect URI registered on that Services ID (return URL).
  /// Example: `https://api.yjeektech.com/callbacks/sign_in_with_apple`
  static const String appleRedirectUri = '';

  static bool get hasAppleAndroidWebAuth =>
      appleServicesId.trim().isNotEmpty && appleRedirectUri.trim().isNotEmpty;
}
