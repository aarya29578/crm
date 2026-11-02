import 'package:crm_flutter/api/response/history_timeline_response.dart';
import 'package:crm_flutter/pages/Allocations/components/callLogCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lead History UI - Excluded Fields Filter', () {
    test('identifies all excluded field variations', () {
      final excludedSamples = [
        'List ID: 6721efbc99',
        'List id: 6721efbc99',
        'list_id: 6721efbc99',
        'listid: 6721efbc99',
        'Custom List Label: Hot Leads',
        'Custom List: Hot Leads',
        'custom_list_label: Hot Leads',
        'custom_list: Hot Leads',
        'customlistlabel: Hot Leads',
        'Name First: John',
        'name first: John',
        'Name: First: John',
        'First: John',
        'first: John',
        'Phone: +1234567890',
        'phone: +1234567890',
        'Phone Number: +1234567890',
        'phone_number: +1234567890',
      ];

      for (final sample in excludedSamples) {
        expect(
          CallLogCard.isExcludedHistoryDetail(sample),
          isTrue,
          reason: 'Expected "$sample" to be excluded',
        );
      }
    });

    test('retains valid fields without false positives', () {
      final validSamples = [
        'Remarks: Followed up with client',
        'Remark: Customer requested brochure',
        'Follow Up Date: 2026-11-15T10:00:00.000Z',
        'Follow up date: 2026-11-15T10:00:00.000Z',
        'Lead stage: Qualified',
        'Sub-status: Callback Requested',
        'Priority: High',
        'Assigned agent: Agent Smith',
      ];

      for (final sample in validSamples) {
        expect(
          CallLogCard.isExcludedHistoryDetail(sample),
          isFalse,
          reason: 'Expected "$sample" to not be excluded',
        );
      }
    });

    test('HistoryTimelineEntry omits excluded keys from changeDetails', () {
      final entry = HistoryTimelineEntry.fromJson({
        'action': 'UPDATE',
        'changes': {
          'listId': '6721ef',
          'customList': 'List A',
          'customListLabel': 'Label A',
          'nameFirst': 'Robert',
          'phone': '9876543210',
          'phoneNumber': '9876543210',
          'name': {'first': 'Robert', 'last': 'Frost'},
          'remarks': 'Client asked for a quote',
          'followUpDate': '2026-11-20T14:30:00.000Z',
          'lead_stage_id': 'Qualified',
          'sub_status_id': 'Interested',
          'priority': 'High',
          'assignedTo': 'Agent One',
        },
      });

      final details = entry.changeDetails;

      // Excluded fields should not be present
      expect(details.any((d) => d.toLowerCase().contains('list id')), isFalse);
      expect(details.any((d) => d.toLowerCase().contains('custom list')), isFalse);
      expect(details.any((d) => d.toLowerCase().contains('name first')), isFalse);
      expect(details.any((d) => d.toLowerCase().contains('phone')), isFalse);

      // Important and standard fields should be present
      expect(details, contains('Remarks: Client asked for a quote'));
      expect(details, contains('Follow Up Date: 2026-11-20T14:30:00.000Z'));
      expect(details, contains('Lead stage: Qualified'));
      expect(details, contains('Sub-status: Interested'));
      expect(details, contains('Priority: High'));
      expect(details, contains('Assigned agent: Agent One'));
      expect(details, contains('Name: Last: Frost'));
    });
  });

  group('Lead History UI - Highlighted Fields Rendering', () {
    testWidgets('renders Remark in prominent highlighted container with icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return CallLogCard.buildChangeDetailItem(
                  context,
                  'Remarks: Spoke to customer, ready to close deal',
                  isDark: false,
                );
              },
            ),
          ),
        ),
      );

      // Verify Remark header and body
      expect(find.text('Remark'), findsOneWidget);
      expect(find.text('Spoke to customer, ready to close deal'), findsOneWidget);

      // Verify prominent icon
      expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);

      // Verify styled container
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFFFFBEB)); // Amber 50
      expect(decoration.borderRadius, BorderRadius.circular(8));
      expect(decoration.border?.top.color, const Color(0xFFFDE68A)); // Amber 200
    });

    testWidgets('renders Follow-Up Date in prominent highlighted container with formatted date', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return CallLogCard.buildChangeDetailItem(
                  context,
                  'Follow Up Date: 2026-11-15T10:30:00.000Z',
                  isDark: false,
                );
              },
            ),
          ),
        ),
      );

      // Verify Follow-Up Date header
      expect(find.text('Follow-Up Date'), findsOneWidget);

      // Verify prominent calendar/event icon
      expect(find.byIcon(Icons.event_available_rounded), findsOneWidget);

      // Verify styled container
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFF0FDF4)); // Green 50
      expect(decoration.borderRadius, BorderRadius.circular(8));
      expect(decoration.border?.top.color, const Color(0xFFBBF7D0)); // Green 200

      // Formatted date should be rendered (readable date format)
      expect(find.textContaining('Nov 2026'), findsOneWidget);
    });

    testWidgets('renders other fields with standard clean layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return CallLogCard.buildChangeDetailItem(
                  context,
                  'Lead stage: Qualified',
                  isDark: false,
                );
              },
            ),
          ),
        ),
      );

      // Verify text rendered
      expect(find.text('• '), findsOneWidget);
      expect(
        find.textContaining('Qualified', findRichText: true),
        findsOneWidget,
      );

      // Should NOT render highlight icons
      expect(find.byIcon(Icons.edit_note_rounded), findsNothing);
      expect(find.byIcon(Icons.event_available_rounded), findsNothing);
    });

    testWidgets('renders dark mode styling for Remark and Follow-Up Date', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    CallLogCard.buildChangeDetailItem(
                      context,
                      'Remarks: Dark mode remark',
                      isDark: true,
                    ),
                    CallLogCard.buildChangeDetailItem(
                      context,
                      'Follow Up Date: 2026-11-15T10:30:00.000Z',
                      isDark: true,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      expect(containers.length, 2);

      // Dark mode remark container
      final remarkDecoration = containers[0].decoration as BoxDecoration;
      expect(remarkDecoration.color, const Color(0xFF2E2415));

      // Dark mode follow up container
      final followUpDecoration = containers[1].decoration as BoxDecoration;
      expect(followUpDecoration.color, const Color(0xFF132E20));
    });

    testWidgets('complete timeline item changes rendering preserves order and filters excluded', (tester) async {
      final entry = HistoryTimelineEntry.fromJson({
        'action': 'UPDATE',
        'changes': {
          'lead_stage_id': 'Qualified',
          'sub_status_id': 'Interested',
          'remarks': 'Follow up soon',
          'followUpDate': '2026-11-20T14:30:00.000Z',
          'priority': 'High',
          'listId': '123',
          'phone': '9999999999',
        },
      });

      // Filter details as CallLogCard does
      final visibleChanges = entry.changeDetails
          .where((detail) => !CallLogCard.isExcludedHistoryDetail(detail))
          .toList();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: visibleChanges
                      .map((detail) => CallLogCard.buildChangeDetailItem(
                            context,
                            detail,
                            isDark: false,
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ),
      );

      // Highlighted fields present
      expect(find.text('Remark'), findsOneWidget);
      expect(find.text('Follow up soon'), findsOneWidget);
      expect(find.text('Follow-Up Date'), findsOneWidget);

      // Other standard fields present
      expect(
        find.textContaining('Qualified', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Interested', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('High', findRichText: true),
        findsOneWidget,
      );

      // Excluded fields absent
      expect(
        find.textContaining('123', findRichText: true),
        findsNothing,
      );
      expect(
        find.textContaining('9999999999', findRichText: true),
        findsNothing,
      );
      expect(
        find.textContaining('List ID', findRichText: true),
        findsNothing,
      );
      expect(
        find.textContaining('Phone', findRichText: true),
        findsNothing,
      );
    });
  });
}
