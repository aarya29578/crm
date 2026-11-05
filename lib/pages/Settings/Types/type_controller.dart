import 'package:crm_flutter/api/dio_api.dart';
import 'package:get/get.dart';
import 'package:crm_flutter/api/response/all_types_response.dart';

class TypeController extends GetxController {
  Rx<AllTypeResponse> allTypeRes = AllTypeResponse().obs;
  Future getAllTypes() async {
    try {
      final response = await DioApi().getAllTypes();
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
      if (response.status == 200) {
        allTypeRes.value = response;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createType(req) async {
    var data = req;
// Old comments , before Nov 3 2026 Tuesday.
    // print(data);
    try {
      final response = await DioApi().createType(data);
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
      if (response['success'] == true) {
        Get.back();
        await getAllTypes();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future deleteType(typeId) async {
    try {
      final response = await DioApi().deleteType(typeId);
      if (response['success'] == true) {
        await getAllTypes();
      }
    } catch (e) {
      rethrow;
    }
  }
}
