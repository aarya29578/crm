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
  RxBool isBackgroundPaging = false.obs;
  RxBool hasMoreError = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  int currentPage = 1;
  static const int _pageSize = 50;
  int _requestGeneration = 0;
  bool _isFetchingPage = false;

  RxString followUpType = 'Missed'.obs; // 'All' or 'Missed'

  // Selected status filter state
  Rx<String?> selectedStatusId = Rx<String?>(null);
  Rx<String?> selectedStatusName = Rx<String?>(null);

  // Total lead count from API for active date/search/type
  Rx<int?> totalApiLeadCount = Rx<int?>(null);

  // Independent search queries for All Follow-Ups and Missed Follow-Ups
  RxString searchQueryAll = ''.obs;
  RxString searchQueryMissed = ''.obs;
  Timer? _searchDebounce;

  String get currentSearchQuery =>
      followUpType.value == 'Missed' ? searchQueryMissed.value : searchQueryAll.value;

  List<dynamic> get displayLeads {
    final query = currentSearchQuery.trim();
    final statusId = selectedStatusId.value;
    final statusName = selectedStatusName.value;

    if (statusId == null && statusName == null && query.isEmpty) {
      return leads;
    }

    return leads.where((lead) {
      if (statusId != null || statusName != null) {
        if (!matchesLeadStatus(lead, statusId: statusId, statusName: statusName)) {
          return false;
        }
      }
      if (query.isNotEmpty) {
        if (!matchesLeadSearch(lead, query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  int get totalMatchingLeadCount {
    final hasStatus = selectedStatusId.value != null || selectedStatusName.value != null;
    final hasSearch = currentSearchQuery.trim().isNotEmpty;

    if (hasStatus || hasSearch) {
      return displayLeads.length;
    }
    return totalApiLeadCount.value ?? leads.length;
  }

  int countForStatus({String? statusId, String? statusName}) {
    final query = currentSearchQuery.trim();
    int count = 0;
    for (final lead in leads) {
      if (query.isNotEmpty && !matchesLeadSearch(lead, query)) {
        continue;
      }
      if (matchesLeadStatus(lead, statusId: statusId, statusName: statusName)) {
        count++;
      }
    }
    return count;
  }

  static String? _getLeadId(dynamic lead) {
    if (lead == null) return null;
    if (lead is Map) {
      return (lead['_id'] ?? lead['id'] ?? lead['sId'])?.toString();
    }
    try {
      return (lead as dynamic).sId?.toString();
    } catch (_) {
      return null;
    }
  }

  static bool matchesLeadStatus(
    dynamic lead, {
    String? statusId,
    String? statusName,
  }) {
    if (lead == null) return false;
    if (statusId == null && statusName == null) return true;

    final targetId = statusId?.trim();
    final targetName = statusName?.trim().toLowerCase();

    String? actualId;
    String? actualName;

    if (lead is Map) {
      final rawStage = lead['lead_stage_id'] ?? lead['leadStageId'];
      if (rawStage is Map) {
        actualId = (rawStage['_id'] ?? rawStage['id'] ?? rawStage['sId'])?.toString();
        actualName = (rawStage['name'] ?? rawStage['stageName'])?.toString();
      } else if (rawStage is String) {
        actualId = rawStage;
        actualName = rawStage;
      }
    } else {
      try {
        final rawStage = (lead as dynamic).leadStageId;
        if (rawStage is String) {
          actualId = rawStage;
          actualName = rawStage;
        } else if (rawStage is Map) {
          actualId = (rawStage['_id'] ?? rawStage['id'] ?? rawStage['sId'])?.toString();
          actualName = (rawStage['name'] ?? rawStage['stageName'])?.toString();
        } else if (rawStage != null) {
          try {
            actualId = (rawStage as dynamic).sId?.toString();
          } catch (_) {}
          try {
            actualName = (rawStage as dynamic).name?.toString();
          } catch (_) {}
        }
      } catch (_) {}
    }

    // Exact ID match
    if (targetId != null && targetId.isNotEmpty && actualId != null && actualId.isNotEmpty) {
      if (actualId == targetId) return true;
    }

    // Exact case-insensitive trimmed Name match
    if (targetName != null && targetName.isNotEmpty && actualName != null && actualName.isNotEmpty) {
      if (actualName.trim().toLowerCase() == targetName) return true;
    }

    return false;
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

  void selectStatus(String? statusId, String? statusName) {
    if (selectedStatusId.value == statusId ||
        (selectedStatusName.value != null &&
            statusName != null &&
            selectedStatusName.value!.trim().toLowerCase() ==
                statusName.trim().toLowerCase())) {
      // Toggle off to restore unfiltered
      selectedStatusId.value = null;
      selectedStatusName.value = null;
    } else {
      selectedStatusId.value = statusId;
      selectedStatusName.value = statusName;
    }

    // If remaining pages exist and background paging is not currently active,
    // ensure background pagination continues to collect all leads
    if (isMoreDataAvailable.value &&
        !isBackgroundPaging.value &&
        !hasMoreError.value &&
        !isInitialLoading.value) {
      unawaited(_fetchRemainingPages(_requestGeneration));
    }
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

  // Status-Wise Lead Count State
  Rx<AllLeadStageResponse> allLeadStageRes = AllLeadStageResponse().obs;
  Rx<PageState> stageCountLoading = PageState.loading.obs;
  RxBool isStatusBreakdownExpanded = true.obs;
  bool _isFetchingStages = false;

  /// Fetches overall lead stages across all leads globally
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
        final yesterday = now.subtract(const Duration(days: 1));
        selectedStartDate.value = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
        );
        selectedEndDate.value = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(seconds: 1));
        break;
      case 'Last 30 Days':
        selectedStartDate.value = now.subtract(const Duration(days: 30));
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
      totalApiLeadCount.value = null;
      isMoreDataAvailable.value = true;
      hasMoreError.value = false;
      isLoadingMore.value = false;
      isBackgroundPaging.value = false;
      isInitialLoading.value = true;
    } else {
      if (isInitialLoading.value ||
          isLoadingMore.value ||
          isBackgroundPaging.value ||
          _isFetchingPage ||
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
    final success = await _fetchPage(generation, currentPage, isRefresh: isRefresh);

    if (generation == _requestGeneration) {
      isInitialLoading.value = false;
      isLoadingMore.value = false;
      // If initial page was successfully fetched and more pages are available,
      // trigger background fetch for remaining pages to ensure complete dataset
      if (isRefresh && success && isMoreDataAvailable.value) {
        unawaited(_fetchRemainingPages(generation));
      }
    }
  }

  Future<void> _fetchRemainingPages(int generation) async {
    if (isBackgroundPaging.value) return;
    isBackgroundPaging.value = true;

    try {
      while (isMoreDataAvailable.value &&
          generation == _requestGeneration &&
          !hasMoreError.value) {
        final success = await _fetchPage(generation, currentPage);
        if (!success) break;
      }
    } finally {
      if (generation == _requestGeneration) {
        isBackgroundPaging.value = false;
      }
    }
  }

  Future<bool> _fetchPage(int generation, int pageToFetch, {bool isRefresh = false}) async {
    if (_isFetchingPage) return false;
    if (generation != _requestGeneration) return false;

    _isFetchingPage = true;
    final isMissed = followUpType.value == 'Missed';
    final search = currentSearchQuery.trim();
    final startDate = selectedStartDate.value;
    final endDate = selectedEndDate.value;

    try {
      final List<dynamic>? responseData;
      final int? responseCurrentPage;
      final int? totalPages;
      final int? responseTotal;

      if (isMissed) {
        if (pageToFetch == 1) {
          try {
            await Get.find<FollowUpController>().syncWithApi();
          } catch (_) {}
        }
        final response = await DioApi().getMissedFUps(
          currentDateTime: DateTime.now().toUtc().toIso8601String(),
          page: pageToFetch,
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
        responseTotal = response.total;
      } else {
        final response = await DioApi().getAllFollowUps(
          page: pageToFetch,
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
        responseTotal = response.total;
      }

      if (generation != _requestGeneration) return false;

      if (responseTotal != null) {
        totalApiLeadCount.value = responseTotal;
      }

      final records = responseData ?? const [];
      final existingIds = leads.map((l) => _getLeadId(l)).whereType<String>().toSet();
      final List<dynamic> toAdd = [];
      for (final r in records) {
        final id = _getLeadId(r);
        if (id == null || !existingIds.contains(id)) {
          toAdd.add(r);
          if (id != null) existingIds.add(id);
        }
      }
      if (toAdd.isNotEmpty) {
        leads.addAll(toAdd);
      }

      final loadedPage = responseCurrentPage ?? pageToFetch;
      currentPage = loadedPage + 1;
      isMoreDataAvailable.value = records.isNotEmpty &&
          (totalPages != null
              ? loadedPage < totalPages
              : records.length >= _pageSize);

      return true;
    } catch (e) {
// Old comments , before Nov 3 2026 Tuesday.
      // debugPrint('Error loading follow-ups: $e');
      if (generation == _requestGeneration) {
        hasMoreError.value = true;
      }
      return false;
    } finally {
      _isFetchingPage = false;
    }
  }
}
