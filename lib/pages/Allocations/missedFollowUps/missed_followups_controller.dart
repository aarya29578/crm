import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart';
import 'package:crm_flutter/api/response/all_missed_followups_response.dart';
import 'package:crm_flutter/local_storage/up_coming_followups_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_flutter/pages/home/components/date_range_picker_dialog.dart';

class AllMissFUpsController extends GetxController {
  RxList<dynamic> leads = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  int currentPage = 1;
  
  RxString followUpType = 'Missed'.obs; // 'All' or 'Missed'

  // Date Filter State
  RxString selectedTimeRange = 'Today'.obs;
  Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);

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
        selectedStartDate.value = DateTime(yesterday.year, yesterday.month, yesterday.day);
        selectedEndDate.value = DateTime(now.year, now.month, now.day).subtract(Duration(seconds: 1));
        break;
      case 'Last 30 Days':
        selectedStartDate.value = now.subtract(Duration(days: 30));
        selectedEndDate.value = now;
        break;
      case 'Select Range':
        // Show DatePicker dialog here. Assuming DateRangePickerDialogg is available or similar
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
          return;
        }
        break;
    }
    
    // Refresh Data
    fetchData(isRefresh: true);
  }

  Future<void> fetchData({bool isRefresh = false}) async {
    if (followUpType.value == 'Missed') {
      await getAllMissedFUps(isRefresh: isRefresh);
    } else {
      await getAllFollowUps(isRefresh: isRefresh);
    }
  }

  Future<void> getAllMissedFUps({bool isRefresh = false}) async {
    if (isLoading.value) return;

    if (isRefresh) {
      currentPage = 1;
      leads.clear();
      isMoreDataAvailable.value = true;
    }

    isLoading.value = true;

    try {
      String currentTime = DateTime.now().toUtc().toIso8601String();

      await Get.find<FollowUpController>().syncWithApi();
      await Future.delayed(const Duration(milliseconds: 50));

      final response = await DioApi().getMissedFUps(
        currentDateTime: currentTime,
        startDate: selectedStartDate.value,
        endDate: selectedEndDate.value,
      );

      if (response.success == true) {
        final List<MissedFUpsData>? responseData = response.data;

        if (responseData == null || responseData.isEmpty) {
          isMoreDataAvailable.value = false;
        } else {
          leads.addAll(responseData);
          currentPage++;
        }
      }
    } catch (e) {
      print("Error loading missed follow-ups: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAllFollowUps({bool isRefresh = false}) async {
    if (isLoading.value) return;

    if (isRefresh) {
      currentPage = 1;
      leads.clear();
      isMoreDataAvailable.value = true;
    }

    isLoading.value = true;

    try {
      final response = await DioApi().getAllFollowUps(
        page: currentPage,
        startDate: selectedStartDate.value,
        endDate: selectedEndDate.value,
      );

      if (response.success == true) {
        final List<Data>? responseData = response.data;

        if (responseData == null || responseData.isEmpty) {
          isMoreDataAvailable.value = false;
        } else {
          leads.addAll(responseData);
          currentPage++;
        }
      }
    } catch (e) {
      print("Error loading all follow-ups: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
