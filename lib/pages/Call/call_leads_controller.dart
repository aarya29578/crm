import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_calls_history_response.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/home/components/date_range_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum CallLeadType {
  overall,
  outbound,
  inbound;

  String get title {
    switch (this) {
      case CallLeadType.overall:
        return 'Overall Calls';
      case CallLeadType.outbound:
        return 'Outbound Calls';
      case CallLeadType.inbound:
        return 'Inbound Calls';
    }
  }
}

class CallLeadsController extends GetxController {
  final CallLeadType callType;

  CallLeadsController({this.callType = CallLeadType.overall});

  DioApi get _dioApi =>
      Get.isRegistered<DioApi>() ? Get.find<DioApi>() : DioApi();

  Rx<AllCallHistoryResponse> callLogsResponse = AllCallHistoryResponse().obs;
  Rx<PageState> callApiState = PageState.loading.obs;

  // Date filter state
  RxString selectedTimeRange = 'Today'.obs;
  Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);

  // Search filter
  RxString searchQuery = ''.obs;

  final Map<String, _UpdatedLeadDetails> _updatedLeadDetails = {};

  Future<void> fetchCalls({DateTime? startDate, DateTime? endDate}) async {
    try {
      callApiState.value = PageState.loading;

      if (startDate != null) selectedStartDate.value = startDate;
      if (endDate != null) selectedEndDate.value = endDate;

      final Map<String, dynamic> queryParams = {};
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

      final response = await _dioApi.getAllCallsHistory(
        null,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      // Reapply locally edited lead details
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
// Old comments , before Nov 3 2026 Tuesday.
      // debugPrint("Error fetching call leads: $e");
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
    fetchCalls(
      startDate: selectedStartDate.value,
      endDate: selectedEndDate.value,
    );
  }

  List<CallHistoryGroup> get filteredLeads {
    final allLogs = callLogsResponse.value.data ?? [];

    // Filter by call type (overall, outbound, inbound)
    final typeFiltered = allLogs.where((log) {
      final direction = (log.callLog?.direction ?? '').trim().toLowerCase();
      final status = (log.callLog?.status ?? '').trim().toLowerCase();

      switch (callType) {
        case CallLeadType.overall:
          return true;
        case CallLeadType.outbound:
          return direction == 'outbound';
        case CallLeadType.inbound:
          return direction == 'inbound' ||
              (direction.isEmpty && status == 'missed');
      }
    }).toList();

    // Filter by search query
    if (searchQuery.value.trim().isEmpty) {
      return typeFiltered;
    }

    final query = searchQuery.value.trim().toLowerCase();
    return typeFiltered.where((log) {
      final lead = log.lead;
      final nameStr =
          "${lead?.name?.first ?? ''} ${lead?.name?.middle ?? ''} ${lead?.name?.last ?? ''}"
              .trim()
              .toLowerCase();
      final phoneStr = lead?.phone?.toString() ?? '';
      final agentStr = (log.calledBy?.name ?? '').trim().toLowerCase();
      return nameStr.contains(query) ||
          phoneStr.contains(query) ||
          agentStr.contains(query);
    }).toList();
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

    await _dioApi.patchLead(normalizedLeadId, {
      'name': {'first': first, 'middle': middle, 'last': last},
      'phone': phone,
    });

    _updatedLeadDetails[normalizedLeadId] = _UpdatedLeadDetails(
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
}

class _UpdatedLeadDetails {
  final String first;
  final String middle;
  final String last;
  final int phone;

  const _UpdatedLeadDetails({
    required this.first,
    required this.middle,
    required this.last,
    required this.phone,
  });
}

