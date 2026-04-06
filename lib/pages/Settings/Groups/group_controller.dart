import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_groups_response.dart';
import 'package:get/get.dart';

class GroupController extends GetxController {
  Rx<AllGroupResponse> allGroupRes = AllGroupResponse().obs;

  Future getAllGroups() async {
    try {
      final response = await DioApi().getAllGroups();
      print(response);
      if (response.status == 200) {
        allGroupRes.value = response;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> createGroup(req) async {
    var data = req;
    print(data);
    try {
      final response = await DioApi().createGroup(data);
      print(response);
      if (response['success'] == true) {
        Get.back();
        await getAllGroups();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateGroup(data, id) async {
    try {
      print(data);
      final response = await DioApi().updateGroup(data, id);
      print(response);
      if (response['success'] == true) {
        Get.back();
        await getAllGroups(); // Refresh the list
      }
    } catch (e) {
      throw e;
    }
  }

  Future deleteGroup(String groupId) async {
    try {
      final response = await DioApi().deleteGroup(groupId);
      if (response['success'] == true) {
        await getAllGroups();
      }
    } catch (e) {
      throw e;
    }
  }
}
