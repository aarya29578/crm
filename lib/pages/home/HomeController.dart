import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_lead_stage_response.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart';
import 'package:crm_flutter/api/response/dashboard_res.dart';
import 'package:crm_flutter/api/response/substatus_lead_stage_response.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/home/components/date_range_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  Rx<AllLeadStageResponse> allLeadStageRes = AllLeadStageResponse().obs;
  Rx<SubstatusLeadStageResponse> allSubLStageRes =
      SubstatusLeadStageResponse().obs;
  Rx<AllLeadsResponse> allLeadsRes = AllLeadsResponse().obs;

  Rx<PageState> countLoading = PageState.loading.obs;
  Rx<PageState> subStageLoading = PageState.stable.obs;
  Future getAllLeadStage() async {
    print("+++++++++++++++++++++++ GET ALL LEAD STAGES");

    countLoading.value = PageState.loading;
    try {
      final response = await DioApi().getAllLeadStage();
      if (response.success == true) {
        print(response.toJson());
        allLeadStageRes.value = response;
        countLoading.value = PageState.stable;
      }
    } catch (e) {
      countLoading.value = PageState.error;
      throw e;
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
      throw e;
    }
  }

  Future<void> getAllLeads() async {
    try {
      print("+++++++++++++++++++++++ GET ALL LEADS");
      final response = await DioApi().getAllLeads();
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
      throw e;
    }
  }

  //=======================
  RxInt selectedTab = 1.obs;
  // Dashboard Data
  Rx<PageState> dashboardLoading = PageState.loading.obs;
  Rx<DashboardDataRes> dashboardData = DashboardDataRes().obs;
  RxString selectedTimeRange = 'Today'.obs;
  Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  final userId = LocalStorage.sharedPreferences!.getString('user_Id') ?? "User";

  Future<void> getDashboardData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      dashboardLoading.value = PageState.loading;
      final response = await DioApi().getDashboard(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
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
      throw e;
    }
  }

  //
  void selectTimeRange(String range, BuildContext context) async {
    selectedTimeRange.value = range;

    DateTime? startDate;
    DateTime? endDate;

    final now = DateTime.now();

    switch (range) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = now;
        break;
      case 'Yesterday':
        final yesterday = now.subtract(Duration(days: 1));
        startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        endDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(seconds: 1));
        break;
      case 'Last 30 Days':
        startDate = now.subtract(Duration(days: 30));
        endDate = now;
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
          startDate = selectedStartDate.value;
          endDate = selectedEndDate.value;
        } else {
          return; // User cancelled
        }
        break;
    }

    // Fetch data with the selected date range
    if (startDate != null && endDate != null) {
      await getDashboardData(startDate: startDate, endDate: endDate);
    }
  }

  //
}
