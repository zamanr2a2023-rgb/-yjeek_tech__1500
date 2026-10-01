import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  /// Intercept BenefitPay return URLs before Flutter deeplinking can swallow them.
  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    var remaining = Set<UIOpenURLContext>()
    for context in URLContexts {
      if BenefitPayDeepLinkHandler.shared.handle(context.url) {
        NSLog("[BenefitPay] SceneDelegate handled %@", context.url.absoluteString)
      } else {
        remaining.insert(context)
      }
    }
    if !remaining.isEmpty {
      super.scene(scene, openURLContexts: remaining)
    }
  }

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    for context in connectionOptions.urlContexts {
      _ = BenefitPayDeepLinkHandler.shared.handle(context.url)
    }
  }
}
