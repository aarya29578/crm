import 'dart:async';

import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_lead_stage_response.dart' as stage;
import 'package:crm_flutter/api/response/all_leads_response.dart';
import 'package:crm_flutter/api/response/all_sources_response.dart' as source;
import 'package:crm_flutter/local_storage/up_coming_followups_controller.dart';
import 'package:crm_flutter/pages/home/components/date_range_picker_dialog.dart';
import 'package:crm_flutter/pages/home/components/status_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllocationController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    getAllLeadStages();
  }

  RxList<Data> leads = <Data>[].obs;
  RxBool isLoading = false.obs;
  RxBool isPaginationLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  int currentPage = 1;

  RxString selectedTimeRange = 'Today'.obs;
  Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);

  RxList<stage.Data> allLeadStages = <stage.Data>[].obs;

  DateTime? filterStartDate;
  DateTime? filterEndDate;

  RxList<String> selectedStatusIds = <String>[].obs;
  List<String>? filterStatusIds;

  // ─── Lead Source Filter ─────────────────────────────────────

  RxList<source.Data> allLeadSources = <source.Data>[].obs;

  Rx<source.Data?> selectedLeadSource = Rx<source.Data?>(null);

  RxBool isLeadSourceLoading = false.obs;

  String? filterLeadSourceId;

  // ─── Search ───────────────────────────────────────────────

  RxString searchQuery = ''.obs;
  RxList<Data> searchResults = <Data>[].obs;
  RxBool isSearchLoading = false.obs;
  RxBool isSearchMode = false.obs;

  Timer? _debounce;

  Future<void> onSearchChanged(String query) async {
    _debounce?.cancel();

    final trimmed = query.trim();
    searchQuery.value = trimmed;

    if (trimmed.isEmpty) {
      isSearchMode.value = false;
      searchResults.clear();
      return;
    }

    isSearchMode.value = true;

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _doSearch(trimmed);
    });
  }

  Future<void> _doSearch(String query) async {
    if (isSearchLoading.value) return;

    isSearchLoading.value = true;

    try {
      final response = await DioApi().searchLeads(query);

      if (response.success == true) {
        searchResults.assignAll(response.data ?? []);
      }
    } catch (e) {
      print("Search error: $e");
    } finally {
      isSearchLoading.value = false;
    }
  }

  Future<Data?> getLeadWithTimeline(String leadId) async {
    for (final lead in [...leads, ...searchResults]) {
      if (lead.sId == leadId && (lead.timeline?.isNotEmpty ?? false)) {
        debugPrint(
          'CALL LOG TIMELINE: leadId=$leadId '
          'timelineCount=${lead.timeline!.length} source=allocation-cache',
        );
        return lead;
      }
    }

    final firstPage = await DioApi().getAllLeads(page: 1);
    if (firstPage.success != true) {
      throw Exception(
        'Failed to load leads while resolving timeline for $leadId',
      );
    }

    final totalPages = firstPage.totalPages;
    for (var page = 1;
        totalPages == null || page <= totalPages;
        page++) {
      final response = page == 1
          ? firstPage
          : await DioApi().getAllLeads(page: page);
      if (response.success != true) {
        throw Exception(
          'Failed to load lead page $page while resolving timeline for $leadId',
        );
      }

      for (final lead in response.data ?? <Data>[]) {
        if (lead.sId == leadId) {
          debugPrint(
            'CALL LOG TIMELINE: leadId=$leadId '
            'timelineCount=${lead.timeline?.length ?? 0} source=lead/all',
          );
          return lead;
        }
      }

      if (response.data == null || response.data!.isEmpty) {
        break;
      }
    }

    debugPrint(
      'CALL LOG TIMELINE: leadId=$leadId timelineCount=0 source=not-found',
    );
    return null;
  }

  void clearSearch() {
    _debounce?.cancel();

    searchQuery.value = '';
    searchResults.clear();
    isSearchMode.value = false;
    isSearchLoading.value = false;
  }

  void updateLeadInLists(Data updatedLead) {
    final leadId = updatedLead.sId;
    if (leadId == null) return;

    final leadIndex = leads.indexWhere((lead) => lead.sId == leadId);
    if (leadIndex != -1) {
      leads[leadIndex] = updatedLead;
    }

    final searchIndex = searchResults.indexWhere((lead) => lead.sId == leadId);
    if (searchIndex != -1) {
      searchResults[searchIndex] = updatedLead;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  // ──────────────────────────────────────────────────────────
  // GET ALL LEADS
  // ──────────────────────────────────────────────────────────

  Future<void> getAllLeads({
    bool isInitial = false,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? statusIds,
    String? leadSourceId,
  }) async {
    if (isInitial) {
      if (isLoading.value) return;

      isLoading.value = true;
    } else {
      if (isPaginationLoading.value || !isMoreDataAvailable.value) {
        return;
      }

      isPaginationLoading.value = true;
    }

    try {
      if (isInitial) {
        currentPage = 1;
        leads.clear();
        isMoreDataAvailable.value = true;

        filterStartDate = startDate;
        filterEndDate = endDate;
        filterStatusIds = statusIds;
        filterLeadSourceId = leadSourceId;
      }

      await Get.find<FollowUpController>().syncWithApi();

      await Future.delayed(
        const Duration(milliseconds: 10),
      );

      final response = await DioApi().getAllLeads(
        page: currentPage,
        startDate: filterStartDate,
        endDate: filterEndDate,
        statusIds: filterStatusIds,
        leadSourceId: filterLeadSourceId,
      );

      if (response.success == true) {
        final List<Data>? responseData = response.data;

        if (responseData == null || responseData.isEmpty) {
          isMoreDataAvailable.value = false;
        } else {
          leads.addAll(responseData);
          for (final lead in responseData) {
  debugPrint(
    'ALLOCATION TIMELINE CHECK: '
    'leadId=${lead.sId}, '
    'timelineCount=${lead.timeline?.length ?? 0}',
  );
}
          currentPage++;
        }
      }
    } catch (e) {
      print("Error loading leads: $e");
    } finally {
      isLoading.value = false;
      isPaginationLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────
  // TIME RANGE
  // ──────────────────────────────────────────────────────────

  Future<void> selectTimeRange(
    String range,
    BuildContext context,
  ) async {
    selectedTimeRange.value = range;

    final now = DateTime.now();

    switch (range) {
      case 'Today':
        selectedStartDate.value = DateTime(
          now.year,
          now.month,
          now.day,
        );

        selectedEndDate.value = now;
        break;

      case 'Yesterday':
        final yesterday = now.subtract(
          const Duration(days: 1),
        );

        selectedStartDate.value = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
        );

        selectedEndDate.value = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(
          const Duration(seconds: 1),
        );
        break;

      case 'Last 30 Days':
        selectedStartDate.value = now.subtract(
          const Duration(days: 30),
        );

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

  // ──────────────────────────────────────────────────────────
  // LEAD STAGES
  // ──────────────────────────────────────────────────────────

  Future<void> getAllLeadStages() async {
    try {
      final response = await DioApi().getAllLeadStage();

      if (response.success == true) {
        allLeadStages.assignAll(
          response.data ?? [],
        );
      }
    } catch (e) {
      print("Error fetching lead stages: $e");
    }
  }

  // ──────────────────────────────────────────────────────────
  // LEAD SOURCES
  // ──────────────────────────────────────────────────────────

  Future<void> getAllLeadSources() async {
    if (isLeadSourceLoading.value) return;

    isLeadSourceLoading.value = true;

    try {
      final response = await DioApi().getAllSources();

      if (response.success == true) {
        allLeadSources.assignAll(
          response.data ?? [],
        );
      }
    } catch (e) {
      print("Error fetching lead sources: $e");
    } finally {
      isLeadSourceLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────
  // LEAD SOURCE FILTER DIALOG
  // ──────────────────────────────────────────────────────────

  Future<void> showLeadSourceFilter(
    BuildContext context,
  ) async {
    if (allLeadSources.isEmpty) {
      await getAllLeadSources();
    }

    source.Data? tempSelected =
        selectedLeadSource.value;

    final result = await showDialog<source.Data?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Filter by Lead Source',
              ),

              content: SizedBox(
                width: double.maxFinite,

                child: isLeadSourceLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : DropdownButtonFormField<source.Data>(
                        value: tempSelected,

                        decoration: const InputDecoration(
                          labelText: 'Lead Source',
                          border: OutlineInputBorder(),
                        ),

                        items: allLeadSources.map((item) {
                          return DropdownMenuItem<source.Data>(
                            value: item,
                            child: Text(
                              item.name ?? 'Unknown',
                            ),
                          );
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            tempSelected = value;
                          });
                        },
                      ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),

                if (selectedLeadSource.value != null)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      source.Data(),
                      );
                    },
                    child: const Text('Clear'),
                  ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      tempSelected,
                    );
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      if (result.sId == null) {
        selectedLeadSource.value = null;
      } else {
        selectedLeadSource.value = result;
      }

      await refreshData();
    }
  }

  // ──────────────────────────────────────────────────────────
  // STATUS FILTER
  // ──────────────────────────────────────────────────────────

  void showStatusFilter(BuildContext context) async {
    if (allLeadStages.isEmpty) {
      await getAllLeadStages();
    }

    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => StatusFilterDialog(
        allStages: allLeadStages,
        initialSelectedIds: selectedStatusIds,
      ),
    );

    if (result != null) {
      selectedStatusIds.assignAll(result);
      refreshData();
    }
  }

  void toggleStatus(
    String statusId,
    BuildContext context,
  ) {
    if (selectedStatusIds.contains(statusId)) {
      selectedStatusIds.remove(statusId);
    } else {
      selectedStatusIds.add(statusId);
    }

    refreshData();
  }

  // ────────────────────────── ────────────────────────────────
  // REFRESH DATA
  // ──────────────────────────────────────────────────────────

  Future<void> refreshData() async {
    await getAllLeads(
      isInitial: true,
      startDate: selectedStartDate.value,
      endDate: selectedEndDate.value,
      statusIds: selectedStatusIds,
      leadSourceId: selectedLeadSource.value?.sId,
    );
  }
}
