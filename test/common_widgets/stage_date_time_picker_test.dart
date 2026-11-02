import 'package:crm_flutter/common_widgets/stage_date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('1. Lead Stage Field Key and Display Label Mapping', () {
    test('siteVisitDate maps strictly to "Site Visit Planned"', () {
      expect(
        getStageFieldDisplayLabel({'fieldName': 'siteVisitDate'}),
        'Site Visit Planned',
      );
      expect(
        getStageFieldDisplayLabel({'key': 'siteVisitDate'}),
        'Site Visit Planned',
      );
      expect(
        getStageFieldDisplayLabel({'name': 'siteVisitDate'}),
        'Site Visit Planned',
      );
      expect(
        getStageFieldDisplayLabel({'fieldName': 'sitevisitdate'}),
        'Site Visit Planned',
      );
      expect(
        getStageFieldDisplayLabel({'fieldName': 'site_visit_planned'}),
        'Site Visit Planned',
      );
      expect(getStageFieldKey({'fieldName': 'siteVisitDate'}), 'siteVisitDate');
    });

    test('siteVisitDone maps to "Site Visit Done"', () {
      expect(
        getStageFieldDisplayLabel({'fieldName': 'siteVisitDone'}),
        'Site Visit Done',
      );
      expect(
        getStageFieldDisplayLabel({'name': 'sitevisitdone'}),
        'Site Visit Done',
      );
      expect(getStageFieldKey({'fieldName': 'siteVisitDone'}), 'siteVisitDone');
    });

    test('meetingDone maps to "Meeting Done"', () {
      expect(
        getStageFieldDisplayLabel({'fieldName': 'meetingDone'}),
        'Meeting Done',
      );
      expect(
        getStageFieldDisplayLabel({'key': 'meetingdone'}),
        'Meeting Done',
      );
      expect(getStageFieldKey({'fieldName': 'meetingDone'}), 'meetingDone');
    });

    test('isTargetStageDateTimeField correctly identifies target fields', () {
      expect(
        isTargetStageDateTimeField({'fieldName': 'siteVisitDate'}),
        isTrue,
      );
      expect(
        isTargetStageDateTimeField({'fieldName': 'siteVisitDone'}),
        isTrue,
      );
      expect(
        isTargetStageDateTimeField({'fieldName': 'meetingDone'}),
        isTrue,
      );
      expect(
        isTargetStageDateTimeField({'fieldName': 'otherDateField'}),
        isFalse,
      );
      expect(
        isTargetStageDateTimeField({'fieldName': 'remarks'}),
        isFalse,
      );
    });

    test('Unrelated stage fields preserve their custom labels', () {
      expect(
        getStageFieldDisplayLabel({
          'fieldName': 'clientBudget',
          'name': 'Client Budget',
        }),
        'Client Budget',
      );
      expect(
        getStageFieldDisplayLabel({
          'fieldType': 'datetime',
          'name': 'Custom Follow-Up',
        }),
        'Custom Follow-Up',
      );
    });
  });

  group('2. Formatting & Datetime Combination Logic', () {
    test('formatTimeOfDay formats correctly in 12-hour AM/PM format', () {
      expect(
        formatTimeOfDay(const TimeOfDay(hour: 10, minute: 30)),
        '10:30 AM',
      );
      expect(
        formatTimeOfDay(const TimeOfDay(hour: 14, minute: 30)),
        '02:30 PM',
      );
      expect(
        formatTimeOfDay(const TimeOfDay(hour: 0, minute: 0)),
        '12:00 AM',
      );
      expect(
        formatTimeOfDay(const TimeOfDay(hour: 23, minute: 59)),
        '11:59 PM',
      );
    });

    test('formatDisplayDateTime formats ISO strings properly', () {
      final formatted = formatDisplayDateTime('2026-11-05T10:30:00');
      expect(formatted, contains('05 Nov 2026'));
      expect(formatted, contains('10:30 AM'));
    });

    test('combineDateAndTime combines date and time into ISO string', () {
      final date = DateTime(2026, 11, 5);
      final time = const TimeOfDay(hour: 10, minute: 30);
      final isoStr = combineDateAndTime(date, time);

      expect(isoStr, startsWith('2026-11-05T10:30:00'));
    });

    test('Independent selection: changing date preserves time', () {
      final initialDate = DateTime(2026, 11, 5);
      final preservedTime = const TimeOfDay(hour: 14, minute: 15);

      // User changes date only
      final updatedDate = DateTime(2026, 11, 12);
      final isoStr = combineDateAndTime(updatedDate, preservedTime);

      expect(isoStr, startsWith('2026-11-12T14:15:00'));
    });

    test('Independent selection: changing time preserves date', () {
      final preservedDate = DateTime(2026, 11, 5);
      final initialTime = const TimeOfDay(hour: 9, minute: 0);

      // User changes time only
      final updatedTime = const TimeOfDay(hour: 16, minute: 45);
      final isoStr = combineDateAndTime(preservedDate, updatedTime);

      expect(isoStr, startsWith('2026-11-05T16:45:00'));
    });
  });

  group('3. Pre-filling from Saved Stage Values', () {
    final mockSavedStageValues = [
      {
        'fieldId': 'field_1',
        'fieldName': 'siteVisitDate',
        'fieldType': 'datetime',
        'value': '2026-11-05T10:30:00.000Z',
      },
      {
        'fieldId': 'field_2',
        'fieldName': 'siteVisitDone',
        'fieldType': 'datetime',
        'value': '2026-11-06T15:45:00.000Z',
      },
      {
        'fieldId': 'field_3',
        'fieldName': 'specialRemarks',
        'fieldType': 'text',
        'value': 'Client requested evening call',
      },
    ];

    test('Extracts saved value by fieldId', () {
      final val = findSavedStageValue(mockSavedStageValues, {'_id': 'field_1'});
      expect(val, '2026-11-05T10:30:00.000Z');
    });

    test('Extracts saved value by fieldName (canonical key)', () {
      final val = findSavedStageValue(
        mockSavedStageValues,
        {'fieldName': 'siteVisitDate'},
      );
      expect(val, '2026-11-05T10:30:00.000Z');
    });

    test('Extracts saved text field value', () {
      final val = findSavedStageValue(mockSavedStageValues, {'_id': 'field_3'});
      expect(val, 'Client requested evening call');
    });

    test('Parses saved datetime into separate Date and Time correctly', () {
      final rawIso = findSavedStageValue(
        mockSavedStageValues,
        {'fieldName': 'siteVisitDate'},
      );
      final dt = DateTime.parse(rawIso).toLocal();
      final extractedDate = DateTime(dt.year, dt.month, dt.day);
      final extractedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);

      expect(extractedDate.year, dt.year);
      expect(extractedDate.month, dt.month);
      expect(extractedDate.day, dt.day);
      expect(extractedTime.hour, dt.hour);
      expect(extractedTime.minute, dt.minute);
    });

    test('Returns null when field is not found or stageFieldValues is empty', () {
      expect(findSavedStageValue(null, {'_id': 'unknown'}), isNull);
      expect(findSavedStageValue([], {'_id': 'unknown'}), isNull);
      expect(
        findSavedStageValue(mockSavedStageValues, {'_id': 'unknown'}),
        isNull,
      );
    });
  });

  group('4. Form Submission Payload and Incomplete Value Validation', () {
    test('Complete datetime is formatted and added to stageFieldValues payload', () {
      final fields = [
        {
          '_id': 'f_sv_planned',
          'fieldName': 'siteVisitDate',
          'fieldType': 'datetime',
        },
        {
          '_id': 'f_remark',
          'fieldName': 'stageRemark',
          'fieldType': 'text',
        },
      ];

      final dynamicDates = <String, DateTime>{
        'f_sv_planned': DateTime(2026, 11, 5),
      };
      final dynamicTimes = <String, TimeOfDay>{
        'f_sv_planned': const TimeOfDay(hour: 10, minute: 30),
      };

      final payload = <Map<String, dynamic>>[];
      for (var f in fields) {
        final fId = f['_id']!;
        final key = getStageFieldKey(f);
        if (f['fieldType'] == 'datetime' || isTargetStageDateTimeField(f)) {
          final d = dynamicDates[fId];
          final t = dynamicTimes[fId];
          if (d != null && t != null) {
            payload.add({
              'fieldId': fId,
              'fieldName': key,
              'fieldType': 'datetime',
              'value': combineDateAndTime(d, t),
            });
          }
        }
      }

      expect(payload.length, 1);
      expect(payload.first['fieldName'], 'siteVisitDate');
      expect(payload.first['value'], startsWith('2026-11-05T10:30:00'));
    });

    test('Incomplete datetime (only date, no time) is detected and blocked', () {
      final dynamicDates = <String, DateTime>{
        'f_sv_done': DateTime(2026, 11, 5),
      };
      final dynamicTimes = <String, TimeOfDay>{}; // missing time

      final fId = 'f_sv_done';
      final d = dynamicDates[fId];
      final t = dynamicTimes[fId];

      final isIncomplete = (d != null && t == null) || (d == null && t != null);
      expect(isIncomplete, isTrue);

      // Verify that it is NOT added to submission payload
      final payload = <Map<String, dynamic>>[];
      if (d != null && t != null) {
        payload.add({'value': combineDateAndTime(d, t)});
      }
      expect(payload, isEmpty);
    });

    test('Incomplete datetime (only time, no date) is detected and blocked', () {
      final dynamicDates = <String, DateTime>{}; // missing date
      final dynamicTimes = <String, TimeOfDay>{
        'f_meeting_done': const TimeOfDay(hour: 11, minute: 0),
      };

      final fId = 'f_meeting_done';
      final d = dynamicDates[fId];
      final t = dynamicTimes[fId];

      final isIncomplete = (d != null && t == null) || (d == null && t != null);
      expect(isIncomplete, isTrue);

      final payload = <Map<String, dynamic>>[];
      if (d != null && t != null) {
        payload.add({'value': combineDateAndTime(d, t)});
      }
      expect(payload, isEmpty);
    });

    test('Optional empty datetime field is omitted without errors', () {
      final dynamicDates = <String, DateTime>{};
      final dynamicTimes = <String, TimeOfDay>{};

      final fId = 'f_optional';
      final d = dynamicDates[fId];
      final t = dynamicTimes[fId];

      final payload = <Map<String, dynamic>>[];
      if (d != null && t != null) {
        payload.add({'value': combineDateAndTime(d, t)});
      }
      expect(payload, isEmpty);
    });
  });

  group('5. StageDateTimePicker Widget Tests', () {
    testWidgets('Renders label "Site Visit Planned" and separate Date & Time controls', (
      tester,
    ) async {
      DateTime? selectedDate = DateTime(2026, 11, 5);
      TimeOfDay? selectedTime = const TimeOfDay(hour: 10, minute: 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageDateTimePicker(
              fieldKey: 'siteVisitDate',
              label: 'Site Visit Planned',
              date: selectedDate,
              time: selectedTime,
              onDateChanged: (d) => selectedDate = d,
              onTimeChanged: (t) => selectedTime = t,
            ),
          ),
        ),
      );

      // Label check
      expect(find.text('Site Visit Planned'), findsOneWidget);

      // Separate Date & Time control presence
      expect(find.byKey(const ValueKey('stage-date-picker-siteVisitDate')), findsOneWidget);
      expect(find.byKey(const ValueKey('stage-time-picker-siteVisitDate')), findsOneWidget);

      // Formatted values displayed
      expect(find.text('05 November 2026'), findsOneWidget);
      expect(find.text('10:30 AM'), findsOneWidget);
    });

    testWidgets('Shows placeholders "Select Date" and "Select Time" when unselected', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageDateTimePicker(
              fieldKey: 'meetingDone',
              label: 'Meeting Done',
              date: null,
              time: null,
              onDateChanged: (_) {},
              onTimeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Meeting Done'), findsOneWidget);
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Select Time'), findsOneWidget);
    });

    testWidgets('Renders Clear button when value is present and triggers onClear', (
      tester,
    ) async {
      var cleared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageDateTimePicker(
              fieldKey: 'siteVisitDone',
              label: 'Site Visit Done',
              date: DateTime(2026, 11, 5),
              time: const TimeOfDay(hour: 14, minute: 0),
              onDateChanged: (_) {},
              onTimeChanged: (_) {},
              onClear: () => cleared = true,
            ),
          ),
        ),
      );

      expect(find.text('Clear'), findsOneWidget);
      await tester.tap(find.text('Clear'));
      await tester.pump();

      expect(cleared, isTrue);
    });

    testWidgets('Renders properly in dark mode without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: StageDateTimePicker(
              fieldKey: 'siteVisitDate',
              label: 'Site Visit Planned',
              isDark: true,
              date: DateTime(2026, 11, 5),
              time: const TimeOfDay(hour: 10, minute: 30),
              onDateChanged: (_) {},
              onTimeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Site Visit Planned'), findsOneWidget);
      expect(find.text('05 November 2026'), findsOneWidget);
      expect(find.text('10:30 AM'), findsOneWidget);
    });
  });
}
