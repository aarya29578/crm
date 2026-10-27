import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/helper/pending_outbound_call.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('verifies a connected call with its known duration', () async {
    final fixture = await _createFixture(
      expectedDuration: 42,
      expectedStatus: 'completed',
      actualDuration: 42,
      actualStatus: 'completed',
    );

    try {
      await CallHelper.submitPendingCall(fixture.payload);
      expect(fixture.timelineRequests, 1);
      expect(await fixture.store.load(), isNull);
    } finally {
      fixture.dispose();
    }
  });

  test(
    'does not verify a connected call with unknown timeline duration',
    () async {
      final fixture = await _createFixture(
        expectedDuration: 42,
        expectedStatus: 'completed',
        actualDuration: null,
        actualStatus: 'completed',
      );

      try {
        await expectLater(
          CallHelper.submitPendingCall(fixture.payload),
          throwsA(isA<StateError>()),
        );
        expect(await fixture.store.load(), isNotNull);
      } finally {
        fixture.dispose();
      }
    },
  );

  test(
    'verifies an unanswered call with null timeline duration as zero',
    () async {
      final fixture = await _createFixture(
        expectedDuration: 0,
        expectedStatus: 'failed',
        actualDuration: null,
        actualStatus: 'failed',
      );

      try {
        await CallHelper.submitPendingCall(fixture.payload);
        expect(fixture.timelineRequests, 1);
        expect(await fixture.store.load(), isNull);
      } finally {
        fixture.dispose();
      }
    },
  );

  test('does not treat a failed call API request as verified', () async {
    final fixture = await _createFixture(
      expectedDuration: 0,
      expectedStatus: 'failed',
      actualDuration: null,
      actualStatus: 'failed',
      callApiStatus: 503,
    );

    try {
      await expectLater(
        CallHelper.submitPendingCall(fixture.payload),
        throwsA(isA<Exception>()),
      );
      expect(fixture.timelineRequests, 0);
      expect(await fixture.store.load(), isNotNull);
    } finally {
      fixture.dispose();
    }
  });
}

Future<_VerificationFixture> _createFixture({
  required Object expectedDuration,
  required String expectedStatus,
  required Object? actualDuration,
  required String actualStatus,
  int callApiStatus = 201,
}) async {
  SharedPreferences.setMockInitialValues({});
  LocalStorage.sharedPreferences = await SharedPreferences.getInstance();

  final preferences = LocalStorage.sharedPreferences!;
  final session = PendingOutboundCall.create(
    leadId: 'lead-1',
    phoneNumber: 'test-number',
    stageName: null,
    startedAt: DateTime.now(),
  );
  final payload = <String, dynamic>{
    'lead_id': session.leadId,
    'direction': 'outbound',
    'duration': expectedDuration,
    'status': expectedStatus,
  };
  final store = PendingOutboundCallStore(preferences);
  await store.save(session.copyWith(callData: payload));

  var timelineRequests = 0;
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final isCallSave = options.uri.path.endsWith('/call/dial');
        if (!isCallSave) timelineRequests++;
        final responseData = isCallSave
            ? {'success': callApiStatus < 400}
            : {
                'success': true,
                'data': [
                  {
                    'action': 'CALL',
                    'lead_id': session.leadId,
                    'createdAt': DateTime.now().toIso8601String(),
                    'call_log': {
                      'direction': 'OUTBOUND',
                      'duration': actualDuration,
                      'status': actualStatus,
                    },
                  },
                ],
              };
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: isCallSave ? callApiStatus : 200,
            data: responseData,
          ),
        );
      },
    ),
  );
  DioUtil.dio = dio;

  return _VerificationFixture(
    payload: payload,
    store: store,
    dio: dio,
    getTimelineRequests: () => timelineRequests,
  );
}

class _VerificationFixture {
  final Map<String, dynamic> payload;
  final PendingOutboundCallStore store;
  final Dio dio;
  final int Function() _getTimelineRequests;

  _VerificationFixture({
    required this.payload,
    required this.store,
    required this.dio,
    required int Function() getTimelineRequests,
  }) : _getTimelineRequests = getTimelineRequests;

  int get timelineRequests => _getTimelineRequests();

  void dispose() {
    dio.close(force: true);
    LocalStorage.sharedPreferences = null;
  }
}
