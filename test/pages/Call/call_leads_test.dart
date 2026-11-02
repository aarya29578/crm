import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/api/response/all_calls_history_response.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/Call/call_leads_controller.dart';
import 'package:crm_flutter/pages/Call/call_leads_page.dart';
import 'package:crm_flutter/pages/home/HomePage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio mockDio;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'user_Id': 'test-user-123',
      'user_name': 'Test User',
      'token': 'mock-token',
    });
    LocalStorage.sharedPreferences = await SharedPreferences.getInstance();
    Get.reset();

    mockDio = Dio();
    DioUtil.dio = mockDio;
  });

  tearDown(() {
    mockDio.close();
    Get.reset();
  });

  group('CallLeadsController Tests', () {
    test('filters calls by overall, outbound, and inbound correctly', () async {
      final sampleCalls = [
        CallHistoryGroup(
          date: '2026-11-02',
          lastCallAt: '2026-11-02T10:00:00.000Z',
          callCount: 2,
          calledBy: CalledBy(sId: 'user-1', name: 'Agent John'),
          lead: Lead(
            sId: 'lead-1',
            name: LeadName(first: 'Alice', last: 'Smith'),
            phone: 9876543210,
          ),
          callLog: CallLog(
            direction: 'outbound',
            duration: 120,
            status: 'completed',
          ),
        ),
        CallHistoryGroup(
          date: '2026-11-02',
          lastCallAt: '2026-11-02T11:00:00.000Z',
          callCount: 1,
          calledBy: CalledBy(sId: 'user-2', name: 'Agent Jane'),
          lead: Lead(
            sId: 'lead-2',
            name: LeadName(first: 'Bob', last: 'Jones'),
            phone: 9123456780,
          ),
          callLog: CallLog(
            direction: 'inbound',
            duration: 45,
            status: 'completed',
          ),
        ),
        CallHistoryGroup(
          date: '2026-11-02',
          lastCallAt: '2026-11-02T12:00:00.000Z',
          callCount: 1,
          calledBy: CalledBy(sId: 'user-3', name: 'Agent Jane'),
          lead: Lead(
            sId: 'lead-3',
            name: LeadName(first: 'Charlie', last: 'Brown'),
            phone: 9988776655,
          ),
          callLog: CallLog(
            direction: '',
            duration: 0,
            status: 'missed',
          ),
        ),
      ];

      // 1. Overall
      final overallController = CallLeadsController(callType: CallLeadType.overall);
      overallController.callLogsResponse.value = AllCallHistoryResponse(
        success: true,
        data: sampleCalls,
      );
      expect(overallController.filteredLeads.length, 3);
      expect(overallController.callType.title, 'Overall Calls');

      // 2. Outbound
      final outboundController = CallLeadsController(callType: CallLeadType.outbound);
      outboundController.callLogsResponse.value = AllCallHistoryResponse(
        success: true,
        data: sampleCalls,
      );
      expect(outboundController.filteredLeads.length, 1);
      expect(outboundController.filteredLeads.first.lead?.name?.first, 'Alice');
      expect(outboundController.callType.title, 'Outbound Calls');

      // 3. Inbound (includes inbound and missed)
      final inboundController = CallLeadsController(callType: CallLeadType.inbound);
      inboundController.callLogsResponse.value = AllCallHistoryResponse(
        success: true,
        data: sampleCalls,
      );
      expect(inboundController.filteredLeads.length, 2);
      expect(inboundController.filteredLeads[0].lead?.name?.first, 'Bob');
      expect(inboundController.filteredLeads[1].lead?.name?.first, 'Charlie');
      expect(inboundController.callType.title, 'Inbound Calls');
    });

    test('search filters leads by lead name, phone number, and agent name', () {
      final sampleCalls = [
        CallHistoryGroup(
          calledBy: CalledBy(name: 'Agent Cooper'),
          lead: Lead(
            name: LeadName(first: 'Bruce', last: 'Wayne'),
            phone: 9876543210,
          ),
          callLog: CallLog(direction: 'outbound'),
        ),
        CallHistoryGroup(
          calledBy: CalledBy(name: 'Agent Scully'),
          lead: Lead(
            name: LeadName(first: 'Clark', last: 'Kent'),
            phone: 9112233445,
          ),
          callLog: CallLog(direction: 'outbound'),
        ),
      ];

      final controller = CallLeadsController(callType: CallLeadType.outbound);
      controller.callLogsResponse.value = AllCallHistoryResponse(
        success: true,
        data: sampleCalls,
      );

      // Search by first name
      controller.searchQuery.value = 'bruce';
      expect(controller.filteredLeads.length, 1);
      expect(controller.filteredLeads.first.lead?.name?.first, 'Bruce');

      // Search by phone
      controller.searchQuery.value = '91122';
      expect(controller.filteredLeads.length, 1);
      expect(controller.filteredLeads.first.lead?.name?.first, 'Clark');

      // Search by agent name
      controller.searchQuery.value = 'cooper';
      expect(controller.filteredLeads.length, 1);
      expect(controller.filteredLeads.first.lead?.name?.first, 'Bruce');

      // Empty query restores all
      controller.searchQuery.value = '';
      expect(controller.filteredLeads.length, 2);
    });

    test('fetchCalls sends date query params and updates state', () async {
      Map<String, dynamic>? requestedParams;
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedParams = options.queryParameters;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'data': [
                    {
                      'date': '2026-11-02',
                      'call_log': {'direction': 'outbound', 'duration': 60},
                      'lead': {
                        '_id': 'lead-99',
                        'name': {'first': 'Diana', 'last': 'Prince'},
                        'phone': 9999999999,
                      },
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final controller = CallLeadsController(callType: CallLeadType.overall);
      final startDate = DateTime(2026, 11, 1);
      final endDate = DateTime(2026, 11, 2);

      await controller.fetchCalls(startDate: startDate, endDate: endDate);

      expect(controller.callApiState.value, PageState.stable);
      expect(controller.callLogsResponse.value.data?.length, 1);
      expect(requestedParams, isNotNull);
      expect(requestedParams?['startDate'], isNotNull);
      expect(requestedParams?['endDate'], isNotNull);
    });

    test('handles API errors safely without throwing unhandled exceptions', () async {
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 500,
                  data: {'message': 'Internal Server Error'},
                ),
              ),
            );
          },
        ),
      );

      final controller = CallLeadsController(callType: CallLeadType.overall);
      await controller.fetchCalls();

      expect(controller.callApiState.value, PageState.error);
    });
  });

  group('CallLeadsPage Widget Tests', () {
    testWidgets('renders CallLeadsPage with correct title, chips, and empty state', (
      tester,
    ) async {
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true, 'data': []},
              ),
            );
          },
        ),
      );

      await tester.pumpWidget(
        GetMaterialApp(
          home: CallLeadsPage(
            callType: CallLeadType.outbound,
            timeRange: 'Today',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title
      expect(find.text('Outbound Calls'), findsOneWidget);

      // Verify time tabs
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Last 30 Days'), findsOneWidget);
      expect(find.text('Select Range'), findsOneWidget);

      // Verify empty state
      expect(find.text('No outbound calls found'), findsOneWidget);
    });

    testWidgets('renders lead cards with name, phone, call type, duration, and time', (
      tester,
    ) async {
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'data': [
                    {
                      'lastCallAt': '2026-11-02T10:30:00.000Z',
                      'callCount': 3,
                      'calledBy': {'_id': 'agent-1', 'name': 'Agent Smith'},
                      'lead': {
                        '_id': 'lead-100',
                        'name': {'first': 'Sarah', 'middle': 'J', 'last': 'Connor'},
                        'phone': 9876543210,
                        'lead_stage_id': {'name': 'Negotiation'},
                      },
                      'call_log': {
                        'direction': 'inbound',
                        'duration': 135,
                        'status': 'completed',
                      },
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      await tester.pumpWidget(
        GetMaterialApp(
          home: CallLeadsPage(
            callType: CallLeadType.inbound,
            timeRange: 'Today',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Lead name
      expect(find.text('Sarah J Connor'), findsOneWidget);

      // Phone number
      expect(find.text('9876543210'), findsOneWidget);

      // Call type badge
      expect(find.text('Inbound'), findsWidgets);

      // Call duration: 135s -> 2m 15s
      expect(find.text('2m 15s'), findsOneWidget);

      // Call count badge
      expect(find.text('3 Calls'), findsOneWidget);

      // Agent name
      expect(find.text('Agent Smith'), findsOneWidget);

      // Stage
      expect(find.text('Negotiation'), findsOneWidget);
    });
  });

  group('Home Screen Stat Tabs Navigation Tests', () {
    void setupHomeMockDio(Dio dio) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final path = options.uri.path;
            if (path.contains('/dashboard/call-duration')) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'success': true,
                    'data': {
                      'callStates': {
                        'overall': 12,
                        'outbound': 8,
                        'inbound': 4,
                        'overallTotalCallsCount': 12,
                        'overallConnectedCount': 6,
                        'totalDuration': 120,
                        'totalDurationFormatted': '2m 0s',
                      },
                    },
                  },
                ),
              );
            } else if (path.contains('/campaign')) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true, 'data': []},
                ),
              );
            } else if (path.contains('/lead/stage')) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true, 'data': []},
                ),
              );
            } else if (path.contains('/lead')) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true, 'data': []},
                ),
              );
            } else if (path.endsWith('/call')) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true, 'data': []},
                ),
              );
            } else {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
            }
          },
        ),
      );
    }

    testWidgets('tapping Overall Calls navigates to CallLeadsPage with Overall Calls title', (
      tester,
    ) async {
      setupHomeMockDio(mockDio);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      final overallTab = find.text('Overall');
      expect(overallTab, findsOneWidget);

      await tester.tap(overallTab);
      await tester.pumpAndSettle();

      expect(find.text('Overall Calls'), findsOneWidget);
    });

    testWidgets('tapping Outbound Calls navigates to CallLeadsPage with Outbound Calls title', (
      tester,
    ) async {
      setupHomeMockDio(mockDio);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      final outboundTab = find.text('Outbound');
      expect(outboundTab, findsOneWidget);

      await tester.tap(outboundTab);
      await tester.pumpAndSettle();

      expect(find.text('Outbound Calls'), findsOneWidget);
    });

    testWidgets('tapping Inbound Calls navigates to CallLeadsPage with Inbound Calls title', (
      tester,
    ) async {
      setupHomeMockDio(mockDio);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      final inboundTab = find.text('Inbound');
      expect(inboundTab, findsOneWidget);

      await tester.tap(inboundTab);
      await tester.pumpAndSettle();

      expect(find.text('Inbound Calls'), findsOneWidget);
    });
  });
}
