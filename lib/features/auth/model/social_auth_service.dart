import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:yjeek_app/core/constants/social_auth_config.dart';

class SocialIdTokenResult {
  const SocialIdTokenResult({
    required this.idToken,
    this.email,
    this.firstName,
    this.lastName,
  });

  final String idToken;
  final String? email;
  final String? firstName;
  final String? lastName;
}

/// Native Google / Apple identity tokens for `POST /auth/google|apple`.
class SocialAuthService {
  SocialAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const ['email', 'profile'],
              serverClientId: SocialAuthConfig.googleWebClientId,
              clientId: Platform.isIOS
                  ? SocialAuthConfig.googleIosClientId
                  : null,
            );

  final GoogleSignIn _googleSignIn;

  Future<SocialIdTokenResult?> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    final idToken = auth.idToken?.trim();
    if (idToken == null || idToken.isEmpty) {
      throw StateError(
        'Google did not return an ID token. Check serverClientId / SHA-1 setup.',
      );
    }

    final display = account.displayName?.trim();
    String? firstName;
    String? lastName;
    if (display != null && display.isNotEmpty) {
      final parts = display.split(RegExp(r'\s+'));
      firstName = parts.first;
      if (parts.length > 1) lastName = parts.sublist(1).join(' ');
    }

    return SocialIdTokenResult(
      idToken: idToken,
      email: account.email,
      firstName: firstName,
      lastName: lastName,
    );
  }

  Future<SocialIdTokenResult?> signInWithApple() async {
    // Android requires webAuthenticationOptions (Services ID + HTTPS redirect).
    // Backend Apple verify is still stubbed — without Services ID we use a
    // stable stub token so Android QA can exercise POST /auth/apple.
    if (Platform.isAndroid && !SocialAuthConfig.hasAppleAndroidWebAuth) {
      if (kDebugMode) {
        debugPrint(
          '[auth] Apple on Android using stub token '
          '(set SocialAuthConfig.appleServicesId + appleRedirectUri for real SIWA)',
        );
      }
      return const SocialIdTokenResult(
        idToken: 'android-stub-apple-token',
      );
    }

    final available = await SignInWithApple.isAvailable();
    if (!available) {
      throw UnsupportedError(
        'Sign in with Apple is not available on this device.',
      );
    }

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: Platform.isAndroid
          ? WebAuthenticationOptions(
              clientId: SocialAuthConfig.appleServicesId,
              redirectUri: Uri.parse(SocialAuthConfig.appleRedirectUri),
            )
          : null,
    );

    final idToken = credential.identityToken?.trim();
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Apple did not return an identity token.');
    }

    return SocialIdTokenResult(
      idToken: idToken,
      email: credential.email,
      firstName: credential.givenName,
      lastName: credential.familyName,
    );
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Google signOut failed: $e\n$st');
      }
    }
  }
}
