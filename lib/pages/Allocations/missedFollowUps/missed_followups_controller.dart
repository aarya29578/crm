import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_missed_followups_response.dart';
import 'package:crm_flutter/local_storage/up_coming_followups_controller.dart';
import 'package:crm_flutter/pages/home/components/date_range_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllMissFUpsController extends GetxController {
  // final DioApi api = Get.find<DioApi>();
  RxList<MissedFUpsData> leads = <MissedFUpsData>[].obs;
  RxBool isLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  int currentPage = 1;
  // RxString selectedTimeRange = 'Today'.obs;
  // Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  // Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);

  Future<void> getAllMissedFUps({bool? isRefresh}) async {
    if (isLoading.value) return;

    if (isRefresh == true) {
      currentPage = 1;
      leads.clear();
      isMoreDataAvailable.value = true;
    }

    isLoading.value = true;

    try {
      String currentTime = DateTime.now().toUtc().toIso8601String();

      await Get.find<FollowUpController>().syncWithApi();
      await Future.delayed(Duration(milliseconds: 50));

      final response = await DioApi().getMissedFUps(
        currentDateTime: currentTime,
      );

      if (response.success == true) {
        // Safely handle the data
        final List<MissedFUpsData>? responseData = response.data;

        if (responseData == null || responseData.isEmpty) {
          isMoreDataAvailable.value = false;
        } else {
          leads.addAll(responseData);
          currentPage++;
        }
      }
    } catch (e) {
      print("Error loading leads: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
