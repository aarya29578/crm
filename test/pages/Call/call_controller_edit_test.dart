import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/api/response/all_calls_history_response.dart';
import 'package:crm_flutter/constants.dart';
import 'package:crm_flutter/pages/Call/call_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'patches name and phone and preserves them over stale API data',
    () async {
      final dio = Dio();
      Map<String, dynamic>? patchPayload;
      String? patchPath;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.method == 'PATCH') {
              patchPath = options.uri.path;
              patchPayload = Map<String, dynamic>.from(options.data as Map);
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
              return;
            }

            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'data': [
                    {
                      'lead': {
                        '_id': 'lead-1',
                        'name': {
                          'first': 'Old',
                          'middle': 'Stale',
                          'last': 'Name',
                        },
                        'phone': 1111111111,
                      },
                    },
                  ],
                },
              ),
            );
          },
        ),
      );
      DioUtil.dio = dio;
      addTearDown(dio.close);

      final controller = CallLogController();
      controller.callLogsResponse.value = AllCallHistoryResponse(
        data: [
          CallHistoryGroup(
            lead: Lead(
              sId: 'lead-1',
              name: LeadName(first: 'Old', last: 'Name'),
              phone: 1111111111,
            ),
          ),
        ],
      );

      await controller.updateClientDetails(
        leadId: 'lead-1',
        clientName: 'Grace Brewster Murray Hopper',
        mobileNumber: '9876543210',
      );

      expect(patchPath, '${Uri.parse(link).path}/lead/lead-1');
      expect(patchPayload, {
        'name': {
          'first': 'Grace',
          'middle': 'Brewster Murray',
          'last': 'Hopper',
        },
        'phone': 9876543210,
      });
      expect(
        controller.callLogsResponse.value.data?.single.lead?.phone,
        9876543210,
      );
      expect(
        controller.callLogsResponse.value.data?.single.lead?.name?.middle,
        'Brewster Murray',
      );

      await controller.getApi();
      final refreshedLead = controller.callLogsResponse.value.data?.single.lead;
      expect(refreshedLead?.name?.first, 'Grace');
      expect(refreshedLead?.name?.middle, 'Brewster Murray');
      expect(refreshedLead?.name?.last, 'Hopper');
      expect(refreshedLead?.phone, 9876543210);
    },
  );

  test('does not update displayed data when the PATCH request fails', () async {
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
                data: {'message': 'Save failed'},
              ),
            ),
          );
        },
      ),
    );
    DioUtil.dio = dio;
    addTearDown(dio.close);

    final controller = CallLogController();
    controller.callLogsResponse.value = AllCallHistoryResponse(
      data: [
        CallHistoryGroup(
          lead: Lead(
            sId: 'lead-1',
            name: LeadName(first: 'Ada', last: 'Lovelace'),
            phone: 1234567890,
          ),
        ),
      ],
    );

    await expectLater(
      controller.updateClientDetails(
        leadId: 'lead-1',
        clientName: 'Grace Hopper',
        mobileNumber: '9876543210',
      ),
      throwsA(isA<Exception>()),
    );
    expect(
      controller.callLogsResponse.value.data?.single.lead?.name?.first,
      'Ada',
    );
    expect(
      controller.callLogsResponse.value.data?.single.lead?.phone,
      1234567890,
    );
  });
}
