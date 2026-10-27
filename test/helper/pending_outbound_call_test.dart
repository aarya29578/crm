import 'package:call_log/call_log.dart';
import 'package:crm_flutter/helper/pending_outbound_call.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'persists a session for restoration after a new store is created',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = PendingOutboundCallStore(preferences);
      final session = PendingOutboundCall.create(
        leadId: 'lead-1',
        phoneNumber: '+1 (415) 555-0100',
        stageName: 'Qualified',
        startedAt: DateTime(2026, 1, 1, 10),
      );

      await store.save(session);

      final restored = await PendingOutboundCallStore(
        await SharedPreferences.getInstance(),
      ).load();

      expect(restored?.sessionId, session.sessionId);
      expect(restored?.leadId, 'lead-1');
      expect(restored?.startedAt, session.startedAt);
      expect(restored?.phoneNumber, session.phoneNumber);
    },
  );

  test('matches a long outgoing call by its call-start timestamp', () {
    final startedAt = DateTime(2026, 1, 1, 10);
    final session = PendingOutboundCall.create(
      leadId: 'lead-1',
      phoneNumber: '+1 (415) 555-0100',
      stageName: null,
      startedAt: startedAt,
    );
    final callEntry = CallLogEntry(
      number: '14155550100',
      callType: CallType.outgoing,
      duration: 75 * 60,
      timestamp: startedAt.millisecondsSinceEpoch,
    );

    final match = PendingOutboundCall.matchCallLogEntry(
      session: session,
      entries: [callEntry],
      now: startedAt.add(const Duration(minutes: 76)),
    );

    expect(match, same(callEntry));
  });

  test('treats a short connected call as completed', () {
    final startedAt = DateTime(2026, 1, 1, 10);
    final session = PendingOutboundCall.create(
      leadId: 'lead-1',
      phoneNumber: '4155550100',
      stageName: null,
      startedAt: startedAt,
    );
    final entry = CallLogEntry(
      number: '4155550100',
      callType: CallType.outgoing,
      duration: 25,
      timestamp: startedAt.millisecondsSinceEpoch,
    );

    final payload = PendingOutboundCall.callPayloadForEntry(
      session: session,
      entry: entry,
      fromNumber: 'private',
    );

    expect(payload['duration'], 25);
    expect(payload['status'], 'completed');
    expect(payload['disposition'], 'connected');
  });

  test('does not treat a zero-duration call as completed', () {
    final startedAt = DateTime(2026, 1, 1, 10);
    final session = PendingOutboundCall.create(
      leadId: 'lead-1',
      phoneNumber: '4155550100',
      stageName: null,
      startedAt: startedAt,
    );
    final entry = CallLogEntry(
      number: '4155550100',
      callType: CallType.outgoing,
      duration: 0,
      timestamp: startedAt.millisecondsSinceEpoch,
    );

    final payload = PendingOutboundCall.callPayloadForEntry(
      session: session,
      entry: entry,
      fromNumber: 'private',
    );

    expect(payload['duration'], 0);
    expect(payload['status'], 'failed');
    expect(payload['disposition'], 'not connected');
  });

  test('does not match incoming, wrong-number, or stale call-log entries', () {
    final startedAt = DateTime(2026, 1, 1, 10);
    final session = PendingOutboundCall.create(
      leadId: 'lead-1',
      phoneNumber: '4155550100',
      stageName: null,
      startedAt: startedAt,
    );
    final entries = [
      CallLogEntry(
        number: '4155550100',
        callType: CallType.incoming,
        duration: 60,
        timestamp: startedAt.millisecondsSinceEpoch,
      ),
      CallLogEntry(
        number: '4155550199',
        callType: CallType.outgoing,
        duration: 60,
        timestamp: startedAt.millisecondsSinceEpoch,
      ),
      CallLogEntry(
        number: '4155550100',
        callType: CallType.outgoing,
        duration: 60,
        timestamp: startedAt
            .subtract(const Duration(minutes: 5))
            .millisecondsSinceEpoch,
      ),
    ];

    expect(
      PendingOutboundCall.matchCallLogEntry(
        session: session,
        entries: entries,
        now: startedAt.add(const Duration(minutes: 10)),
      ),
      isNull,
    );
  });

  test('clear only removes the matching session', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = PendingOutboundCallStore(preferences);
    final session = PendingOutboundCall.create(
      leadId: 'lead-1',
      phoneNumber: '4155550100',
      stageName: null,
      startedAt: DateTime(2026),
    );
    await store.save(session);

    await store.clear('different-session');
    expect(await store.load(), isNotNull);

    await store.clear(session.sessionId);
    expect(await store.load(), isNull);
  });
}
