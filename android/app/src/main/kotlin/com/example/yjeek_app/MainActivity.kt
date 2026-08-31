package com.example.yjeek_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(BenefitPayPlugin())
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "yjeek_default",
                "Yjeek notifications",
                NotificationManager.IMPORTANCE_HIGH,
            )
            channel.description = "Order, payment, and account alerts"
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }
}
