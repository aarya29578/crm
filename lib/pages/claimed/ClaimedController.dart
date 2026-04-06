import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/getLeadByStage.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:get/get.dart';

class Claimedcontroller extends GetxController {
  Rx<GetLeadbyStageRes> getLeadByStageRes = GetLeadbyStageRes().obs;
  Rx<PageState> stateload = PageState.loading.obs;
  Future getLeadbyStage(String stage_id) async {
    stateload.value = PageState.loading;
    print('Fetching leads for stage: $stage_id');
    try {
      await Future.delayed(Duration(seconds: 1));
      final response = await DioApi().getLeadbyStage(stage_id);
      if (response.success == true) {
        getLeadByStageRes.value = response;
        stateload.value = PageState.stable;
      }
    } catch (e) {
      stateload.value = PageState.error;

      throw e;
    }
  }
}
