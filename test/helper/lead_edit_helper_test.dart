import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/constants.dart';
import 'package:crm_flutter/helper/lead_edit_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fetches and maps complete lead details for the edit form', () async {
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
              data: {
                'success': true,
                'data': {
                  '_id': 'lead-42',
                  'name': {
                    'first': 'Ada',
                    'middle': 'Byron',
                    'last': 'Lovelace',
                  },
                  'phone': 1234567890,
                  'email': 'ada@example.test',
                  'customList': [
                    {
                      'label': 'Interest',
                      'value': 'Commercial',
                      '_id': 'custom-1',
                    },
                  ],
                  'lead_source_id': {'_id': 'source-1', 'name': 'Referral'},
                  'sub_source_id': {'_id': 'sub-source-1', 'name': 'Partner'},
                  'lead_stage_id': {'_id': 'stage-1', 'name': 'Interested'},
                  'sub_status_id': {'_id': 'sub-status-1', 'name': 'Warm'},
                  'assignedTo': {'_id': 'agent-1', 'name': 'Agent One'},
                  'campaign': {'_id': 'campaign-1', 'name': 'Campaign One'},
                  'followUpDate': '2026-10-27T12:00:00.000Z',
                  'location': {
                    'country': {'_id': 'country-1', 'name': 'Country'},
                    'state': {'_id': 'state-1', 'name': 'State'},
                    'city': {'_id': 'city-1', 'name': 'City'},
                  },
                  'company_name': 'Analytical Engines',
                  'priority': 'Hot',
                  'gender': 'Other',
                  'age': 36,
                  'remarks': 'Call tomorrow',
                },
              },
            ),
          );
        },
      ),
    );
    DioUtil.dio = dio;
    addTearDown(dio.close);

    final lead = await LeadEditHelper.fetchLeadForEditing('lead-42');

    expect(requestOptions?.uri.toString(), '$link/lead/lead-42');
    expect(lead.sId, 'lead-42');
    expect(lead.name?.first, 'Ada');
    expect(lead.name?.middle, 'Byron');
    expect(lead.name?.last, 'Lovelace');
    expect(lead.customList?.single.value, ['Commercial']);
    expect(lead.leadSourceId?.sId, 'source-1');
    expect(lead.leadSubSourceId?.sId, 'sub-source-1');
    expect(lead.leadStageId?.sId, 'stage-1');
    expect(lead.subStatusId?.sId, 'sub-status-1');
    expect(lead.assignedTo?.sId, 'agent-1');
    expect(lead.compaignName?.sId, 'campaign-1');
    expect(lead.followUpDate, DateTime.parse('2026-10-27T12:00:00.000Z'));
    expect(lead.location?.country?.sId, 'country-1');
    expect(lead.location?.state?.sId, 'state-1');
    expect(lead.location?.city?.sId, 'city-1');
    expect(lead.companyName, 'Analytical Engines');
    expect(lead.priority, 'Hot');
    expect(lead.gender, 'Other');
    expect(lead.age, 36);
    expect(lead.remarks, 'Call tomorrow');
  });

  test('rejects an empty ID without making an API request', () async {
    await expectLater(
      LeadEditHelper.fetchLeadForEditing(' '),
      throwsArgumentError,
    );
  });

  test('rejects failed detail requests', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 500,
                data: {'message': 'Unable to load lead'},
              ),
            ),
          );
        },
      ),
    );
    DioUtil.dio = dio;
    addTearDown(dio.close);

    await expectLater(
      LeadEditHelper.fetchLeadForEditing('lead-42'),
      throwsA(isA<Exception>()),
    );
  });
}
