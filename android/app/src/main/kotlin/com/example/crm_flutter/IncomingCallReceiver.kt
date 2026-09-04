package com.example.crm_flutter

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import android.provider.CallLog
import android.provider.Settings
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.content.ContextCompat
import org.json.JSONObject

class IncomingCallReceiver : BroadcastReceiver() {

    companion object {

        private const val TAG = "IncomingCallReceiver"

        private const val PREF_NAME = "incoming_call_receiver"

        private const val KEY_INCOMING_NUMBER =
            "incoming_number"

        private const val KEY_CALL_ACTIVE =
            "call_active"

        // NEW:
        // Keeps track of whether the call was actually answered.
        private const val KEY_CALL_ANSWERED =
            "call_answered"

        private const val KEY_LATEST_CALL =
            "latest_call"
    }

    private fun getDeviceId(context: Context): String {

        return Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ANDROID_ID
        ) ?: ""
    }

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {

        if (
            intent.action !=
            TelephonyManager.ACTION_PHONE_STATE_CHANGED
        ) {
            return
        }

        val state =
            intent.getStringExtra(
                TelephonyManager.EXTRA_STATE
            ) ?: return

        Log.d(TAG, "Phone state: $state")

        when (state) {

            // --------------------------------
            // INCOMING CALL
            // --------------------------------

            TelephonyManager.EXTRA_STATE_RINGING -> {

                val incomingNumber =
                    intent.getStringExtra(
                        TelephonyManager.EXTRA_INCOMING_NUMBER
                    )

                Log.d(
                    TAG,
                    "Incoming number: $incomingNumber"
                )

                if (!incomingNumber.isNullOrBlank()) {

                    val prefs =
                        context.getSharedPreferences(
                            PREF_NAME,
                            Context.MODE_PRIVATE
                        )

                    prefs.edit()
                        .putString(
                            KEY_INCOMING_NUMBER,
                            incomingNumber
                        )
                        .putBoolean(
                            KEY_CALL_ACTIVE,
                            true
                        )
                        // IMPORTANT:
                        // At RINGING stage the call has NOT
                        // been answered yet.
                        .putBoolean(
                            KEY_CALL_ANSWERED,
                            false
                        )
                        .apply()

                    Log.d(
                        TAG,
                        "📞 Incoming call started"
                    )
                }
            }

            // --------------------------------
            // CALL ANSWERED
            // --------------------------------

            TelephonyManager.EXTRA_STATE_OFFHOOK -> {

                val prefs =
                    context.getSharedPreferences(
                        PREF_NAME,
                        Context.MODE_PRIVATE
                    )

                prefs.edit()
                    .putBoolean(
                        KEY_CALL_ACTIVE,
                        true
                    )
                    // IMPORTANT:
                    // OFFHOOK means the incoming call
                    // was answered.
                    .putBoolean(
                        KEY_CALL_ANSWERED,
                        true
                    )
                    .apply()

                Log.d(
                    TAG,
                    "✅ Call connected / answered"
                )
            }

            // --------------------------------
            // CALL ENDED / MISSED / REJECTED
            // --------------------------------

            TelephonyManager.EXTRA_STATE_IDLE -> {

                val prefs =
                    context.getSharedPreferences(
                        PREF_NAME,
                        Context.MODE_PRIVATE
                    )

                val incomingNumber =
                    prefs.getString(
                        KEY_INCOMING_NUMBER,
                        null
                    )

                val callWasActive =
                    prefs.getBoolean(
                        KEY_CALL_ACTIVE,
                        false
                    )

                val callWasAnswered =
                    prefs.getBoolean(
                        KEY_CALL_ANSWERED,
                        false
                    )

                Log.d(
                    TAG,
                    "Call ended. " +
                            "Number=$incomingNumber " +
                            "active=$callWasActive " +
                            "answered=$callWasAnswered"
                )

                if (callWasActive) {

                    Handler(
                        Looper.getMainLooper()
                    ).postDelayed({

                        syncLatestIncomingCall(
                            context.applicationContext,
                            incomingNumber,
                            callWasAnswered
                        )

                    }, 1500)
                }

                // Clear current call state

                prefs.edit()
                    .remove(KEY_INCOMING_NUMBER)
                    .putBoolean(
                        KEY_CALL_ACTIVE,
                        false
                    )
                    .putBoolean(
                        KEY_CALL_ANSWERED,
                        false
                    )
                    .apply()
            }
        }
    }

    private fun syncLatestIncomingCall(
        context: Context,
        fallbackNumber: String?,
        callWasAnswered: Boolean
    ) {

        if (
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.READ_CALL_LOG
            ) != PackageManager.PERMISSION_GRANTED
        ) {

            Log.e(
                TAG,
                "READ_CALL_LOG permission not granted"
            )

            return
        }

        Thread {

            try {

                // --------------------------------
                // Get latest incoming OR missed call
                // --------------------------------

                val cursor =
                    context.contentResolver.query(

                        CallLog.Calls.CONTENT_URI,

                        arrayOf(
                            CallLog.Calls.NUMBER,
                            CallLog.Calls.DURATION,
                            CallLog.Calls.TYPE,
                            CallLog.Calls.DATE
                        ),

                        "${CallLog.Calls.TYPE} = ? OR " +
                                "${CallLog.Calls.TYPE} = ?",

                        arrayOf(
                            CallLog.Calls.INCOMING_TYPE.toString(),
                            CallLog.Calls.MISSED_TYPE.toString()
                        ),

                        "${CallLog.Calls.DATE} DESC"
                    )

                cursor?.use {

                    if (!it.moveToFirst()) {

                        Log.d(
                            TAG,
                            "No incoming or missed call found"
                        )

                        return@Thread
                    }

                    // --------------------------------
                    // Get indexes
                    // --------------------------------

                    val numberIndex =
                        it.getColumnIndex(
                            CallLog.Calls.NUMBER
                        )

                    val durationIndex =
                        it.getColumnIndex(
                            CallLog.Calls.DURATION
                        )

                    val typeIndex =
                        it.getColumnIndex(
                            CallLog.Calls.TYPE
                        )

                    val dateIndex =
                        it.getColumnIndex(
                            CallLog.Calls.DATE
                        )

                    // --------------------------------
                    // Get values
                    // --------------------------------

                    val numberFromLog =
                        if (numberIndex >= 0) {
                            it.getString(numberIndex)
                        } else {
                            null
                        }

                    val duration =
                        if (durationIndex >= 0) {
                            it.getLong(durationIndex)
                        } else {
                            0L
                        }

                    val type =
                        if (typeIndex >= 0) {
                            it.getInt(typeIndex)
                        } else {
                            -1
                        }

                    val timestamp =
                        if (dateIndex >= 0) {
                            it.getLong(dateIndex)
                        } else {
                            0L
                        }

                    // --------------------------------
                    // Number
                    // --------------------------------

                    val number =
                        numberFromLog
                            ?: fallbackNumber
                            ?: ""

                    if (number.isBlank()) {

                        Log.d(
                            TAG,
                            "Incoming number is empty"
                        )

                        return@Thread
                    }

                    // --------------------------------
                    // Determine missed / rejected
                    // --------------------------------

                    /*
                     * IMPORTANT LOGIC:
                     *
                     * If OFFHOOK happened:
                     *     call was answered
                     *     missed = false
                     *
                     * If OFFHOOK did NOT happen:
                     *     caller hung up OR user rejected
                     *     missed = true
                     *
                     * We also check MISSED_TYPE from CallLog.
                     */

                    val missed =
                        !callWasAnswered ||
                                type == CallLog.Calls.MISSED_TYPE

                    Log.d(
                        TAG,
                        "Call type=$type"
                    )

                    Log.d(
                        TAG,
                        "Duration=$duration"
                    )

                    Log.d(
                        TAG,
                        "Call answered=$callWasAnswered"
                    )

                    Log.d(
                        TAG,
                        "Missed/Rejected=$missed"
                    )

                    // --------------------------------
                    // Device ID
                    // --------------------------------

                    val deviceId =
                        getDeviceId(context)

                    val deviceCallId =
                        "${deviceId}_${timestamp}"

                    // --------------------------------
                    // Create call JSON
                    // --------------------------------

                    val call =
                        JSONObject()

                    call.put(
                        "phone_number",
                        number
                    )

                    call.put(
                        "device_call_id",
                        deviceCallId
                    )

                    call.put(
                        "duration",
                        duration
                    )

                    call.put(
                        "missed",
                        missed
                    )

                    call.put(
                        "started_at",
                        java.time.Instant
                            .ofEpochMilli(timestamp)
                            .toString()
                    )

                    call.put(
                        "ended_at",
                        java.time.Instant
                            .ofEpochMilli(
                                timestamp +
                                        (duration * 1000)
                            )
                            .toString()
                    )

                    // --------------------------------
                    // Backend format
                    // --------------------------------

                    val data =
                        JSONObject()

                    val calls =
                        org.json.JSONArray()

                    calls.put(call)

                    data.put(
                        "calls",
                        calls
                    )

                    val callJson =
                        data.toString()

                    Log.d(
                        TAG,
                        "📞 Final call data: $callJson"
                    )

                    // --------------------------------
                    // Save call
                    // --------------------------------

                    val prefs =
                        context.getSharedPreferences(
                            PREF_NAME,
                            Context.MODE_PRIVATE
                        )

                    prefs.edit()
                        .putString(
                            KEY_LATEST_CALL,
                            callJson
                        )
                        .apply()

                    Log.d(
                        TAG,
                        "✅ Incoming call saved"
                    )

                    // --------------------------------
                    // Send to Flutter
                    // --------------------------------

                    Log.d(
                        TAG,
                        "🚀 Sending call to Flutter"
                    )

                    MainActivity.sendIncomingCallToFlutter(
                        callJson
                    )
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
}