package com.example.yjeek_app

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import android.view.View
import android.view.ViewGroup
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import mobi.foo.benefitinapp.data.Transaction
import mobi.foo.benefitinapp.listener.BenefitInAppButtonListener
import mobi.foo.benefitinapp.listener.CheckoutListener
import mobi.foo.benefitinapp.utils.BenefitInAppButton
import mobi.foo.benefitinapp.utils.BenefitInAppCheckout
import mobi.foo.benefitinapp.utils.BenefitInAppHelper

class BenefitPayPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener {

    companion object {
        private const val TAG = "BenefitPayPlugin"
        private const val CHANNEL = "bh.yjeek.customer/benefit_pay"
        private const val PAYMENT_REQUEST_CODE = 238

        private val BENEFIT_PAY_PACKAGES = listOf(
            "mobi.foo.benefitpay.pay",
            "mobi.foo.benefit",
            "mobi.foo.benefittest",
            "mobi.foo.benefitdev",
        )
    }

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingResult: MethodChannel.Result? = null
    private var hiddenButton: BenefitInAppButton? = null
    private var pendingConfig: Map<String, String>? = null

    private val checkoutListener = object : CheckoutListener {
        override fun onTransactionSuccess(transaction: Transaction) {
            Log.d(
                TAG,
                "onTransactionSuccess reference=${transaction.referenceNumber} " +
                    "amount=${transaction.amount} message=${transaction.transactionMessage}",
            )
            completePending(
                mapOf(
                    "status" to "success",
                    "referenceId" to (transaction.referenceNumber ?: ""),
                    "amount" to (transaction.amount ?: ""),
                    "message" to (transaction.transactionMessage ?: "Payment successful"),
                ),
            )
        }

        override fun onTransactionFail(transaction: Transaction) {
            Log.d(
                TAG,
                "onTransactionFail reference=${transaction.referenceNumber} " +
                    "amount=${transaction.amount} message=${transaction.transactionMessage}",
            )
            completePending(
                mapOf(
                    "status" to "failed",
                    "referenceId" to (transaction.referenceNumber ?: ""),
                    "amount" to (transaction.amount ?: ""),
                    "message" to (transaction.transactionMessage ?: "Payment failed"),
                ),
            )
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addActivityResultListener(this)
        ensureHiddenButton()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addActivityResultListener(this)
        ensureHiddenButton()
    }

    override fun onDetachedFromActivity() {
        detachActivity()
    }

    private fun detachActivity() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
        activity = null
        hiddenButton = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAvailable" -> result.success(isBenefitPayInstalled())
            "pay" -> startPayment(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PAYMENT_REQUEST_CODE) return false
        Log.d(
            TAG,
            "onActivityResult code=$resultCode action=${data?.action} " +
                "hasData=${data != null}",
        )
        if (data != null) {
            val action = data.action
            if (action != null &&
                action.equals(
                    "benefitinapp.foo.mobi.benefitinappsdk.transactionstatus",
                    ignoreCase = true,
                )
            ) {
                Log.d(
                    TAG,
                    "handleResult from transaction intent " +
                        "isSuccess=${data.getBooleanExtra("isSuccess", false)} " +
                        "message=${data.getStringExtra("message")}",
                )
                BenefitInAppHelper.handleResult(data)
                return true
            }
        }
        if (resultCode == Activity.RESULT_OK && data != null) {
            BenefitInAppHelper.handleResult(data)
            return true
        }
        if (pendingResult != null) {
            Log.d(TAG, "onActivityResult completing cancelled (no transaction intent)")
            completePending(
                mapOf(
                    "status" to "cancelled",
                    "message" to "Payment cancelled",
                ),
            )
        }
        return true
    }

    private fun isBenefitPayInstalled(): Boolean {
        val act = activity ?: return false
        val pm = act.packageManager
        return BENEFIT_PAY_PACKAGES.any { pkg ->
            try {
                pm.getPackageInfo(pkg, 0)
                true
            } catch (_: PackageManager.NameNotFoundException) {
                false
            }
        }
    }

    private fun ensureHiddenButton() {
        val act = activity ?: return
        if (hiddenButton != null) return
        val button = BenefitInAppButton(act)
        button.visibility = View.GONE
        button.layoutParams = ViewGroup.LayoutParams(1, 1)
        button.setListener(
            object : BenefitInAppButtonListener {
                override fun onButtonClicked() {
                    val config = pendingConfig ?: return
                    val currentActivity = activity ?: return
                    val countryCode = config["countryCode"]!!
                    val currencyCode = config["currencyCode"]!!
                    val merchantCategoryCode = config["merchantCategoryCode"]!!
                    Log.d(
                        TAG,
                        "countryCode=$countryCode currencyCode=$currencyCode " +
                            "merchantCategoryCode=$merchantCategoryCode",
                    )
                    BenefitInAppCheckout.newInstance(
                        currentActivity,
                        config["appId"]!!,
                        config["referenceId"]!!,
                        config["merchantId"]!!,
                        config["secretKey"]!!,
                        config["amount"]!!,
                        countryCode,
                        currencyCode,
                        merchantCategoryCode,
                        config["merchantName"]!!,
                        config["merchantCity"]!!,
                        checkoutListener,
                    )
                }

                override fun onFail(reason: Int) {
                    completePending(
                        mapOf(
                            "status" to "failed",
                            "message" to "BenefitPay configuration error ($reason)",
                        ),
                    )
                }
            },
        )
        act.findViewById<ViewGroup>(android.R.id.content)?.addView(button)
        hiddenButton = button
    }

    private fun startPayment(call: MethodCall, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("busy", "Another BenefitPay payment is in progress", null)
            return
        }
        val act = activity
        if (act == null) {
            result.success(
                mapOf(
                    "status" to "unavailable",
                    "message" to "Activity not available",
                ),
            )
            return
        }
        if (!isBenefitPayInstalled()) {
            result.success(
                mapOf(
                    "status" to "unavailable",
                    "message" to "BenefitPay app is not installed",
                ),
            )
            return
        }

        val config = parseConfig(call)
        if (config == null) {
            result.success(
                mapOf(
                    "status" to "failed",
                    "message" to "Missing BenefitPay session fields from server",
                ),
            )
            return
        }

        pendingResult = result
        pendingConfig = config
        ensureHiddenButton()
        hiddenButton?.performClick()
    }

    private fun parseConfig(call: MethodCall): Map<String, String>? {
        fun req(key: String): String? = call.argument<String>(key)?.trim()?.takeIf { it.isNotEmpty() }
        val appId = req("appId") ?: return null
        val merchantId = req("merchantId") ?: return null
        val secretKey = req("secretKey") ?: return null
        val referenceId = req("referenceId") ?: return null
        val amount = req("amount") ?: return null
        val currencyCode = req("currencyCode") ?: return null
        val merchantCategoryCode = req("merchantCategoryCode") ?: return null
        val merchantName = req("merchantName") ?: return null
        val merchantCity = req("merchantCity") ?: return null
        val countryCode = req("countryCode") ?: return null
        return mapOf(
            "appId" to appId,
            "merchantId" to merchantId,
            "secretKey" to secretKey,
            "referenceId" to referenceId,
            "amount" to amount,
            "currencyCode" to currencyCode,
            "merchantCategoryCode" to merchantCategoryCode,
            "merchantName" to merchantName,
            "merchantCity" to merchantCity,
            "countryCode" to countryCode,
        )
    }

    private fun completePending(payload: Map<String, String>) {
        pendingResult?.success(payload)
        pendingResult = null
        pendingConfig = null
    }
}
