import 'package:crm_flutter/api/response/all_leads_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses scalar and list custom field values', () {
    final scalarValue = Data.fromJson({
      'customList': [
        {'label': 'Interest', 'value': 'Commercial', '_id': 'custom-1'},
      ],
    });
    final listValue = Data.fromJson({
      'customList': [
        {
          'label': 'Regions',
          'value': ['North', 'South'],
          '_id': 'custom-2',
        },
      ],
    });
    final emptyValue = Data.fromJson({
      'customList': [
        {'label': 'Optional', 'value': null, '_id': 'custom-3'},
      ],
    });

    expect(scalarValue.customList?.single.value, ['Commercial']);
    expect(listValue.customList?.single.value, ['North', 'South']);
    expect(emptyValue.customList?.single.value, isEmpty);
  });

  test('rejects unsupported custom field value types', () {
    expect(
      () => Data.fromJson({
        'customList': [
          {'label': 'Interest', 'value': 42},
        ],
      }),
      throwsFormatException,
    );
  });

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
