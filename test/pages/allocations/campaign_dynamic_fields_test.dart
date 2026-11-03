import 'dart:convert';
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart';
import 'package:crm_flutter/api/response/campaign_custom_fields_response.dart';
import 'package:crm_flutter/pages/Allocations/components/campaign_dynamic_fields_widget.dart';
import 'package:crm_flutter/pages/Allocations/components/edit_allocation_lead_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData;

void main() {
  group('Campaign Custom Fields Response Parsing', () {
    test('parses verified backend response structure', () {
      final json = {
        "success": true,
        "data": {
          "_id": "6ae838643a95a1249b775f9d",
          "campaign": "69a95227a401cba96ea6b243",
          "fields": [
            {
              "label": "Alternate Phone Number",
              "type": "number",
              "options": [],
              "required": true,
              "mask": false,
              "_id": "6ae838643a95a1249b775f9e"
            },
            {
              "label": "Department",
              "type": "dropdown",
              "options": ["Sales", "Engineering", "Marketing"],
              "required": false,
              "_id": "6ae838643a95a1249b775f9f"
            }
          ]
        }
      };

      final response = CampaignCustomFieldsResponse.fromJson(json);
      expect(response.success, isTrue);
      expect(response.id, "6ae838643a95a1249b775f9d");
      expect(response.campaignId, "69a95227a401cba96ea6b243");
      expect(response.fields.length, 2);

      final f1 = response.fields[0];
      expect(f1.id, "6ae838643a95a1249b775f9e");
      expect(f1.label, "Alternate Phone Number");
      expect(f1.type, "number");
      expect(f1.required, isTrue);
      expect(f1.mask, isFalse);

      final f2 = response.fields[1];
      expect(f2.id, "6ae838643a95a1249b775f9f");
      expect(f2.label, "Department");
      expect(f2.type, "dropdown");
      expect(f2.options, ["Sales", "Engineering", "Marketing"]);
      expect(f2.required, isFalse);
    });

    test('handles empty fields and variations safely', () {
      final response = CampaignCustomFieldsResponse.fromJson({
        "success": true,
        "data": {"fields": []}
      });
      expect(response.success, isTrue);
      expect(response.fields, isEmpty);
    });
  });

  group('Campaign Dynamic Fields Error Handling & Scenarios', () {
    late Dio testDio;

    setUp(() {
      testDio = Dio();
      DioUtil.dio = testDio;
      Get.reset();
      CampaignDynamicFieldsWidgetState.clearCache();
    });

    tearDown(() {
      testDio.close();
      Get.reset();
      CampaignDynamicFieldsWidgetState.clearCache();
    });

    void setupMockDio({
      Map<String, dynamic>? campaignAFields,
      Map<String, dynamic>? campaignBFields,
      bool failA = false,
    }) {
      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final path = options.uri.path;

            if (path.contains('/customlist/campaign/campaign-a')) {
              if (failA) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    response: Response(
                      requestOptions: options,
                      statusCode: 500,
                      data: {'message': 'Server error'},
                    ),
                  ),
                );
                return;
              }
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: campaignAFields ?? {
                    "success": true,
                    "data": {
                      "campaign": "campaign-a",
                      "fields": [
                        {
                          "label": "Alternate Phone",
                          "type": "number",
                          "options": [],
                          "required": true,
                          "_id": "field-a-1"
                        },
                        {
                          "label": "Company Category",
                          "type": "dropdown",
                          "options": ["IT", "Manufacturing", "Finance"],
                          "required": false,
                          "_id": "field-a-2"
                        }
                      ]
                    }
                  },
                ),
              );
              return;
            } else if (path.contains('/customlist/campaign/campaign-b')) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: campaignBFields ?? {
                    "success": true,
                    "data": {
                      "campaign": "campaign-b",
                      "fields": [
                        {
                          "label": "Project Budget",
                          "type": "number",
                          "options": [],
                          "required": false,
                          "_id": "field-b-1"
                        }
                      ]
                    }
                  },
                ),
              );
              return;
            } else if (path.contains('/customlist/campaign/campaign-empty')) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    "success": true,
                    "data": {"campaign": "campaign-empty", "fields": []}
                  },
                ),
              );
              return;
            } else if (path.contains('/customlist/campaign/campaign-404-noconfig')) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 404,
                    data: {
                      "success": false,
                      "message": "Custom list not found for this campaign",
                    },
                  ),
                ),
              );
              return;
            }

            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {"success": true, "data": []},
              ),
            );
          },
        ),
      );
    }

    test('1. Successful API response containing fields', () async {
      setupMockDio();
      final res = await DioApi().getCampaignCustomFields('campaign-a');
      expect(res.success, isTrue);
      expect(res.fields.length, 2);
      expect(res.fields[0].label, 'Alternate Phone');
    });

    test('2. Successful API response with empty fields array returns empty list', () async {
      setupMockDio();
      final res = await DioApi().getCampaignCustomFields('campaign-empty');
      expect(res.success, isTrue);
      expect(res.fields, isEmpty);
    });

    testWidgets('2. Widget hides dynamic section on empty fields', (tester) async {
      setupMockDio();

      final widgetKey = GlobalKey<CampaignDynamicFieldsWidgetState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CampaignDynamicFieldsWidget(
              key: widgetKey,
              campaignId: 'campaign-empty',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Must not display error, retry button, or dynamic section
      expect(find.text('Campaign Fields'), findsNothing);
      expect(find.text('Retry'), findsNothing);
      expect(find.textContaining('Failed to load'), findsNothing);
      expect(widgetKey.currentState!.fields, isEmpty);
      expect(widgetKey.currentState!.validate(), isTrue);
    });

    test('3. Confirmed no-configuration 404 response returns empty list without throwing', () async {
      setupMockDio();
      final res = await DioApi().getCampaignCustomFields('campaign-404-noconfig');
      expect(res.success, isTrue);
      expect(res.fields, isEmpty);
    });

    testWidgets('3. Widget hides dynamic section on confirmed 404 without error', (tester) async {
      setupMockDio();

      final widgetKey = GlobalKey<CampaignDynamicFieldsWidgetState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CampaignDynamicFieldsWidget(
              key: widgetKey,
              campaignId: 'campaign-404-noconfig',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Must not display error, retry button, or dynamic section
      expect(find.text('Campaign Fields'), findsNothing);
      expect(find.text('Retry'), findsNothing);
      expect(find.textContaining('Failed to load'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(widgetKey.currentState!.fields, isEmpty);
      expect(widgetKey.currentState!.validate(), isTrue);
      expect(widgetKey.currentState!.hasChanges(), isFalse);
    });

    test('4. Invalid campaign ID is rejected with descriptive error', () async {
      // Empty or whitespace ID throws immediately
      expect(
        () => DioApi().getCampaignCustomFields(''),
        throwsA(isA<Exception>().having((e) => e.toString(), 'msg', contains('Invalid campaign ID'))),
      );

      expect(
        () => DioApi().getCampaignCustomFields('   '),
        throwsA(isA<Exception>().having((e) => e.toString(), 'msg', contains('Invalid campaign ID'))),
      );

      expect(
        () => DioApi().getCampaignCustomFields('undefined'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'msg', contains('Invalid campaign ID'))),
      );

      // Backend 404 indicating invalid ObjectId format is NOT treated as no-configuration
      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 404,
                  data: {'message': 'Invalid campaign ID: Cast to ObjectId failed'},
                ),
              ),
            );
          },
        ),
      );

      expect(
        () => DioApi().getCampaignCustomFields('invalid-123'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'msg', contains('Invalid campaign ID'))),
      );
    });

    testWidgets('5. 401 Unauthorized and 500 Server errors display error banner and allow retry', (tester) async {
      var statusCode = 401;

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: statusCode,
                  data: {'message': statusCode == 401 ? 'Unauthorized access' : 'Database connection error'},
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CampaignDynamicFieldsWidget(campaignId: 'camp-auth-fail'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Unauthorized'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Switch to 500
      statusCode = 500;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Server error (500)'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('6. Network connection failure displays connection error banner', (tester) async {
      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
                message: 'Connection timed out',
              ),
            );
          },
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CampaignDynamicFieldsWidget(campaignId: 'camp-net-fail'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Network connection error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('7. Switching between campaigns with and without fields (A -> B -> C)', (tester) async {
      setupMockDio();

      String currentCampaign = 'campaign-a';
      final widgetKey = GlobalKey<CampaignDynamicFieldsWidgetState>();

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => currentCampaign = 'campaign-404-noconfig'),
                      child: const Text('Switch to B (No Fields)'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => currentCampaign = 'campaign-b'),
                      child: const Text('Switch to C (With Fields)'),
                    ),
                    CampaignDynamicFieldsWidget(
                      key: widgetKey,
                      campaignId: currentCampaign,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Campaign A has custom fields
      expect(find.text('Alternate Phone *'), findsOneWidget);
      expect(find.text('Company Category'), findsOneWidget);

      // Enter value in Campaign A
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Alternate Phone *'),
        '9998887776',
      );
      await tester.pumpAndSettle();
      expect(find.text('9998887776'), findsOneWidget);

      // Switch to Campaign B (No Fields - 404 confirmed)
      await tester.tap(find.text('Switch to B (No Fields)'));
      await tester.pumpAndSettle();

      // Dynamic fields section must be completely hidden
      expect(find.text('Campaign Fields'), findsNothing);
      expect(find.text('Alternate Phone *'), findsNothing);
      expect(find.text('9998887776'), findsNothing);
      expect(find.text('Retry'), findsNothing);
      expect(widgetKey.currentState!.fields, isEmpty);

      // Switch to Campaign C (has Project Budget)
      await tester.tap(find.text('Switch to C (With Fields)'));
      await tester.pumpAndSettle();

      // Campaign C fields appear
      expect(find.text('Project Budget'), findsOneWidget);
      // Campaign A's entered value does NOT leak
      expect(find.text('9998887776'), findsNothing);
    });

    test('DioApi.createLead serializes customList as JSON in FormData', () async {
      FormData? sentFormData;

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.data is FormData) {
              sentFormData = options.data as FormData;
            }
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {'success': true},
              ),
            );
          },
        ),
      );

      final customFields = [
        {"label": "Alternate Phone Number", "value": "9876543210"},
        {"label": "Company Name", "value": "ABC Technologies"},
      ];

      await DioApi().createLead({
        'name': {'first': 'Test', 'middle': '', 'last': 'User'},
        'phone': 9876543210,
        'customList': jsonEncode(customFields),
      });

      expect(sentFormData, isNotNull);
      final customListEntry = sentFormData!.fields.firstWhere(
        (f) => f.key == 'customList',
      );
      expect(customListEntry.value, jsonEncode(customFields));

      final decoded = jsonDecode(customListEntry.value) as List;
      expect(decoded.length, 2);
      expect(decoded[0]['label'], 'Alternate Phone Number');
      expect(decoded[0]['value'], '9876543210');
      expect(decoded[1]['label'], 'Company Name');
      expect(decoded[1]['value'], 'ABC Technologies');
    });

    testWidgets('8. EditAllocationLeadDialog works smoothly when campaign has no custom fields (404)', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      Map<String, dynamic>? lastPatch;
      Data? savedLead;

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final path = options.uri.path;
            if (options.method == 'PATCH') {
              lastPatch = Map<String, dynamic>.from(options.data as Map);
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
              return;
            }

            // Confirmed 404 for campaign-404-noconfig
            if (path.contains('/customlist/campaign/campaign-404-noconfig')) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 404,
                    data: {
                      "success": false,
                      "message": "Custom list not found for this campaign",
                    },
                  ),
                ),
              );
              return;
            }

            if (path.endsWith('/leadsource/all')) {
              handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true, 'data': []}));
              return;
            }
            if (path.endsWith('/leadstage/all')) {
              handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true, 'data': []}));
              return;
            }
            if (path.endsWith('/campaign/all')) {
              handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true, 'data': []}));
              return;
            }
            if (path.endsWith('/location/countries')) {
              handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'status': true, 'data': {'countries': []}}));
              return;
            }
            if (path.endsWith('/createuser/all')) {
              handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'data': []}));
              return;
            }

            handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true, 'data': []}));
          },
        ),
      );

      final lead = Data.fromJson({
        '_id': 'lead-1',
        'phone': 9876543210,
        'campaign': {'_id': 'campaign-404-noconfig', 'name': 'Campaign Without Custom Fields'},
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    savedLead = await showDialog<Data>(
                      context: context,
                      builder: (_) => EditAllocationLeadDialog(lead: lead),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // No error, no dynamic fields shown
      expect(find.textContaining('Failed to load campaign fields'), findsNothing);
      expect(find.text('Campaign Fields'), findsNothing);
      expect(find.text('Retry'), findsNothing);

      // Edit standard field: phone number
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number'),
        '9123456780',
      );
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(lastPatch, isNotNull);
      expect(lastPatch!['phone'], 9123456780);
      // customList should NOT be in payload
      expect(lastPatch!.containsKey('customList'), isFalse);
      expect(savedLead?.phone, 9123456780);
    });

    testWidgets('EditAllocationLeadDialog saves updated custom fields via PATCH when fields exist', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      Map<String, dynamic>? lastPatch;
      Data? savedLead;

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final path = options.uri.path;
            if (options.method == 'PATCH') {
              lastPatch = Map<String, dynamic>.from(options.data as Map);
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
              return;
            }

            if (path.contains('/customlist/campaign/campaign-a')) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    "success": true,
                    "data": {
                      "campaign": "campaign-a",
                      "fields": [
                        {
                          "label": "Alternate Phone",
                          "type": "number",
                          "options": [],
                          "required": false,
                          "_id": "field-a-1"
                        }
                      ]
                    }
                  },
                ),
              );
              return;
            }

            if (path.endsWith('/leadsource/all')) {
              handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true, 'data': []}));
              return;
            }
            if (path.endsWith('/leadstage/all')) {
              handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true, 'data': []}));
              return;
            }
            if (path.endsWith('/campaign/all')) {
              handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true, 'data': []}));
              return;
            }
            if (path.endsWith('/location/countries')) {
              handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'status': true, 'data': {'countries': []}}));
              return;
            }
            if (path.endsWith('/createuser/all')) {
              handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'data': []}));
              return;
            }

            handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true, 'data': []}));
          },
        ),
      );

      final lead = Data.fromJson({
        '_id': 'lead-1',
        'campaign': {'_id': 'campaign-a', 'name': 'Campaign A'},
        'customList': [
          {'label': 'Alternate Phone', 'value': ['9876543210'], '_id': 'field-a-1'},
        ],
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    savedLead = await showDialog<Data>(
                      context: context,
                      builder: (_) => EditAllocationLeadDialog(lead: lead),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Campaign Fields'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);

      // Edit field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Alternate Phone'),
        '9111111111',
      );
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(lastPatch, isNotNull);
      expect(lastPatch!.containsKey('customList'), isTrue);

      final decodedPatch =
          (jsonDecode(lastPatch!['customList'] as String) as List)
              .cast<Map<dynamic, dynamic>>();
      expect(
        decodedPatch.any((e) =>
            e['label'] == 'Alternate Phone' && e['value'] == '9111111111'),
        isTrue,
      );

      final updatedField = savedLead?.customList
          ?.firstWhere((e) => e.label == 'Alternate Phone');
      expect(updatedField?.value, ['9111111111']);
    });
  });
}
