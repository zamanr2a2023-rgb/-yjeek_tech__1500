package com.example.yjeek_app

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.util.Log
import mobi.foo.benefitinapp.data.Transaction

/**
 * Temporary DEBUG-only tracing for BenefitPay native SDK failures.
 * No-op unless the host app is debuggable (release builds are not).
 */
internal object BenefitPayDebugLog {
    const val TAG = "BenefitPayDebug"
    private const val MAX_BUFFER_EVENTS = 200

    @Volatile
    var debuggable: Boolean = false

    private val buffer = ArrayDeque<Map<String, Any>>()
    private val bufferLock = Any()

    private val sensitiveKeys =
        setOf(
            "secretkey",
            "secret_key",
            "secret",
            "appid",
            "app_id",
            "cardnumber",
            "card_number",
            "pin",
            "token",
            "authorization",
            "secure_hash",
            "hashedstring",
        )

    fun bindDebuggable(applicationInfo: ApplicationInfo) {
        debuggable = (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        if (!debuggable) {
            clearBuffer()
        }
    }

    fun snapshot(): List<Map<String, Any>> {
        if (!debuggable) return emptyList()
        synchronized(bufferLock) {
            return buffer.map { entry -> entry.toMap() }
        }
    }

    fun clearBuffer() {
        synchronized(bufferLock) {
            buffer.clear()
        }
    }

    fun log(line: String) {
        if (!debuggable) return
        Log.d(TAG, line)
    }

    fun logEvent(event: String, fields: Map<String, String?>) {
        if (!debuggable) return
        val sanitized =
            fields
                .filter { (key, value) ->
                    value != null && !isSensitiveKey(key)
                }
                .mapValues { it.value!!.trim() }
        recordEvent(event, sanitized)
        val parts = buildList {
            add("EVENT=$event")
            for ((key, value) in sanitized) {
                add("$key=$value")
            }
        }
        Log.d(TAG, parts.joinToString(separator = " "))
    }

    private fun recordEvent(event: String, fields: Map<String, String>) {
        val entry =
            mapOf(
                "timestampMs" to System.currentTimeMillis(),
                "event" to event,
                "fields" to fields,
            )
        synchronized(bufferLock) {
            buffer.addLast(entry)
            while (buffer.size > MAX_BUFFER_EVENTS) {
                buffer.removeFirst()
            }
        }
    }

    private fun isSensitiveKey(key: String): Boolean {
        val normalized = key.lowercase().replace(Regex("[^a-z0-9_]"), "")
        return sensitiveKeys.contains(normalized)
    }

    fun maskMerchantId(value: String?): String {
        val v = value?.trim() ?: return "—"
        if (v.isEmpty()) return "—"
        if (v.length <= 4) return "***"
        return "${v.take(2)}…${v.takeLast(2)}(len=${v.length})"
    }

    /** SDK Transaction fields (benefitinappsdk 1.0.25) — excludes card PAN. */
    fun logTransaction(event: String, transaction: Transaction) {
        if (!debuggable) return
        logEvent(
            event,
            mapOf(
                "message" to nullOrDash(transaction.transactionMessage),
                "referenceId" to nullOrDash(transaction.referenceNumber),
                "amount" to nullOrDash(transaction.amount),
                "currency" to nullOrDash(transaction.currency),
                "merchantName" to nullOrDash(transaction.merchant),
                "merchantId" to maskMerchantId(transaction.merchantId),
                "terminalId" to nullOrDash(transaction.terminalId),
                "hasCardNumber" to if (transaction.cardNumber.isNullOrBlank()) "false" else "true",
            ),
        )
    }

    fun logCheckoutStart(config: Map<String, String>, installedPackages: List<String>) {
        if (!debuggable) return
        logEvent(
            "checkout_start",
            mapOf(
                "referenceId" to config["referenceId"],
                "amount" to config["amount"],
                "currencyCode" to config["currencyCode"],
                "merchantCategoryCode" to config["merchantCategoryCode"],
                "countryCode" to config["countryCode"],
                "merchantName" to config["merchantName"],
                "merchantCity" to config["merchantCity"],
                "walletEnvironmentHint" to walletEnvironmentHint(installedPackages),
                "installedWalletPackages" to installedPackages.joinToString(",").ifEmpty { "—" },
            ),
        )
        for (pkg in installedPackages) {
            logEvent("wallet_detected", mapOf("package" to pkg))
        }
    }

    fun logActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?,
    ) {
        if (!debuggable) return
        val uri = data?.data
        logEvent(
            "activity_result",
            mapOf(
                "requestCode" to requestCode.toString(),
                "resultCode" to resultCode.toString(),
                "hasIntentData" to (data != null).toString(),
                "action" to (data?.action ?: "—"),
                "dataScheme" to (uri?.scheme ?: "—"),
                "dataHost" to (uri?.host ?: "—"),
                "intentIsSuccess" to intentExtraOrDash(data, "isSuccess"),
                "intentMessage" to intentExtraOrDash(data, "message"),
            ),
        )
    }

    fun logException(event: String, throwable: Throwable) {
        if (!debuggable) return
        logEvent(
            event,
            mapOf(
                "type" to throwable.javaClass.simpleName,
                "message" to (throwable.message ?: "—"),
                "stackTrace" to Log.getStackTraceString(throwable),
            ),
        )
    }

    fun installedBenefitPayPackages(
        packageManager: PackageManager,
        candidates: List<String>,
    ): List<String> {
        return candidates.filter { pkg ->
            try {
                packageManager.getPackageInfo(pkg, 0)
                true
            } catch (_: PackageManager.NameNotFoundException) {
                false
            }
        }
    }

    private fun walletEnvironmentHint(installed: List<String>): String {
        return when {
            installed.any { it.contains("benefittest") || it.contains("benefitdev") } -> "likely_UAT_test_wallet"
            installed.any { it == "mobi.foo.benefitpay.pay" } -> "likely_production_wallet_apk"
            installed.any { it == "mobi.foo.benefit" } -> "legacy_benefit_apk"
            installed.isEmpty() -> "none"
            else -> "unknown"
        }
    }

    private fun nullOrDash(value: String?): String =
        if (value.isNullOrBlank()) "—" else value.trim()

    private fun intentExtraOrDash(data: Intent?, key: String): String {
        if (data == null) return "—"
        if (!data.hasExtra(key)) return "—"
        return when (val raw = data.extras?.get(key)) {
            null -> "—"
            is Boolean -> raw.toString()
            else -> raw.toString()
        }
    }
}
