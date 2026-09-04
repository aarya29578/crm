package com.example.crm_flutter

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {

    companion object {

        private const val CHANNEL =
            "com.example.crm_flutter/call"

        private const val PREF_NAME =
            "incoming_call_receiver"

        private const val KEY_LATEST_CALL =
            "latest_call"

        private var methodChannel: MethodChannel? = null

        fun sendIncomingCallToFlutter(
            callJson: String
        ) {

            Handler(Looper.getMainLooper()).post {

                val channel = methodChannel

                if (channel == null) {

                    Log.d(
                        "MainActivity",
                        "❌ Flutter channel is not available"
                    )

                    return@post
                }

                try {

                    val json =
                        JSONObject(callJson)

                    val calls =
                        json.optJSONArray("calls")

                    if (
                        calls == null ||
                        calls.length() == 0
                    ) {

                        Log.d(
                            "MainActivity",
                            "❌ No calls found in JSON"
                        )

                        return@post
                    }

                    val call =
                        calls.getJSONObject(0)

                    val callData = mapOf(

                        "phone_number" to
                            call.optString(
                                "phone_number"
                            ),

                        "device_call_id" to
                            call.optString(
                                "device_call_id"
                            ),

                        "duration" to
                            call.optLong(
                                "duration"
                            ),

                        "missed" to
                            call.optBoolean(
                                "missed"
                            ),

                        "started_at" to
                            call.optString(
                                "started_at"
                            ),

                        "ended_at" to
                            call.optString(
                                "ended_at"
                            )
                    )

                    Log.d(
                        "MainActivity",
                        "🔥 Sending call to Flutter: $callData"
                    )

                    channel.invokeMethod(
                        "incomingCallEnded",
                        callData
                    )

                    Log.d(
                        "MainActivity",
                        "✅ MethodChannel event sent"
                    )

                } catch (e: Exception) {

                    Log.e(
                        "MainActivity",
                        "❌ Failed to send call to Flutter",
                        e
                    )
                }
            }
        }
    }

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {

        super.configureFlutterEngine(
            flutterEngine
        )

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        Log.d(
            "MainActivity",
            "🔥 MethodChannel initialized"
        )

        methodChannel?.setMethodCallHandler {
                call,
                result ->

            when (call.method) {

                "getLatestIncomingCall" -> {

                    val prefs =
                        getSharedPreferences(
                            PREF_NAME,
                            MODE_PRIVATE
                        )

                    val latestCall =
                        prefs.getString(
                            KEY_LATEST_CALL,
                            null
                        )

                    if (latestCall == null) {

                        result.success(null)

                        return@setMethodCallHandler
                    }

                    try {

                        val json =
                            JSONObject(latestCall)

                        val calls =
                            json.optJSONArray("calls")

                        if (
                            calls == null ||
                            calls.length() == 0
                        ) {

                            result.success(null)

                            return@setMethodCallHandler
                        }

                        val callData =
                            calls.getJSONObject(0)

                        result.success(
                            mapOf(

                                "phone_number" to
                                    callData.optString(
                                        "phone_number"
                                    ),

                                "device_call_id" to
                                    callData.optString(
                                        "device_call_id"
                                    ),

                                "duration" to
                                    callData.optLong(
                                        "duration"
                                    ),

                                "missed" to
                                    callData.optBoolean(
                                        "missed"
                                    ),

                                "started_at" to
                                    callData.optString(
                                        "started_at"
                                    ),

                                "ended_at" to
                                    callData.optString(
                                        "ended_at"
                                    )
                            )
                        )

                    } catch (e: Exception) {

                        result.error(
                            "CALL_DATA_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {

        methodChannel = null

        super.onDestroy()
    }
}