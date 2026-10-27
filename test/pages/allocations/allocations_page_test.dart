import 'package:crm_flutter/api/response/all_lead_stage_response.dart'
    as stage_model;
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/Allocations/allocations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _TestAllocationController extends AllocationController {
  @override
  Future<void> getAllLeadStages() async {}

  @override
  Future<void> selectTimeRange(String range, BuildContext context) async {}

  @override
  Future<void> refreshData() async {}
}

void main() {
  const categories = ['Fresh', 'Claimed', 'New', 'Interested', 'Follow Up'];
  const dateFilters = ['Today', 'Yesterday', 'Last 30 Days', 'Select Range'];

  Future<void> pumpAllocationPage(
    WidgetTester tester,
    _TestAllocationController controller,
  ) async {
    Get.put<AllocationController>(controller);
    await tester.pumpWidget(const MaterialApp(home: AllocationPage()));
    await tester.pump();
  }

  void expectFiltersVisible(WidgetTester tester) {
    for (final label in [...categories, ...dateFilters]) {
      expect(find.text(label), findsOneWidget);
    }
  }

  tearDown(Get.reset);

  testWidgets(
    'category and date filters stay visible while loading, empty, refreshing, '
    'and after remount',
    (tester) async {
      final controller = _TestAllocationController()..isLoading.value = true;
      await pumpAllocationPage(tester, controller);
      expectFiltersVisible(tester);

      controller.isLoading.value = false;
      controller.leads.clear();
      await tester.pump();
      expectFiltersVisible(tester);

      controller.isSearchMode.value = true;
      await tester.pump();
      expectFiltersVisible(tester);
      controller.isSearchMode.value = false;
      await tester.pump();

      controller.allLeadStages.assignAll([
        stage_model.Data(sId: 'fresh-id', name: 'Fresh'),
        stage_model.Data(sId: 'claimed-id', name: 'Claimed'),
        stage_model.Data(sId: 'new-id', name: 'New'),
        stage_model.Data(sId: 'interested-id', name: 'Interested'),
        stage_model.Data(sId: 'follow-up-id', name: 'Follow Up'),
      ]);
      await tester.pump();
      await tester.tap(find.text('Fresh'));
      await tester.pump();
      expect(controller.selectedStatusIds, contains('fresh-id'));
      expectFiltersVisible(tester);

      controller.isLoading.value = true;
      await tester.pump();
      expectFiltersVisible(tester);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      Get.reset();

      await pumpAllocationPage(
        tester,
        _TestAllocationController()..isLoading.value = true,
      );
      expectFiltersVisible(tester);
    },
  );

  testWidgets('lead count displays totals and handles loading states', (
    tester,
  ) async {
    final controller = _TestAllocationController();
    await pumpAllocationPage(tester, controller);
    expect(find.text('Total Leads: 0'), findsOneWidget);

    controller.totalLeadCount.value = 24;
    await tester.pump();
    expect(find.text('Total Leads: 24'), findsOneWidget);

    controller.totalLeadCount.value = null;
    await tester.pump();
    expect(find.text('Total Leads: 0'), findsOneWidget);

    controller.isLoading.value = true;
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('allocation-lead-count')),
        matching: find.text('Loading leads…'),
      ),
      findsOneWidget,
    );

    controller.isLoading.value = false;
    controller.isSearchMode.value = true;
    controller.isSearchLoading.value = true;
    await tester.pump();
    expect(find.text('Searching leads…'), findsOneWidget);

    controller.isSearchLoading.value = false;
    await tester.pump();
    expect(find.text('Total Leads: 0'), findsOneWidget);
  });
}
