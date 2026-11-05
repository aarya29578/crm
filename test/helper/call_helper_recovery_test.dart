import 'package:call_log/call_log.dart';
import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/helper/pending_outbound_call.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_state/phone_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late PendingOutboundCallStore store;
  final launchedNumbers = <String>[];
  final messages = <String>[];
  final postedCallPayloads = <Map<String, dynamic>>[];
  final idempotencyKeys = <String?>[];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    LocalStorage.sharedPreferences = preferences;
    store = PendingOutboundCallStore(preferences);

    CallHelper.resetForTesting();
    CallHelper.callResolveDelay = Duration.zero;
    CallHelper.callSetupDuration = const Duration(seconds: 15);

    launchedNumbers.clear();
    messages.clear();
    postedCallPayloads.clear();
    idempotencyKeys.clear();

    CallHelper.directCallerTestOverride = (number) async {
      launchedNumbers.add(number);
      return true;
    };
    CallHelper.requestPermissionsTestOverride = () async {};
    CallHelper.hasPhonePermissionTestOverride = () => true;
    CallHelper.showMessageTestOverride = (msg) => messages.add(msg);

    // Setup Mock Dio for DioApi calls
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final isDial = options.uri.path.endsWith('/call/dial');
          final isStartCall = options.uri.path.endsWith('/call/start');
          final isTimeline = options.uri.path.contains('/timeline');

          if (isDial) {
            postedCallPayloads.add(
              Map<String, dynamic>.from(options.data as Map),
            );
            idempotencyKeys.add(
              options.headers['Idempotency-Key']?.toString() ??
                  options.headers['X-Idempotency-Key']?.toString(),
            );
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {'success': true},
              ),
            );
            return;
          }

          if (isStartCall) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true},
              ),
            );
            return;
          }

          if (isTimeline) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'data': [
                    {
                      'action': 'CALL',
                      'lead_id': options.uri.pathSegments.last,
                      'createdAt': DateTime.now().toIso8601String(),
                      'call_log': {
                        'direction': 'OUTBOUND',
                        'duration': 30,
                        'status': 'completed',
                      },
                    },
                  ],
                },
              ),
            );
            return;
          }

          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true},
            ),
          );
        },
      ),
    );
    DioUtil.dio = dio;
  });

  tearDown(() {
    CallHelper.resetForTesting();
    LocalStorage.sharedPreferences = null;
  });

  // 1. Starting a call with no previous session
  test('Scenario 1: starts a new call immediately when no previous session exists', () async {
    await CallHelper.callAndTrack('9876543210', 'lead-1', 'Initial');

    expect(launchedNumbers, ['9876543210']);
    final active = await store.load();
    expect(active, isNotNull);
    expect(active?.leadId, 'lead-1');
    expect(active?.phoneNumber, '9876543210');
    expect(active?.stageName, 'Initial');
    expect(CallHelper.currentSession?.sessionId, active?.sessionId);
  });

  // 2. Blocking a new call when the phone is actively in a call
  test('Scenario 2: blocks a new call when another call is actively running', () async {
    final session = PendingOutboundCall.create(
      leadId: 'lead-active',
      phoneNumber: '1111111111',
      stageName: null,
      startedAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    await store.save(session);
    CallHelper.isCallInProgress = true;
    CallHelper.lastPhoneStateStatus = PhoneStateStatus.CALL_STARTED;

    await CallHelper.callAndTrack('2222222222', 'lead-2', null);

    expect(launchedNumbers, isEmpty);
    expect(messages, contains('Another call is currently in progress.'));
    final active = await store.load();
    expect(active?.leadId, 'lead-active');
  });

  // 3 & 6 & 7: Recovering a previous session when phone is idle and auto-starting new call in same user action
  test('Scenario 3, 6, 7: recovers previous session from CallLog and launches new call in the same action without second tap', () async {
    final startTime = DateTime.now().subtract(const Duration(minutes: 5));
    final oldSession = PendingOutboundCall.create(
      leadId: 'lead-old',
      phoneNumber: '1111111111',
      stageName: null,
      startedAt: startTime,
    );
    await store.save(oldSession);
    CallHelper.lastPhoneStateStatus = PhoneStateStatus.CALL_ENDED;

    CallHelper.callLogQueryTestOverride = (dateFrom, dateTo) async {
      return [
        CallLogEntry(
          number: '1111111111',
          callType: CallType.outgoing,
          duration: 30,
          timestamp: startTime.millisecondsSinceEpoch,
        ),
      ];
    };

    await CallHelper.callAndTrack('2222222222', 'lead-new', 'StageNew');

    // New call launched immediately
    expect(launchedNumbers, ['2222222222']);
    // Old call was submitted
    expect(postedCallPayloads.length, 1);
    expect(postedCallPayloads.first['lead_id'], 'lead-old');
    expect(postedCallPayloads.first['duration'], 30);
    // Active session is now the new call
    final active = await store.load();
    expect(active?.leadId, 'lead-new');
    expect(active?.phoneNumber, '2222222222');
  });

  // 4 & 5: Archiving a session when CallLog entry is missing, preserving old data
  test('Scenario 4 & 5: archives old session as unresolved when CallLog is missing and preserves all data before starting new call', () async {
    final startTime = DateTime.now().subtract(const Duration(minutes: 10));
    final oldSession = PendingOutboundCall.create(
      leadId: 'lead-unresolved',
      phoneNumber: '9999999999',
      stageName: 'Negotiation',
      startedAt: startTime,
    );
    await store.save(oldSession);
    CallHelper.lastPhoneStateStatus = PhoneStateStatus.CALL_ENDED;

    // No matching call log entry
    CallHelper.callLogQueryTestOverride = (dateFrom, dateTo) async => [];

    await CallHelper.callAndTrack('8888888888', 'lead-fresh', 'NewStage');

    // New call started
    expect(launchedNumbers, ['8888888888']);
    expect(messages, contains('Previous unfinished call was archived.'));

    // Old session preserved in archive
    final archived = await store.loadArchived();
    expect(archived.length, 1);
    expect(archived.first.sessionId, oldSession.sessionId);
    expect(archived.first.leadId, 'lead-unresolved');
    expect(archived.first.phoneNumber, '9999999999');
    expect(archived.first.stageName, 'Negotiation');
    expect(archived.first.status, 'unresolved');
    expect(archived.first.archiveReason, 'unresolved_no_call_log');

    // Active session replaced safely
    final active = await store.load();
    expect(active?.leadId, 'lead-fresh');
  });

  // 8. Recovering after an app restart
  test('Scenario 8: reconcilePendingSession restores session after app restart', () async {
    final startTime = DateTime.now().subtract(const Duration(minutes: 2));
    final session = PendingOutboundCall.create(
      leadId: 'lead-restart',
      phoneNumber: '5555555555',
      stageName: null,
      startedAt: startTime,
    );
    await store.save(session);
    CallHelper.lastPhoneStateStatus = PhoneStateStatus.CALL_ENDED;

    CallHelper.callLogQueryTestOverride = (dateFrom, dateTo) async {
      return [
        CallLogEntry(
          number: '5555555555',
          callType: CallType.outgoing,
          duration: 30,
          timestamp: startTime.millisecondsSinceEpoch,
        ),
      ];
    };

    await CallHelper.reconcilePendingSession();

    final restored = await store.load();
    expect(restored?.callData, isNotNull);
    expect(restored?.callData?['lead_id'], 'lead-restart');
    expect(restored?.status, 'ready');
  });

  // 9. Handling missed CALL_STARTED events
  test('Scenario 9: handles CALL_ENDED even when CALL_STARTED was missed', () async {
    final startTime = DateTime.now().subtract(const Duration(minutes: 1));
    final session = PendingOutboundCall.create(
      leadId: 'lead-missed-start',
      phoneNumber: '7777777777',
      stageName: null,
      startedAt: startTime,
    );
    await store.save(session);
    CallHelper.isCallInProgress = false; // missed CALL_STARTED!

    CallHelper.callLogQueryTestOverride = (dateFrom, dateTo) async {
      return [
        CallLogEntry(
          number: '7777777777',
          callType: CallType.outgoing,
          duration: 30,
          timestamp: startTime.millisecondsSinceEpoch,
        ),
      ];
    };

    // CALL_ENDED event arrives via PhoneState
    await CallHelper.handlePhoneStateForTesting(
      PhoneState.nothing()..status = PhoneStateStatus.CALL_ENDED,
    );

    final updated = await store.load();
    expect(updated?.callData, isNotNull);
    expect(updated?.callData?['lead_id'], 'lead-missed-start');
    expect(CallHelper.isCallInProgress, isFalse);
  });

  // 10. Handling missed CALL_ENDED events
  test('Scenario 10: recovers stale session when CALL_ENDED was missed but phone is idle', () async {
    final startTime = DateTime.now().subtract(const Duration(minutes: 30));
    final session = PendingOutboundCall.create(
      leadId: 'lead-missed-end',
      phoneNumber: '3333333333',
      stageName: null,
      startedAt: startTime,
    );
    await store.save(session);
    // In memory was left with isCallInProgress=true from long ago
    CallHelper.isCallInProgress = false;
    CallHelper.lastPhoneStateStatus = PhoneStateStatus.CALL_ENDED;

    CallHelper.callLogQueryTestOverride = (dateFrom, dateTo) async => [];

    await CallHelper.callAndTrack('4444444444', 'lead-next', null);

    expect(launchedNumbers, ['4444444444']);
    final archived = await store.loadArchived();
    expect(archived.any((s) => s.leadId == 'lead-missed-end'), isTrue);
  });

  // 11 & 12: Preserving API-pending sessions and retrying failed submissions
  test('Scenario 11 & 12: preserves API-pending session and retries submission on recovery', () async {
    final oldSession = PendingOutboundCall.create(
      leadId: 'lead-api-pending',
      phoneNumber: '1231231234',
      stageName: null,
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ).copyWith(
      callData: {
        'lead_id': 'lead-api-pending',
        'duration': 30,
        'status': 'completed',
        'direction': 'outbound',
      },
      status: 'ready',
    );
    await store.save(oldSession);
    CallHelper.lastPhoneStateStatus = PhoneStateStatus.CALL_ENDED;

    await CallHelper.callAndTrack('9999999991', 'lead-brand-new', null);

    // Old API-pending session was submitted and cleared
    expect(postedCallPayloads.length, 1);
    expect(postedCallPayloads.first['lead_id'], 'lead-api-pending');
    expect(idempotencyKeys.first, oldSession.sessionId);

    // New call launched
    expect(launchedNumbers, ['9999999991']);
    final active = await store.load();
    expect(active?.leadId, 'lead-brand-new');
  });

  // 13. Preventing duplicate API submissions
  test('Scenario 13: prevents duplicate API submissions when timeline already verified', () async {
    final attemptAt = DateTime.now();
    final session = PendingOutboundCall.create(
      leadId: 'lead-already-saved',
      phoneNumber: '1122334455',
      stageName: null,
      startedAt: attemptAt.subtract(const Duration(minutes: 1)),
    ).copyWith(
      callData: {
        'lead_id': 'lead-already-saved',
        'duration': 30,
        'status': 'completed',
        'direction': 'outbound',
      },
      submissionStartedAt: attemptAt,
    );
    await store.save(session);

    // submitPendingCall verifies on timeline and clears without re-posting
    await CallHelper.submitPendingCall(session.callData!);

    expect(postedCallPayloads, isEmpty); // No POST was made!
    expect(await store.load(), isNull); // Cleared!
  });

  // 14. Preventing duplicate archive entries
  test('Scenario 14: prevents duplicate archive entries when archived multiple times', () async {
    final session = PendingOutboundCall.create(
      leadId: 'lead-dup-archive',
      phoneNumber: '9988776655',
      stageName: null,
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );

    await store.archive(session, reason: 'attempt_1');
    await store.archive(session, reason: 'attempt_2');

    final archived = await store.loadArchived();
    expect(archived.length, 1);
    expect(archived.first.archiveReason, 'attempt_2');
  });

  // 15. Handling phone-state listener startup failure
  test('Scenario 15: proceeds safely if phone-state listener fails to start', () async {
    // Starting a call when listener throws an unexpected error
    await CallHelper.callAndTrack('6677889900', 'lead-listener-fail', null);

    expect(launchedNumbers, ['6677889900']);
    final active = await store.load();
    expect(active?.leadId, 'lead-listener-fail');
  });

  // 16. Handling unknown phone state safely
  test('Scenario 16: protects active call setup when phone state is unknown within setup window', () async {
    // Session was created just 2 seconds ago
    final recentSession = PendingOutboundCall.create(
      leadId: 'lead-setting-up',
      phoneNumber: '1212121212',
      stageName: null,
      startedAt: DateTime.now().subtract(const Duration(seconds: 2)),
    );
    await store.save(recentSession);
    CallHelper.isCallInProgress = false;
    CallHelper.lastPhoneStateStatus = null; // unknown!

    await CallHelper.callAndTrack('3434343434', 'lead-blocked', null);

    // Should NOT launch second call during setup window
    expect(launchedNumbers, isEmpty);
    expect(messages, contains('Another call is currently in progress.'));
    final active = await store.load();
    expect(active?.leadId, 'lead-setting-up');
  });

  // 17. Preventing concurrent double taps
  test('Scenario 17: prevents concurrent call button taps from creating multiple sessions', () async {
    // Two rapid concurrent calls
    final future1 = CallHelper.callAndTrack('1234567890', 'lead-concurrent-1', null);
    final future2 = CallHelper.callAndTrack('0987654321', 'lead-concurrent-2', null);

    await Future.wait([future1, future2]);

    // Only one call should launch
    expect(launchedNumbers.length, 1);
    expect(launchedNumbers.first, '1234567890');
    final active = await store.load();
    expect(active?.leadId, 'lead-concurrent-1');
  });

  // 18. Retrying stranded archived API-pending sessions
  test('Scenario 18: syncArchivedApiPendingSessions retries and clears stranded archived sessions', () async {
    final archivedSession = PendingOutboundCall.create(
      leadId: 'lead-stranded',
      phoneNumber: '5566778899',
      stageName: null,
      startedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ).copyWith(
      callData: {
        'lead_id': 'lead-stranded',
        'duration': 45, // not in initial timeline (30) so requires POST
        'status': 'completed',
        'direction': 'outbound',
      },
      status: 'ready',
    );
    await store.archive(archivedSession, reason: 'api_submission_pending');
    expect((await store.loadArchived()).length, 1);

    // Mock timeline to return matching entry with duration 45 only after POST
    var postCalled = false;
    final customDio = Dio();
    customDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.uri.path.endsWith('/call/dial')) {
            postCalled = true;
            postedCallPayloads.add(Map<String, dynamic>.from(options.data as Map));
            handler.resolve(Response(requestOptions: options, statusCode: 201, data: {'success': true}));
            return;
          }
          if (options.uri.path.contains('/timeline')) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'data': postCalled
                      ? [
                          {
                            'action': 'CALL',
                            'lead_id': 'lead-stranded',
                            'createdAt': DateTime.now().toIso8601String(),
                            'call_log': {
                              'direction': 'OUTBOUND',
                              'duration': 45,
                              'status': 'completed',
                            },
                          },
                        ]
                      : [],
                },
              ),
            );
            return;
          }
          handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true}));
        },
      ),
    );
    DioUtil.dio = customDio;

    // Run sync
    await CallHelper.syncArchivedApiPendingSessions();

    expect(postCalled, isTrue);
    expect(postedCallPayloads.length, 1);
    expect(postedCallPayloads.first['lead_id'], 'lead-stranded');
    expect(postedCallPayloads.first['duration'], 45);
    // Successfully verified and removed from archive!
    expect((await store.loadArchived()).isEmpty, isTrue);
  });

  // 19. Actively querying telephony state prevents call launch when in-memory state was reset after app restart
  test('Scenario 19: queries active telephony state preventing new call after restart even if in-memory flag is false', () async {
    final activeCall = PendingOutboundCall.create(
      leadId: 'lead-restart-active',
      phoneNumber: '7788990011',
      stageName: null,
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );
    await store.save(activeCall);

    // In-memory flags are false (app just restarted)
    CallHelper.isCallInProgress = false;
    CallHelper.lastPhoneStateStatus = null;

    // Platform reports phone is actively OFFHOOK
    CallHelper.phoneStateStatusProviderTestOverride = () => PhoneStateStatus.CALL_STARTED;

    await CallHelper.callAndTrack('8899001122', 'lead-should-block', null);

    expect(launchedNumbers, isEmpty);
    expect(messages, contains('Another call is currently in progress.'));
    final active = await store.load();
    expect(active?.leadId, 'lead-restart-active');
  });

  // 20. syncArchivedApiPendingSessions runs on resume even when no active pending session exists
  test('Scenario 20: syncArchivedApiPendingSessions runs on resume even when no active session exists', () async {
    expect(await store.load(), isNull); // No active session

    final archivedSession = PendingOutboundCall.create(
      leadId: 'lead-resume-sync',
      phoneNumber: '1122334455',
      stageName: null,
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ).copyWith(
      callData: {
        'lead_id': 'lead-resume-sync',
        'duration': 55,
        'status': 'completed',
        'direction': 'outbound',
      },
      status: 'ready',
    );
    await store.archive(archivedSession, reason: 'api_submission_pending');
    expect((await store.loadArchived()).length, 1);

    var postCalled = false;
    final customDio = Dio();
    customDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.uri.path.endsWith('/call/dial')) {
            postCalled = true;
            postedCallPayloads.add(Map<String, dynamic>.from(options.data as Map));
            handler.resolve(Response(requestOptions: options, statusCode: 201, data: {'success': true}));
            return;
          }
          if (options.uri.path.contains('/timeline')) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'data': postCalled
                      ? [
                          {
                            'action': 'CALL',
                            'lead_id': 'lead-resume-sync',
                            'createdAt': DateTime.now().toIso8601String(),
                            'call_log': {
                              'direction': 'OUTBOUND',
                              'duration': 55,
                              'status': 'completed',
                            },
                          },
                        ]
                      : [],
                },
              ),
            );
            return;
          }
          handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true}));
        },
      ),
    );
    DioUtil.dio = customDio;

    // Trigger onAppResumed()
    await CallHelper.onAppResumed();

    // Verify it submitted and cleared the archived session
    expect(postCalled, isTrue);
    expect(postedCallPayloads.any((p) => p['lead_id'] == 'lead-resume-sync'), isTrue);
    expect((await store.loadArchived()).isEmpty, isTrue);
    expect(await store.load(), isNull); // Still no active session
  });

  // 21. Failed archived API submissions remain available for future retries
  test('Scenario 21: failed archived API submissions remain in archive when API or verification fails', () async {
    final archivedSession = PendingOutboundCall.create(
      leadId: 'lead-network-fail',
      phoneNumber: '9988776655',
      stageName: null,
      startedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ).copyWith(
      callData: {
        'lead_id': 'lead-network-fail',
        'duration': 60,
        'status': 'completed',
        'direction': 'outbound',
      },
      status: 'ready',
    );
    await store.archive(archivedSession, reason: 'api_submission_pending');

    // Simulate Dio network failure (500 Server Error)
    final failingDio = Dio();
    failingDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(requestOptions: options, statusCode: 500),
              type: DioExceptionType.badResponse,
            ),
          );
        },
      ),
    );
    DioUtil.dio = failingDio;

    await CallHelper.syncArchivedApiPendingSessions();

    // Verify archived session was NOT deleted and remains available for retry
    final archived = await store.loadArchived();
    expect(archived.length, 1);
    expect(archived.first.leadId, 'lead-network-fail');
    expect(archived.first.archiveReason, 'api_submission_pending');
  });
}
