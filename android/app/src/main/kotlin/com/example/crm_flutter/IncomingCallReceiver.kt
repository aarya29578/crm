package com.example.crm_flutter

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import android.provider.CallLog
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.content.ContextCompat
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

class IncomingCallReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "IncomingCallReceiver"

        private const val API_URL =
            "http://192.168.0.104:8010/api/v1/call/sync-incoming"

        private const val PREF_NAME = "incoming_call_receiver"
        private const val KEY_INCOMING_NUMBER = "incoming_number"
        private const val KEY_CALL_ACTIVE = "call_active"
    }

    override fun onReceive(context: Context, intent: Intent) {

        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            return
        }

        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            ?: return

        Log.d(TAG, "Phone state: $state")

        when (state) {

            TelephonyManager.EXTRA_STATE_RINGING -> {

                val incomingNumber =
                    intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)

                Log.d(TAG, "Incoming number: $incomingNumber")

                if (!incomingNumber.isNullOrBlank()) {

                    val prefs = context.getSharedPreferences(
                        PREF_NAME,
                        Context.MODE_PRIVATE
                    )

                    prefs.edit()
                        .putString(KEY_INCOMING_NUMBER, incomingNumber)
                        .putBoolean(KEY_CALL_ACTIVE, true)
                        .apply()
                }
            }

            TelephonyManager.EXTRA_STATE_OFFHOOK -> {

                val prefs = context.getSharedPreferences(
                    PREF_NAME,
                    Context.MODE_PRIVATE
                )

                prefs.edit()
                    .putBoolean(KEY_CALL_ACTIVE, true)
                    .apply()

                Log.d(TAG, "Call connected")
            }

            TelephonyManager.EXTRA_STATE_IDLE -> {

                val prefs = context.getSharedPreferences(
                    PREF_NAME,
                    Context.MODE_PRIVATE
                )

                val incomingNumber =
                    prefs.getString(KEY_INCOMING_NUMBER, null)

                val callWasActive =
                    prefs.getBoolean(KEY_CALL_ACTIVE, false)

                Log.d(
                    TAG,
                    "Call ended. Number=$incomingNumber active=$callWasActive"
                )

                if (callWasActive) {

                    Handler(Looper.getMainLooper()).postDelayed({

                        syncLatestIncomingCall(
                            context.applicationContext,
                            incomingNumber
                        )

                    }, 1500)
                }

                prefs.edit()
                    .remove(KEY_INCOMING_NUMBER)
                    .putBoolean(KEY_CALL_ACTIVE, false)
                    .apply()
            }
        }
    }

    private fun syncLatestIncomingCall(
        context: Context,
        fallbackNumber: String?
    ) {

        if (
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.READ_CALL_LOG
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.e(TAG, "READ_CALL_LOG permission not granted")
            return
        }

        Thread {

            try {

                val cursor = context.contentResolver.query(
                    CallLog.Calls.CONTENT_URI,
                    arrayOf(
                        CallLog.Calls.NUMBER,
                        CallLog.Calls.DURATION,
                        CallLog.Calls.TYPE,
                        CallLog.Calls.DATE
                    ),
                    "${CallLog.Calls.TYPE} = ?",
                    arrayOf(
                        CallLog.Calls.INCOMING_TYPE.toString()
                    ),
                    "${CallLog.Calls.DATE} DESC"
                )

                cursor?.use {

                    if (!it.moveToFirst()) {
                        Log.d(TAG, "No incoming call found")
                        return@Thread
                    }

                    val numberIndex =
                        it.getColumnIndex(CallLog.Calls.NUMBER)

                    val durationIndex =
                        it.getColumnIndex(CallLog.Calls.DURATION)

                    val typeIndex =
                        it.getColumnIndex(CallLog.Calls.TYPE)

                    val dateIndex =
                        it.getColumnIndex(CallLog.Calls.DATE)

                    val numberFromLog =
                        if (numberIndex >= 0)
                            it.getString(numberIndex)
                        else
                            null

                    val duration =
                        if (durationIndex >= 0)
                            it.getLong(durationIndex)
                        else
                            0L

                    val type =
                        if (typeIndex >= 0)
                            it.getInt(typeIndex)
                        else
                            -1

                    val timestamp =
                        if (dateIndex >= 0)
                            it.getLong(dateIndex)
                        else
                            0L

                    if (type != CallLog.Calls.INCOMING_TYPE) {
                        Log.d(TAG, "Latest call is not incoming")
                        return@Thread
                    }

                    val number =
                        numberFromLog
                            ?: fallbackNumber
                            ?: ""

                    if (number.isBlank()) {
                        Log.d(TAG, "Incoming number is empty")
                        return@Thread
                    }

                    val data = JSONObject()

                    data.put("number", number)
                    data.put("duration", duration)
                    data.put("callType", "incoming")
                    data.put("timestamp", timestamp)

                    Log.d(TAG, "Sending incoming call: $data")

                    sendToBackend(context, data.toString())
                }

            } catch (e: Exception) {

                Log.e(
                    TAG,
                    "Failed to read incoming call log",
                    e
                )
            }

        }.start()
    }

    private fun sendToBackend(
        context: Context,
        jsonBody: String
    ) {

        var connection: HttpURLConnection? = null

        try {

            /*
             * Flutter's legacy SharedPreferences Android storage.
             * The Flutter plugin uses the "flutter." key prefix.
             */
            val flutterPrefs =
                context.getSharedPreferences(
                    "FlutterSharedPreferences",
                    Context.MODE_PRIVATE
                )

            val token =
                flutterPrefs.getString(
                    "flutter.token",
                    null
                )

            if (token.isNullOrBlank()) {

                Log.e(
                    TAG,
                    "No authentication token found"
                )

                return
            }

            val url = URL(API_URL)

            connection =
                url.openConnection() as HttpURLConnection

            connection.requestMethod = "POST"
            connection.connectTimeout = 15000
            connection.readTimeout = 15000

            connection.doOutput = true

            connection.setRequestProperty(
                "Content-Type",
                "application/json"
            )

            connection.setRequestProperty(
                "Authorization",
                "Bearer $token"
            )

            connection.outputStream.use { outputStream ->

                outputStream.write(
                    jsonBody.toByteArray(Charsets.UTF_8)
                )

                outputStream.flush()
            }

            val responseCode =
                connection.responseCode

            Log.d(
                TAG,
                "Incoming call API response: $responseCode"
            )

            if (responseCode == 200 || responseCode == 201) {

                Log.d(
                    TAG,
                    "Incoming call synced successfully"
                )

            } else {

                Log.e(
                    TAG,
                    "Incoming call sync failed: $responseCode"
                )
            }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Error sending incoming call",
                e
            )

        } finally {

            connection?.disconnect()
        }
    }
}