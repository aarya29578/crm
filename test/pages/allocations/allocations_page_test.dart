import 'package:crm_flutter/api/response/all_lead_stage_response.dart'
    as stage_model;
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/Allocations/allocations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _TestAllocationController extends AllocationController {
  final bool _allowDefaultStages;

  _TestAllocationController({
    List<stage_model.Data>? initialStages,
    bool allowDefaultStages = true,
  }) : _allowDefaultStages = allowDefaultStages {
    if (initialStages != null) {
      allLeadStages.assignAll(initialStages);
    }
  }

  @override
  Future<void> getAllLeadStages() async {
    if (allLeadStages.isEmpty && _allowDefaultStages) {
      allLeadStages.assignAll([
        stage_model.Data(sId: 'fresh-id', name: 'Fresh'),
        stage_model.Data(sId: 'claimed-id', name: 'Claimed'),
        stage_model.Data(sId: 'new-id', name: 'New'),
        stage_model.Data(sId: 'interested-id', name: 'Interested'),
        stage_model.Data(sId: 'follow-up-id', name: 'Follow Up'),
      ]);
    }
  }

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

  testWidgets('renders and selects when there are fewer than 5 filters', (
    tester,
  ) async {
    final controller = _TestAllocationController(
      allowDefaultStages: false,
      initialStages: [
        stage_model.Data(sId: 'stage-1', name: 'Qualified'),
        stage_model.Data(sId: 'stage-2', name: 'Contacted'),
        stage_model.Data(sId: 'stage-3', name: 'Proposal Sent'),
      ],
    );
    await pumpAllocationPage(tester, controller);

    expect(find.text('Qualified'), findsOneWidget);
    expect(find.text('Contacted'), findsOneWidget);
    expect(find.text('Proposal Sent'), findsOneWidget);
    expect(find.text('Fresh'), findsNothing);
    expect(find.text('Claimed'), findsNothing);
    expect(find.text('Follow Up'), findsNothing);

    await tester.tap(find.text('Contacted'));
    await tester.pump();
    expect(controller.selectedStatusIds, contains('stage-2'));
  });

  testWidgets('renders and selects when there are exactly 5 filters', (
    tester,
  ) async {
    final controller = _TestAllocationController(
      allowDefaultStages: false,
      initialStages: [
        stage_model.Data(sId: 's-1', name: 'Stage 1'),
        stage_model.Data(sId: 's-2', name: 'Stage 2'),
        stage_model.Data(sId: 's-3', name: 'Stage 3'),
        stage_model.Data(sId: 's-4', name: 'Stage 4'),
        stage_model.Data(sId: 's-5', name: 'Stage 5'),
      ],
    );
    await pumpAllocationPage(tester, controller);

    for (var i = 1; i <= 5; i++) {
      expect(find.text('Stage $i'), findsOneWidget);
    }
    expect(find.text('Fresh'), findsNothing);

    await tester.tap(find.text('Stage 3'));
    await tester.pump();
    expect(controller.selectedStatusIds, contains('s-3'));
  });

  testWidgets(
    'supports horizontal scrolling and selecting when there are more than 5 filters',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final stages = List.generate(
        12,
        (i) => stage_model.Data(
          sId: 'stage-${i + 1}',
          name: 'Filter Stage ${i + 1}',
        ),
      );
      final controller = _TestAllocationController(
        allowDefaultStages: false,
        initialStages: stages,
      );
      await pumpAllocationPage(tester, controller);

      expect(find.text('Filter Stage 1'), findsOneWidget);

      final scrollFinder = find.byKey(
        const ValueKey('allocation-category-filters-scroll'),
      );
      expect(scrollFinder, findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Filter Stage 12'),
        150,
        scrollable: find.descendant(
          of: scrollFinder,
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Filter Stage 12'), findsOneWidget);

      await tester.tap(find.text('Filter Stage 12'));
      await tester.pump();
      expect(controller.selectedStatusIds, contains('stage-12'));

      await tester.drag(scrollFinder, const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Filter Stage 1'), findsOneWidget);
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

