import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/getLeadByStage.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:get/get.dart';

class Claimedcontroller extends GetxController {

  Rx<GetLeadbyStageRes> getLeadByStageRes = GetLeadbyStageRes().obs;
  Rx<PageState> stateload = PageState.loading.obs;

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
