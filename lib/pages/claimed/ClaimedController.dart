import 'dart:async';

import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart' as lead_model;
import 'package:crm_flutter/api/response/getLeadByStage.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:get/get.dart';

class Claimedcontroller extends GetxController {
  Rx<GetLeadbyStageRes> getLeadByStageRes = GetLeadbyStageRes().obs;
  Rx<PageState> stateload = PageState.loading.obs;
  final RxString searchQuery = ''.obs;
  final RxList<lead_model.Data> searchResults = <lead_model.Data>[].obs;
  final RxBool isSearchLoading = false.obs;
  final RxString searchError = ''.obs;
  Timer? _searchDebounce;
  int _searchRequestId = 0;

  void onSearchChanged(String query) {
    _searchDebounce?.cancel();
    final trimmedQuery = query.trim();
    searchQuery.value = trimmedQuery;
    searchError.value = '';
    searchResults.clear();
    final requestId = ++_searchRequestId;

    if (trimmedQuery.isEmpty) {
      isSearchLoading.value = false;
      return;
    }

    isSearchLoading.value = true;
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSearchResults(trimmedQuery, requestId);
    });
  }

  Future<void> refreshSearch() async {
    _searchDebounce?.cancel();
    final query = searchQuery.value;
    if (query.isEmpty) return;

    final requestId = ++_searchRequestId;
    isSearchLoading.value = true;
    searchError.value = '';
    await _fetchSearchResults(query, requestId);
  }

  Future<void> _fetchSearchResults(String query, int requestId) async {
    try {
      final response = await DioApi().searchLeads(query);
      if (requestId != _searchRequestId) return;
      if (response.success != true) {
        throw Exception('Lead search was not successful');
      }
      searchResults.assignAll(response.data ?? []);
    } catch (error) {
      if (requestId != _searchRequestId) return;
      searchError.value = 'Unable to search leads: $error';
    } finally {
      if (requestId == _searchRequestId) {
        isSearchLoading.value = false;
      }
    }
  }

  List<lead_model.Data> searchResultsForStages(Iterable<String> stageIds) {
    final selectedStageIds = stageIds.toSet();
    return searchResults
        .where((lead) => selectedStageIds.contains(lead.leadStageId?.sId))
        .toList();
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    _searchRequestId++;
    searchQuery.value = '';
    searchResults.clear();
    isSearchLoading.value = false;
    searchError.value = '';
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future getLeadbyStage(String stageId) async {
    stateload.value = PageState.loading;
    print('Fetching leads for stage: $stageId');
    try {
      await Future.delayed(Duration(seconds: 1));
      final response = await DioApi().getLeadbyStage(stageId);
      if (response.success == true) {
        getLeadByStageRes.value = response;
        stateload.value = PageState.stable;
      }
    } catch (e) {
      stateload.value = PageState.error;

      rethrow;
    }
  }

  Future getLeadsByMultipleStages(List<String> stageIds) async {
    stateload.value = PageState.loading;
    print('Fetching leads for multiple stages: $stageIds');
    try {
      await Future.delayed(Duration(milliseconds: 500));
      List<dynamic> allLeads = [];
      for (String id in stageIds) {
        final response = await DioApi().getLeadbyStage(id);
        if (response.success == true && response.leadDetails != null) {
          allLeads.addAll(response.leadDetails!);
        }
      }
      getLeadByStageRes.value = GetLeadbyStageRes(
        success: true,
        leadDetails: allLeads.cast(),
      );
      stateload.value = PageState.stable;
    } catch (e) {
      stateload.value = PageState.error;
      rethrow;
    }
  }
}
