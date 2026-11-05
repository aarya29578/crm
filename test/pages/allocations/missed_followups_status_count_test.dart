import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/local_storage/up_coming_followups_controller.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
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
  bool shouldFailPage2 = false;

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
    shouldFailPage2 = false;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestedPaths.add(options.uri.path);
          requestedQueryParams.add(Map<String, dynamic>.from(options.queryParameters));

          if (options.uri.path.endsWith('/leadstage/all')) {
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
            final page = options.queryParameters['page'] ?? 1;
            if (page == 2 && shouldFailPage2) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(requestOptions: options, statusCode: 500),
                  type: DioExceptionType.badResponse,
                ),
              );
              return;
            }

            if (page == 2) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'success': true,
                    'total': 4,
                    'totalPages': 2,
                    'currentPage': 2,
                    'data': [
                      {
                        '_id': 'missed-lead-4',
                        'name': {'first': 'Emma', 'last': 'Davis'},
                        'phone': 9988776655,
                        'campaign': {'_id': 'camp-104', 'name': 'Alpha Campaign'},
                        'lead_stage_id': {'_id': 'stage-fresh', 'name': 'Fresh'},
                        'updatedAt': '2026-11-02T12:00:00.000Z',
                        'followUpDate': '2026-11-02T12:00:00.000Z',
                      },
                    ],
                  },
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
                  'total': 4,
                  'totalPages': 2,
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
                    {
                      '_id': 'missed-lead-2',
                      'name': {'first': 'Charlie', 'last': 'Brown'},
                      'phone': 9876543211,
                      'campaign': {'_id': 'camp-102', 'name': 'Alpha Campaign'},
                      'lead_stage_id': {'_id': 'stage-fresh', 'name': 'Fresh'},
                      'updatedAt': '2026-11-02T10:30:00.000Z',
                      'followUpDate': '2026-11-02T10:30:00.000Z',
                    },
                    {
                      '_id': 'missed-lead-3',
                      'name': {'first': 'David', 'last': 'Wilson'},
                      'phone': 9876543212,
                      'campaign': {'_id': 'camp-103', 'name': 'Alpha Campaign'},
                      'lead_stage_id': {'_id': 'stage-interested', 'name': 'Interested'},
                      'updatedAt': '2026-11-02T11:00:00.000Z',
                      'followUpDate': '2026-11-02T11:00:00.000Z',
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
                  'total': 2,
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
                    {
                      '_id': 'all-lead-2',
                      'name': {'first': 'Frank', 'last': 'Miller'},
                      'phone': 9123456780,
                      'campaign': {'_id': 'camp-203', 'name': 'Beta Campaign'},
                      'lead_stage_id': {'_id': 'stage-fresh', 'name': 'Fresh'},
                      'updatedAt': '2026-11-03T11:00:00.000Z',
                      'followUpDate': '2026-11-03T11:00:00.000Z',
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

    Get.put<FollowUpController>(_MockFollowUpController());
    Get.put<DioApi>(DioApi());
    Get.put<WhatsappSmsController>(WhatsappSmsController());
    Get.lazyPut<AllocationController>(() => AllocationController());
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

    await controller.fetchLeadStages();
    expect(requestedPaths.where((p) => p.endsWith('/leadstage/all')), hasLength(1));

    await controller.fetchLeadStages(forceRefresh: true);
    expect(requestedPaths.where((p) => p.endsWith('/leadstage/all')), hasLength(2));
  });

  testWidgets('MissedFollowupsPage displays horizontal status chips and Total Leads count bar', (tester) async {
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

    // Verify old breakdown header does NOT exist
    expect(find.text('Total Leads Breakdown'), findsNothing);

    // Verify horizontal status chips exist
    expect(find.byKey(const ValueKey('followups-status-filters-scroll')), findsOneWidget);
    expect(find.text('Fresh'), findsOneWidget);
    expect(find.text('Interested'), findsOneWidget);
    expect(find.text('Follow Up'), findsWidgets);

    // Verify Allocation-style Total Leads count card
    expect(find.byKey(const ValueKey('followups-lead-count')), findsOneWidget);
    expect(find.text('Total Leads: 4'), findsOneWidget); // 4 total leads in missed (pages 1 + 2)

    // Verify lead cards from both pages are rendered
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Charlie Brown'), findsOneWidget);
    expect(find.text('David Wilson'), findsOneWidget);
    expect(find.text('Emma Davis'), findsOneWidget);
  });

  testWidgets('Selecting Fresh status displays only Fresh leads and exact matching count', (tester) async {
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

    // Tap 'Fresh' chip
    await tester.tap(find.text('Fresh'));
    await tester.pumpAndSettle();

    // Only Fresh leads should appear
    expect(find.text('Charlie Brown'), findsOneWidget); // From Page 1
    expect(find.text('Emma Davis'), findsOneWidget); // From Page 2
    expect(find.text('Alice Smith'), findsNothing); // Follow Up - hidden!
    expect(find.text('David Wilson'), findsNothing); // Interested - hidden!

    // Count must be 2 (exact matching count across all pages)
    expect(find.text('Total Leads: 2'), findsOneWidget);
    expect(find.text('42'), findsNothing); // Does NOT use global count!

    // Tap 'Fresh' again to toggle off -> restores all leads
    await tester.tap(find.text('Fresh'));
    await tester.pumpAndSettle();

    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('David Wilson'), findsOneWidget);
    expect(find.text('Total Leads: 4'), findsOneWidget);
  });

  testWidgets('Switching between All and Missed preserves selected status', (tester) async {
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

    // Select 'Fresh' on Missed tab
    await tester.tap(find.text('Fresh'));
    await tester.pumpAndSettle();

    expect(find.text('Charlie Brown'), findsOneWidget);
    expect(find.text('Total Leads: 2'), findsOneWidget);

    // Switch to 'All'
    await tester.tap(find.widgetWithText(ElevatedButton, 'All'));
    await tester.pumpAndSettle();

    // Fresh should remain selected on All tab!
    // In 'All', Frank Miller is Fresh, Bob Jones is Interested
    expect(find.text('Frank Miller'), findsOneWidget);
    expect(find.text('Bob Jones'), findsNothing);
    expect(find.text('Total Leads: 1'), findsOneWidget); // 1 Fresh lead in All
  });

  testWidgets('Switching between statuses repeatedly isolates records cleanly', (tester) async {
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

    // Select Interested
    await tester.tap(find.text('Interested'));
    await tester.pumpAndSettle();

    expect(find.text('David Wilson'), findsOneWidget);
    expect(find.text('Charlie Brown'), findsNothing);
    expect(find.text('Total Leads: 1'), findsOneWidget);

    // Switch to Follow Up
    await tester.tap(find.widgetWithText(GestureDetector, 'Follow Up').first);
    await tester.pumpAndSettle();

    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('David Wilson'), findsNothing);
    expect(find.text('Total Leads: 1'), findsOneWidget);
  });

  testWidgets('Search works together with active status filter', (tester) async {
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

    // Select Fresh (2 leads: Charlie Brown, Emma Davis)
    await tester.tap(find.text('Fresh'));
    await tester.pumpAndSettle();

    expect(find.text('Charlie Brown'), findsOneWidget);
    expect(find.text('Emma Davis'), findsOneWidget);

    // Search for 'Charlie'
    await tester.enterText(find.byType(TextField).first, 'Charlie');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.text('Charlie Brown'), findsOneWidget);
    expect(find.text('Emma Davis'), findsNothing);
    expect(find.text('Total Leads: 1'), findsOneWidget);
  });

  testWidgets('Changing date filter preserves active status filter', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = Get.put(AllMissFUpsController());
    await tester.pumpWidget(
      const GetMaterialApp(
        home: MissedFollowupsPage(initialType: 'Missed'),
      ),
    );
    await tester.pumpAndSettle();

    // Select Fresh
    await tester.tap(find.text('Fresh'));
    await tester.pumpAndSettle();
    expect(controller.selectedStatusName.value, 'Fresh');

    // Tap Yesterday
    await tester.tap(find.text('Yesterday'));
    await tester.pumpAndSettle();

    // Status filter is still Fresh!
    expect(controller.selectedStatusName.value, 'Fresh');
    expect(find.text('Yesterday'), findsOneWidget);
  });

  test('Background pagination error keeps already loaded records intact', () async {
    final controller = AllMissFUpsController();
    Get.put(controller);

    shouldFailPage2 = true;
    await controller.fetchData(isRefresh: true);
    // Allow background paging to trigger and catch error
    await Future.delayed(const Duration(milliseconds: 50));

    // Page 1 records remain in leads!
    expect(controller.leads, hasLength(3));
    expect(controller.hasMoreError.value, isTrue);
    expect(controller.isBackgroundPaging.value, isFalse);
  });

  test('Does not re-fetch all pages repeatedly when switching status on fully loaded dataset', () async {
    final controller = AllMissFUpsController();
    Get.put(controller);

    await controller.fetchData(isRefresh: true);
    await Future.delayed(const Duration(milliseconds: 50));
    final initialMissedRequests = requestedPaths.where((p) => p.endsWith('/lead/followup/missed')).length;

    // Switch status to Fresh
    controller.selectStatus('stage-fresh', 'Fresh');
    expect(controller.displayLeads, hasLength(2));

    // Switch status to Interested
    controller.selectStatus('stage-interested', 'Interested');
    expect(controller.displayLeads, hasLength(1));

    // No new API calls were made because the dataset is already fully loaded!
    final newMissedRequests = requestedPaths.where((p) => p.endsWith('/lead/followup/missed')).length;
    expect(newMissedRequests, initialMissedRequests);
  });
}
