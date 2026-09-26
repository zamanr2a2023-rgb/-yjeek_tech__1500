import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/auth/model/social_auth_service.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/notifications/service/push_notification_service.dart';
import 'package:yjeek_app/l10n/locale_controller.dart';

final socialAuthServiceProvider = Provider<SocialAuthService>(
  (ref) => SocialAuthService(),
);

/// Runs Google or Apple native sign-in, then `POST /auth/{provider}`.
///
/// Phone is mandatory before the provider sheet opens (market rule + backend
/// first-time signup).
Future<void> completeSocialLogin({
  required BuildContext context,
  required WidgetRef ref,
  required String provider,
  required bool termsAccepted,
  String phoneDigits = '',
  void Function(bool busy)? onBusyChanged,
}) async {
  void snack(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  final phone = phoneDigits.replaceAll(RegExp(r'\D'), '');
  if (phone.length < 8) {
    // Caller should focus the phone field; avoid duplicate snackbars.
    return;
  }

  if (!termsAccepted) {
    return;
  }

  onBusyChanged?.call(true);
  try {
    final social = ref.read(socialAuthServiceProvider);
    final SocialIdTokenResult? identity;
    if (provider == 'apple') {
      identity = await social.signInWithApple();
    } else {
      identity = await social.signInWithGoogle();
    }

    if (identity == null) {
      // User cancelled the provider sheet.
      return;
    }

    final result = await ref.read(authApiProvider).socialLogin(
          provider: provider,
          idToken: identity.idToken,
          phone: phone,
          countryCode: AppStrings.countryCode,
          email: identity.email,
          firstName: identity.firstName,
          lastName: identity.lastName,
        );

    if (!context.mounted) return;

    if (!result.success) {
      snack(result.error ?? 'Social login failed.');
      return;
    }

    final token = result.token?.trim();
    if (token == null || token.isEmpty) {
      snack('Login succeeded but no session token was returned.');
      return;
    }

    final storage = ref.read(storageServiceProvider);
    await storage.saveToken(token);
    final displayPhone = result.phone != null && result.phone!.isNotEmpty
        ? '${AppStrings.countryCode} ${result.phone}'
        : '${AppStrings.countryCode} $phone';
    await storage.savePhone(displayPhone);
    await storage.setLoggedIn(true);
    ref.invalidate(userMeProvider);
    ref.invalidate(homeFeedProvider);

    try {
      final me = await ref.read(userRepositoryProvider).fetchMe();
      final lang = me?.profile.language;
      if (lang != null && lang.isNotEmpty) {
        await ref.read(localeControllerProvider.notifier).setLanguage(lang);
      }
    } catch (_) {}

    if (!context.mounted) return;
    await navigateAfterLogin(context, ref);
    PushNotificationService.instance.syncToken();
    PushNotificationService.instance.consumePendingOpen();
  } on UnsupportedError catch (e) {
    snack(e.message ?? 'This sign-in method is not available.');
  } catch (e) {
    snack(e.toString().replaceFirst('Exception: ', ''));
  } finally {
    onBusyChanged?.call(false);
  }
}
