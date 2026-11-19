import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_sources_response.dart';
import 'package:get/get.dart';

class SourceController extends GetxController {
  Rx<AllSourceResponse> allSourceRes = AllSourceResponse().obs;

  Future getAllSources() async {
    try {
      final response = await DioApi().getAllSources();
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
      if (response.status == 200) {
        allSourceRes.value = response;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createSource(req) async {
    var data = req;
// Old comments , before Nov 3 2026 Tuesday.
    // print(data);
    try {
      final response = await DioApi().createSource(data);
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
      if (response['success'] == true) {
        Get.back();
        await getAllSources();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future deleteSource(sourceId) async {
    try {
      final response = await DioApi().deleteSource(sourceId);
      if (response['success'] == true) {
        await getAllSources();
      }
    } catch (e) {
      rethrow;
    }
  }
}
