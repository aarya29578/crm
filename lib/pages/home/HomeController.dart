import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_campaigns_response.dart';
import 'package:crm_flutter/api/response/all_lead_stage_response.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart';
import 'package:crm_flutter/api/response/dashboard_res.dart';
import 'package:crm_flutter/api/response/substatus_lead_stage_response.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/home/components/date_range_picker_dialog.dart';
import 'package:crm_flutter/pages/home/components/status_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  Rx<AllLeadStageResponse> allLeadStageRes = AllLeadStageResponse().obs;
  Rx<SubstatusLeadStageResponse> allSubLStageRes =
      SubstatusLeadStageResponse().obs;
  Rx<AllLeadsResponse> allLeadsRes = AllLeadsResponse().obs;

  Rx<PageState> countLoading = PageState.loading.obs;
  Rx<PageState> subStageLoading = PageState.stable.obs;

  // ============ CAMPAIGN STATE ============
  RxList<CampaignData> allCampaigns = <CampaignData>[].obs;
  RxList<CampaignData> selectedCampaigns = <CampaignData>[].obs;
  Rx<PageState> campaignLoading = PageState.stable.obs;

  String? get selectedCampaignId {
    if (selectedCampaigns.isEmpty) return null;
    return selectedCampaigns.map((c) => c.sId).join(',');
  }

  Future<void> fetchAllCampaigns() async {
    try {
      campaignLoading.value = PageState.loading;
      final response = await DioApi().getAllCampaigns();
      if (response.success == true && response.data != null) {
        allCampaigns.assignAll(response.data!);
      }
      campaignLoading.value = PageState.stable;
    } catch (e) {
      campaignLoading.value = PageState.error;
      print("Error fetching campaigns: $e");
    }
  }

  void toggleCampaignSelection(CampaignData campaign, BuildContext context) {
    if (selectedCampaigns.any((c) => c.sId == campaign.sId)) {
      selectedCampaigns.removeWhere((c) => c.sId == campaign.sId);
    } else {
      selectedCampaigns.add(campaign);
    }
  }

  void toggleSelectAllCampaigns(
    List<CampaignData> filtered,
    BuildContext context,
  ) {
    bool allSelected = filtered.every(
      (fc) => selectedCampaigns.any((sc) => sc.sId == fc.sId),
    );

    if (allSelected) {
      for (var fc in filtered) {
        selectedCampaigns.removeWhere((sc) => sc.sId == fc.sId);
      }
    } else {
      for (var fc in filtered) {
        if (!selectedCampaigns.any((sc) => sc.sId == fc.sId)) {
          selectedCampaigns.add(fc);
        }
      }
    }
  }

  void clearCampaign(BuildContext context) {
    selectedCampaigns.clear();
  }

  Future<void> refreshAllData(BuildContext context) async {
    await getAllLeadStage();
    await getAllLeads();
    await selectTimeRange(selectedTimeRange.value, context);

    if (Get.isRegistered<AllocationController>()) {
      try {
        final allocCtrl = Get.find<AllocationController>();

        await allocCtrl.getAllLeadStages();
        await allocCtrl.selectTimeRange(
          allocCtrl.selectedTimeRange.value,
          context,
        );
      } catch (e) {
        print("Error refreshing AllocationController: $e");
      }
    }
  }

  Future getAllLeadStage() async {
    print("+++++++++++++++++++++++ GET ALL LEAD STAGES");

    countLoading.value = PageState.loading;
    try {
      final response = await DioApi().getAllLeadStage(
        campaignId: selectedCampaignId,
      );
      if (response.success == true) {
        print(response.toJson());
        allLeadStageRes.value = response;
        countLoading.value = PageState.stable;
      }
    } catch (e) {
      countLoading.value = PageState.error;
      rethrow;
    }
  }

  Future getFailedSubLStage({String? selectedStageId}) async {
    print("+++++++++++++++++++++++ GET SUB LEAD STAGES");

    subStageLoading.value = PageState.loading;
    try {
      final response = await DioApi().getFailedSubLeadStage(
        selectedStageId: selectedStageId,
      );
      if (response.success == true) {
        print(response.toJson());
        allSubLStageRes.value = response;
        subStageLoading.value = PageState.stable;
      }
    } catch (e) {
      subStageLoading.value = PageState.error;
      rethrow;
    }
  }

  Future<void> getAllLeads() async {
    try {
      print("+++++++++++++++++++++++ GET ALL LEADS");
      final response = await DioApi().getAllLeads(
        campaignId: selectedCampaignId,
      );
      if (response.success == true) {
        allLeadsRes.value = response;
        print(
          "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++",
        );
        print(allLeadsRes.value);
        print(
          "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++",
        );
      } else {
        print("Leads API returned success = false");
      }
    } catch (e) {
      rethrow;
    }
  }

  //=======================
  RxInt selectedTab = 1.obs;
  RxSet<int> mainSelectedIndices = {0}.obs;
  // Dashboard Data
  Rx<PageState> dashboardLoading = PageState.loading.obs;
  Rx<DashboardDataRes> dashboardData = DashboardDataRes().obs;
  RxString selectedTimeRange = 'Today'.obs;
  Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  RxList<String> selectedStatusIds = <String>[].obs;
  final userId = LocalStorage.sharedPreferences!.getString('user_Id') ?? "User";

  Future<void> getDashboardData({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? statusIds,
  }) async {
    try {
      dashboardLoading.value = PageState.loading;
      final response = await DioApi().getDashboard(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        statusIds: statusIds,
        campaignId: selectedCampaignId,
      );
      if (response.success == true) {
        dashboardData.value = response;
        dashboardLoading.value = PageState.stable;
      } else {
        print("dashboard API returned success = false");
        dashboardLoading.value = PageState.error;
      }
    } catch (e) {
      dashboardLoading.value = PageState.error;
      rethrow;
    }
  }

  //
  Future<void> selectTimeRange(String range, BuildContext context) async {
    selectedTimeRange.value = range;

    final now = DateTime.now();

    switch (range) {
      case 'Today':
        selectedStartDate.value = DateTime(now.year, now.month, now.day);
        selectedEndDate.value = now;
        break;
      case 'Yesterday':
        final yesterday = now.subtract(Duration(days: 1));
        selectedStartDate.value = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
        );
        selectedEndDate.value = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(seconds: 1));
        break;
      case 'Last 30 Days':
        selectedStartDate.value = now.subtract(Duration(days: 30));
        selectedEndDate.value = now;
        break;
      case 'Select Range':
        final result = await showDialog(
          context: context,
          builder: (context) => DateRangePickerDialogg(
            initialStartDate: selectedStartDate.value,
            initialEndDate: selectedEndDate.value,
          ),
        );

        if (result != null) {
          selectedStartDate.value = result['startDate'];
          selectedEndDate.value = result['endDate'];
        } else {
          return; // User cancelled
        }
        break;
    }

    refreshData();
  }

  void loadLeadsForSelectedTab(dynamic ccontroller) {
    final stages = allLeadStageRes.value.data ?? [];
    List<String> selectedStageIds = [];
    for (int index in mainSelectedIndices) {
      if (index > 0 && index - 1 < stages.length) {
        final stageId = stages[index - 1].sId;
        if (stageId != null) {
          selectedStageIds.add(stageId);
        }
      }
    }

    if (selectedStageIds.isNotEmpty) {
      ccontroller.getLeadsByMultipleStages(selectedStageIds);
    }
  }

  void showStatusFilter(BuildContext context) async {
    if (allLeadStageRes.value.data == null ||
        allLeadStageRes.value.data!.isEmpty) {
      await getAllLeadStage();
    }

    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => StatusFilterDialog(
        allStages: allLeadStageRes.value.data ?? [],
        initialSelectedIds: selectedStatusIds,
      ),
    );

    if (result != null) {
      selectedStatusIds.assignAll(result);
      refreshData();
    }
  }

  void toggleStatus(String statusId, BuildContext context) {
    if (selectedStatusIds.contains(statusId)) {
      selectedStatusIds.remove(statusId);
    } else {
      selectedStatusIds.add(statusId);
    }
    refreshData();
  }

  void refreshData() {
    getDashboardData(
      startDate: selectedStartDate.value,
      endDate: selectedEndDate.value,
      statusIds: selectedStatusIds,
    );
  }
}
  