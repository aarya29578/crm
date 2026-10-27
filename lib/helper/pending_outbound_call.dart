import 'dart:convert';
import 'dart:math';

import 'package:call_log/call_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingOutboundCall {
  static const storageKey = 'pending_outbound_call';

  final String sessionId;
  final String leadId;
  final String phoneNumber;
  final String? stageName;
  final DateTime startedAt;
  final DateTime? connectedAt;
  final DateTime? endedAt;
  final DateTime? submissionStartedAt;
  final bool startCallApiSent;
  final Map<String, dynamic>? callData;

  const PendingOutboundCall({
    required this.sessionId,
    required this.leadId,
    required this.phoneNumber,
    required this.stageName,
    required this.startedAt,
    this.connectedAt,
    this.endedAt,
    this.submissionStartedAt,
    this.startCallApiSent = false,
    this.callData,
  });

  factory PendingOutboundCall.create({
    required String leadId,
    required String phoneNumber,
    required String? stageName,
    required DateTime startedAt,
  }) {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
    final id = hex.join();
    final sessionId =
        '${id.substring(0, 8)}-${id.substring(8, 12)}-'
        '${id.substring(12, 16)}-${id.substring(16, 20)}-'
        '${id.substring(20)}';

    return PendingOutboundCall(
      sessionId: sessionId,
      leadId: leadId,
      phoneNumber: phoneNumber,
      stageName: stageName,
      startedAt: startedAt,
    );
  }

  PendingOutboundCall copyWith({
    DateTime? endedAt,
    DateTime? connectedAt,
    DateTime? submissionStartedAt,
    bool? startCallApiSent,
    Map<String, dynamic>? callData,
  }) {
    return PendingOutboundCall(
      sessionId: sessionId,
      leadId: leadId,
      phoneNumber: phoneNumber,
      stageName: stageName,
      startedAt: startedAt,
      connectedAt: connectedAt ?? this.connectedAt,
      endedAt: endedAt ?? this.endedAt,
      submissionStartedAt: submissionStartedAt ?? this.submissionStartedAt,
      startCallApiSent: startCallApiSent ?? this.startCallApiSent,
      callData: callData ?? this.callData,
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'leadId': leadId,
    'phoneNumber': phoneNumber,
    'stageName': stageName,
    'startedAt': startedAt.toIso8601String(),
    'connectedAt': connectedAt?.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'submissionStartedAt': submissionStartedAt?.toIso8601String(),
    'startCallApiSent': startCallApiSent,
    'callData': callData,
  };

  factory PendingOutboundCall.fromJson(Map<String, dynamic> json) {
    final startedAt = DateTime.tryParse(json['startedAt']?.toString() ?? '');
    if (startedAt == null) {
      throw const FormatException('Pending call has an invalid start time');
    }
    final sessionId = json['sessionId']?.toString() ?? '';
    final leadId = json['leadId']?.toString() ?? '';
    if (sessionId.isEmpty || leadId.isEmpty) {
      throw const FormatException(
        'Pending call is missing required identifiers',
      );
    }
    final callData = json['callData'];

    return PendingOutboundCall(
      sessionId: sessionId,
      leadId: leadId,
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      stageName: json['stageName']?.toString(),
      startedAt: startedAt,
      connectedAt: DateTime.tryParse(json['connectedAt']?.toString() ?? ''),
      endedAt: DateTime.tryParse(json['endedAt']?.toString() ?? ''),
      submissionStartedAt: DateTime.tryParse(
        json['submissionStartedAt']?.toString() ?? '',
      ),
      startCallApiSent: json['startCallApiSent'] == true,
      callData: callData is Map ? Map<String, dynamic>.from(callData) : null,
    );
  }

  static CallLogEntry? matchCallLogEntry({
    required PendingOutboundCall session,
    required Iterable<CallLogEntry> entries,
    required DateTime now,
    Duration startTolerance = const Duration(seconds: 30),
  }) {
    final startFloor = session.startedAt.subtract(startTolerance);
    final endCeiling = now.add(const Duration(seconds: 30));
    final expectedNumber = normalizePhoneNumber(session.phoneNumber);

    final candidates = entries.where((entry) {
      final timestamp = entry.timestamp;
      if (timestamp == null || timestamp <= 0) return false;

      final callStartedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (callStartedAt.isBefore(startFloor) ||
          callStartedAt.isAfter(endCeiling)) {
        return false;
      }

      if (entry.callType != CallType.outgoing &&
          entry.callType != CallType.wifiOutgoing) {
        return false;
      }

      final entryNumber = normalizePhoneNumber(
        entry.number ?? entry.formattedNumber ?? '',
      );
      return entryNumber.isEmpty ||
          expectedNumber.isEmpty ||
          entryNumber == expectedNumber;
    }).toList()..sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));

    return candidates.isEmpty ? null : candidates.first;
  }

  static Map<String, dynamic> callPayloadForEntry({
    required PendingOutboundCall session,
    required CallLogEntry entry,
    required Object fromNumber,
    String? recordingPath,
  }) {
    final timestamp = entry.timestamp;
    if (timestamp == null || timestamp <= 0) {
      throw ArgumentError.value(entry.timestamp, 'timestamp');
    }
    if (entry.callType != CallType.outgoing &&
        entry.callType != CallType.wifiOutgoing) {
      throw ArgumentError.value(entry.callType, 'callType');
    }

    final callStartedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final durationSeconds = entry.duration != null && entry.duration! > 0
        ? entry.duration!
        : 0;
    final connected = durationSeconds > 0;
    final endedAt = callStartedAt.add(Duration(seconds: durationSeconds));

    return {
      'lead_id': session.leadId,
      'to_number': entry.number ?? session.phoneNumber,
      'from_number': fromNumber,
      'direction': 'outbound',
      'duration': durationSeconds,
      'recording_url': '',
      'recording_path': recordingPath ?? '',
      'status': connected ? 'completed' : 'failed',
      'userStatus': 'idle',
      'disposition': connected ? 'connected' : 'not connected',
      'started_at': callStartedAt.toIso8601String(),
      'ended_at': endedAt.toIso8601String(),
    };
  }

  static String normalizePhoneNumber(String phoneNumber) =>
      phoneNumber.replaceAll(RegExp(r'\D'), '');
}

class PendingOutboundCallStore {
  final SharedPreferences preferences;

  const PendingOutboundCallStore(this.preferences);

  Future<PendingOutboundCall?> load() async {
    final encoded = preferences.getString(PendingOutboundCall.storageKey);
    if (encoded == null) return null;

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) {
        throw const FormatException('Pending call is not an object');
      }
      return PendingOutboundCall.fromJson(Map<String, dynamic>.from(decoded));
    } catch (error) {
      throw FormatException('Unable to restore pending call session: $error');
    }
  }

  Future<void> save(PendingOutboundCall session) async {
    final saved = await preferences.setString(
      PendingOutboundCall.storageKey,
      jsonEncode(session.toJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist pending call session');
    }
  }

  Future<void> clear(String sessionId) async {
    final existing = await load();
    if (existing?.sessionId != sessionId) return;

    final removed = await preferences.remove(PendingOutboundCall.storageKey);
    if (!removed) {
      throw StateError('Unable to clear saved call session');
    }
  }
}
