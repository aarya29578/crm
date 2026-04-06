import 'package:crm_flutter/api/dio_api.dart';
import 'package:get/get.dart';
import 'package:crm_flutter/api/response/all_types_response.dart';
import 'package:get/get.dart';

class TypeController extends GetxController {
  Rx<AllTypeResponse> allTypeRes = AllTypeResponse().obs;
  Future getAllTypes() async {
    try {
      final response = await DioApi().getAllTypes();
      print(response);
      if (response.status == 200) {
        allTypeRes.value = response;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> createType(req) async {
    var data = req;
    print(data);
    try {
      final response = await DioApi().createType(data);
      print(response);
      if (response['success'] == true) {
        Get.back();
        await getAllTypes();
      }
    } catch (e) {
      throw e;
    }
  }

  Future deleteType(typeId) async {
    try {
      final response = await DioApi().deleteType(typeId);
      if (response['success'] == true) {
        await getAllTypes();
      }
    } catch (e) {
      throw e;
    }
  }
}
