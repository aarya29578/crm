import 'dart:async';
import 'dart:io';
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/common_widgets/popup_after_call_ui.dart';
import 'package:crm_flutter/common_widgets/call_storage.dart';
import 'package:crm_flutter/helper/bottom_sheet_helper.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:call_log/call_log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class CallHelper {
  static bool _startApiSent = false;

  static StreamSubscription<PhoneState>? _subscription;
  static bool _isCallInProgress = false;

  // ============================================================
  // CALL RECORDER
  // ============================================================

  static final AudioRecorder _recorder = AudioRecorder();

  static bool _isRecording = false;

  static String? _currentRecordingPath;

  // ============================================================
  // INITIATE CALL + TRACK CALL
  // ============================================================

  static Future<void> callAndTrack(
    String number,
    String? leadId,
    String? stageName,
  ) async {
    _isCallInProgress = false;
    _startApiSent = false;

    // ==========================================================
    // REQUEST PERMISSIONS
    // ==========================================================

    await _requestPermissions();

    // ==========================================================
    // RESET STATE
    // ==========================================================

    _isCallInProgress = false;

    // ==========================================================
    // START LISTENING BEFORE DIALER OPENS
    // ==========================================================

    await _subscription?.cancel();

    _subscription = PhoneState.stream.listen(
      (event) async {
        print("📞 Phone State: ${event.status}");

        switch (event.status) {
          // ====================================================
          // INCOMING CALL
          // ====================================================

          case PhoneStateStatus.CALL_INCOMING:
            _isCallInProgress = true;
            break;

          // ====================================================
          // CALL STARTED
          // ====================================================

          case PhoneStateStatus.CALL_STARTED:
            if (_startApiSent) return;

            _startApiSent = true;
            _isCallInProgress = true;

            print("📞 Call started/connected");

            // --------------------------------------------------
            // START LOCAL RECORDING
            // --------------------------------------------------

            await _startRecording(number: number, leadId: leadId);

            // --------------------------------------------------
            // EXISTING START CALL API
            // --------------------------------------------------

            try {
              await DioApi().startPostPhoneCall();

              print("✅ Start call API sent");
            } catch (e) {
              print("❌ Start call API failed: $e");
            }

            break;

          // ====================================================
          // CALL ENDED
          // ====================================================

          case PhoneStateStatus.CALL_ENDED:
            if (!_isCallInProgress) return;

            print("✅ Call ended");

            _isCallInProgress = false;

            // --------------------------------------------------
            // STOP RECORDING FIRST
            // --------------------------------------------------

            final recordingPath = await _stopRecording();

            if (recordingPath != null) {
              print("🎙️ Recording saved at:");
              print(recordingPath);
            } else {
              print("⚠️ No recording file was created");
            }

            // --------------------------------------------------
            // WAIT FOR CALL LOG TO UPDATE
            // --------------------------------------------------

            await Future.delayed(const Duration(seconds: 3));

            try {
              var now = DateTime.now();

              int from = now
                  .subtract(const Duration(hours: 1))
                  .millisecondsSinceEpoch;

              int to = now.millisecondsSinceEpoch;

              // ------------------------------------------------
              // GET CALL LOG ONLY FOR CRM-INITIATED NUMBER
              // ------------------------------------------------

              final Iterable<CallLogEntry> entries = await CallLog.query(
                number: number,
                dateFrom: from,
                dateTo: to,
              );

              Map<String, dynamic> data;

              // =================================================
              // CALL LOG FOUND
              // =================================================

              if (entries.isNotEmpty) {
                final log = entries.first;

                final int timestampMilliseconds = log.timestamp ?? 0;

                final DateTime callStartTime =
                    DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

                final int durationSeconds = log.duration ?? 0;

                final DateTime endedAt = callStartTime.add(
                  Duration(seconds: durationSeconds),
                );

                String status;
                String disposition;

                // ------------------------------------------------
                // DETERMINE CALL STATUS
                // ------------------------------------------------

                switch (log.callType) {
                  case CallType.outgoing:
                  case CallType.wifiOutgoing:
                    if (log.duration! > 0) {
                      status = 'completed';
                      disposition = 'connected';
                    } else {
                      status = 'failed';
                      disposition = 'not connected';
                    }
                    break;

                  case CallType.incoming:
                  case CallType.wifiIncoming:
                    if (log.duration! > 0) {
                      status = 'completed';
                      disposition = 'answered';
                    } else {
                      status = 'missed';
                      disposition = 'no answer';
                    }
                    break;

                  default:
                    status = 'failed';
                    disposition = 'unknown';
                }

                // =================================================
                // CREATE CALL DATA
                // =================================================

                data = {
                  "lead_id": leadId,
                  "to_number": log.number,

                  "from_number":
                      LocalStorage.sharedPreferences!.getInt('phone_number') ??
                      "no number found",

                  "direction": "outbound",

                  "duration": log.duration,

                  // Recording is local for now.
                  // We are NOT sending it to backend.
                  "recording_url": "",

                  "recording_path": recordingPath ?? "",

                  "status": status,

                  "userStatus": "idle",

                  "disposition": disposition,

                  "started_at": callStartTime.toIso8601String(),

                  "ended_at": endedAt.toIso8601String(),
                };
              }
              // =================================================
              // CALL LOG NOT FOUND
              // =================================================
              else {
                print("No call log found");

                data = {
                  "lead_id": leadId,

                  "number": number,

                  "duration": 0,

                  "timestamp": DateTime.now().millisecondsSinceEpoch,

                  "callType": "OUTGOING",

                  "userStatus": "idle",

                  "recording_path": recordingPath ?? "",

                  "note": "Call log not found",
                };
              }

              // =================================================
              // STORE DATA
              // =================================================

              PendingCallData.data = data;

              print("✅ DATA STORED: ${PendingCallData.data}");

              // =================================================
              // SHOW POST-CALL POPUP
              // =================================================

              final context = AppNavigator.key.currentContext;

              if (context != null) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return PopScope(
                      canPop: false,
                      child: Dialog(
                        insetPadding: const EdgeInsets.all(20),
                        child: PopupAfterCallUi(
                          leadId: leadId!,
                          stageName: stageName,
                        ),
                      ),
                    );
                  },
                );
              }
            } catch (e) {
              print("Error fetching call log: $e");

              // =================================================
              // FALLBACK DATA
              // =================================================

              PendingCallData.data = {
                "lead_id": leadId,

                "number": number,

                "duration": 0,

                "timestamp": DateTime.now().millisecondsSinceEpoch,

                "callType": "OUTGOING",

                "userStatus": "idle",

                "recording_path": recordingPath ?? "",

                "note": "Error: $e",
              };

              print("✅ FALLBACK DATA STORED");
            }

            // ==================================================
            // STOP PHONE STATE LISTENER
            // ==================================================

            await _subscription?.cancel();

            _subscription = null;

            break;

          // ====================================================
          // OTHER PHONE STATES
          // ====================================================

          default:
            break;
        }
      },
      onError: (error) {
        print("❌ Phone State Stream Error: $error");
      },
    );

    // ==========================================================
    // INITIATE PHONE CALL
    // ==========================================================

    bool? res = await FlutterPhoneDirectCaller.callNumber(number);

    print("📞 Call initiated: $res");
  }

  // ============================================================
  // START RECORDING
  // ============================================================

  static Future<void> _startRecording({
    required String number,
    String? leadId,
  }) async {
    try {
      // --------------------------------------------------------
      // Prevent duplicate recording
      // --------------------------------------------------------

      if (_isRecording) {
        print("⚠️ Recording already running");
        return;
      }

      // --------------------------------------------------------
      // Check microphone permission
      // --------------------------------------------------------

      final microphoneStatus = await Permission.microphone.status;

      if (!microphoneStatus.isGranted) {
        final result = await Permission.microphone.request();

        if (!result.isGranted) {
          print("❌ Microphone permission denied");

          return;
        }
      }

      // --------------------------------------------------------
      // Check recorder permission
      // --------------------------------------------------------

      final hasRecorderPermission = await _recorder.hasPermission();

      if (!hasRecorderPermission) {
        print("❌ Recorder permission denied");

        return;
      }

      // --------------------------------------------------------
      // Get application documents directory
      // --------------------------------------------------------

      final Directory appDirectory = await getApplicationDocumentsDirectory();

      // --------------------------------------------------------
      // Create recordings folder
      // --------------------------------------------------------

      final Directory recordingsDirectory = Directory(
        '${appDirectory.path}/call_recordings',
      );

      if (!await recordingsDirectory.exists()) {
        await recordingsDirectory.create(recursive: true);
      }

      // --------------------------------------------------------
      // Create unique filename
      // --------------------------------------------------------

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final safeNumber = number.replaceAll(RegExp(r'[^0-9+]'), '');

      final leadPart = leadId ?? 'unknown_lead';

      final fileName = 'call_${leadPart}_${safeNumber}_$timestamp.m4a';

      final filePath = '${recordingsDirectory.path}/$fileName';

      // --------------------------------------------------------
      // Start recording
      // --------------------------------------------------------

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          numChannels: 1,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: filePath,
      );

      _isRecording = true;

      _currentRecordingPath = filePath;

      print("🎙️ RECORDING STARTED");

      print("📁 Recording path:");

      print(filePath);
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;

      print("❌ Failed to start recording: $e");
    }
  }

  // ============================================================
  // STOP RECORDING
  // ============================================================

  static Future<String?> _stopRecording() async {
    try {
      if (!_isRecording) {
        print("ℹ️ No active recording");

        return null;
      }

      print("🛑 Stopping recording...");

      final String? path = await _recorder.stop();

      _isRecording = false;

      final savedPath = path ?? _currentRecordingPath;

      _currentRecordingPath = null;

      if (savedPath != null) {
        print("🎙️ RECORDING STOPPED");

        print("📁 Saved at:");

        print(savedPath);

        final file = File(savedPath);

        if (await file.exists()) {
          final size = await file.length();

          print("📦 Recording size: $size bytes");
        } else {
          print("⚠️ Recording file does not exist");
        }
      }

      return savedPath;
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;

      print("❌ Failed to stop recording: $e");

      return null;
    }
  }

  // ============================================================
  // REQUEST PERMISSIONS
  // ============================================================

  static Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.contacts,
      Permission.microphone,
    ].request();

    // ----------------------------------------------------------
    // Phone permission
    // ----------------------------------------------------------

    if (statuses[Permission.phone] != PermissionStatus.granted) {
      throw Exception("Phone permission not granted");
    }

    // ----------------------------------------------------------
    // Contacts permission
    // ----------------------------------------------------------

    if (statuses[Permission.contacts] != PermissionStatus.granted) {
      throw Exception("Contacts permission not granted");
    }

    // ----------------------------------------------------------
    // Microphone permission
    // ----------------------------------------------------------

    if (statuses[Permission.microphone] != PermissionStatus.granted) {
      throw Exception("Microphone permission not granted");
    }

    print("✅ Required permissions granted");
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  static Future<void> dispose() async {
    try {
      // --------------------------------------------------------
      // If somehow recording is active, stop it
      // --------------------------------------------------------

      if (_isRecording) {
        await _stopRecording();
      }

      // --------------------------------------------------------
      // Cancel phone state listener
      // --------------------------------------------------------

      await _subscription?.cancel();

      _subscription = null;

      _isCallInProgress = false;

      _startApiSent = false;

      print("🧹 CallHelper disposed");
    } catch (e) {
      print("Dispose Error: $e");
    }
  }
}
