import BenefitInAppSDK
import Flutter
import UIKit

/// Native BenefitPay bridge.
///
/// Official SDK expects a real `BPInAppButton` (258×60) + `yjeekbp://` callback.
/// We also register as a Flutter scene/app lifecycle delegate so UIScene
/// deeplinking cannot swallow the return URL (Android does not have this issue).
final class BenefitPayPlugin: NSObject, FlutterPlugin, BPInAppButtonDelegate,
  FlutterSceneLifeCycleDelegate, FlutterApplicationLifeCycleDelegate
{
  private static let channelName = "bh.yjeek.customer/benefit_pay"
  /// Must match CFBundleURLSchemes in Info.plist.
  private static let callbackScheme = "yjeekbp"
  private static let launchGraceSeconds: TimeInterval = 2.5
  private static let returnGraceSeconds: TimeInterval = 1.5
  private static let paymentTimeoutSeconds: TimeInterval = 180

  private var channel: FlutterMethodChannel?
  private var pendingResult: FlutterResult?
  private var pendingSession: [String: String] = [:]
  private var payButton: BPInAppButton?
  private var timeoutWorkItem: DispatchWorkItem?
  private var launchWatchWorkItem: DispatchWorkItem?
  private var returnWatchWorkItem: DispatchWorkItem?
  private var leftForBenefitPay = false
  private var lifecycleObservers: [NSObjectProtocol] = []

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    let instance = BenefitPayPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
    if #available(iOS 13.0, *) {
      registrar.addSceneDelegate(instance)
    }
    BenefitPayDeepLinkHandler.shared.plugin = instance
    instance.observeAppLifecycle()
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isAvailable":
      result(isBenefitPayAvailable())
    case "pay":
      startPayment(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - FlutterSceneLifeCycleDelegate

  func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) -> Bool {
    var handled = false
    for context in URLContexts where deliverDeepLink(context.url) {
      handled = true
    }
    return handled
  }

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    guard let contexts = connectionOptions?.urlContexts, !contexts.isEmpty else {
      return false
    }
    var handled = false
    for context in contexts where deliverDeepLink(context.url) {
      handled = true
    }
    return handled
  }

  // MARK: - FlutterApplicationLifeCycleDelegate

  func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    deliverDeepLink(url)
  }

  // MARK: - Payment

  private func isBenefitPayAvailable() -> Bool {
    guard let url = URL(string: "benefitinapp://") else {
      NSLog("[BenefitPay] availability check failed — invalid benefitinapp URL")
      return false
    }
    let available = UIApplication.shared.canOpenURL(url)
    NSLog(
      "[BenefitPay] availability check canOpenURL(%@)=%@",
      url.absoluteString,
      available ? "true" : "false"
    )
    return available
  }

  private func startPayment(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if pendingResult != nil {
      result(
        FlutterError(
          code: "busy",
          message: "Another BenefitPay payment is in progress",
          details: nil
        )
      )
      return
    }
    guard isBenefitPayAvailable() else {
      result([
        "status": "unavailable",
        "message": "BenefitPay app is not installed",
      ])
      return
    }
    guard let args = call.arguments as? [String: Any],
          var config = parseConfig(args)
    else {
      result([
        "status": "failed",
        "message": "Missing BenefitPay session fields from server",
      ])
      return
    }

    // SDK validates amount with locale-sensitive decimal checks — force "0.000".
    config["amount"] = Self.normalizedAmount(config["amount"] ?? "")

    pendingSession = config
    pendingResult = result
    leftForBenefitPay = false

    guard let button = recreatePayButton() else {
      completePending([
        "status": "failed",
        "message": "Could not start BenefitPay",
      ])
      return
    }

    schedulePaymentTimeout()
    scheduleLaunchWatch()

    NSLog(
      "[BenefitPay] launching amount=%@ referenceId=%@ currency=%@",
      config["amount"] ?? "?",
      config["referenceId"] ?? "?",
      config["currencyCode"] ?? "?"
    )

    // Run on next run-loop tick so the button's nib finishes wiring.
    DispatchQueue.main.async {
      self.triggerButtonAction(button)
    }
  }

  /// Official docs: BPInAppButton is 258×60 and lives in the view hierarchy.
  /// `buttonAction:` is the SDK method the nib wires to a tap; it builds
  /// `benefitinapp://cwinappdeeplinking` and calls `openURL`.
  private func recreatePayButton() -> BPInAppButton? {
    payButton?.removeFromSuperview()
    payButton = nil

    guard let host = topViewController()?.view else {
      NSLog("[BenefitPay] button create failed — no host view controller")
      return nil
    }

    let width: CGFloat = 258
    let height: CGFloat = 60
    let x = max(0, (host.bounds.width - width) / 2)
    let y = max(0, host.bounds.height - height - host.safeAreaInsets.bottom)
    let frame = CGRect(x: x, y: y, width: width, height: height)

    let button = BPInAppButton(frame: frame)
    button.delegate = self
    // Must stay in-window and not hidden so the SDK nib finishes loading.
    // Alpha keeps it from covering the Flutter Pay button; we invoke
    // buttonAction: ourselves instead of waiting for a user tap.
    button.isHidden = false
    button.alpha = 0.02
    button.isUserInteractionEnabled = false
    host.addSubview(button)
    host.bringSubviewToFront(button)
    host.layoutIfNeeded()
    button.layoutIfNeeded()
    payButton = button
    NSLog(
      "[BenefitPay] button created frame=%@ window=%@",
      NSCoder.string(for: button.frame),
      button.window == nil ? "nil" : "attached"
    )
    return button
  }

  private func triggerButtonAction(_ button: BPInAppButton) {
    let selector = NSSelectorFromString("buttonAction:")
    guard button.responds(to: selector) else {
      NSLog("[BenefitPay] SDK buttonAction: missing on BPInAppButton")
      completePending([
        "status": "failed",
        "message": "BenefitPay SDK buttonAction unavailable",
      ])
      return
    }
    NSLog(
      "[BenefitPay] SDK buttonAction: triggered — opening benefitinapp://cwinappdeeplinking callback=%@",
      Self.callbackScheme
    )
    _ = button.perform(selector, with: button)
    NSLog("[BenefitPay] SDK buttonAction: returned")
  }

  /// If BenefitPay never takes focus, fail fast instead of spinning for minutes.
  private func scheduleLaunchWatch() {
    launchWatchWorkItem?.cancel()
    let work = DispatchWorkItem { [weak self] in
      guard let self, self.pendingResult != nil, !self.leftForBenefitPay else { return }
      NSLog("[BenefitPay] did not leave app — launch failed")
      self.completePending([
        "status": "failed",
        "message":
          "Could not open BenefitPay. Please try again or choose another payment method.",
      ])
    }
    launchWatchWorkItem = work
    DispatchQueue.main.asyncAfter(
      deadline: .now() + Self.launchGraceSeconds,
      execute: work
    )
  }

  private func scheduleReturnWatch() {
    returnWatchWorkItem?.cancel()
    let work = DispatchWorkItem { [weak self] in
      guard let self, self.pendingResult != nil else { return }
      // Came back from BenefitPay without a yjeekbp:// callback.
      NSLog("[BenefitPay] returned without callback — treating as cancelled")
      self.completePending([
        "status": "cancelled",
        "message": "Payment cancelled",
      ])
    }
    returnWatchWorkItem = work
    DispatchQueue.main.asyncAfter(
      deadline: .now() + Self.returnGraceSeconds,
      execute: work
    )
  }

  private func schedulePaymentTimeout() {
    timeoutWorkItem?.cancel()
    let work = DispatchWorkItem { [weak self] in
      guard let self, self.pendingResult != nil else { return }
      self.completePending([
        "status": "failed",
        "message": "BenefitPay timed out — no callback received",
      ])
    }
    timeoutWorkItem = work
    DispatchQueue.main.asyncAfter(
      deadline: .now() + Self.paymentTimeoutSeconds,
      execute: work
    )
  }

  private static func normalizedAmount(_ raw: String) -> String {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: ",", with: ".")
    guard let value = Double(trimmed) else { return trimmed }
    return String(format: "%.3f", value)
  }

  private func parseConfig(_ args: [String: Any]) -> [String: String]? {
    func req(_ key: String) -> String? {
      // Accept String or NSNumber from the method channel.
      if let raw = args[key] as? String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
      }
      if let num = args[key] as? NSNumber {
        return num.stringValue
      }
      return nil
    }
    guard let appId = req("appId"),
          let merchantId = req("merchantId"),
          let secretKey = req("secretKey"),
          let referenceId = req("referenceId"),
          let amount = req("amount"),
          let currencyCode = req("currencyCode"),
          let merchantCategoryCode = req("merchantCategoryCode"),
          let merchantName = req("merchantName"),
          let merchantCity = req("merchantCity"),
          let countryCode = req("countryCode")
    else { return nil }

    return [
      "appId": appId,
      "merchantId": merchantId,
      "secretKey": secretKey,
      "referenceId": referenceId,
      "amount": amount,
      "currencyCode": currencyCode,
      "merchantCategoryCode": merchantCategoryCode,
      "merchantName": merchantName,
      "merchantCity": merchantCity,
      "countryCode": countryCode,
      "callBackTag": Self.callbackScheme,
    ]
  }

  private func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let windows = scenes.flatMap(\.windows)
    let key = windows.first(where: \.isKeyWindow) ?? windows.first
    var controller = key?.rootViewController
    while let presented = controller?.presentedViewController {
      controller = presented
    }
    return controller
  }

  func bpInAppConfiguration() -> BPInAppConfiguration! {
    let session = pendingSession
    return BPInAppConfiguration(
      appId: session["appId"] ?? "",
      andSecretKey: session["secretKey"] ?? "",
      andAmount: session["amount"] ?? "",
      andCurrencyCode: session["currencyCode"] ?? "",
      andMerchantId: session["merchantId"] ?? "",
      andMerchantName: session["merchantName"] ?? "",
      andMerchantCity: session["merchantCity"] ?? "",
      andCountryCode: session["countryCode"] ?? "",
      andMerchantCategoryId: session["merchantCategoryCode"] ?? "",
      andReferenceId: session["referenceId"] ?? "",
      andCallBackTag: Self.callbackScheme
    )
  }

  @discardableResult
  func deliverDeepLink(_ url: URL) -> Bool {
    guard url.scheme?.caseInsensitiveCompare(Self.callbackScheme) == .orderedSame else {
      return false
    }
    NSLog("[BenefitPay] callback returned url=%@", url.absoluteString)
    returnWatchWorkItem?.cancel()
    returnWatchWorkItem = nil
    launchWatchWorkItem?.cancel()
    launchWatchWorkItem = nil

    guard pendingResult != nil else {
      NSLog("[BenefitPay] callback with no pending payment — acknowledged")
      return true
    }

    guard let item = BPDLPaymentCallBackItem(deepLinkURL: url) else {
      completePending([
        "status": "failed",
        "message": "Invalid BenefitPay callback",
      ])
      return true
    }
    switch item.status {
    case PaymentCallBackStatusSuccess:
      completePending([
        "status": "success",
        "referenceId": item.referenceId ?? pendingSession["referenceId"] ?? "",
        "amount": item.amount ?? pendingSession["amount"] ?? "",
        "message": item.message ?? "Payment successful",
      ])
    case PaymentCallBackStatusCancel:
      completePending([
        "status": "cancelled",
        "referenceId": item.referenceId ?? pendingSession["referenceId"] ?? "",
        "message": item.message ?? "Payment cancelled",
      ])
    case PaymentCallBackStatusFail:
      completePending([
        "status": "failed",
        "referenceId": item.referenceId ?? pendingSession["referenceId"] ?? "",
        "amount": item.amount ?? pendingSession["amount"] ?? "",
        "message": item.message ?? "Payment failed",
      ])
    default:
      completePending([
        "status": "failed",
        "message": "Unknown BenefitPay callback status",
      ])
    }
    return true
  }

  private func completePending(_ payload: [String: String]) {
    timeoutWorkItem?.cancel()
    timeoutWorkItem = nil
    launchWatchWorkItem?.cancel()
    launchWatchWorkItem = nil
    returnWatchWorkItem?.cancel()
    returnWatchWorkItem = nil
    leftForBenefitPay = false
    let result = pendingResult
    pendingResult = nil
    pendingSession = [:]
    result?(payload)
  }

  private func observeAppLifecycle() {
    lifecycleObservers.forEach(NotificationCenter.default.removeObserver)
    lifecycleObservers = []

    let resign = NotificationCenter.default.addObserver(
      forName: UIApplication.willResignActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let self, self.pendingResult != nil else { return }
      self.leftForBenefitPay = true
      self.launchWatchWorkItem?.cancel()
      self.launchWatchWorkItem = nil
      NSLog("[BenefitPay] app resigning — BenefitPay likely opened")
    }

    let active = NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let self, self.pendingResult != nil, self.leftForBenefitPay else { return }
      NSLog("[BenefitPay] app active again — waiting briefly for yjeekbp://")
      self.scheduleReturnWatch()
    }

    lifecycleObservers = [resign, active]
  }
}
