import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart' as all_leads;
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/local_storage/up_coming_followups_controller.dart';
import 'package:crm_flutter/pages/Allocations/WhatsappSMS/whatsapp_sms_controller.dart';
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/Allocations/missedFollowUps/missed_followups_controller.dart';
import 'package:crm_flutter/pages/Allocations/missedFollowUps/missed_followups_page.dart';
import 'package:crm_flutter/pages/home/HomeController.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
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

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    LocalStorage.sharedPreferences = await SharedPreferences.getInstance();

    dio = Dio();
    DioUtil.dio = dio;
    requestedPaths.clear();
    requestedQueryParams.clear();

    Get.put<FollowUpController>(_MockFollowUpController());
    Get.put(DioApi());
    Get.put(WhatsappSmsController());
    Get.put(HomeController());
    Get.put(AllocationController());
    Get.put(Leaddetailscontroller());

    // Set up interceptor to mock API responses and verify query parameters
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestedPaths.add(options.uri.path);
          requestedQueryParams.add(
            Map<String, dynamic>.from(options.queryParameters),
          );

          if (options.uri.path.endsWith('/leadstage/all')) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'data': [
                    {'_id': 'stage-1', 'name': 'Follow Up', 'count': 5},
                  ],
                },
              ),
            );
          } else if (options.uri.path.endsWith('/lead/followup/all')) {
            final searchQuery = (options.queryParameters['search'] ?? '').toString().toLowerCase();
            final allItems = [
              {
                '_id': 'all-1',
                'name': {'first': 'Aryan', 'last': 'Sharma'},
                'phone': 9876543210,
                'email': 'aryan@example.com',
                'campaign': {'_id': 'c1', 'name': 'Camp 1'},
                'lead_stage_id': {'_id': 's1', 'name': 'Follow Up'},
                'updatedAt': '2026-11-04T10:00:00.000Z',
                'followUpDate': '2026-11-04T10:00:00.000Z',
              },
              {
                '_id': 'all-2',
                'name': {'first': 'Neha', 'last': 'Gupta'},
                'phone': 9123456789,
                'email': 'neha@example.com',
                'campaign': {'_id': 'c2', 'name': 'Camp 2'},
                'lead_stage_id': {'_id': 's1', 'name': 'Follow Up'},
                'updatedAt': '2026-11-04T11:00:00.000Z',
                'followUpDate': '2026-11-04T11:00:00.000Z',
              },
            ];

            final filtered = searchQuery.isEmpty
                ? allItems
                : allItems.where((item) {
                    final rawName = item['name'] as Map;
                    final name = '${rawName['first']} ${rawName['last']}'.toLowerCase();
                    final phone = item['phone'].toString();
                    final email = (item['email'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery) ||
                        phone.contains(searchQuery) ||
                        email.contains(searchQuery);
                  }).toList();

            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'total': filtered.length,
                  'totalPages': 1,
                  'currentPage': options.queryParameters['page'] ?? 1,
                  'data': filtered,
                },
              ),
            );
          } else if (options.uri.path.endsWith('/lead/followup/missed')) {
            final searchQuery = (options.queryParameters['search'] ?? '').toString().toLowerCase();
            final missedItems = [
              {
                '_id': 'missed-1',
                'name': {'first': 'Bob', 'last': 'Jones'},
                'phone': 9988776655,
                'email': 'bob.jones@example.com',
                'campaign': {'_id': 'c3', 'name': 'Camp 3'},
                'lead_stage_id': {'_id': 's2', 'name': 'Missed'},
                'updatedAt': '2026-11-03T10:00:00.000Z',
                'followUpDate': '2026-11-03T10:00:00.000Z',
              },
            ];

            final filtered = searchQuery.isEmpty
                ? missedItems
                : missedItems.where((item) {
                    final rawName = item['name'] as Map;
                    final name = '${rawName['first']} ${rawName['last']}'.toLowerCase();
                    final phone = item['phone'].toString();
                    final email = (item['email'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery) ||
                        phone.contains(searchQuery) ||
                        email.contains(searchQuery);
                  }).toList();

            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'total': filtered.length,
                  'totalPages': 1,
                  'currentPage': options.queryParameters['page'] ?? 1,
                  'data': filtered,
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

  group('AllMissFUpsController - Lead Search Matching Logic', () {
    test('1. Search by complete and partial lead name (case-insensitive)', () {
      final lead = all_leads.Data(
        sId: 'lead-1',
        name: all_leads.Name(first: 'Aryan', last: 'Sharma'),
        phone: 9876543210,
        email: 'aryan.sharma@example.com',
      );

      // Complete name
      expect(AllMissFUpsController.matchesLeadSearch(lead, 'Aryan Sharma'), isTrue);
      // Case-insensitive
      expect(AllMissFUpsController.matchesLeadSearch(lead, 'aryan'), isTrue);
      expect(AllMissFUpsController.matchesLeadSearch(lead, 'SHARMA'), isTrue);
      // Partial name
      expect(AllMissFUpsController.matchesLeadSearch(lead, 'ary'), isTrue);
      expect(AllMissFUpsController.matchesLeadSearch(lead, 'shar'), isTrue);
      // Non-matching
      expect(AllMissFUpsController.matchesLeadSearch(lead, 'John'), isFalse);
    });

    test('2. Search by complete and partial phone number', () {
      final lead = all_leads.Data(
        sId: 'lead-2',
        name: all_leads.Name(first: 'Bob', last: 'Smith'),
        phone: 9876543210,
        email: 'bob@smith.com',
      );

      // Complete phone
      expect(AllMissFUpsController.matchesLeadSearch(lead, '9876543210'), isTrue);
      // Partial phone
      expect(AllMissFUpsController.matchesLeadSearch(lead, '98765'), isTrue);
      expect(AllMissFUpsController.matchesLeadSearch(lead, '43210'), isTrue);
      expect(AllMissFUpsController.matchesLeadSearch(lead, '7654'), isTrue);
      // Non-matching phone
      expect(AllMissFUpsController.matchesLeadSearch(lead, '112233'), isFalse);
    });

    test('3. Search by email (case-insensitive and partial)', () {
      final lead = all_leads.Data(
        sId: 'lead-3',
        name: all_leads.Name(first: 'Charlie', last: 'Brown'),
        phone: 9988776655,
        email: 'charlie.brown@testdomain.com',
      );

      // Complete email
      expect(
        AllMissFUpsController.matchesLeadSearch(lead, 'charlie.brown@testdomain.com'),
        isTrue,
      );
      // Case-insensitive
      expect(
        AllMissFUpsController.matchesLeadSearch(lead, 'CHARLIE.BROWN@TESTDOMAIN.COM'),
        isTrue,
      );
      // Partial email
      expect(AllMissFUpsController.matchesLeadSearch(lead, 'charlie'), isTrue);
      expect(AllMissFUpsController.matchesLeadSearch(lead, '@testdomain'), isTrue);
      expect(AllMissFUpsController.matchesLeadSearch(lead, '.com'), isTrue);
      // Non-matching email
      expect(AllMissFUpsController.matchesLeadSearch(lead, 'yahoo.com'), isFalse);
    });

    test('4. Empty query matches all leads', () {
      final lead = all_leads.Data(
        sId: 'lead-4',
        name: all_leads.Name(first: 'David', last: 'Miller'),
        phone: 9112233445,
        email: 'david@miller.com',
      );

      expect(AllMissFUpsController.matchesLeadSearch(lead, ''), isTrue);
      expect(AllMissFUpsController.matchesLeadSearch(lead, '   '), isTrue);
    });
  });

  group('AllMissFUpsController - Server-side query parameter and pagination', () {
    test('5. Sends search query parameter to API and resets pagination to page 1', () async {
      final controller = AllMissFUpsController();
      controller.followUpType.value = 'All';

      // First fetch without search
      await controller.fetchData(isRefresh: true);
      expect(requestedPaths.last, contains('/lead/followup/all'));
      expect(requestedQueryParams.last['page'], 1);
      expect(requestedQueryParams.last.containsKey('search'), isFalse);

      // Search with query 'ary'
      controller.onSearchChanged('ary');
      // Wait for debounce timer
      await Future.delayed(const Duration(milliseconds: 450));

      expect(requestedPaths.last, contains('/lead/followup/all'));
      expect(requestedQueryParams.last['page'], 1);
      expect(requestedQueryParams.last['search'], 'ary');
    });

    test('6. Passes date filter alongside search query parameter', () async {
      final controller = AllMissFUpsController();
      controller.followUpType.value = 'Missed';
      controller.selectedStartDate.value = DateTime(2026, 11, 1);
      controller.selectedEndDate.value = DateTime(2026, 11, 4);

      controller.onSearchChanged('Bob');
      await Future.delayed(const Duration(milliseconds: 450));

      expect(requestedPaths.last, contains('/lead/followup/missed'));
      expect(requestedQueryParams.last['search'], 'Bob');
      expect(requestedQueryParams.last.containsKey('followUpStartDate'), isTrue);
      expect(requestedQueryParams.last.containsKey('followUpEndDate'), isTrue);
    });
  });

  group('MissedFollowupsPage - Widget Integration Tests', () {
    testWidgets('7. Search UI renders with icon, hint, filters leads, and clear button restores list', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MissedFollowupsPage(initialType: 'All'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify UI elements
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search leads by name, phone or email...'), findsOneWidget);

      // Both leads loaded from mock
      expect(find.text('Aryan Sharma'), findsOneWidget);
      expect(find.text('Neha Gupta'), findsOneWidget);

      // Search by partial name: 'ary'
      await tester.enterText(find.byType(TextField).first, 'ary');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Clear button is visible
      expect(find.byTooltip('Clear search'), findsOneWidget);
      // 'Aryan Sharma' displayed, 'Neha Gupta' filtered out
      expect(find.text('Aryan Sharma'), findsOneWidget);
      expect(find.text('Neha Gupta'), findsNothing);

      // Search by partial phone: '1234'
      await tester.enterText(find.byType(TextField).first, '1234');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 'Neha Gupta' displayed, 'Aryan Sharma' filtered out
      expect(find.text('Aryan Sharma'), findsNothing);
      expect(find.text('Neha Gupta'), findsOneWidget);

      // Tap clear search button
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Both leads restored
      expect(find.text('Aryan Sharma'), findsOneWidget);
      expect(find.text('Neha Gupta'), findsOneWidget);
    });

    testWidgets('8. No matching leads shows "No leads found" message', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MissedFollowupsPage(initialType: 'All'),
        ),
      );
      await tester.pumpAndSettle();

      // Search for non-existent lead
      await tester.enterText(find.byType(TextField).first, 'NonExistent999');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.text('Aryan Sharma'), findsNothing);
      expect(find.text('Neha Gupta'), findsNothing);
      expect(find.text('No leads found'), findsOneWidget);
    });

    testWidgets('9. Toggling between All and Missed maintains independent search queries', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MissedFollowupsPage(initialType: 'All'),
        ),
      );
      await tester.pumpAndSettle();

      final controller = Get.find<AllMissFUpsController>();

      // Search 'Aryan' on All tab
      await tester.enterText(find.byType(TextField).first, 'Aryan');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(controller.searchQueryAll.value, 'Aryan');
      expect(find.text('Aryan Sharma'), findsOneWidget);

      // Switch to Missed tab
      await tester.tap(find.text('Missed'));
      await tester.pumpAndSettle();

      // TextField should be empty on Missed tab
      final tfMissed = tester.widget<TextField>(find.byType(TextField).first);
      expect(tfMissed.controller?.text, '');
      expect(controller.currentSearchQuery, '');
      // Missed lead 'Bob Jones' should be visible
      expect(find.text('Bob Jones'), findsOneWidget);

      // Search 'Bob' on Missed tab
      await tester.enterText(find.byType(TextField).first, 'Bob');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(controller.searchQueryMissed.value, 'Bob');
      expect(controller.searchQueryAll.value, 'Aryan'); // All tab query preserved!

      // Switch back to All tab
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // TextField should restore 'Aryan'
      final tfAll = tester.widget<TextField>(find.byType(TextField).first);
      expect(tfAll.controller?.text, 'Aryan');
      expect(controller.currentSearchQuery, 'Aryan');
      expect(find.text('Aryan Sharma'), findsOneWidget);
    });

    testWidgets('10. Shows loading indicator and error state when appropriate', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MissedFollowupsPage(initialType: 'All'),
        ),
      );
      await tester.pumpAndSettle();

      final controller = Get.find<AllMissFUpsController>();

      // Test loading state
      controller.leads.clear();
      controller.isInitialLoading.value = true;
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Test error retry state
      controller.isInitialLoading.value = false;
      controller.hasMoreError.value = true;
      await tester.pump();
      expect(find.text('Could not load follow-ups. Retry'), findsOneWidget);
    });

    test('11. Multi-page pagination continues to work with search query', () async {
      final controller = AllMissFUpsController();
      controller.followUpType.value = 'All';

      // Start search
      controller.onSearchChanged('searchTest');
      await Future.delayed(const Duration(milliseconds: 450));
      expect(requestedQueryParams.last['search'], 'searchTest');
      expect(requestedQueryParams.last['page'], 1);

      // Simulate loading next page (page 2)
      controller.currentPage = 2;
      controller.isMoreDataAvailable.value = true;
      await controller.fetchData(isRefresh: false);

      expect(requestedQueryParams.last['search'], 'searchTest');
      expect(requestedQueryParams.last['page'], 2);
    });
  });
}
