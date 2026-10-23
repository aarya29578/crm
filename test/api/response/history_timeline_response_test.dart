import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/history_timeline_response.dart';
import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('requests timeline history for the selected lead ID', () async {
    final dio = Dio();
    RequestOptions? requestOptions;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestOptions = options;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true, 'data': []},
            ),
          );
        },
      ),
    );
    DioUtil.dio = dio;

    try {
      await DioApi().getLeadTimeline('lead-42');

      expect(requestOptions?.uri.toString(), '$link/history/timeline/lead-42');
    } finally {
      dio.close();
    }
  });

  test('parses CALL and UPDATE timeline records', () {
    final response = HistoryTimelineResponse.fromJson({
      'success': true,
      'total': 17,
      'page': 1,
      'limit': 10,
      'data': <Map<String, dynamic>>[
        {
          '_id': 'call-1',
          'action': 'CALL',
          'changedBy': {
            '_id': 'agent-1',
            'name': 'Agent One',
            'email': 'agent@example.test',
          },
          'createdAt': '2026-10-19T10:00:00.000Z',
          'updatedAt': '2026-10-19T10:00:00.000Z',
          'changes': <String, dynamic>{},
          'call_log': {
            '_id': 'call-log-1',
            'direction': 'OUTBOUND',
            'duration': 45,
            'status': 'COMPLETED',
          },
          'lead_id': 'lead-1',
          'tenantId': 'tenant-1',
        },
        {
          '_id': 'update-1',
          'action': 'UPDATE',
          'changedBy': {
            '_id': 'agent-2',
            'name': 'Agent Two',
            'email': 'agent2@example.test',
          },
          'createdAt': '2026-10-20T11:15:00.000Z',
          'updatedAt': '2026-10-20T11:15:00.000Z',
          'changes': {
            'lead_stage_id': {'_id': 'stage-1', 'name': 'Qualified'},
            'sub_status_id': {'_id': 'sub-1', 'name': 'Interested'},
            'remarks': 'Followed up',
            'priority': 'High',
            'assignedTo': {
              '_id': 'agent-3',
              'name': 'Agent Three',
              'email': 'agent3@example.test',
            },
            'documents': <dynamic>[],
            'customList': null,
          },
          'lead_id': 'lead-1',
          'tenantId': 'tenant-1',
        },
      ],
    });

    expect(response.success, isTrue);
    expect(response.total, 17);
    expect(response.data, hasLength(2));

    final call = response.data[0];
    expect(call.action, 'CALL');
    expect(call.id, 'call-1');
    expect(call.leadId, 'lead-1');
    expect(call.tenantId, 'tenant-1');
    expect(call.changedBy?.name, 'Agent One');
    expect(call.createdAt, DateTime.parse('2026-10-19T10:00:00.000Z'));
    expect(call.callLog?.direction, 'OUTBOUND');
    expect(call.callLog?.duration, 45);
    expect(call.callDetails, [
      'Direction: OUTBOUND',
      'Status: COMPLETED',
      'Duration: 45',
    ]);

    final update = response.data[1];
    expect(update.action, 'UPDATE');
    expect(update.changedBy?.name, 'Agent Two');
    expect(update.callLog, isNull);
    expect(update.changeDetails, contains('Lead stage: Qualified'));
    expect(update.changeDetails, contains('Sub-status: Interested'));
    expect(update.changeDetails, contains('Remarks: Followed up'));
    expect(update.changeDetails, contains('Priority: High'));
    expect(update.changeDetails, contains('Assigned agent: Agent Three'));
    expect(update.changeDetails, isNot(contains('Documents:')));
  });

  test('handles missing nested fields and empty records safely', () {
    final response = HistoryTimelineResponse.fromJson({
      'success': true,
      'total': '1',
      'data': [
        {
          'action': 'UPDATE',
          'changedBy': null,
          'createdAt': null,
          'changes': {'remarks': null, 'documents': []},
        },
      ],
    });

    expect(response.total, 1);
    expect(response.data.single.changedBy, isNull);
    expect(response.data.single.callLog, isNull);
    expect(response.data.single.templateUsage, isNull);
    expect(response.data.single.createdAt, isNull);
    expect(response.data.single.changeDetails, isEmpty);
    expect(response.data.single.callDetails, isEmpty);
  });

  test('parses WhatsApp template usage and preserves message formatting', () {
    const messageBody =
        'Hello, {{name}}!\n\n'
        'Here are the details:\n'
        '• First item\n'
        '• Second item';
    final response = HistoryTimelineResponse.fromJson({
      'success': true,
      'data': [
        {
          'action': 'WHATSAPP_TEMPLATE',
          'template_usage': {
            'template_id': {
              'name': 'Property follow-up',
              'channel': 'WhatsApp',
              'body': messageBody,
            },
            'used_by': {'name': 'Agent One', 'channel': 'WhatsApp'},
          },
        },
      ],
    });

    final entry = response.data.single;
    expect(entry.isWhatsAppTemplate, isTrue);
    expect(entry.templateUsage?.template?.name, 'Property follow-up');
    expect(entry.templateUsage?.template?.channel, 'WhatsApp');
    expect(entry.templateUsage?.template?.body, messageBody);
    expect(entry.templateUsage?.usedBy?.name, 'Agent One');
    expect(entry.templateUsage?.usedBy?.channel, 'WhatsApp');
  });

  test('handles partial template usage without throwing', () {
    final response = HistoryTimelineResponse.fromJson({
      'success': true,
      'data': [
        {
          'action': 'WHATSAPP_TEMPLATE',
          'template_usage': {'template_id': null, 'used_by': null},
        },
      ],
    });

    expect(response.data.single.isWhatsAppTemplate, isTrue);
    expect(response.data.single.templateUsage?.template, isNull);
    expect(response.data.single.templateUsage?.usedBy, isNull);
  });

  test('rejects a response without a data list', () {
    expect(
      () => HistoryTimelineResponse.fromJson({'success': true}),
      throwsFormatException,
    );
  });
}
