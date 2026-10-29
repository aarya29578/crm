import 'dart:async';
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/helper/whatsapp_helper.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Allocations/WhatsappSMS/whatsapp_sms_controller.dart';
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/Allocations/components/callLogCard.dart';
import 'package:crm_flutter/pages/claimed/ClaimedController.dart';
import 'package:crm_flutter/pages/home/HomeController.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
import 'package:crm_flutter/widgets/ClaimedLeadCard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

class _MockAllocationController extends AllocationController {
  bool refreshDataCalled = false;

  @override
  Future<void> getAllLeadStages() async {}

  @override
  Future<void> refreshData() async {
    refreshDataCalled = true;
  }
}

void main() {
  late Dio dio;
  final requestedCampaignIds = <String?>[];
  Uri? lastLaunchedUrl;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'user_name': 'Agent Smith',
    });
    LocalStorage.sharedPreferences = await SharedPreferences.getInstance();

    WhatsAppHelper.defaultCanLaunchChecker = (url) async => true;
    WhatsAppHelper.defaultLauncher = (url, mode) async {
      lastLaunchedUrl = url;
      return true;
    };

    dio = Dio();
    DioUtil.dio = dio;
    requestedCampaignIds.clear();
    lastLaunchedUrl = null;

    Get.reset();
    Get.put(DioApi());
    Get.put(WhatsappSmsController());
    Get.put<AllocationController>(_MockAllocationController());
    Get.put(Leaddetailscontroller());
    Get.put(HomeController());
    Get.put(Claimedcontroller());

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.uri.path.endsWith('/templates/all')) {
            final campaignId = options.queryParameters['campaign_id'] as String?;
            requestedCampaignIds.add(campaignId);

            if (campaignId == 'campaign-a') {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'success': true,
                    'data': [
                      {
                        '_id': 'template-a-1',
                        'name': 'Welcome A',
                        'body': 'Welcome {customer_name} from Campaign A! Agent: {agent_name}',
                        'channel': 'whatsapp',
                      },
                    ],
                  },
                ),
              );
            } else if (campaignId == 'campaign-b') {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'success': true,
                    'data': [
                      {
                        '_id': 'template-b-1',
                        'name': 'Offer B',
                        'body': 'Special Offer for {name} from Campaign B!',
                        'channel': 'whatsapp',
                      },
                    ],
                  },
                ),
              );
            } else if (campaignId == 'campaign-empty') {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'success': true,
                    'data': [],
                  },
                ),
              );
            } else if (campaignId == 'campaign-error') {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 500,
                    data: {'success': false, 'message': 'Internal Server Error'},
                  ),
                  type: DioExceptionType.badResponse,
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
          } else if (options.uri.path.endsWith('/templates/usage')) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true, 'message': 'Usage recorded'},
              ),
            );
          } else if (options.uri.path.contains('/timeline/')) {
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
  });

  tearDown(() {
    WhatsAppHelper.defaultCanLaunchChecker = null;
    WhatsAppHelper.defaultLauncher = null;
    Get.reset();
    LocalStorage.sharedPreferences = null;
    dio.close(force: true);
  });

  testWidgets(
      '1. WhatsApp option appears in Home screen lead card and does not trigger navigation',
      (tester) async {
    var navigationTriggered = false;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: GestureDetector(
              onTap: () => navigationTriggered = true,
              child: ClaimedLeadCard(
                context,
                '2 hours ago',
                'John Doe',
                '9876543210',
                'Acme Corp',
                'Agent Smith',
                'Campaign A',
                'lead-1',
                'john@example.com',
                null,
                null,
                campaignId: 'campaign-a',
              ),
            ),
          ),
        ),
      ),
    );

    final whatsappButtonFinder = find.byTooltip('WhatsApp');
    expect(whatsappButtonFinder, findsOneWidget);

    // Tap WhatsApp button - should NOT trigger card navigation
    await tester.tap(whatsappButtonFinder);
    await tester.pumpAndSettle();

    expect(navigationTriggered, isFalse);
    expect(find.text('WhatsApp Templates'), findsOneWidget);
  });

  testWidgets(
      '2. Correct campaign ID is passed when loading templates for each lead',
      (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ClaimedLeadCard(
              context,
              'Just now',
              'Lead One',
              '9876543210',
              'Org',
              'Agent',
              'Campaign Alpha',
              'lead-alpha-1',
              'lead@test.com',
              null,
              null,
              campaignId: 'campaign-a',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('WhatsApp'));
    await tester.pumpAndSettle();

    expect(requestedCampaignIds, contains('campaign-a'));
    expect(find.text('Welcome A'), findsOneWidget);
  });

  testWidgets(
      '3. Leads from different campaigns receive their respective templates and substitute variables',
      (tester) async {
    // First Lead: Campaign A
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              WhatsAppHelper.showWhatsAppTemplates(
                context: context,
                leadId: 'lead-a',
                campaignId: 'campaign-a',
                phone: '9876543210',
                customerName: 'Alice',
              );
            },
            child: const Text('Open Lead A WhatsApp'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Lead A WhatsApp'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome A'), findsOneWidget);
    // Verifies customerName 'Alice' and agentName 'Agent Smith' are substituted
    expect(
      find.text('Welcome Alice from Campaign A! Agent: Agent Smith'),
      findsOneWidget,
    );

    // Tap the template to send
    await tester.tap(find.text('Welcome A'));
    await tester.pumpAndSettle();

    expect(lastLaunchedUrl, isNotNull);
    expect(
      lastLaunchedUrl.toString(),
      contains('whatsapp://send?phone=919876543210'),
    );
    expect(
      lastLaunchedUrl.toString(),
      contains(Uri.encodeComponent('Welcome Alice from Campaign A! Agent: Agent Smith')),
    );

    // Now Lead B: Campaign B
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              WhatsAppHelper.showWhatsAppTemplates(
                context: context,
                leadId: 'lead-b',
                campaignId: 'campaign-b',
                phone: '9123456789',
                customerName: 'Bob',
              );
            },
            child: const Text('Open Lead B WhatsApp'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Lead B WhatsApp'));
    await tester.pumpAndSettle();

    expect(find.text('Offer B'), findsOneWidget);
    expect(
      find.text('Special Offer for Bob from Campaign B!'),
      findsOneWidget,
    );
    expect(find.text('Welcome A'), findsNothing);
  });

  testWidgets(
      '4. Switching from one lead to another does not reuse stale template data',
      (tester) async {
    final completerA = Completer<Response>();

    // Set up interceptor where campaign-a is held pending
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final campaignId = options.queryParameters['campaign_id'];
          if (campaignId == 'campaign-a') {
            final res = await completerA.future;
            handler.resolve(res);
          } else {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'data': [
                    {
                      '_id': 'template-b-1',
                      'name': 'Template B Only',
                      'body': 'Campaign B message',
                      'channel': 'whatsapp',
                    },
                  ],
                },
              ),
            );
          }
        },
      ),
    );

    // 1. Start fetching for Lead A (Campaign A)
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  WhatsAppHelper.showWhatsAppTemplates(
                    context: context,
                    leadId: 'lead-a',
                    campaignId: 'campaign-a',
                    phone: '9876543210',
                    customerName: 'Lead A',
                  );
                },
                child: const Text('Lead A'),
              ),
              ElevatedButton(
                onPressed: () {
                  WhatsAppHelper.showWhatsAppTemplates(
                    context: context,
                    leadId: 'lead-b',
                    campaignId: 'campaign-b',
                    phone: '9123456789',
                    customerName: 'Lead B',
                  );
                },
                child: const Text('Lead B'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Lead A'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Shows loading indicator for Lead A
    expect(find.text('Loading templates...'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // 2. Open dialog for Lead B (Campaign B) while Lead A's response hasn't returned yet
    await tester.tap(find.text('Lead B'));
    await tester.pumpAndSettle();

    // Lead B received its own templates
    expect(find.text('Template B Only'), findsOneWidget);

    // 3. Now let Lead A's slow network request complete
    completerA.complete(
      Response(
        requestOptions: RequestOptions(path: '/templates/all'),
        statusCode: 200,
        data: {
          'success': true,
          'data': [
            {
              '_id': 'template-a-stale',
              'name': 'Stale Template A',
              'body': 'Should never be shown in B',
              'channel': 'whatsapp',
            },
          ],
        },
      ),
    );
    await tester.pumpAndSettle();

    // Verify stale template A does NOT appear in Lead B's dialog!
    expect(find.text('Stale Template A'), findsNothing);
    expect(find.text('Template B Only'), findsOneWidget);
  });

  testWidgets(
      '5. Existing Allocation screen WhatsApp functionality continues to work',
      (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: CallLogCard(
            name: 'Allocation Lead',
            leadId: 'alloc-lead-1',
            campaignId: 'campaign-a',
            tag: 'Assigned',
            phone: 9876543210,
            assignedTo: null,
            time: '2026-10-28',
            isMissedFUps: true,
          ),
        ),
      ),
    );

    // Verify the WhatsApp icon button is present on CallLogCard
    final whatsappBtn = find.byWidgetPredicate(
      (w) => w is IconButton && w.onPressed != null,
    );
    expect(whatsappBtn, findsWidgets);

    // Open WhatsApp dialog on CallLogCard
    final callLogCardState = tester.state(find.byType(Scaffold));
    final cardWidget = tester.widget<CallLogCard>(find.byType(CallLogCard));
    cardWidget.onWhatsApp(callLogCardState.context);
    await tester.pumpAndSettle();

    expect(find.text('WhatsApp Templates'), findsOneWidget);
    expect(find.text('Welcome A'), findsOneWidget);

    // Test openWhatsApp directly
    await cardWidget.openWhatsApp('9876543210', 'Test message');
    expect(lastLaunchedUrl, isNotNull);
  });

  testWidgets(
      '6. Loading, empty-template, and API-error states are handled safely',
      (tester) async {
    // 6a. Empty template state
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                WhatsAppHelper.showWhatsAppTemplates(
                  context: context,
                  leadId: 'lead-empty',
                  campaignId: 'campaign-empty',
                  phone: '9876543210',
                  customerName: 'No Templates User',
                );
              },
              child: const Text('Open Empty Campaign'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Empty Campaign'));
    await tester.pumpAndSettle();

    expect(find.text('No templates available'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // 6b. Error state
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                WhatsAppHelper.showWhatsAppTemplates(
                  context: context,
                  leadId: 'lead-err',
                  campaignId: 'campaign-error',
                  phone: '9876543210',
                  customerName: 'Error User',
                );
              },
              child: const Text('Open Error Campaign'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Error Campaign'));
    await tester.pumpAndSettle();

    expect(find.text('Failed to load templates'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // 6c. Missing campaign ID edge case
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                WhatsAppHelper.showWhatsAppTemplates(
                  context: context,
                  leadId: 'lead-no-camp',
                  campaignId: null,
                  phone: '9876543210',
                  customerName: 'No Campaign User',
                );
              },
              child: const Text('Missing Campaign'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Missing Campaign'));
    await tester.pump(const Duration(milliseconds: 100));

    // Shows error snackbar without crashing and does not open template dialog
    expect(find.text('WhatsApp Templates'), findsNothing);

    // Drain snackbars
    await tester.pump(const Duration(seconds: 4));

    // 6d. Missing phone number edge case
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                WhatsAppHelper.showWhatsAppTemplates(
                  context: context,
                  leadId: 'lead-no-phone',
                  campaignId: 'campaign-a',
                  phone: 'no number found',
                  customerName: 'No Phone User',
                );
              },
              child: const Text('Missing Phone'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Missing Phone'));
    await tester.pump(const Duration(milliseconds: 100));

    // Shows error snackbar without crashing and does not open template dialog
    expect(find.text('WhatsApp Templates'), findsNothing);

    // Drain snackbars
    await tester.pump(const Duration(seconds: 4));
  });
}

