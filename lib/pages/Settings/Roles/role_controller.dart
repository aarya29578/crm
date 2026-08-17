import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_roles_response.dart';
import 'package:get/get.dart';

class RoleController extends GetxController {
  Rx<AllRoleResponse> allRoleRes = AllRoleResponse().obs;
  //RxList<String> rolePermissionsList = <String>[].obs;

  Future getAllRoles() async {
    try {
      final response = await DioApi().getAllRoles();
      print(response);
      if (response.success == true) {
        allRoleRes.value = response;
      }
    } catch (e) {
      rethrow;
    }
  }
}
