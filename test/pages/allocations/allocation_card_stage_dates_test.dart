import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart' as all_leads;
import 'package:crm_flutter/api/response/all_missed_followups_response.dart'
    as missed_followups;
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/Allocations/components/callLogCard.dart';
import 'package:crm_flutter/pages/Allocations/WhatsappSMS/whatsapp_sms_controller.dart';
import 'package:crm_flutter/pages/home/HomeController.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAllocationController extends AllocationController {}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    LocalStorage.sharedPreferences = await SharedPreferences.getInstance();
    Get.put(DioApi());
    Get.put(WhatsappSmsController());
    Get.put(HomeController());
    Get.put<AllocationController>(_MockAllocationController());
    Get.put(Leaddetailscontroller());
  });

  tearDown(() {
    Get.reset();
  });

  Widget createCard({
    required String tag,
    DateTime? followUp,
    bool showFollowUpDate = false,
    dynamic siteVisitDate,
    dynamic siteVisitDone,
    dynamic meetingDone,
    List<dynamic>? stageFieldValues,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CallLogCard(
            name: 'Test Customer',
            tag: tag,
            leadId: 'lead-test-1',
            followUp: followUp,
            showFollowUpDate: showFollowUpDate,
            siteVisitDate: siteVisitDate,
            siteVisitDone: siteVisitDone,
            meetingDone: meetingDone,
            stageFieldValues: stageFieldValues,
            time: '2026-11-05T10:00:00.000Z',
          ),
        ),
      ),
    );
  }

  group('Allocation Lead Card - Stage Specific Date Chips', () {
    testWidgets('follow-up screens show the top-level date regardless of status', (
      tester,
    ) async {
      final date = DateTime.parse('2026-11-05T14:21:00.000Z');
      final expectedText =
          'Follow up date: ${DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal())}';

      await tester.pumpWidget(
        createCard(
          tag: 'Qualified',
          followUp: date,
          showFollowUpDate: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(expectedText), findsOneWidget);
    });

    testWidgets('follow-up screens omit missing and invalid dates', (
      tester,
    ) async {
      await tester.pumpWidget(
        createCard(
          tag: 'Qualified',
          showFollowUpDate: true,
          followUp: null,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Follow up date:'), findsNothing);

      expect(
        all_leads.Data.fromJson({'followUpDate': 'not-a-date'}).followUpDate,
        isNull,
      );
      expect(
        missed_followups.MissedFUpsData.fromJson({
          'followUpDate': 'not-a-date',
        }).followUpDate,
        isNull,
      );
    });

    testWidgets('1. Follow Up status displays "Follow up date" with exact matching UI', (
      tester,
    ) async {
      final date = DateTime(2026, 11, 5, 14, 21);
      final expectedText =
          "Follow up date: ${DateFormat('dd/MM/yyyy  hh:mm a').format(date.toLocal())}";

      await tester.pumpWidget(
        createCard(
          tag: 'Follow Up',
          followUp: date,
        ),
      );
      await tester.pumpAndSettle();

      final textFinder = find.text(expectedText);
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, 11);
      expect(textWidget.style?.fontWeight, FontWeight.w600);
      expect(textWidget.style?.color, Colors.red.shade900);

      final containerFinder = find.ancestor(
        of: textFinder,
        matching: find.byType(Container),
      ).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red.shade50);
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(container.padding, const EdgeInsets.symmetric(horizontal: 10, vertical: 4));
    });

    testWidgets('2. Site Visit Planned status displays "Site Visit Planned date" with exact matching UI', (
      tester,
    ) async {
      final isoDate = '2026-11-05T10:30:00.000Z';
      final parsed = DateTime.parse(isoDate).toLocal();
      final expectedText =
          "Site Visit Planned date: ${DateFormat('dd/MM/yyyy  hh:mm a').format(parsed)}";

      await tester.pumpWidget(
        createCard(
          tag: 'Site Visit Planned',
          siteVisitDate: isoDate,
          followUp: DateTime(2026, 11, 1), // Should NOT be used
        ),
      );
      await tester.pumpAndSettle();

      final textFinder = find.text(expectedText);
      expect(textFinder, findsOneWidget);
      expect(find.textContaining('Follow up date'), findsNothing);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, 11);
      expect(textWidget.style?.fontWeight, FontWeight.w600);
      expect(textWidget.style?.color, Colors.red.shade900);

      final containerFinder = find.ancestor(
        of: textFinder,
        matching: find.byType(Container),
      ).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red.shade50);
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('3. Site Visit Done status displays "Site Visit Done date" with exact matching UI', (
      tester,
    ) async {
      final isoDate = '2026-11-06T15:45:00.000Z';
      final parsed = DateTime.parse(isoDate).toLocal();
      final expectedText =
          "Site Visit Done date: ${DateFormat('dd/MM/yyyy  hh:mm a').format(parsed)}";

      await tester.pumpWidget(
        createCard(
          tag: 'Site Visit Done',
          siteVisitDone: isoDate,
        ),
      );
      await tester.pumpAndSettle();

      final textFinder = find.text(expectedText);
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, 11);
      expect(textWidget.style?.fontWeight, FontWeight.w600);
      expect(textWidget.style?.color, Colors.red.shade900);

      final containerFinder = find.ancestor(
        of: textFinder,
        matching: find.byType(Container),
      ).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red.shade50);
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('4. Booking Done status displays "Booking Done date" with exact matching UI', (
      tester,
    ) async {
      final isoDate = '2026-11-07T11:00:00.000Z';
      final parsed = DateTime.parse(isoDate).toLocal();
      final expectedText =
          "Booking Done date: ${DateFormat('dd/MM/yyyy  hh:mm a').format(parsed)}";

      await tester.pumpWidget(
        createCard(
          tag: 'Booking Done',
          meetingDone: isoDate,
        ),
      );
      await tester.pumpAndSettle();

      final textFinder = find.text(expectedText);
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, 11);
      expect(textWidget.style?.fontWeight, FontWeight.w600);
      expect(textWidget.style?.color, Colors.red.shade900);

      final containerFinder = find.ancestor(
        of: textFinder,
        matching: find.byType(Container),
      ).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red.shade50);
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('5. Missing or null date hides the date chip completely', (
      tester,
    ) async {
      // Site Visit Planned with null siteVisitDate
      await tester.pumpWidget(
        createCard(
          tag: 'Site Visit Planned',
          siteVisitDate: null,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('date:'), findsNothing);

      // Follow Up with null followUp
      await tester.pumpWidget(
        createCard(
          tag: 'Follow Up',
          followUp: null,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('date:'), findsNothing);

      // Booking Done with empty string meetingDone
      await tester.pumpWidget(
        createCard(
          tag: 'Booking Done',
          meetingDone: '   ',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('date:'), findsNothing);
    });

    testWidgets('6. Other statuses (New Lead, Lost, Converted) do NOT show any date chip', (
      tester,
    ) async {
      // Even if dates are present in the model, they must not show for other statuses
      await tester.pumpWidget(
        createCard(
          tag: 'New Lead',
          followUp: DateTime(2026, 11, 5),
          siteVisitDate: '2026-11-05T10:30:00.000Z',
          siteVisitDone: '2026-11-06T15:45:00.000Z',
          meetingDone: '2026-11-07T11:00:00.000Z',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('date:'), findsNothing);

      await tester.pumpWidget(
        createCard(
          tag: 'Lost',
          siteVisitDone: '2026-11-06T15:45:00.000Z',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('date:'), findsNothing);

      await tester.pumpWidget(
        createCard(
          tag: 'Converted',
          meetingDone: '2026-11-07T11:00:00.000Z',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('date:'), findsNothing);
    });

    testWidgets('7. Strict status-field isolation: Never use followUpDate as fallback for stage dates', (
      tester,
    ) async {
      final followUpDate = DateTime(2026, 11, 10, 9, 0);

      // Site Visit Planned lead with followUpDate set but siteVisitDate null:
      // MUST NOT fall back to followUpDate. Must hide date badge.
      await tester.pumpWidget(
        createCard(
          tag: 'Site Visit Planned',
          siteVisitDate: null,
          followUp: followUpDate,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Site Visit Planned date:'), findsNothing);
      expect(find.textContaining('Follow up date:'), findsNothing);
      expect(find.textContaining('date:'), findsNothing);

      // Follow Up lead with siteVisitDate set but followUp null:
      // MUST NOT show Site Visit Planned date.
      await tester.pumpWidget(
        createCard(
          tag: 'Follow Up',
          followUp: null,
          siteVisitDate: '2026-11-05T10:30:00.000Z',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Site Visit Planned date:'), findsNothing);
      expect(find.textContaining('Follow up date:'), findsNothing);
      expect(find.textContaining('date:'), findsNothing);
    });

    testWidgets('8. Dynamic fallback to stageFieldValues for matching status and prevents duplicate chips', (
      tester,
    ) async {
      final isoDate = '2026-11-05T10:30:00.000Z';
      final parsed = DateTime.parse(isoDate).toLocal();
      final expectedText =
          "Site Visit Planned date: ${DateFormat('dd/MM/yyyy  hh:mm a').format(parsed)}";

      await tester.pumpWidget(
        createCard(
          tag: 'Site Visit Planned',
          siteVisitDate: null, // Null at top-level
          stageFieldValues: [
            {
              'fieldName': 'siteVisitDate',
              'fieldType': 'datetime',
              'value': isoDate,
            },
            {
              'fieldName': 'stageRemark',
              'fieldType': 'text',
              'value': 'Client requested morning slot',
            },
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Top status date chip is rendered
      expect(find.text(expectedText), findsOneWidget);

      // Secondary text field (stageRemark) is displayed below
      expect(
        find.textContaining('Client requested morning slot', findRichText: true),
        findsOneWidget,
      );

      // Target datetime field is NOT duplicated in the lower list
      final allDateWidgets = find.textContaining(DateFormat('dd/MM/yyyy').format(parsed));
      expect(allDateWidgets, findsOneWidget);
    });
  });
}
