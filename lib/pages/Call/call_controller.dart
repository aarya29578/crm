import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_calls_history_response.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/home/components/date_range_picker_dialog.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart' as device_call_log;

class CallLogController extends GetxController {
  var callLogs = <device_call_log.CallLogEntry>[].obs;
  var isLoading = true.obs;

  Rx<AllCallHistoryResponse> callLogsResponse = AllCallHistoryResponse().obs;
  Rx<PageState> callApiState = PageState.loading.obs;
  final Map<String, _UpdatedCallLeadDetails> _updatedLeadDetails = {};

  // Date filter state
  RxString selectedTimeRange = 'Today'.obs;
  Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);

  Future getApi({DateTime? startDate, DateTime? endDate}) async {
    try {
      callApiState.value = PageState.loading;

      // Store the dates
      if (startDate != null) selectedStartDate.value = startDate;
      if (endDate != null) selectedEndDate.value = endDate;

      Map<String, dynamic> queryParams = {};
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

      final response = await DioApi().getAllCallsHistory(
        null,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );
      for (final group in response.data ?? <CallHistoryGroup>[]) {
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
      callLogsResponse.value = response;
      callApiState.value = PageState.stable;
    } catch (e) {
      callApiState.value = PageState.error;
      print(e);
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
        print('Name: ${callLogs[0].name}');
        print('Number: ${callLogs[0].number}');
        print('Formatted Number: ${callLogs[0].formattedNumber}');
        print('Call Type: ${callLogs[0].callType}');
        print('Duration: ${callLogs[0].duration}');
        print('Timestamp: ${callLogs[0].timestamp}');
        print('Cached Number Type: ${callLogs[0].cachedNumberType}');
        print('Cached Number Label: ${callLogs[0].cachedNumberLabel}');
        print('SIM Display Name: ${callLogs[0].simDisplayName}');
        print('Phone Account ID: ${callLogs[0].phoneAccountId}');
        print('ID: ${callLogs[0].id}');
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
