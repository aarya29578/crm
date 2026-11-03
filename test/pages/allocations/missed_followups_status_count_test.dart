import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/local_storage/up_coming_followups_controller.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/Allocations/components/callLogCard.dart';
import 'package:crm_flutter/pages/Allocations/missedFollowUps/missed_followups_controller.dart';
import 'package:crm_flutter/pages/Allocations/missedFollowUps/missed_followups_page.dart';
import 'package:crm_flutter/pages/Allocations/WhatsappSMS/whatsapp_sms_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

class _MockFollowUpController extends GetxController implements FollowUpController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> syncWithApi() async {}
}

void main() {
  late Dio dio;
  final requestedPaths = <String>[];
  final requestedQueryParams = <Map<String, dynamic>>[];
  bool shouldFailStages = false;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'user_name': 'Agent Smith',
      'user_Id': 'agent-1',
    });
    LocalStorage.sharedPreferences = await SharedPreferences.getInstance();

    Get.reset();
    dio = Dio();
    DioUtil.dio = dio;
    requestedPaths.clear();
    requestedQueryParams.clear();
    shouldFailStages = false;

    Get.put<FollowUpController>(_MockFollowUpController());
    Get.put<DioApi>(DioApi());
    Get.put<WhatsappSmsController>(WhatsappSmsController());
    Get.put<AllocationController>(AllocationController());

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestedPaths.add(options.uri.path);
          requestedQueryParams.add(Map<String, dynamic>.from(options.queryParameters));

          if (options.uri.path.endsWith('/leadstage/all')) {
            if (shouldFailStages) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 500,
                  ),
                  type: DioExceptionType.badResponse,
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
                    {'_id': 'stage-fresh', 'name': 'Fresh', 'count': 42},
                    {'_id': 'stage-interested', 'name': 'Interested', 'count': 18},
                    {'_id': 'stage-followup', 'name': 'Follow Up', 'count': 9},
                  ],
                },
              ),
            );
          } else if (options.uri.path.endsWith('/lead/followup/missed')) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'total': 1,
                  'totalPages': 1,
                  'currentPage': 1,
                  'data': [
                    {
                      '_id': 'missed-lead-1',
                      'name': {'first': 'Alice', 'last': 'Smith'},
                      'phone': 9876543210,
                      'campaign': {'_id': 'camp-101', 'name': 'Alpha Campaign'},
                      'lead_stage_id': {'_id': 'stage-followup', 'name': 'Follow Up'},
                      'updatedAt': '2026-11-02T10:00:00.000Z',
                      'followUpDate': '2026-11-02T10:00:00.000Z',
                    },
                  ],
                },
              ),
            );
          } else if (options.uri.path.endsWith('/lead/followup/all')) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'total': 1,
                  'totalPages': 1,
                  'currentPage': 1,
                  'data': [
                    {
                      '_id': 'all-lead-1',
                      'name': {'first': 'Bob', 'last': 'Jones'},
                      'phone': 9123456789,
                      'campaign': {'_id': 'camp-202', 'name': 'Beta Campaign'},
                      'lead_stage_id': {'_id': 'stage-interested', 'name': 'Interested'},
                      'updatedAt': '2026-11-03T10:00:00.000Z',
                      'followUpDate': '2026-11-03T10:00:00.000Z',
                    },
                  ],
                },
              ),
            );
          } else {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true, 'data': []},
              ),
            );
          }
        },
      ),
    );
  });

  tearDown(() {
    Get.reset();
  });

  test('AllMissFUpsController fetches global lead stages without campaignId', () async {
    final controller = AllMissFUpsController();
    Get.put(controller);

    await controller.fetchLeadStages();

    expect(controller.stageCountLoading.value, PageState.stable);
    expect(controller.allLeadStageRes.value.data, hasLength(3));
    expect(controller.allLeadStageRes.value.data![0].name, 'Fresh');
    expect(controller.allLeadStageRes.value.data![0].count, 42);
    expect(controller.allLeadStageRes.value.data![1].name, 'Interested');
    expect(controller.allLeadStageRes.value.data![1].count, 18);
    expect(controller.allLeadStageRes.value.data![2].name, 'Follow Up');
    expect(controller.allLeadStageRes.value.data![2].count, 9);

    // Verify it called /leadstage/all with NO campaignId (global overall counts)
    final stageRequests = requestedPaths.where((p) => p.endsWith('/leadstage/all')).toList();
    expect(stageRequests, hasLength(1));
    final stageQuery = requestedQueryParams[requestedPaths.indexOf(stageRequests.first)];
    expect(stageQuery.containsKey('campaign'), isFalse);
  });

  test('fetchLeadStages does not re-fetch if already loaded unless forceRefresh is true', () async {
    final controller = AllMissFUpsController();
    Get.put(controller);

    await controller.fetchLeadStages();
    expect(requestedPaths.where((p) => p.endsWith('/leadstage/all')), hasLength(1));

    // Calling again without forceRefresh should do nothing
    await controller.fetchLeadStages();
    expect(requestedPaths.where((p) => p.endsWith('/leadstage/all')), hasLength(1));

    // Calling with forceRefresh = true should fetch again
    await controller.fetchLeadStages(forceRefresh: true);
    expect(requestedPaths.where((p) => p.endsWith('/leadstage/all')), hasLength(2));
  });

  testWidgets('MissedFollowupsPage displays overall status breakdown with names and counts', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Get.put(AllMissFUpsController());
    await tester.pumpWidget(
      const GetMaterialApp(
        home: MissedFollowupsPage(initialType: 'Missed'),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header exists
    expect(find.text('Total Leads Breakdown'), findsOneWidget);
    expect(find.text('3 Statuses'), findsOneWidget);

    // Verify each status name and corresponding total count are rendered
    expect(find.text('Fresh'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    expect(find.text('Interested'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);

    expect(find.text('Follow Up'), findsWidgets);
    expect(find.text('9'), findsOneWidget);

    // Verify the lead card is rendered
    expect(find.text('Alice Smith'), findsOneWidget);

    // Verify CallLogCard received the campaignId
    final cardFinder = find.byType(CallLogCard);
    expect(cardFinder, findsOneWidget);
    final cardWidget = tester.widget<CallLogCard>(cardFinder);
    expect(cardWidget.campaignId, 'camp-101');
    expect(cardWidget.campaign, 'Alpha Campaign');
  });

  testWidgets('Status counts remain unchanged when switching between All and Missed', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Get.put(AllMissFUpsController());
    await tester.pumpWidget(
      const GetMaterialApp(
        home: MissedFollowupsPage(initialType: 'Missed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Fresh'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    final initialStageCallCount = requestedPaths.where((p) => p.endsWith('/leadstage/all')).length;

    // Switch to "All"
    await tester.tap(find.widgetWithText(ElevatedButton, 'All'));
    await tester.pumpAndSettle();

    // Verify status counts are still displayed and unchanged
    expect(find.text('Fresh'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);

    // Verify lead list switched to All follow-ups
    expect(find.text('Bob Jones'), findsOneWidget);
    final cardWidget = tester.widget<CallLogCard>(find.byType(CallLogCard));
    expect(cardWidget.campaignId, 'camp-202');

    // Verify /leadstage/all was NOT re-requested on tab switch
    final newStageCallCount = requestedPaths.where((p) => p.endsWith('/leadstage/all')).length;
    expect(newStageCallCount, initialStageCallCount);
  });

  testWidgets('Status counts remain unchanged when changing date filters', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Get.put(AllMissFUpsController());
    await tester.pumpWidget(
      const GetMaterialApp(
        home: MissedFollowupsPage(initialType: 'Missed'),
      ),
    );
    await tester.pumpAndSettle();

    final initialStageCallCount = requestedPaths.where((p) => p.endsWith('/leadstage/all')).length;

    // Tap "Yesterday"
    await tester.tap(find.text('Yesterday'));
    await tester.pumpAndSettle();

    // Verify status counts still intact
    expect(find.text('Fresh'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    // Tap "Last 30 Days"
    await tester.tap(find.text('Last 30 Days'));
    await tester.pumpAndSettle();

    expect(find.text('Fresh'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    // Verify /leadstage/all was NOT re-requested on date filter changes
    final newStageCallCount = requestedPaths.where((p) => p.endsWith('/leadstage/all')).length;
    expect(newStageCallCount, initialStageCallCount);
  });

  testWidgets('Collapse and expand toggle works smoothly without overflow', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Get.put(AllMissFUpsController());
    await tester.pumpWidget(
      const GetMaterialApp(
        home: MissedFollowupsPage(initialType: 'Missed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fresh'), findsOneWidget);

    // Tap header to collapse
    await tester.tap(find.text('Total Leads Breakdown'));
    await tester.pumpAndSettle();

    // After collapse, status cards are hidden to maximize lead list space
    expect(find.text('Fresh'), findsNothing);
    expect(find.text('Total Leads Breakdown'), findsOneWidget);

    // Tap header again to expand
    await tester.tap(find.text('Total Leads Breakdown'));
    await tester.pumpAndSettle();

    expect(find.text('Fresh'), findsOneWidget);
  });

  testWidgets('Error state renders retry button which reloads status counts', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    shouldFailStages = true;

    Get.put(AllMissFUpsController());
    await tester.pumpWidget(
      const GetMaterialApp(
        home: MissedFollowupsPage(initialType: 'Missed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Failed to load status counts'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Allow stages to succeed and tap Retry
    shouldFailStages = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Fresh'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  });
}
