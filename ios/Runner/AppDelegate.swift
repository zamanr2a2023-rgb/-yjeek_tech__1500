import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyC7BXis0DYkbNBdzeXQV6VWPPcSj6aL-PM")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "BenefitPayPlugin") {
      BenefitPayPlugin.register(with: registrar)
    }
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if BenefitPayDeepLinkHandler.shared.handle(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
}

/// Forwards BenefitPay deep links to the active plugin instance.
final class BenefitPayDeepLinkHandler {
  static let shared = BenefitPayDeepLinkHandler()
  weak var plugin: BenefitPayPlugin?

  func handle(_ url: URL) -> Bool {
    plugin?.deliverDeepLink(url) ?? false
  }
}
