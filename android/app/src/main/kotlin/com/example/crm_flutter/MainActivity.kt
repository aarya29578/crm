package com.example.crm_flutter

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.example.crm_flutter/call"
        private const val PREF_NAME = "incoming_call_receiver"
        private const val KEY_LATEST_CALL = "latest_call"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "getLatestIncomingCall" -> {

                    val prefs = getSharedPreferences(
                        PREF_NAME,
                        MODE_PRIVATE
                    )

                    val latestCall = prefs.getString(
                        KEY_LATEST_CALL,
                        null
                    )

                    if (latestCall != null) {
                        val json = JSONObject(latestCall)

                        val callData = mapOf(
                            "number" to json.optString("number"),
                            "duration" to json.optLong("duration"),
                            "callType" to json.optString("callType"),
                            "timestamp" to json.optLong("timestamp"),
                            "deviceId" to json.optString("deviceId")
                        )

                        result.success(callData)
                    } else {
                        result.success(null)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}