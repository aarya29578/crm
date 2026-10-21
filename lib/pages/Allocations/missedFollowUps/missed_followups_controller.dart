import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/local_storage/up_coming_followups_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_flutter/pages/home/components/date_range_picker_dialog.dart';

class AllMissFUpsController extends GetxController {
  RxList<dynamic> leads = <dynamic>[].obs;
  RxBool isInitialLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMoreError = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  int currentPage = 1;
  static const int _pageSize = 50;
  int _requestGeneration = 0;

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
          return;
        }
        break;
    }

    fetchData(isRefresh: true);
  }

  Future<void> fetchData({bool isRefresh = false}) async {
    if (isRefresh) {
      _requestGeneration++;
      currentPage = 1;
      leads.clear();
      isMoreDataAvailable.value = true;
      hasMoreError.value = false;
      isLoadingMore.value = false;
      isInitialLoading.value = true;
    } else {
      if (isInitialLoading.value ||
          isLoadingMore.value ||
          !isMoreDataAvailable.value) {
        return;
      }
      if (leads.isEmpty) {
        isInitialLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      hasMoreError.value = false;
    }

    final generation = _requestGeneration;
    final requestedPage = currentPage;
    final isMissed = followUpType.value == 'Missed';
    final startDate = selectedStartDate.value;
    final endDate = selectedEndDate.value;

    try {
      final List<dynamic>? responseData;
      final int? responseCurrentPage;
      final int? totalPages;

      if (isMissed) {
        if (requestedPage == 1) {
          await Get.find<FollowUpController>().syncWithApi();
        }
        final response = await DioApi().getMissedFUps(
          currentDateTime: DateTime.now().toUtc().toIso8601String(),
          page: requestedPage,
          limit: _pageSize,
          startDate: startDate,
          endDate: endDate,
        );
        if (response.success != true) {
          throw StateError('Missed follow-ups request was unsuccessful');
        }
        responseData = response.data;
        responseCurrentPage = response.currentPage;
        totalPages = response.totalPages;
      } else {
        final response = await DioApi().getAllFollowUps(
          page: requestedPage,
          limit: _pageSize,
          startDate: startDate,
          endDate: endDate,
        );
        if (response.success != true) {
          throw StateError('All follow-ups request was unsuccessful');
        }
        responseData = response.data;
        responseCurrentPage = response.currentPage;
        totalPages = response.totalPages;
      }

      if (generation != _requestGeneration) return;

      final records = responseData ?? const [];
      leads.addAll(records);
      final loadedPage = responseCurrentPage ?? requestedPage;
      currentPage = loadedPage + 1;
      isMoreDataAvailable.value = records.isNotEmpty &&
          (totalPages != null
              ? loadedPage < totalPages
              : records.length >= _pageSize);
    } catch (e) {
      debugPrint('Error loading follow-ups: $e');
      if (generation == _requestGeneration) {
        hasMoreError.value = true;
      }
    } finally {
      if (generation == _requestGeneration) {
        isInitialLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }
}
