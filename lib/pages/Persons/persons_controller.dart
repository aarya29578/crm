import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_organizations_response.dart';
import 'package:crm_flutter/api/response/all_persons_response.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:get/get.dart';

class PersonsController extends GetxController {
  Rx<AllPersonResponse> allPersonRes = AllPersonResponse().obs;
  Rx<AllOrganizationResponse> allOrganizationRes =
      AllOrganizationResponse().obs;

  Rx<PageState> personState = PageState.loading.obs;

  //
  RxList<String> emails = <String>[].obs;
  RxList<String> contacts = <String>[].obs;
  //
  Future getAllPersons() async {
    try {
      personState.value = PageState.loading;
      final response = await DioApi().getAllPersons();
      if (response.success == true) {
        allPersonRes.value = response;
        personState.value = PageState.stable;
      }
    } catch (e) {
      personState.value = PageState.error;
    }
  }

  Future getAllOrganizations() async {
    try {
      final response = await DioApi().getAllOrganizations();
      if (response.status == 200) {
        allOrganizationRes.value = response;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future deletePerson(String personId) async {
    try {
      final response = await DioApi().deletePerson(personId);
      if (response['success'] == true) {
        await getAllPersons();
      }
    } catch (e) {
      personState.value = PageState.error;
    }
  }

  Future<void> createPerson(req) async {
    try {
      var data = req;

      print(data);
      final response = await DioApi().createPerson(data);
      print(response);
      if (response['success'] == true) {
        Get.back();
        await getAllPersons(); // Refresh the list
        emails.value = [];
        contacts.value = [];
      }
    } catch (e) {
      personState.value = PageState.error;
    }
  }

  Future<void> updatePerson(data, id) async {
    try {
      final response = await DioApi().updatePerson(data, id);
      print(response);
      if (response['success'] == true) {
        Get.back();
        await getAllPersons(); // Refresh the list
        emails.value = [];
        contacts.value = [];
      }
    } catch (e) {
      personState.value = PageState.error;
    }
  }
}
