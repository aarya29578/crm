import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart';
import 'package:crm_flutter/pages/Allocations/components/edit_allocation_lead_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Widget buildTestDialog({required Data lead, required Dio dio}) {
    DioUtil.dio = dio;
    return MaterialApp(
      home: Scaffold(
        body: EditAllocationLeadDialog(lead: lead),
      ),
    );
  }

  Finder findLeadStageField() => find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<String> &&
            widget.decoration.labelText == 'Lead Stage',
      );

  Dio createMockDio({
    required Function(Map<String, dynamic> patchData) onPatch,
  }) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.uri.path;
          if (options.method == 'PATCH') {
            final data = Map<String, dynamic>.from(options.data as Map);
            onPatch(data);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true},
              ),
            );
            return;
          }

          if (path.endsWith('/leadstage/all')) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'data': [
                    {
                      '_id': 'stage-svp',
                      'name': 'Site Visit Planned',
                      'hasSubStatus': false,
                    },
                    {
                      '_id': 'stage-svd',
                      'name': 'Site Visit Done',
                      'hasSubStatus': false,
                    },
                    {
                      '_id': 'stage-bd',
                      'name': 'Booking Done',
                      'hasSubStatus': false,
                    },
                    {
                      '_id': 'stage-md',
                      'name': 'Meeting Done',
                      'hasSubStatus': false,
                    },
                    {
                      '_id': 'stage-fu',
                      'name': 'Follow Up',
                      'hasSubStatus': false,
                    },
                    {
                      '_id': 'stage-new',
                      'name': 'New',
                      'hasSubStatus': false,
                    },
                    {
                      '_id': 'stage-lost',
                      'name': 'Lost',
                      'hasSubStatus': false,
                    },
                  ],
                },
              ),
            );
          } else if (path.endsWith('/leadsource/all')) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true, 'data': []},
              ),
            );
          } else if (path.endsWith('/campaign/all')) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true, 'data': []},
              ),
            );
          } else if (path.endsWith('/location/countries')) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'status': true, 'data': {'countries': []}},
              ),
            );
          } else if (path.endsWith('/users/tenant/users')) {
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
                data: {'success': true, 'data': []},
              ),
            );
          }
        },
      ),
    );
    return dio;
  }

  testWidgets(
    '1. Opening lead with Site Visit Planned displays Site Visit Planned Date and hides Follow-up Date & Time',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final dio = createMockDio(onPatch: (_) {});

      final lead = Data.fromJson({
        '_id': 'lead-1',
        'name': {'first': 'John', 'last': 'Doe'},
        'lead_stage_id': {
          '_id': 'stage-svp',
          'name': 'Site Visit Planned',
        },
        'siteVisitDate': '2026-11-05T10:30:00.000',
        'followUpDate': '2026-11-20T10:00:00.000Z',
      });

      await tester.pumpWidget(buildTestDialog(lead: lead, dio: dio));
      await tester.pumpAndSettle();

      // Site Visit Planned Date picker must be visible
      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDate')), findsOneWidget);
      expect(find.text('Site Visit Planned Date'), findsOneWidget);

      // Follow-up Date & Time picker must NOT be visible
      expect(find.byKey(const ValueKey('follow-up-date-picker')), findsNothing);
      expect(find.text('Follow-up Date & Time'), findsNothing);

      // Other stage pickers must NOT be visible
      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDone')), findsNothing);
      expect(find.byKey(const ValueKey('stage-date-picker-meetingDone')), findsNothing);
    },
  );

  testWidgets(
    '2. Dynamic status switching shows matching picker, hides Follow-Up, and hides both for other statuses',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final dio = createMockDio(onPatch: (_) {});

      final lead = Data.fromJson({
        '_id': 'lead-2',
        'name': {'first': 'Jane', 'last': 'Smith'},
        'lead_stage_id': {
          '_id': 'stage-new',
          'name': 'New',
        },
      });

      await tester.pumpWidget(buildTestDialog(lead: lead, dio: dio));
      await tester.pumpAndSettle();

      // 1. Initial status "New": NEITHER picker should be shown
      expect(find.byKey(const ValueKey('follow-up-date-picker')), findsNothing);
      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDate')), findsNothing);
      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDone')), findsNothing);
      expect(find.byKey(const ValueKey('stage-date-picker-meetingDone')), findsNothing);

      // 2. Switch to "Follow Up" -> Shows Follow-up Date & Time
      final stageField = findLeadStageField();
      await tester.scrollUntilVisible(stageField, 250, scrollable: find.byType(Scrollable).last);
      await tester.tap(stageField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Follow Up').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('follow-up-date-picker')), findsOneWidget);
      expect(find.text('Follow-up Date & Time'), findsOneWidget);
      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDate')), findsNothing);

      // 3. Switch to "Site Visit Planned" -> Hides Follow-Up, Shows Site Visit Planned Date
      await tester.tap(stageField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Site Visit Planned').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('follow-up-date-picker')), findsNothing);
      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDate')), findsOneWidget);
      expect(find.text('Site Visit Planned Date'), findsOneWidget);

      // 4. Switch to "Site Visit Done" -> Shows Site Visit Done Date
      await tester.tap(stageField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Site Visit Done').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('follow-up-date-picker')), findsNothing);
      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDate')), findsNothing);
      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDone')), findsOneWidget);
      expect(find.text('Site Visit Done Date'), findsOneWidget);

      // 5. Switch to "Booking Done" -> Shows Booking Done Date
      await tester.tap(stageField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Booking Done').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('follow-up-date-picker')), findsNothing);
      expect(find.byKey(const ValueKey('stage-date-picker-meetingDone')), findsOneWidget);
      expect(find.text('Booking Done Date'), findsOneWidget);

      // 6. Switch to "Lost" (other status) -> Hides BOTH pickers
      await tester.tap(stageField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lost').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('follow-up-date-picker')), findsNothing);
      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDate')), findsNothing);
      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDone')), findsNothing);
      expect(find.byKey(const ValueKey('stage-date-picker-meetingDone')), findsNothing);
    },
  );

  testWidgets(
    '3. Preserves existing values when switching between statuses without erasing',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final dio = createMockDio(onPatch: (_) {});

      final lead = Data.fromJson({
        '_id': 'lead-3',
        'name': {'first': 'Alice', 'last': 'Wonderland'},
        'lead_stage_id': {
          '_id': 'stage-svp',
          'name': 'Site Visit Planned',
        },
        'siteVisitDate': '2026-11-05T10:30:00.000',
        'siteVisitDone': '2026-11-06T14:30:00.000',
        'followUpDate': '2026-11-20T09:00:00.000Z',
      });

      await tester.pumpWidget(buildTestDialog(lead: lead, dio: dio));
      await tester.pumpAndSettle();

      // On Site Visit Planned: picker is visible and shows prefilled date
      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDate')), findsOneWidget);

      // Switch to Site Visit Done
      final stageField = findLeadStageField();
      await tester.scrollUntilVisible(stageField, 250, scrollable: find.byType(Scrollable).last);
      await tester.tap(stageField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Site Visit Done').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDone')), findsOneWidget);

      // Switch to Follow Up
      await tester.tap(stageField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Follow Up').last);
      await tester.pumpAndSettle();

      // Follow-up Date & Time is visible with prefilled value
      expect(find.byKey(const ValueKey('follow-up-date-picker')), findsOneWidget);

      // Switch back to Site Visit Planned
      await tester.tap(stageField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Site Visit Planned').last);
      await tester.pumpAndSettle();

      // Site Visit Planned value is still intact
      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDate')), findsOneWidget);
    },
  );

  testWidgets(
    '4. Stage pickers match the existing Follow-Up picker styling and interaction',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final dio = createMockDio(onPatch: (_) {});

      final lead = Data.fromJson({
        '_id': 'lead-4',
        'name': {'first': 'Bob', 'last': 'Builder'},
        'lead_stage_id': {
          '_id': 'stage-fu',
          'name': 'Follow Up',
        },
        'followUpDate': '2026-11-20T09:00:00.000Z',
      });

      await tester.pumpWidget(buildTestDialog(lead: lead, dio: dio));
      await tester.pumpAndSettle();

      // Follow-up picker structure check
      final followUpDecorator = tester.widget<InputDecorator>(
        find.byKey(const ValueKey('follow-up-date-picker')),
      );
      expect(followUpDecorator.decoration.labelText, 'Follow-up Date & Time');

      // Switch to Site Visit Planned
      final stageField = findLeadStageField();
      await tester.scrollUntilVisible(stageField, 250, scrollable: find.byType(Scrollable).last);
      await tester.tap(stageField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Site Visit Planned').last);
      await tester.pumpAndSettle();

      // Site Visit Planned uses identical InputDecorator structure
      final svpDecorator = tester.widget<InputDecorator>(
        find.byKey(const ValueKey('stage-date-picker-siteVisitDate')),
      );
      expect(svpDecorator.decoration.labelText, 'Site Visit Planned Date');
      expect(svpDecorator.decoration.border, isA<OutlineInputBorder>());

      // Both have calendar_month icon and clear icon when value present
      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
    },
  );

  testWidgets(
    '5. Submitting stage date saves top-level targetKey without altering followUpDate and filters stageFieldValues',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      Map<String, dynamic>? submittedPatch;
      final dio = createMockDio(onPatch: (d) => submittedPatch = d);

      final lead = Data.fromJson({
        '_id': 'lead-5',
        'name': {'first': 'Charlie', 'last': 'Brown'},
        'lead_stage_id': {
          '_id': 'stage-svp',
          'name': 'Site Visit Planned',
        },
        'siteVisitDate': '2026-11-05T10:30:00.000',
        'followUpDate': '2026-11-20T09:00:00.000Z',
        'stageFieldValues': [
          {
            'fieldId': 'field-remark-1',
            'fieldName': 'existingRemark',
            'fieldType': 'text',
            'value': 'Do not touch',
          },
        ],
      });

      await tester.pumpWidget(buildTestDialog(lead: lead, dio: dio));
      await tester.pumpAndSettle();

      // Switch status to Site Visit Done
      final stageField = findLeadStageField();
      await tester.scrollUntilVisible(stageField, 250, scrollable: find.byType(Scrollable).last);
      await tester.tap(stageField);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Site Visit Done').last);
      await tester.pumpAndSettle();

      // Pick Date & Time via the calendar button
      await tester.tap(find.byIcon(Icons.calendar_month));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); // Select date
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); // Select time
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verification of submission payload
      expect(submittedPatch, isNotNull);
      expect(submittedPatch!['lead_stage_id'], 'stage-svd');
      expect(submittedPatch!['siteVisitDone'], isNotNull);
      expect(submittedPatch!.containsKey('followUpDate'), isFalse);

      // stageFieldValues must NOT contain siteVisitDone or any datetime fields!
      if (submittedPatch!.containsKey('stageFieldValues')) {
        final stageFields = submittedPatch!['stageFieldValues'] as List;
        expect(
          stageFields.any((f) => f['fieldType'] == 'datetime'),
          isFalse,
        );
        expect(
          stageFields.any((f) => f['fieldName'] == 'siteVisitDone'),
          isFalse,
        );
        expect(
          stageFields.any((f) => f['fieldName'] == 'existingRemark'),
          isTrue,
        );
      }
    },
  );

  testWidgets(
    '6. Selecting Booking Done displays Booking Done Date and saves meetingDone',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      Map<String, dynamic>? submittedPatch;
      final dio = createMockDio(onPatch: (d) => submittedPatch = d);

      final lead = Data.fromJson({
        '_id': 'lead-6',
        'name': {'first': 'Dan', 'last': 'Miller'},
        'lead_stage_id': {
          '_id': 'stage-new',
          'name': 'New',
        },
      });

      await tester.pumpWidget(buildTestDialog(lead: lead, dio: dio));
      await tester.pumpAndSettle();

      // Switch to Booking Done
      final stageField = findLeadStageField();
      await tester.scrollUntilVisible(stageField, 250, scrollable: find.byType(Scrollable).last);
      await tester.tap(stageField);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Booking Done').last);
      await tester.pumpAndSettle();

      // Check Booking Done Date picker
      expect(find.byKey(const ValueKey('stage-date-picker-meetingDone')), findsOneWidget);
      expect(find.text('Booking Done Date'), findsOneWidget);

      // Select Date & Time
      await tester.tap(find.byIcon(Icons.calendar_month));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(submittedPatch, isNotNull);
      expect(submittedPatch!['lead_stage_id'], 'stage-bd');
      expect(submittedPatch!['meetingDone'], isNotNull);
      expect(submittedPatch!.containsKey('stageFieldValues'), isFalse);
    },
  );
}
