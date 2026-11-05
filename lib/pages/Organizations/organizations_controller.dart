import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_organizations_response.dart';
import 'package:get/get.dart';

class OrganizationsController extends GetxController {
  Rx<AllOrganizationResponse> allOrganizationRes =
      AllOrganizationResponse().obs;

  Future getAllOrganizations() async {
    try {
      final response = await DioApi().getAllOrganizations();
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
      if (response.status == 200) {
        allOrganizationRes.value = response;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createOrganization(req) async {
    try {
      var data = req;
      //print(data);
      final response = await DioApi().createOrganization(data);
      //print(response);
      if (response['success'] == true) {
        Get.back();
        await getAllOrganizations(); // Refresh the list
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrganization(data, id) async {
    try {
// Old comments , before Nov 3 2026 Tuesday.
      // print(data);
      final response = await DioApi().updateOrganization(data, id);
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
      // This update has a problem
      if (response['success'] == false) {
        Get.back();
        await getAllOrganizations(); // Refresh the list
      }
    } catch (e) {
      rethrow;
    }
  }

  Future deleteOrganization(String organizationId) async {
    try {
      final response = await DioApi().deleteOrganization(organizationId);
      if (response['success'] == true) {
        await getAllOrganizations();
      }
    } catch (e) {
      rethrow;
    }
  }
}
