import 'package:crm_flutter/api/response/all_lead_details_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses and serializes lead timeline entries', () {
    final response = AllLeadDetailResponse.fromJson({
      'success': true,
      'data': {
        '_id': 'lead-1',
        'timeline': [
          {
            'stage': 'Qualified',
            'note': 'Followed up',
            'agent': 'Agent One',
            'action': 'updated',
            'date': '2026-10-19T10:00:00.000Z',
          },
        ],
      },
    });

    final timeline = response.data!.timeline!;
    expect(timeline, hasLength(1));
    expect(timeline.single.stage, 'Qualified');
    expect(timeline.single.note, 'Followed up');
    expect(response.toJson()['data']['timeline'], hasLength(1));
  });
}
