import 'dart:async';

import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_lead_stage_response.dart';
import 'package:crm_flutter/local_storage/up_coming_followups_controller.dart';
import 'package:crm_flutter/models/enums.dart';
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

  // Independent search queries for All Follow-Ups and Missed Follow-Ups
  RxString searchQueryAll = ''.obs;
  RxString searchQueryMissed = ''.obs;
  Timer? _searchDebounce;

  String get currentSearchQuery =>
      followUpType.value == 'Missed' ? searchQueryMissed.value : searchQueryAll.value;

  List<dynamic> get displayLeads {
    final query = currentSearchQuery.trim();
    if (query.isEmpty) return leads;
    return leads.where((lead) => matchesLeadSearch(lead, query)).toList();
  }

  static bool matchesLeadSearch(dynamic lead, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (lead == null) return false;

    String nameStr = '';
    String phoneStr = '';
    String emailStr = '';

    if (lead is Map) {
      final rawName = lead['name'];
      if (rawName is String) {
        nameStr = rawName;
      } else if (rawName is Map) {
        final first = rawName['first'];
        final middle = rawName['middle'];
        final last = rawName['last'];
        nameStr = [first, middle, last]
            .where((s) => s != null && s.toString().trim().isNotEmpty)
            .join(' ');
      }
      phoneStr = (lead['phone'] ?? '').toString();
      emailStr = (lead['email'] ?? '').toString();
    } else {
      try {
        final rawName = (lead as dynamic).name;
        if (rawName is String) {
          nameStr = rawName;
        } else if (rawName != null) {
          final first = (rawName as dynamic).first;
          dynamic middle;
          try {
            middle = (rawName as dynamic).middle;
          } catch (_) {}
          final last = (rawName as dynamic).last;
          nameStr = [first, middle, last]
              .where((s) => s != null && s.toString().trim().isNotEmpty)
              .join(' ');
        }
      } catch (_) {}

      try {
        phoneStr = ((lead as dynamic).phone ?? '').toString();
      } catch (_) {}

      try {
        emailStr = ((lead as dynamic).email ?? '').toString();
      } catch (_) {}
    }

    // 1. Lead name (case-insensitive partial matching)
    if (nameStr.toLowerCase().contains(q)) return true;

    // 2. Phone number (partial matching e.g. '98765' matches 9876543210)
    if (phoneStr.toLowerCase().contains(q)) return true;

    // 3. Email address (case-insensitive partial matching)
    if (emailStr.toLowerCase().contains(q)) return true;

    return false;
  }

  void onSearchChanged(String query) {
    _searchDebounce?.cancel();

    final isMissed = followUpType.value == 'Missed';
    if (isMissed) {
      searchQueryMissed.value = query;
    } else {
      searchQueryAll.value = query;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchData(isRefresh: true);
    });
  }

  void clearSearch() {
    _searchDebounce?.cancel();

    final isMissed = followUpType.value == 'Missed';
    if (isMissed) {
      searchQueryMissed.value = '';
    } else {
      searchQueryAll.value = '';
    }

    fetchData(isRefresh: true);
  }

  void setFollowUpType(String type) {
    if (followUpType.value == type) return;
    _searchDebounce?.cancel();
    followUpType.value = type;
    fetchData(isRefresh: true);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  // Date Filter State
  RxString selectedTimeRange = 'Today'.obs;
  Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);

  // Status-Wise Lead Count State (matching Home dashboard)
  Rx<AllLeadStageResponse> allLeadStageRes = AllLeadStageResponse().obs;
  Rx<PageState> stageCountLoading = PageState.loading.obs;
  RxBool isStatusBreakdownExpanded = true.obs;
  bool _isFetchingStages = false;

  /// Fetches overall lead stages and counts across all leads globally
  Future<void> fetchLeadStages({bool forceRefresh = false}) async {
    if (_isFetchingStages) return;
    if (!forceRefresh &&
        stageCountLoading.value == PageState.stable &&
        (allLeadStageRes.value.data?.isNotEmpty ?? false)) {
      return;
    }

    _isFetchingStages = true;
    stageCountLoading.value = PageState.loading;

    try {
      // Calls getAllLeadStage() without campaignId to obtain global counts across all leads
      final response = await DioApi().getAllLeadStage();
      if (response.success == true) {
        allLeadStageRes.value = response;
        stageCountLoading.value = PageState.stable;
      } else {
        stageCountLoading.value = PageState.error;
      }
    } catch (e) {
// Old comments , before Nov 3 2026 Tuesday.
      // debugPrint('Error loading lead stages in follow-ups: $e');
      stageCountLoading.value = PageState.error;
    } finally {
      _isFetchingStages = false;
    }
  }

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
    final search = currentSearchQuery.trim();
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
          search: search,
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
          search: search,
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
// Old comments , before Nov 3 2026 Tuesday.
      // debugPrint('Error loading follow-ups: $e');
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
