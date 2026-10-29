import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/get_whatsappSms_response.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:get/get.dart';

class WhatsappSmsController extends GetxController {
  DioApi get _dioApi =>
      Get.isRegistered<DioApi>() ? Get.find<DioApi>() : DioApi();

  RxList<WSData> wsData = <WSData>[].obs;
  RxBool isMoreDataAvailable = true.obs;
  Rx<PageState> isLoading = PageState.stable.obs;

  int currentPage = 1;
  int _currentRequestId = 0;
  String? activeCampaignId;

  Future<void> getWhatsSms({
    String? campaignId,
    String? whichSource,
    bool forceRefresh = false,
  }) async {
    if (forceRefresh ||
        (campaignId != null && campaignId != activeCampaignId)) {
      currentPage = 1;
      wsData.clear();
      isMoreDataAvailable.value = true;
      activeCampaignId = campaignId;
    } else if (campaignId != null) {
      activeCampaignId = campaignId;
    }

    if (!isMoreDataAvailable.value) {
      return;
    }

    final requestId = ++_currentRequestId;

    try {
      isLoading.value = PageState.loading;

      final res = await _dioApi.getwhatsSms(
        page: currentPage,
        campaignId: campaignId,
        whichSource: whichSource,
      );

      if (requestId != _currentRequestId) {
        return;
      }

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
      if (requestId != _currentRequestId) {
        return;
      }
      isLoading.value = PageState.error;
      print("Error loading data: $err");
    }
  }

  void reset({String? campaignId}) {
    _currentRequestId++;
    currentPage = 1;
    wsData.clear();
    isMoreDataAvailable.value = true;
    isLoading.value = PageState.stable;
    activeCampaignId = campaignId;
  }

  Future<void> refreshData({String? campaignId, String? whichSource}) async {
    reset(campaignId: campaignId);
    await getWhatsSms(
      campaignId: campaignId,
      whichSource: whichSource,
      forceRefresh: true,
    );
  }
}
