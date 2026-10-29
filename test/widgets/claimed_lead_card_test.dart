import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/Allocations/WhatsappSMS/whatsapp_sms_controller.dart';
import 'package:crm_flutter/pages/Allocations/components/callLogCard.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
import 'package:crm_flutter/widgets/ClaimedLeadCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestAllocationController extends AllocationController {
  @override
  Future<void> getAllLeadStages() async {}
}

void main() {
  tearDown(() {
    Get.reset();
    LocalStorage.sharedPreferences = null;
  });

  testWidgets('shows Edit when provided and does not trigger card navigation', (
    tester,
  ) async {
    var editCount = 0;
    var navigationCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: GestureDetector(
              onTap: () => navigationCount++,
              child: ClaimedLeadCard(
                context,
                'Today',
                'Lead Name',
                '5551234',
                'Organization',
                'Agent One',
                'Campaign',
                'lead-1',
                'lead@example.test',
                null,
                null,
                onEdit: () => editCount++,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Edit lead'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit lead'));
    await tester.pump();

    expect(editCount, 1);
    expect(navigationCount, 0);
  });

  testWidgets('does not show Edit when no callback is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ClaimedLeadCard(
              context,
              'Today',
              'Lead Name',
              '5551234',
              'Organization',
              'Agent One',
              'Campaign',
              'lead-1',
              'lead@example.test',
              null,
              null,
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Edit lead'), findsNothing);
  });

  testWidgets('missed follow-up call cards show and invoke Edit', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    LocalStorage.sharedPreferences = await SharedPreferences.getInstance();
    Get.put(DioApi());
    Get.put(WhatsappSmsController());
    Get.put<AllocationController>(_TestAllocationController());
    Get.put(Leaddetailscontroller());

    var editCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CallLogCard(
            name: 'Lead Name',
            tag: 'Missed',
            leadId: 'lead-1',
            time: DateTime.now().toIso8601String(),
            isMissedFUps: true,
            onEdit: () => editCount++,
            onCallBack: () {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Edit lead'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit lead'));
    await tester.pump();

    expect(editCount, 1);
  });

  testWidgets('claimed lead card renders WhatsApp button with campaignId', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ClaimedLeadCard(
              context,
              'Today',
              'Lead Name',
              '5551234',
              'Organization',
              'Agent One',
              'Campaign',
              'lead-1',
              'lead@example.test',
              null,
              null,
              campaignId: 'campaign-123',
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('WhatsApp'), findsOneWidget);
  });
}
