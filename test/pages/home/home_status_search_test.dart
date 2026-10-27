import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart' as lead_model;
import 'package:crm_flutter/pages/claimed/ClaimedController.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio dio;
  late Claimedcontroller controller;
  var requestCount = 0;
  final searchTerms = <String?>[];
  final requestPaths = <String>[];

  setUp(() {
    dio = Dio();
    DioUtil.dio = dio;
    requestCount = 0;
    searchTerms.clear();
    requestPaths.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestCount++;
          final query = options.queryParameters['search'];
          searchTerms.add(query as String?);
          requestPaths.add(options.uri.path);
          final data = query == 'not found'
              ? <Map<String, dynamic>>[]
              : [
                  {
                    '_id': 'lead-a',
                    'lead_stage_id': {'_id': 'stage-a'},
                  },
                  {
                    '_id': 'lead-b',
                    'lead_stage_id': {'_id': 'stage-b'},
                  },
                ];
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true, 'data': data},
            ),
          );
        },
      ),
    );
    controller = Claimedcontroller();
  });

  tearDown(() {
    controller.onClose();
    dio.close(force: true);
  });

  test('search results follow selected statuses, refresh, and clear', () async {
    controller.onSearchChanged('alex');
    await Future<void>.delayed(const Duration(milliseconds: 550));

    expect(controller.searchQuery.value, 'alex');
    expect(controller.searchResults, hasLength(2));
    expect(searchTerms, ['alex']);
    expect(requestPaths.single, endsWith('/lead/all'));
    expect(controller.searchResultsForStages(['stage-a']), hasLength(1));
    expect(controller.searchResultsForStages(['stage-b']), hasLength(1));
    expect(
      controller.searchResultsForStages(['stage-a', 'stage-b']),
      hasLength(2),
    );
    expect(controller.searchResultsForStages(['stage-c']), isEmpty);

    final requestsBeforeRefresh = requestCount;
    await controller.refreshSearch();
    expect(requestCount, requestsBeforeRefresh + 1);
    expect(searchTerms.last, 'alex');
    expect(controller.searchQuery.value, 'alex');

    controller.onSearchChanged('not found');
    await Future<void>.delayed(const Duration(milliseconds: 550));
    expect(controller.searchResults, isEmpty);
    expect(controller.searchResultsForStages(['stage-a']), isEmpty);
    expect(searchTerms.last, 'not found');

    controller.searchResults.add(
      lead_model.Data(
        sId: 'lead-a',
        leadStageId: lead_model.LeadStageId(sId: 'stage-a'),
      ),
    );
    controller.clearSearch();
    expect(controller.searchQuery.value, isEmpty);
    expect(controller.searchResults, isEmpty);
    expect(controller.isSearchLoading.value, isFalse);
  });
}
