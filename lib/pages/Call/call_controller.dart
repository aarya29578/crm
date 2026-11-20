import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_calls_history_response.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/home/components/date_range_picker_dialog.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart' as device_call_log;

class CallLogController extends GetxController {
  static const int defaultPageSize = 50;

  var callLogs = <device_call_log.CallLogEntry>[].obs;
  var isLoading = true.obs;

  Rx<AllCallHistoryResponse> callLogsResponse = AllCallHistoryResponse().obs;
  Rx<PageState> callApiState = PageState.loading.obs;
  final Map<String, _UpdatedCallLeadDetails> _updatedLeadDetails = {};

  // Pagination state
  RxInt currentPage = 1.obs;
  RxInt totalCount = 0.obs;
  RxBool hasMore = true.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMoreError = false.obs;
  int _requestGeneration = 0;

  // Date filter state
  RxString selectedTimeRange = 'Today'.obs;
  Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);

  Map<String, dynamic> _buildQueryParams({
    required int page,
    required int limit,
  }) {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };
    if (selectedStartDate.value != null) {
      final sd = DateTime(
        selectedStartDate.value!.year,
        selectedStartDate.value!.month,
        selectedStartDate.value!.day,
      );
      queryParams['startDate'] = sd.toUtc().toIso8601String();
    }
    if (selectedEndDate.value != null) {
      final ed = DateTime(
        selectedEndDate.value!.year,
        selectedEndDate.value!.month,
        selectedEndDate.value!.day,
        23,
        59,
        59,
        999,
      );
      queryParams['endDate'] = ed.toUtc().toIso8601String();
    }
    return queryParams;
  }

  void _applyUpdatedLeadDetails(List<CallHistoryGroup> groups) {
    for (final group in groups) {
      final lead = group.lead;
      final updated = lead == null ? null : _updatedLeadDetails[lead.sId];
      if (lead != null && updated != null) {
        lead.name = LeadName(
          first: updated.first,
          middle: updated.middle,
          last: updated.last,
        );
        lead.phone = updated.phone;
      }
    }
  }

  String _callGroupKey(CallHistoryGroup item) {
    return '${item.lead?.sId ?? ''}_${item.date ?? ''}_${item.lastCallAt ?? ''}';
  }

  bool _computeHasMore({
    required AllCallHistoryResponse response,
    required int fetchedCount,
    required int loadedCount,
    required int requestedLimit,
  }) {
    if (fetchedCount == 0) return false;
    final effectiveLimit = response.limit ?? requestedLimit;
    if (fetchedCount < effectiveLimit) return false;
    if (response.total != null) {
      return loadedCount < response.total!;
    }
    return true;
  }

  Future getApi({
    DateTime? startDate,
    DateTime? endDate,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (isLoadingMore.value ||
          !hasMore.value ||
          callApiState.value == PageState.loading) {
        return;
      }

      final int targetPage = currentPage.value + 1;
      final int generation = _requestGeneration;

      try {
        isLoadingMore.value = true;
        hasMoreError.value = false;

        final queryParams = _buildQueryParams(
          page: targetPage,
          limit: defaultPageSize,
        );

        final response = await DioApi().getAllCallsHistory(
          null,
          queryParams: queryParams,
        );

        if (generation != _requestGeneration) return;

        if (response.page != null && response.page! < targetPage) {
          hasMore.value = false;
          return;
        }

        final fetchedItems = List<CallHistoryGroup>.from(
          response.data ?? const <CallHistoryGroup>[],
        );
        _applyUpdatedLeadDetails(fetchedItems);

        final existingItems =
            callLogsResponse.value.data ?? const <CallHistoryGroup>[];
        final existingKeys = existingItems.map(_callGroupKey).toSet();
        final newUniqueItems = <CallHistoryGroup>[];
        for (final item in fetchedItems) {
          final key = _callGroupKey(item);
          if (existingKeys.add(key)) {
            newUniqueItems.add(item);
          }
        }

        if (newUniqueItems.isEmpty) {
          hasMore.value = false;
          return;
        }

        final mergedItems = <CallHistoryGroup>[
          ...existingItems,
          ...newUniqueItems,
        ];

        final resolvedLimit = response.limit ?? defaultPageSize;

        currentPage.value = targetPage;
        totalCount.value = response.total ?? mergedItems.length;
        hasMore.value = _computeHasMore(
          response: response,
          fetchedCount: fetchedItems.length,
          loadedCount: mergedItems.length,
          requestedLimit: defaultPageSize,
        );

        callLogsResponse.value = AllCallHistoryResponse(
          success: response.success ?? callLogsResponse.value.success,
          total: response.total ?? callLogsResponse.value.total,
          page: targetPage,
          limit: resolvedLimit,
          data: mergedItems,
        );
      } catch (e) {
        if (generation == _requestGeneration) {
          hasMoreError.value = true;
        }
      } finally {
        if (generation == _requestGeneration) {
          isLoadingMore.value = false;
        }
      }
      return;
    }

    final int generation = ++_requestGeneration;

    try {
      callApiState.value = PageState.loading;
      currentPage.value = 1;
      totalCount.value = 0;
      hasMore.value = true;
      isLoadingMore.value = false;
      hasMoreError.value = false;

      // Store the dates
      if (startDate != null) selectedStartDate.value = startDate;
      if (endDate != null) selectedEndDate.value = endDate;

      final queryParams = _buildQueryParams(
        page: 1,
        limit: defaultPageSize,
      );

      final response = await DioApi().getAllCallsHistory(
        null,
        queryParams: queryParams,
      );

      if (generation != _requestGeneration) return;

      final fetchedItems = List<CallHistoryGroup>.from(
        response.data ?? const <CallHistoryGroup>[],
      );
      _applyUpdatedLeadDetails(fetchedItems);

      final resolvedPage = response.page ?? 1;
      final resolvedLimit = response.limit ?? defaultPageSize;

      currentPage.value = resolvedPage;
      totalCount.value = response.total ?? fetchedItems.length;
      hasMore.value = _computeHasMore(
        response: response,
        fetchedCount: fetchedItems.length,
        loadedCount: fetchedItems.length,
        requestedLimit: defaultPageSize,
      );

      callLogsResponse.value = AllCallHistoryResponse(
        success: response.success,
        total: response.total,
        page: resolvedPage,
        limit: resolvedLimit,
        data: fetchedItems,
      );
      callApiState.value = PageState.stable;
    } catch (e) {
      if (generation == _requestGeneration) {
        hasMore.value = false;
        callApiState.value = PageState.error;
      }
      // Old comments , before Nov 3 2026 Tuesday.
      // print(e);
    }
  }

  Future<void> loadMore() async {
    await getApi(loadMore: true);
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

    refreshData();
  }

  void refreshData() {
    getApi(startDate: selectedStartDate.value, endDate: selectedEndDate.value);
  }

  Future<void> updateClientDetails({
    required String leadId,
    required String clientName,
    required String mobileNumber,
  }) async {
    final normalizedLeadId = leadId.trim();
    final normalizedName = clientName.trim();
    final normalizedPhone = mobileNumber.trim();
    if (normalizedLeadId.isEmpty) {
      throw ArgumentError.value(leadId, 'leadId', 'Lead ID is required');
    }
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(
        clientName,
        'clientName',
        'Client name is required',
      );
    }
    if (!RegExp(r'^\d{10}$').hasMatch(normalizedPhone)) {
      throw ArgumentError.value(
        mobileNumber,
        'mobileNumber',
        'Mobile number must contain exactly 10 digits',
      );
    }

    final nameParts = normalizedName.split(RegExp(r'\s+'));
    final first = nameParts.first;
    final last = nameParts.length > 1 ? nameParts.last : '';
    final middle = nameParts.length > 2
        ? nameParts.sublist(1, nameParts.length - 1).join(' ')
        : '';
    final phone = int.parse(normalizedPhone);

    await DioApi().patchLead(normalizedLeadId, {
      'name': {'first': first, 'middle': middle, 'last': last},
      'phone': phone,
    });

    _updatedLeadDetails[normalizedLeadId] = _UpdatedCallLeadDetails(
      first: first,
      middle: middle,
      last: last,
      phone: phone,
    );

    for (final group in callLogsResponse.value.data ?? <CallHistoryGroup>[]) {
      final lead = group.lead;
      if (lead?.sId == normalizedLeadId) {
        lead!.name = LeadName(first: first, middle: middle, last: last);
        lead.phone = phone;
      }
    }
    callLogsResponse.refresh();
  }

  var searchQuery = ''.obs;

  List<CallHistoryGroup> get filteredCallLogs {
    final allLogs = callLogsResponse.value.data ?? [];
    if (searchQuery.value.isEmpty) {
      return allLogs;
    }
    final query = searchQuery.value.toLowerCase();
    return allLogs.where((log) {
      final nameStr =
          "${log.lead?.name?.first ?? ''} ${log.lead?.name?.last ?? ''}"
              .trim()
              .toLowerCase();
      final phoneStr = log.lead?.phone?.toString() ?? '';
      return nameStr.contains(query) || phoneStr.contains(query);
    }).toList();
  }

  Future<void> fetchCallLogs() async {
    try {
      isLoading(true);

      // Check and request permission
      if (await Permission.phone.request().isGranted) {
        // Get call logs
        Iterable<device_call_log.CallLogEntry> entries =
            await device_call_log.CallLog.get();
        callLogs.assignAll(entries);
        // Old comments , before Nov 3 2026 Tuesday.
        // print('Name: ${callLogs[0].name}');
        // Old comments , before Nov 3 2026 Tuesday.
        // print('Number: ${callLogs[0].number}');
        // Old comments , before Nov 3 2026 Tuesday.
        // print('Formatted Number: ${callLogs[0].formattedNumber}');
        // Old comments , before Nov 3 2026 Tuesday.
        // print('Call Type: ${callLogs[0].callType}');
        // Old comments , before Nov 3 2026 Tuesday.
        // print('Duration: ${callLogs[0].duration}');
        // Old comments , before Nov 3 2026 Tuesday.
        // print('Timestamp: ${callLogs[0].timestamp}');
        // Old comments , before Nov 3 2026 Tuesday.
        // print('Cached Number Type: ${callLogs[0].cachedNumberType}');
        // Old comments , before Nov 3 2026 Tuesday.
        // print('Cached Number Label: ${callLogs[0].cachedNumberLabel}');
        // Old comments , before Nov 3 2026 Tuesday.
        // print('SIM Display Name: ${callLogs[0].simDisplayName}');
        // Old comments , before Nov 3 2026 Tuesday.
        // print('Phone Account ID: ${callLogs[0].phoneAccountId}');
        // Old comments , before Nov 3 2026 Tuesday.
        // print('ID: ${callLogs[0].id}');
      } else {
        Get.snackbar(
          'Permission denied',
          'Cannot access call logs without permission',
        );
      }
    } finally {
      isLoading(false);
    }
  }
}

class _UpdatedCallLeadDetails {
  final String first;
  final String middle;
  final String last;
  final int phone;

  const _UpdatedCallLeadDetails({
    required this.first,
    required this.middle,
    required this.last,
    required this.phone,
  });
}
