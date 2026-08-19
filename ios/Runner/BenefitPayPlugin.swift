import BenefitInAppSDK
import Flutter
import UIKit

final class BenefitPayPlugin: NSObject, FlutterPlugin, BPInAppButtonDelegate {
  private static let channelName = "bh.yjeek.customer/benefit_pay"
  private static let callbackScheme = "yjeekbp"

  private var channel: FlutterMethodChannel?
  private var pendingResult: FlutterResult?
  private var pendingSession: [String: String] = [:]
  private weak var hostView: UIView?
  private var payButton: BPInAppButton?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    let instance = BenefitPayPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
    BenefitPayDeepLinkHandler.shared.plugin = instance
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

  private func isBenefitPayAvailable() -> Bool {
    guard let url = URL(string: "benefitinapp://") else { return false }
    return UIApplication.shared.canOpenURL(url)
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
          let config = parseConfig(args)
    else {
      result([
        "status": "failed",
        "message": "Missing BenefitPay session fields from server",
      ])
      return
    }

    pendingSession = config
    pendingResult = result
    ensurePayButton()
    payButton?.sendActions(for: .touchUpInside)
  }

  private func parseConfig(_ args: [String: Any]) -> [String: String]? {
    func req(_ key: String) -> String? {
      guard let raw = args[key] as? String else { return nil }
      let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
      return trimmed.isEmpty ? nil : trimmed
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

    let callBackTag = req("callBackTag") ?? Self.callbackScheme
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
      "callBackTag": callBackTag,
    ]
  }

  private func ensurePayButton() {
    guard payButton == nil else { return }
    guard let controller = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap(\.windows)
      .first(where: { $0.isKeyWindow })?.rootViewController
    else { return }

    let button = BPInAppButton(frame: CGRect(x: 0, y: 0, width: 258, height: 60))
    button.isHidden = true
    button.delegate = self
    controller.view.addSubview(button)
    hostView = controller.view
    payButton = button
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
      andCallBackTag: session["callBackTag"] ?? Self.callbackScheme
    )
  }

  func deliverDeepLink(_ url: URL) -> Bool {
    guard url.scheme?.caseInsensitiveCompare(Self.callbackScheme) == .orderedSame else {
      return false
    }
    guard pendingResult != nil else { return false }

    let item = BPDLPaymentCallBackItem(deepLinkURL: url)
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
    @unknown default:
      completePending([
        "status": "failed",
        "message": "Unknown BenefitPay callback status",
      ])
    }
    return true
  }

  private func completePending(_ payload: [String: String]) {
    pendingResult?(payload)
    pendingResult = nil
    pendingSession = [:]
  }
}
