import 'package:crm_flutter/api/response/substatus_lead_stage_response.dart';
import 'package:crm_flutter/pages/Allocations/components/searchable_sub_status_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses Failed Reason only for the Failed status', () {
    expect(subStatusLabelForStage('Failed'), 'Failed Reason');
    expect(subStatusLabelForStage(' failed '), 'Failed Reason');
    expect(subStatusLabelForStage('Fresh'), 'Sub Status');
    expect(subStatusLabelForStage(null), 'Sub Status');
  });

  testWidgets(
    'renders field and empty search labels from the selected status',
    (tester) async {
      Future<void> pumpField(String stageName) async {
        final label = subStatusLabelForStage(stageName);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SearchableSubStatusField(
                subStatuses: const <SubStatusData>[],
                selectedId: null,
                label: label,
                decoration: InputDecoration(labelText: label),
                onChanged: (_) {},
              ),
            ),
          ),
        );
      }

      await pumpField('Failed');
      expect(find.text('Failed Reason'), findsOneWidget);
      await tester.tap(find.text('Select Failed Reason'));
      await tester.pumpAndSettle();
      expect(find.text('Search failed reason'), findsOneWidget);
      expect(find.text('No failed reason found'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await pumpField('Interested');
      expect(find.text('Sub Status'), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(find.text('Search sub-status'), findsOneWidget);
      expect(find.text('No sub-status found'), findsOneWidget);
    },
  );
}
