import 'package:crm_flutter/api/response/all_leads_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses allocation lead sub-status and sub-source IDs', () {
    final lead = Data.fromJson({
      '_id': 'lead-1',
      'sub_source_id': 'sub-source-1',
      'sub_status_id': {'_id': 'sub-status-1', 'name': 'Qualified'},
    });

    expect(lead.leadSubSourceId?.sId, 'sub-source-1');
    expect(lead.subStatusId?.sId, 'sub-status-1');
    expect(lead.subStatusId?.name, 'Qualified');
    expect(lead.toJson()['sub_status_id']['_id'], 'sub-status-1');
  });
}
