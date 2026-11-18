import 'package:call_log/call_log.dart';
import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/common_widgets/call_storage.dart';
import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/helper/pending_outbound_call.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/services/incoming_call_service.dart';
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
  final startCallCalls = <Uri>[];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    LocalStorage.sharedPreferences = preferences;
    store = PendingOutboundCallStore(preferences);

    CallHelper.resetForTesting();
    CallHelper.callResolveDelay = Duration.zero;
    CallHelper.callSetupDuration = const Duration(seconds: 15);
    IncomingCallService.isProcessingCall = false;
    PendingCallData.clear();

    launchedNumbers.clear();
    messages.clear();
    startCallCalls.clear();

    CallHelper.directCallerTestOverride = (number) async {
      launchedNumbers.add(number);
      return true;
    };
    CallHelper.requestPermissionsTestOverride = () async {};
    CallHelper.hasPhonePermissionTestOverride = () => true;
    CallHelper.showMessageTestOverride = (msg) => messages.add(msg);

    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.uri.path.contains('/start')) {
            startCallCalls.add(options.uri);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true},
              ),
            );
            return;
          }
          handler.next(options);
        },
      ),
    );
    DioUtil.dio = dio;
  });

  tearDown(() {
    CallHelper.resetForTesting();
    IncomingCallService.isProcessingCall = false;
    PendingCallData.clear();
  });

  test('CALL_INCOMING sets isIncomingCallActive to true', () async {
    expect(CallHelper.isIncomingCallActive, isFalse);

    await CallHelper.handlePhoneStateForTesting(
      PhoneState.nothing()..status = PhoneStateStatus.CALL_INCOMING,
    );

    expect(CallHelper.isIncomingCallActive, isTrue);
    expect(CallHelper.lastPhoneStateStatus, equals(PhoneStateStatus.CALL_INCOMING));
  });

  test('CALL_STARTED on active incoming call does not attach to or mutate existing outbound session', () async {
    // Simulate an existing saved outbound session
    final outboundSession = PendingOutboundCall.create(
      leadId: 'lead-outbound-1',
      phoneNumber: '9876543210',
      stageName: 'Cold',
      startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    );
    await store.save(outboundSession);

    // Incoming call arrives
    await CallHelper.handlePhoneStateForTesting(
      PhoneState.nothing()..status = PhoneStateStatus.CALL_INCOMING,
    );
    expect(CallHelper.isIncomingCallActive, isTrue);

    // Incoming call is answered (CALL_STARTED)
    await CallHelper.handlePhoneStateForTesting(
      PhoneState.nothing()..status = PhoneStateStatus.CALL_STARTED,
    );

    // Verify: Outbound start call API was NOT invoked
    expect(startCallCalls, isEmpty);

    // Verify: Outbound session in store was not mutated with connectedAt
    final loaded = await store.load();
    expect(loaded?.connectedAt, isNull);
    expect(loaded?.startCallApiSent, isFalse);

    // Incoming call disconnects (CALL_ENDED)
    await CallHelper.handlePhoneStateForTesting(
      PhoneState.nothing()..status = PhoneStateStatus.CALL_ENDED,
    );
    expect(CallHelper.isIncomingCallActive, isFalse);
    expect(CallHelper.lastIncomingCallEndedAt, isNotNull);

    // Outbound session was NOT marked ended or resolved by incoming call
    final finalSession = await store.load();
    expect(finalSession?.endedAt, isNull);
    expect(finalSession?.callData, isNull);
  });

  test('CALL_STARTED ignores stale or resolved outbound session even if CALL_INCOMING was not received', () async {
    // Resolved outbound session from earlier
    final resolvedSession = PendingOutboundCall.create(
      leadId: 'lead-outbound-old',
      phoneNumber: '9999999999',
      stageName: 'Warm',
      startedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ).copyWith(
      callData: {'status': 'ready'},
      status: 'ready',
    );
    await store.save(resolvedSession);

    // CALL_STARTED arrives without CALL_INCOMING
    await CallHelper.handlePhoneStateForTesting(
      PhoneState.nothing()..status = PhoneStateStatus.CALL_STARTED,
    );

    // Verify: startCall API not called, and resolved session not modified
    expect(startCallCalls, isEmpty);
    final loaded = await store.load();
    expect(loaded?.leadId, equals('lead-outbound-old'));
    expect(loaded?.callData, isNotNull);
  });

  test('reconcilePendingSession is skipped when incoming call is active or recently ended', () async {
    final readySession = PendingOutboundCall.create(
      leadId: 'lead-outbound-1',
      phoneNumber: '9876543210',
      stageName: 'Cold',
      startedAt: DateTime.now().subtract(const Duration(minutes: 1)),
    ).copyWith(
      callData: {'duration': 20, 'status': 'completed'},
      status: 'ready',
    );
    await store.save(readySession);

    // Incoming call active: reconcile must skip
    CallHelper.isIncomingCallActive = true;
    await CallHelper.reconcilePendingSession();
    expect(PendingCallData.data, isNull);

    // Incoming call being processed by IncomingCallService: reconcile must skip
    CallHelper.isIncomingCallActive = false;
    IncomingCallService.isProcessingCall = true;
    await CallHelper.reconcilePendingSession();
    expect(PendingCallData.data, isNull);

    // Incoming call ended within last 15s: reconcile must skip
    IncomingCallService.isProcessingCall = false;
    CallHelper.lastIncomingCallEndedAt = DateTime.now().subtract(const Duration(seconds: 3));
    await CallHelper.reconcilePendingSession();
    expect(PendingCallData.data, isNull);
  });

  test('PendingCallData.clear() clears both data and outboundSessionId', () {
    PendingCallData.data = {'test': 123};
    PendingCallData.outboundSessionId = 'session-abc';

    PendingCallData.clear();

    expect(PendingCallData.data, isNull);
    expect(PendingCallData.outboundSessionId, isNull);
  });
}
