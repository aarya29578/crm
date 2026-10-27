import 'dart:async';
import 'dart:io';
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/common_widgets/popup_after_call_ui.dart';
import 'package:crm_flutter/common_widgets/call_storage.dart';
import 'package:crm_flutter/helper/bottom_sheet_helper.dart';
import 'package:crm_flutter/helper/pending_outbound_call.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/home/HomeController.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:call_log/call_log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class CallHelper {
  static StreamSubscription<PhoneState>? _subscription;
  static bool _isCallInProgress = false;
  static bool _reconcileInProgress = false;
  static bool _formOpen = false;
  static bool _submissionInProgress = false;
  static String? _endingSessionId;
  static PhoneStateStatus? _lastPhoneStateStatus;
  static PendingOutboundCall? _currentSession;
  static _CallLifecycleObserver? _lifecycleObserver;

  static PendingOutboundCallStore get _sessionStore {
    final preferences = LocalStorage.sharedPreferences;
    if (preferences == null) {
      throw StateError('Local preferences are not initialized');
    }
    return PendingOutboundCallStore(preferences);
  }

  static void initialize() {
    if (_lifecycleObserver != null) return;
    _lifecycleObserver = _CallLifecycleObserver();
    WidgetsBinding.instance.addObserver(_lifecycleObserver!);
    _log('initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(reconcilePendingSession());
    });
  }

  static void _log(String event, {String? sessionId, String? detail}) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint(
      '[call-session] $timestamp event=$event'
      '${sessionId == null ? '' : ' session=$sessionId'}'
      '${detail == null ? '' : ' detail=$detail'}',
    );
  }

  static void _showMessage(String message) {
    if (Get.context != null) {
      Get.snackbar('Call tracking', message, snackPosition: SnackPosition.TOP);
    }
  }

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
    if (number.trim().isEmpty) {
      _showMessage('A phone number is required to start a call.');
      return;
    }
    if (leadId == null || leadId.trim().isEmpty) {
      _showMessage('This call cannot be tracked because the lead is missing.');
      return;
    }

    try {
      await _requestPermissions();
    } catch (error) {
      _log('permission_denied', detail: error.runtimeType.toString());
      _showMessage(
        'Required phone, contacts, and microphone permissions are needed.',
      );
      return;
    }

    final existing = await _sessionStore.load();
    if (existing != null) {
      _log('existing_session_blocks_new_call', sessionId: existing.sessionId);
      await reconcilePendingSession();
      _showMessage('Finish or retry the pending call before starting another.');
      return;
    }

    final session = PendingOutboundCall.create(
      leadId: leadId,
      phoneNumber: number,
      stageName: stageName,
      startedAt: DateTime.now(),
    );
    await _sessionStore.save(session);
    _currentSession = session;
    _isCallInProgress = false;
    _lastPhoneStateStatus = null;
    _log('session_created', sessionId: session.sessionId);

    try {
      await _ensurePhoneStateListener();
    } catch (error) {
      _log(
        'phone_state_listener_start_failed',
        sessionId: session.sessionId,
        detail: error.runtimeType.toString(),
      );
    }

    try {
      final launched = await FlutterPhoneDirectCaller.callNumber(number);
      _log(
        'phone_app_launch_result',
        sessionId: session.sessionId,
        detail: launched == true ? 'launched' : 'not_launched',
      );
      if (launched != true) {
        await _sessionStore.clear(session.sessionId);
        _currentSession = null;
        _showMessage('The phone app could not start the call.');
      }
    } catch (error) {
      _log('phone_app_launch_failed', sessionId: session.sessionId);
      rethrow;
    }
  }

  static Future<void> _ensurePhoneStateListener() async {
    if (_subscription != null) return;
    _subscription = PhoneState.stream.listen(
      (event) => unawaited(
        _handlePhoneState(event).catchError((Object error) {
          _log(
            'phone_state_handling_failed',
            sessionId: _currentSession?.sessionId,
            detail: error.runtimeType.toString(),
          );
          _showMessage(
            'Call completion could not be processed. The pending session remains saved.',
          );
        }),
      ),
      onError: (Object error) {
        _log('phone_state_stream_error', detail: error.runtimeType.toString());
      },
    );
  }

  static Future<void> _handlePhoneState(PhoneState event) async {
    final session = _currentSession ?? await _sessionStore.load();
    if (session == null) return;
    _currentSession = session;
    if (_lastPhoneStateStatus != event.status) {
      _log(
        'phone_state',
        sessionId: session.sessionId,
        detail: event.status.name,
      );
      _lastPhoneStateStatus = event.status;
    }

    if (event.status == PhoneStateStatus.CALL_STARTED) {
      _isCallInProgress = true;
      if (session.connectedAt == null) {
        _currentSession = session.copyWith(
          connectedAt: DateTime.now(),
          startCallApiSent: true,
        );
        await _sessionStore.save(_currentSession!);
        await _startRecording(
          number: session.phoneNumber,
          leadId: session.leadId,
        );
        try {
          await DioApi().startPostPhoneCall();
          _log('start_call_api_succeeded', sessionId: session.sessionId);
        } catch (error) {
          _log(
            'start_call_api_failed',
            sessionId: session.sessionId,
            detail: error.runtimeType.toString(),
          );
        }
      } else if (!session.startCallApiSent) {
        _currentSession = session.copyWith(startCallApiSent: true);
        await _sessionStore.save(_currentSession!);
        try {
          await DioApi().startPostPhoneCall();
          _log('start_call_api_succeeded', sessionId: session.sessionId);
        } catch (error) {
          _log(
            'start_call_api_failed',
            sessionId: session.sessionId,
            detail: error.runtimeType.toString(),
          );
        }
      }
      return;
    }

    if (event.status == PhoneStateStatus.CALL_ENDED && _isCallInProgress) {
      _isCallInProgress = false;
      if (_endingSessionId == session.sessionId) return;
      _endingSessionId = session.sessionId;
      try {
        final endedSession = session.copyWith(endedAt: DateTime.now());
        await _sessionStore.save(endedSession);
        _currentSession = endedSession;
        _log('call_end_detected', sessionId: session.sessionId);
        final recordingPath = await _stopRecording();
        await _resolveEndedSession(endedSession, recordingPath: recordingPath);
      } finally {
        _endingSessionId = null;
      }
    }
  }

  static Future<void> reconcilePendingSession() async {
    if (_reconcileInProgress) return;
    _reconcileInProgress = true;
    try {
      final session = await _sessionStore.load();
      if (session == null) return;
      _currentSession = session;
      _log('session_restored', sessionId: session.sessionId);
      await _ensurePhoneStateListener();
      if (session.callData != null) {
        PendingCallData.data = Map<String, dynamic>.from(session.callData!);
        PendingCallData.outboundSessionId = session.sessionId;
        _showPostCallForm(session);
        return;
      }
      await _resolveEndedSession(session);
    } catch (error) {
      _log('session_restore_failed', detail: error.runtimeType.toString());
      _showMessage('The pending call could not be restored. It remains saved.');
    } finally {
      _reconcileInProgress = false;
    }
  }

  static Future<void> _resolveEndedSession(
    PendingOutboundCall session, {
    String? recordingPath,
  }) async {
    final permission = await Permission.phone.status;
    if (!permission.isGranted) {
      _log('call_log_permission_missing', sessionId: session.sessionId);
      _showMessage('Call-log permission is needed to complete call tracking.');
      return;
    }

    await Future<void>.delayed(const Duration(seconds: 3));
    try {
      final now = DateTime.now();
      final entries = await CallLog.query(
        dateFrom: session.startedAt
            .subtract(const Duration(minutes: 2))
            .millisecondsSinceEpoch,
        dateTo: now.add(const Duration(seconds: 30)).millisecondsSinceEpoch,
      );
      final entry = PendingOutboundCall.matchCallLogEntry(
        session: session,
        entries: entries,
        now: now,
      );
      if (entry == null) {
        _log('call_log_entry_missing', sessionId: session.sessionId);
        _showMessage(
          'The device call record is not available yet. The pending call was kept for retry.',
        );
        return;
      }

      final data = PendingOutboundCall.callPayloadForEntry(
        session: session,
        entry: entry,
        fromNumber:
            LocalStorage.sharedPreferences?.getInt('phone_number') ??
            'no number found',
        recordingPath: recordingPath,
      );
      final readySession = session.copyWith(
        endedAt: session.endedAt ?? now,
        callData: data,
      );
      await _sessionStore.save(readySession);
      _currentSession = readySession;
      PendingCallData.data = data;
      PendingCallData.outboundSessionId = session.sessionId;
      _log(
        'call_log_matched',
        sessionId: session.sessionId,
        detail: 'duration=${data['duration']}',
      );
      _showPostCallForm(readySession);
    } on PlatformException catch (error) {
      _log(
        'call_log_query_failed',
        sessionId: session.sessionId,
        detail: error.code,
      );
      _showMessage(
        'Android could not read the call record. The pending call was kept for retry.',
      );
    } catch (error) {
      _log(
        'call_log_query_failed',
        sessionId: session.sessionId,
        detail: error.runtimeType.toString(),
      );
      _showMessage(
        'The call record could not be read. The pending call was kept for retry.',
      );
    }
  }

  static void _showPostCallForm(PendingOutboundCall session) {
    if (_formOpen) return;
    final context = AppNavigator.key.currentContext;
    if (context == null ||
        !Get.isRegistered<HomeController>() ||
        !Get.isRegistered<AllocationController>() ||
        !Get.isRegistered<Leaddetailscontroller>()) {
      _log('post_call_form_waiting_for_app', sessionId: session.sessionId);
      return;
    }

    _formOpen = true;
    _log('post_call_form_open', sessionId: session.sessionId);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: PopupAfterCallUi(
            leadId: session.leadId,
            stageName: session.stageName,
          ),
        ),
      ).whenComplete(() {
        _formOpen = false;
      }),
    );
  }

  static Future<void> submitPendingCall(Map<String, dynamic> callData) async {
    if (_submissionInProgress) {
      throw StateError('A call submission is already in progress');
    }
    final session = await _sessionStore.load();
    if (session == null || session.callData == null) {
      throw StateError('No persisted outbound call is ready to submit');
    }

    _submissionInProgress = true;
    try {
      final previousAttempt = session.submissionStartedAt;
      if (previousAttempt != null &&
          await _verifyCallSaved(session, previousAttempt)) {
        await _sessionStore.clear(session.sessionId);
        _currentSession = null;
        PendingCallData.data = null;
        PendingCallData.outboundSessionId = null;
        _log(
          'call_api_saved_and_verified_on_retry',
          sessionId: session.sessionId,
        );
        return;
      }

      final attemptAt = DateTime.now();
      final submission = session.copyWith(
        submissionStartedAt: attemptAt,
        callData: Map<String, dynamic>.from(callData),
      );
      await _sessionStore.save(submission);
      _log('call_api_request', sessionId: session.sessionId);
      await DioApi().postPhoneCall(callData, idempotencyKey: session.sessionId);
      final verified = await _verifyCallSaved(submission, attemptAt);
      if (!verified) {
        _log('call_api_record_not_verified', sessionId: session.sessionId);
        throw StateError(
          'The server accepted the request but the saved call was not found in the lead timeline.',
        );
      }

      await _sessionStore.clear(session.sessionId);
      _currentSession = null;
      PendingCallData.data = null;
      PendingCallData.outboundSessionId = null;
      _log('call_api_saved_and_verified', sessionId: session.sessionId);
    } catch (error) {
      _log(
        'call_api_failed_or_unverified',
        sessionId: session.sessionId,
        detail: error.runtimeType.toString(),
      );
      rethrow;
    } finally {
      _submissionInProgress = false;
    }
  }

  static Future<bool> _verifyCallSaved(
    PendingOutboundCall session,
    DateTime attemptAt,
  ) async {
    final timeline = await DioApi().getLeadTimeline(session.leadId);
    debugPrint(
      '[call-session] ${DateTime.now().toIso8601String()} '
      'event=timeline_verification_response '
      'success=${timeline.success} entries=${timeline.data.length}',
    );
    if (timeline.success != true) {
      debugPrint(
        '[call-session] ${DateTime.now().toIso8601String()} '
        'event=timeline_verification_result result=false '
        'failed_conditions=[timeline.success_is_true]',
      );
      return false;
    }

    final expectedDuration = session.callData?['duration'];
    final expectedSeconds = _normalizeDurationSeconds(expectedDuration);
    final expectedStatus = session.callData?['status']?.toString();
    final failedConditions = <String>{};
    var candidateCount = 0;
    final verified = timeline.data.any((entry) {
      candidateCount++;
      final createdAt = entry.createdAt;
      final callLog = entry.callLog;
      final actualDuration = callLog?.duration;
      final seconds = _normalizeDurationSeconds(actualDuration);
      final leadMatches = entry.leadId == session.leadId;
      final actualDirection = callLog?.direction;
      final directionMatches =
          actualDirection?.toLowerCase() == 'outbound';
      final durationMatches =
          (expectedSeconds != null &&
              seconds != null &&
              seconds == expectedSeconds) ||
          (expectedStatus == 'failed' &&
              expectedSeconds == 0 &&
              actualDuration == null);
      final actualStatus = callLog?.status;
      final statusMatches = actualStatus == expectedStatus;
      final earliestCreatedAt = attemptAt.subtract(
        const Duration(seconds: 30),
      );
      final latestCreatedAt = DateTime.now().add(
        const Duration(seconds: 30),
      );
      final createdAtAfterStart =
          createdAt != null && !createdAt.isBefore(earliestCreatedAt);
      final createdAtBeforeEnd =
          createdAt != null &&
          !createdAt.isAfter(DateTime.now().add(const Duration(seconds: 30)));
      final conditions = <String, bool>{
        'call_log_present': callLog != null,
        'created_at_present': createdAt != null,
        'lead_id_matches': leadMatches,
        'direction_matches': directionMatches,
        'duration_matches': durationMatches,
        'status_matches': statusMatches,
        'created_at_after_start': createdAtAfterStart,
        'created_at_before_end': createdAtBeforeEnd,
      };
      final candidateFailures = conditions.entries
          .where((condition) => !condition.value)
          .map((condition) => condition.key)
          .toList();
      failedConditions.addAll(candidateFailures);
      debugPrint(
        '[call-session] ${DateTime.now().toIso8601String()} '
        'event=timeline_verification_candidate '
        'candidate=$candidateCount '
        'lead_id_matches=$leadMatches '
        'expected_direction=outbound actual_direction=$actualDirection '
        'direction_matches=$directionMatches '
        'expected_duration=$expectedDuration actual_duration=$actualDuration '
        'expected_duration_seconds=$expectedSeconds '
        'actual_duration_seconds=$seconds duration_matches=$durationMatches '
        'expected_status=$expectedStatus actual_status=$actualStatus '
        'status_matches=$statusMatches '
        'expected_created_at_window=$earliestCreatedAt..$latestCreatedAt '
        'actual_created_at=$createdAt '
        'created_at_after_start=$createdAtAfterStart '
        'created_at_before_end=$createdAtBeforeEnd '
        'condition_results=$conditions',
      );
      return createdAt != null &&
          callLog != null &&
          leadMatches &&
          directionMatches &&
          durationMatches &&
          statusMatches &&
          !createdAt.isBefore(
            attemptAt.subtract(const Duration(seconds: 30)),
          ) &&
          !createdAt.isAfter(DateTime.now().add(const Duration(seconds: 30)));
    });
    final finalFailures = verified
        ? <String>[]
        : candidateCount == 0
        ? <String>['no_timeline_entries']
        : failedConditions.toList();
    debugPrint(
      '[call-session] ${DateTime.now().toIso8601String()} '
      'event=timeline_verification_result result=$verified '
      'candidates_checked=$candidateCount '
      'failed_conditions=$finalFailures',
    );
    return verified;
  }

  static int? _normalizeDurationSeconds(Object? duration) {
    return switch (duration) {
      final int value => value,
      final String value => int.tryParse(value.trim()),
      _ => null,
    };
  }

  static Future<void> onAppResumed() async {
    _log('app_lifecycle', detail: 'resumed');
    await reconcilePendingSession();
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
        _log('local_recording_already_active');
        return;
      }

      // --------------------------------------------------------
      // Check microphone permission
      // --------------------------------------------------------

      final microphoneStatus = await Permission.microphone.status;

      if (!microphoneStatus.isGranted) {
        final result = await Permission.microphone.request();

        if (!result.isGranted) {
          _log('microphone_permission_denied');

          return;
        }
      }

      // --------------------------------------------------------
      // Check recorder permission
      // --------------------------------------------------------

      final hasRecorderPermission = await _recorder.hasPermission();

      if (!hasRecorderPermission) {
        _log('recorder_permission_denied');

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

      _log('local_recording_started');
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;

      _log('local_recording_start_failed', detail: e.runtimeType.toString());
    }
  }

  // ============================================================
  // STOP RECORDING
  // ============================================================

  static Future<String?> _stopRecording() async {
    try {
      if (!_isRecording) {
        _log('local_recording_not_active');

        return null;
      }

      _log('local_recording_stopping');

      final String? path = await _recorder.stop();

      _isRecording = false;

      final savedPath = path ?? _currentRecordingPath;

      _currentRecordingPath = null;

      if (savedPath != null) {
        _log('local_recording_stopped');

        final file = File(savedPath);

        if (await file.exists()) {
          final size = await file.length();

          _log('local_recording_saved', detail: 'bytes=$size');
        } else {
          _log('local_recording_file_missing');
        }
      }

      return savedPath;
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;

      _log('local_recording_stop_failed', detail: e.runtimeType.toString());

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

    _log('required_permissions_granted');
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

      _log('phone_state_listener_disposed');
    } catch (e) {
      _log('dispose_failed', detail: e.runtimeType.toString());
    }
  }
}

class _CallLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    CallHelper._log('app_lifecycle', detail: state.name);
    if (state == AppLifecycleState.resumed) {
      unawaited(CallHelper.onAppResumed());
    }
  }
}
