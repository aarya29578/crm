import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/get_whatsappSms_response.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:get/get.dart';

class WhatsappSmsController extends GetxController {
  final DioApi _dioApi = Get.find<DioApi>();

  RxList<WSData> wsData = <WSData>[].obs;
  RxBool isMoreDataAvailable = true.obs;
  Rx<PageState> isLoading = PageState.stable.obs;

  int currentPage = 1;

  Future<void> getWhatsSms({String? campaignId, String? whichSource}) async {
    if (!isMoreDataAvailable.value || isLoading.value == PageState.loading) {
      return;
    }

    try {
      isLoading.value = PageState.loading;

      await Future.delayed(Duration(seconds: 1));

      final res = await _dioApi.getwhatsSms(
        page: currentPage,
        campaignId: campaignId,
        whichSource: whichSource,
      );

      if (res.success == true) {
        final responseData = res.data;

        if (responseData == null || responseData.isEmpty) {
          isMoreDataAvailable.value = false;
        } else {
          wsData.addAll(responseData);
          currentPage++;
        }

        isLoading.value = PageState.stable;
      } else {
        isLoading.value = PageState.error;
      }
    } catch (err) {
      isLoading.value = PageState.error;
      print("Error loading data: $err");
    }
  }

  Future<void> refreshData() async {
    currentPage = 1;
    wsData.clear();
    isMoreDataAvailable.value = true;

    await getWhatsSms();
  }
}
