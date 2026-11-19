import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_groups_response.dart';
import 'package:get/get.dart';

class GroupController extends GetxController {
  Rx<AllGroupResponse> allGroupRes = AllGroupResponse().obs;

  Future getAllGroups() async {
    try {
      final response = await DioApi().getAllGroups();
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
      if (response.status == 200) {
        allGroupRes.value = response;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createGroup(req) async {
    var data = req;
// Old comments , before Nov 3 2026 Tuesday.
    // print(data);
    try {
      final response = await DioApi().createGroup(data);
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
      if (response['success'] == true) {
        Get.back();
        await getAllGroups();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGroup(data, id) async {
    try {
// Old comments , before Nov 3 2026 Tuesday.
      // print(data);
      final response = await DioApi().updateGroup(data, id);
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
      if (response['success'] == true) {
        Get.back();
        await getAllGroups(); // Refresh the list
      }
    } catch (e) {
      rethrow;
    }
  }

  Future deleteGroup(String groupId) async {
    try {
      final response = await DioApi().deleteGroup(groupId);
      if (response['success'] == true) {
        await getAllGroups();
      }
    } catch (e) {
      rethrow;
    }
  }
}
