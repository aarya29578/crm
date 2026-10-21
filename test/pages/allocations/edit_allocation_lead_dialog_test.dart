import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart';
import 'package:crm_flutter/constants.dart';
import 'package:crm_flutter/pages/Allocations/components/edit_allocation_lead_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'edits fields, retries a failed save, and reopens with saved values',
    (tester) async {
      var failPatch = true;
      Map<String, dynamic>? lastPatch;
      String? patchedPath;
      Data? returnedLead;
      var lead = Data.fromJson({
        '_id': 'lead-1',
        'name': {'first': 'Ada', 'middle': '', 'last': 'Lovelace'},
        'phone': 1234567890,
        'email': 'ada@example.test',
        'lead_source_id': {'_id': 'source-old', 'name': 'Referral'},
        'lead_stage_id': {
          '_id': 'stage-1',
          'name': 'Qualified',
          'hasSubStatus': true,
        },
        'sub_status_id': {'_id': 'sub-1', 'name': 'Interested'},
        'assignedTo': {'_id': 'agent-1', 'name': 'Agent One'},
        'location': {
          'country': {'_id': 'country-1', 'name': 'Country'},
          'state': {'_id': 'state-1', 'name': 'State'},
          'city': {'_id': 'city-1', 'name': 'City'},
        },
        'remarks': 'Keep this remark',
        'priority': 'Warm',
        'sub_source_id': {'_id': 'sub-source-1', 'name': 'Partner'},
        'designation': 'Director',
        'website': 'https://example.test',
        'customList': [
          {
            'label': 'Interest',
            'value': ['Commercial'],
            '_id': 'custom-1',
          },
        ],
        'stageFieldValues': [
          {'field': 'budget', 'value': '100000'},
        ],
      });

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final path = options.uri.path;
            if (options.method == 'PATCH') {
              patchedPath = options.uri.path;
              lastPatch = Map<String, dynamic>.from(options.data as Map);
              if (failPatch) {
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
              } else {
                handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: {'success': true},
                  ),
                );
              }
              return;
            }

            final Map<String, dynamic> responseData;
            if (path.endsWith('/leadsource/all')) {
              responseData = {
                'success': true,
                'data': [
                  {'_id': 'source-old', 'name': 'Referral'},
                  {'_id': 'source-new', 'name': 'Online'},
                ],
              };
            } else if (path.endsWith('/leadstage/all')) {
              responseData = {
                'success': true,
                'data': [
                  {'_id': 'stage-1', 'name': 'Qualified', 'hasSubStatus': true},
                ],
              };
            } else if (path.endsWith('/campaign/all')) {
              responseData = {'success': true, 'data': []};
            } else if (path.endsWith('/location/countries')) {
              responseData = {
                'status': true,
                'data': {
                  'countries': [
                    {'_id': 'country-1', 'name': 'Country'},
                  ],
                },
              };
            } else if (path.endsWith('/location/states/state-1')) {
              responseData = {
                'status': true,
                'data': {
                  'states': [
                    {'_id': 'state-1', 'name': 'State'},
                  ],
                },
              };
            } else if (path.endsWith('/location/states/country-1')) {
              responseData = {
                'status': true,
                'data': {
                  'states': [
                    {'_id': 'state-1', 'name': 'State'},
                  ],
                },
              };
            } else if (path.endsWith('/location/cities/state-1')) {
              responseData = {
                'status': true,
                'data': {
                  'cities': [
                    {'_id': 'city-1', 'name': 'City'},
                  ],
                },
              };
            } else if (path.endsWith('/substatus/all')) {
              responseData = {
                'success': true,
                'data': [
                  {'_id': 'sub-1', 'name': 'Interested'},
                ],
              };
            } else if (path.endsWith('/createuser/all')) {
              responseData = {
                'data': [
                  {'_id': 'agent-1', 'name': 'Agent One'},
                ],
              };
            } else {
              handler.reject(
                DioException(
                  requestOptions: options,
                  message: 'Unexpected test request: $path',
                ),
              );
              return;
            }

            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: responseData,
              ),
            );
          },
        ),
      );
      DioUtil.dio = dio;
      addTearDown(dio.close);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    returnedLead = await showDialog<Data>(
                      context: context,
                      builder: (_) => EditAllocationLeadDialog(lead: lead),
                    );
                    if (returnedLead != null) lead = returnedLead!;
                  },
                  child: const Text('Open editor'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open editor'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Lead'), findsOneWidget);
      expect(find.text('Sub-source ID'), findsNothing);
      expect(find.text('Designation'), findsNothing);
      expect(find.text('Website'), findsNothing);
      expect(find.text('Custom Fields (JSON list)'), findsNothing);
      expect(find.text('Stage Fields (JSON list)'), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('edit-lead-phone-number-field')),
        '9876543210',
      );
      await tester.enterText(
        find.byKey(const ValueKey('edit-lead-email-field')),
        'new@example.test',
      );

      final sourceField = find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<String> &&
            widget.decoration.labelText == 'Lead Source',
      );
      await tester.scrollUntilVisible(
        sourceField,
        250,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(sourceField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Online').last);
      await tester.pumpAndSettle();

      final priorityField = find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<String> &&
            widget.decoration.labelText == 'Priority',
      );
      await tester.scrollUntilVisible(
        priorityField,
        250,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(priorityField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hot').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(lastPatch, isNotNull);
      expect(find.textContaining('Update lead error'), findsOneWidget);
      expect(find.text('Edit Lead'), findsOneWidget);
      expect(lastPatch?['phone'], 9876543210);
      expect(lastPatch?['email'], 'new@example.test');
      expect(lastPatch?['lead_source_id'], 'source-new');
      expect(lastPatch?['priority'], 'Hot');
      expect(lastPatch?.containsKey('remarks'), isFalse);
      expect(lastPatch?.containsKey('sub_source_id'), isFalse);
      expect(lastPatch?.containsKey('designation'), isFalse);
      expect(lastPatch?.containsKey('website'), isFalse);
      expect(lastPatch?.containsKey('customList'), isFalse);
      expect(lastPatch?.containsKey('stageFieldValues'), isFalse);
      expect(patchedPath, '${Uri.parse(link).path}/lead/lead-1');

      failPatch = false;
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Lead'), findsNothing);
      expect(returnedLead?.phone, 9876543210);
      expect(returnedLead?.email, 'new@example.test');
      expect(returnedLead?.leadSourceId?.sId, 'source-new');
      expect(returnedLead?.priority, 'Hot');
      expect(returnedLead?.remarks, 'Keep this remark');
      expect(returnedLead?.leadSubSourceId?.sId, 'sub-source-1');
      expect(returnedLead?.designation, 'Director');
      expect(returnedLead?.website, 'https://example.test');
      expect(returnedLead?.customList?.single.sId, 'custom-1');
      expect(returnedLead?.stageFieldValues?.single['value'], '100000');

      await tester.tap(find.text('Open editor'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('edit-lead-phone-number-field')),
            )
            .controller
            ?.text,
        '9876543210',
      );
      await tester.scrollUntilVisible(
        sourceField,
        250,
        scrollable: find.byType(Scrollable).last,
      );
      expect(
        tester
            .widget<DropdownButtonFormField<String>>(sourceField)
            .initialValue,
        'source-new',
      );
      await tester.scrollUntilVisible(
        priorityField,
        250,
        scrollable: find.byType(Scrollable).last,
      );
      expect(
        tester
            .widget<DropdownButtonFormField<String>>(priorityField)
            .initialValue,
        'Hot',
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(lastPatch, isNotNull);
    },
  );
}
