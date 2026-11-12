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

  testWidgets('MissedFollowupsPage displays status counts inside horizontal chips with no separate count card', (tester) async {
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

    // Format: '<Status Name> : <Count>' directly inside chips across all pages
    expect(find.text('Fresh : 2'), findsOneWidget);
    expect(find.text('Interested : 1'), findsOneWidget);
    expect(find.text('Follow Up : 1'), findsWidgets);

    // Verify NO separate Total Leads count card exists
    expect(find.byKey(const ValueKey('followups-lead-count')), findsNothing);
    expect(find.textContaining('Total Leads'), findsNothing);

    // Verify lead cards from both pages are rendered
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Charlie Brown'), findsOneWidget);
    expect(find.text('David Wilson'), findsOneWidget);
    expect(find.text('Emma Davis'), findsOneWidget);
  });

  testWidgets('Chip styling adheres to selected and unselected pill specifications', (tester) async {
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

    // Before selection: Unselected chip has white background and blue text
    final unselectedText = tester.widget<Text>(find.text('Fresh : 2'));
    expect(unselectedText.style?.color, const Color(0xFF1471FF));

    final unselectedContainer = tester.widget<Container>(
      find.ancestor(of: find.text('Fresh : 2'), matching: find.byType(Container)).first,
    );
    final unselectedDecoration = unselectedContainer.decoration as BoxDecoration;
    expect(unselectedDecoration.color, Colors.white);
    expect(unselectedDecoration.borderRadius, BorderRadius.circular(25));
    expect(unselectedDecoration.border?.top.color, const Color(0xFF1471FF));

    // Tap Fresh chip to select it
    await tester.tap(find.text('Fresh : 2'));
    await tester.pumpAndSettle();

    // After selection: Selected chip has blue background and white text
    final selectedText = tester.widget<Text>(find.text('Fresh : 2'));
    expect(selectedText.style?.color, Colors.white);

    final selectedContainer = tester.widget<Container>(
      find.ancestor(of: find.text('Fresh : 2'), matching: find.byType(Container)).first,
    );
    final selectedDecoration = selectedContainer.decoration as BoxDecoration;
    expect(selectedDecoration.color, const Color(0xFF1471FF));
    expect(selectedDecoration.borderRadius, BorderRadius.circular(25));
  });

  testWidgets('Selecting Fresh status displays only Fresh leads and keeps chip counts intact', (tester) async {
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

    // Tap 'Fresh : 2' chip
    await tester.tap(find.text('Fresh : 2'));
    await tester.pumpAndSettle();

    // Only Fresh leads should appear
    expect(find.text('Charlie Brown'), findsOneWidget); // From Page 1
    expect(find.text('Emma Davis'), findsOneWidget); // From Page 2
    expect(find.text('Alice Smith'), findsNothing); // Follow Up - hidden!
    expect(find.text('David Wilson'), findsNothing); // Interested - hidden!

    // Chips still show counts matching their statuses
    expect(find.text('Fresh : 2'), findsOneWidget);
    expect(find.text('Interested : 1'), findsOneWidget);
    expect(find.text('Follow Up : 1'), findsWidgets);

    // No separate Total Leads count card
    expect(find.textContaining('Total Leads'), findsNothing);

    // Tap 'Fresh : 2' again to toggle off -> restores all leads
    await tester.tap(find.text('Fresh : 2'));
    await tester.pumpAndSettle();

    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('David Wilson'), findsOneWidget);
  });

  testWidgets('Switching between All and Missed recalculates counts for each tab across pages', (tester) async {
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

    // Select 'Fresh : 2' on Missed tab
    await tester.tap(find.text('Fresh : 2'));
    await tester.pumpAndSettle();

    expect(find.text('Charlie Brown'), findsOneWidget);
    expect(find.text('Emma Davis'), findsOneWidget);

    // Switch to 'All'
    await tester.tap(find.widgetWithText(ElevatedButton, 'All'));
    await tester.pumpAndSettle();

    // In 'All', Frank Miller is Fresh, Bob Jones is Interested
    // Counts inside chips recalculate across all pages in All:
    expect(find.text('Fresh : 1'), findsOneWidget);
    expect(find.text('Interested : 1'), findsOneWidget);
    expect(find.text('Follow Up : 0'), findsWidgets);

    // Fresh remains selected on All tab, displaying Frank Miller
    expect(find.text('Frank Miller'), findsOneWidget);
    expect(find.text('Bob Jones'), findsNothing);
    expect(find.textContaining('Total Leads'), findsNothing);
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
    await tester.tap(find.text('Interested : 1'));
    await tester.pumpAndSettle();

    expect(find.text('David Wilson'), findsOneWidget);
    expect(find.text('Charlie Brown'), findsNothing);

    // Switch to Follow Up
    await tester.tap(find.widgetWithText(GestureDetector, 'Follow Up : 1').first);
    await tester.pumpAndSettle();

    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('David Wilson'), findsNothing);
  });

  testWidgets('Search recalculates status counts and filters list', (tester) async {
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
    await tester.tap(find.text('Fresh : 2'));
    await tester.pumpAndSettle();

    expect(find.text('Charlie Brown'), findsOneWidget);
    expect(find.text('Emma Davis'), findsOneWidget);

    // Search for 'Charlie'
    await tester.enterText(find.byType(TextField).first, 'Charlie');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.text('Charlie Brown'), findsOneWidget);
    expect(find.text('Emma Davis'), findsNothing);

    // Chips update to reflect matching search query
    expect(find.text('Fresh : 1'), findsOneWidget);
    expect(find.text('Interested : 0'), findsOneWidget);
    expect(find.text('Follow Up : 0'), findsWidgets);
    expect(find.textContaining('Total Leads'), findsNothing);
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
    await tester.tap(find.text('Fresh : 2'));
    await tester.pumpAndSettle();
    expect(controller.selectedStatusName.value, 'Fresh');

    // Tap Yesterday
    await tester.tap(find.text('Yesterday'));
    await tester.pumpAndSettle();

    // Status filter is still Fresh!
    expect(controller.selectedStatusName.value, 'Fresh');
    expect(find.text('Yesterday'), findsOneWidget);
  });

  testWidgets('While background pagination is running, shows loading indicator in chip rather than incomplete count', (tester) async {
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

    // Verify initial complete state
    expect(find.text('Fresh : 2'), findsOneWidget);

    // Simulate background pagination is currently fetching remaining pages
    controller.isBackgroundPaging.value = true;
    await tester.pump();

    // When background paging is active, chips display '<Status Name> : ' with loading indicator
    expect(find.text('Fresh : '), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-loading-indicator')), findsWidgets);
    // Incomplete count is NOT displayed as final
    expect(find.text('Fresh : 2'), findsNothing);

    // Pagination completes
    controller.isBackgroundPaging.value = false;
    await tester.pump();

    // Final count across all pages is displayed
    expect(find.text('Fresh : 2'), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-loading-indicator')), findsNothing);
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
