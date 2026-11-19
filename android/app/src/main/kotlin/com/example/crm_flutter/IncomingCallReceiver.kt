package com.example.crm_flutter

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.CallLog
import android.provider.Settings
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.content.ContextCompat
import org.json.JSONArray
import org.json.JSONObject

class IncomingCallReceiver : BroadcastReceiver() {

    companion object {

        private const val TAG = "IncomingCallReceiver"

        private const val PREF_NAME = "incoming_call_receiver"

        private const val KEY_INCOMING_NUMBER =
            "incoming_number"

        private const val KEY_CALL_ACTIVE =
            "call_active"

        private const val KEY_CALL_ANSWERED =
            "call_answered"

        private const val KEY_LATEST_CALL =
            "latest_call"

        private const val KEY_CALL_START_TIME =
            "call_start_time"

        private const val KEY_CALL_CONNECTED_TIME =
            "call_connected_time"

        private const val KEY_LAST_DISPATCHED_ID =
            "last_dispatched_id"

        private const val KEY_LAST_DISPATCHED_TIME =
            "last_dispatched_time"
    }

    private fun getDeviceId(context: Context): String {

        return Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ANDROID_ID
        ) ?: ""
    }

    private fun numbersMatch(num1: String?, num2: String?): Boolean {
        if (num1.isNullOrBlank() || num2.isNullOrBlank()) return false
        val digits1 = num1.filter { it.isDigit() }
        val digits2 = num2.filter { it.isDigit() }
        if (digits1 == digits2) return true
        if (digits1.length >= 10 && digits2.length >= 10) {
            return digits1.takeLast(10) == digits2.takeLast(10)
        }
        return false
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

                Log.d(TAG, "Incoming call state received: $incomingNumber")

                val prefs =
                    context.getSharedPreferences(
                        PREF_NAME,
                        Context.MODE_PRIVATE
                    )

                val now = System.currentTimeMillis()
                val editor = prefs.edit()

                if (!incomingNumber.isNullOrBlank()) {
                    editor.putString(
                        KEY_INCOMING_NUMBER,
                        incomingNumber
                    )
                }

                editor.putBoolean(
                    KEY_CALL_ACTIVE,
                    true
                )
                editor.putBoolean(
                    KEY_CALL_ANSWERED,
                    false
                )
                editor.putLong(
                    KEY_CALL_START_TIME,
                    now
                )
                editor.remove(KEY_CALL_CONNECTED_TIME)
                editor.apply()

                Log.d(
                    TAG,
                    "📞 Incoming call ringing at $now, number=$incomingNumber"
                )
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

                val isTrackedIncomingCall =
                    prefs.getBoolean(KEY_CALL_ACTIVE, false) &&
                            !prefs.getString(KEY_INCOMING_NUMBER, null).isNullOrBlank()

                if (isTrackedIncomingCall) {
                    val now = System.currentTimeMillis()
                    prefs.edit()
                        .putBoolean(
                            KEY_CALL_ANSWERED,
                            true
                        )
                        .putLong(
                            KEY_CALL_CONNECTED_TIME,
                            now
                        )
                        .apply()

                    Log.d(
                        TAG,
                        "✅ Incoming call connected / answered at $now"
                    )
                } else {
                    Log.d(
                        TAG,
                        "Ignoring OFFHOOK for a non-incoming call"
                    )
                }
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

                val startTime =
                    prefs.getLong(
                        KEY_CALL_START_TIME,
                        System.currentTimeMillis()
                    )

                val connectedTime =
                    prefs.getLong(
                        KEY_CALL_CONNECTED_TIME,
                        0L
                    )

                val endTime = System.currentTimeMillis()

                Log.d(
                    TAG,
                    "Call ended. active=$callWasActive answered=$callWasAnswered start=$startTime end=$endTime number=$incomingNumber"
                )

                if (callWasActive) {
                    // Note: Temporary call state is cleared only AFTER successful capture and dispatch
                    syncLatestIncomingCall(
                        context.applicationContext,
                        incomingNumber,
                        callWasAnswered,
                        startTime,
                        connectedTime,
                        endTime
                    )
                }
            }
        }
    }

    private fun syncLatestIncomingCall(
        context: Context,
        fallbackNumber: String?,
        callWasAnswered: Boolean,
        startTime: Long,
        connectedTime: Long,
        endTime: Long
    ) {
        Thread {
            try {
                var number: String? = null
                var duration = 0L
                var type = -1
                var timestamp = startTime
                var matchFound = false

                val hasPermission = ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.READ_CALL_LOG
                ) == PackageManager.PERMISSION_GRANTED

                if (hasPermission) {
                    // Retry loop with backoff:
                    // Android OS typically takes 1-4 seconds to flush and commit answered call records to CallLog.
                    val delays = longArrayOf(1000L, 1200L, 1500L, 1500L)
                    val minDate = startTime - 10000L // 10s tolerance for clock jitter

                    for (attempt in delays.indices) {
                        try {
                            Thread.sleep(delays[attempt])
                        } catch (e: InterruptedException) {
                            break
                        }

                        Log.d(TAG, "CallLog query attempt ${attempt + 1}/${delays.size} for call started at $startTime")

                        val hasRejectedType = Build.VERSION.SDK_INT >= Build.VERSION_CODES.N
                        val selection = if (hasRejectedType) {
                            "(${CallLog.Calls.TYPE} = ? OR ${CallLog.Calls.TYPE} = ? OR ${CallLog.Calls.TYPE} = ?) AND ${CallLog.Calls.DATE} >= ?"
                        } else {
                            "(${CallLog.Calls.TYPE} = ? OR ${CallLog.Calls.TYPE} = ?) AND ${CallLog.Calls.DATE} >= ?"
                        }

                        val selectionArgs = if (hasRejectedType) {
                            arrayOf(
                                CallLog.Calls.INCOMING_TYPE.toString(),
                                CallLog.Calls.MISSED_TYPE.toString(),
                                CallLog.Calls.REJECTED_TYPE.toString(),
                                minDate.toString()
                            )
                        } else {
                            arrayOf(
                                CallLog.Calls.INCOMING_TYPE.toString(),
                                CallLog.Calls.MISSED_TYPE.toString(),
                                minDate.toString()
                            )
                        }

                        val cursor = context.contentResolver.query(
                            CallLog.Calls.CONTENT_URI,
                            arrayOf(
                                CallLog.Calls.NUMBER,
                                CallLog.Calls.DURATION,
                                CallLog.Calls.TYPE,
                                CallLog.Calls.DATE
                            ),
                            selection,
                            selectionArgs,
                            "${CallLog.Calls.DATE} DESC"
                        )

                        cursor?.use {
                            val numberIndex = it.getColumnIndex(CallLog.Calls.NUMBER)
                            val durationIndex = it.getColumnIndex(CallLog.Calls.DURATION)
                            val typeIndex = it.getColumnIndex(CallLog.Calls.TYPE)
                            val dateIndex = it.getColumnIndex(CallLog.Calls.DATE)

                            while (it.moveToNext()) {
                                val logNumber = if (numberIndex >= 0) it.getString(numberIndex) else null
                                val logDate = if (dateIndex >= 0) it.getLong(dateIndex) else 0L

                                // Reject any entry that occurred before this call started
                                if (logDate < minDate) {
                                    continue
                                }

                                // Verify number matches fallbackNumber if fallbackNumber is available
                                val isNumberMatch = if (!fallbackNumber.isNullOrBlank()) {
                                    numbersMatch(logNumber, fallbackNumber)
                                } else {
                                    !logNumber.isNullOrBlank()
                                }

                                if (isNumberMatch) {
                                    number = if (!logNumber.isNullOrBlank()) logNumber else fallbackNumber
                                    duration = if (durationIndex >= 0) it.getLong(durationIndex) else 0L
                                    type = if (typeIndex >= 0) it.getInt(typeIndex) else -1
                                    timestamp = if (logDate > 0L) logDate else startTime
                                    matchFound = true
                                    Log.d(TAG, "✅ Matched CallLog entry on attempt ${attempt + 1}: number=$number, duration=$duration, type=$type, date=$timestamp")
                                    break
                                }
                            }
                        }

                        if (matchFound) {
                            break
                        }
                    }
                } else {
                    Log.w(TAG, "READ_CALL_LOG permission not granted; using captured lifecycle data directly")
                }

                // If CallLog entry was not found or permission was missing, use captured fallback data
                if (!matchFound) {
                    if (fallbackNumber.isNullOrBlank()) {
                        Log.e(TAG, "No matching CallLog entry and no fallback number available. Aborting.")
                        clearTemporaryCallState(context)
                        return@Thread
                    }

                    number = fallbackNumber
                    timestamp = startTime
                    val calculatedSec = if (callWasAnswered) {
                        val activeDurationMs = if (connectedTime > 0L) (endTime - connectedTime) else (endTime - startTime)
                        Math.max(0L, activeDurationMs / 1000L)
                    } else {
                        0L
                    }
                    duration = calculatedSec
                    type = if (callWasAnswered) CallLog.Calls.INCOMING_TYPE else CallLog.Calls.MISSED_TYPE
                    Log.d(TAG, "ℹ️ Used fallback call data: number=$number, duration=$duration, answered=$callWasAnswered")
                }

                val finalNumber = number ?: fallbackNumber ?: ""
                if (finalNumber.isBlank()) {
                    Log.e(TAG, "Final incoming number is blank. Aborting dispatch.")
                    clearTemporaryCallState(context)
                    return@Thread
                }

                val isMissed = !callWasAnswered ||
                        type == CallLog.Calls.MISSED_TYPE ||
                        (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && type == CallLog.Calls.REJECTED_TYPE)

                val deviceId = getDeviceId(context)
                val deviceCallId = "${deviceId}_${timestamp}"

                // Check for duplicate dispatch
                val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
                val lastDispatchedId = prefs.getString(KEY_LAST_DISPATCHED_ID, null)
                val lastDispatchedTime = prefs.getLong(KEY_LAST_DISPATCHED_TIME, 0L)
                val now = System.currentTimeMillis()

                if (deviceCallId == lastDispatchedId && (now - lastDispatchedTime < 10000L)) {
                    Log.d(TAG, "Duplicate incoming call dispatch prevented for $deviceCallId")
                    clearTemporaryCallState(context)
                    return@Thread
                }

                val call = JSONObject().apply {
                    put("phone_number", finalNumber)
                    put("device_call_id", deviceCallId)
                    put("duration", duration)
                    put("missed", isMissed)
                    put("started_at", java.time.Instant.ofEpochMilli(timestamp).toString())
                    put("ended_at", java.time.Instant.ofEpochMilli(timestamp + (duration * 1000L)).toString())
                }

                val calls = JSONArray().apply { put(call) }
                val data = JSONObject().apply { put("calls", calls) }
                val callJson = data.toString()

                Log.d(TAG, "Final incoming call record prepared: $callJson")

                // Save call and update dispatch tracking
                prefs.edit()
                    .putString(KEY_LATEST_CALL, callJson)
                    .putString(KEY_LAST_DISPATCHED_ID, deviceCallId)
                    .putLong(KEY_LAST_DISPATCHED_TIME, now)
                    .apply()

                Log.d(TAG, "🚀 Sending incoming call to Flutter: $deviceCallId")
                MainActivity.sendIncomingCallToFlutter(callJson)

                // Clear temporary incoming-call state only after successful capture and dispatch
                clearTemporaryCallState(context)

            } catch (e: Exception) {
                Log.e(TAG, "Failed in syncLatestIncomingCall", e)
                clearTemporaryCallState(context)
            }
        }.start()
    }

    private fun clearTemporaryCallState(context: Context) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        prefs.edit()
            .remove(KEY_INCOMING_NUMBER)
            .remove(KEY_CALL_START_TIME)
            .remove(KEY_CALL_CONNECTED_TIME)
            .putBoolean(KEY_CALL_ACTIVE, false)
            .putBoolean(KEY_CALL_ANSWERED, false)
            .apply()
        Log.d(TAG, "Temporary incoming-call state cleared")
    }
}