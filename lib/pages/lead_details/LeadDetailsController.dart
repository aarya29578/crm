import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_lead_details_response.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class Leaddetailscontroller
 extends GetxController {
  RxBool addressEnabled = false.obs;
  Rx<AllLeadDetailResponse> allLeadDetailRes = AllLeadDetailResponse().obs;
  Rx<PageState> pageState = PageState.loading.obs;
  Future<void> getAllLeadDetails(context, id) async {
    pageState.value = PageState.loading;
    try {
      print("Making API call for lead ID: $id");
      final response = await DioApi().getAllLeadDetails(id);
      print("API Response: $response");

      if (response.success == true) {
        allLeadDetailRes.value = response;
        pageState.value = PageState.stable;
      } else {
        print("API returned success=false");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Permission denied!"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      pageState.value = PageState.error;
      print("Error in getAllLeadDetails: $e");
      rethrow; // This will allow the error to propagate up
    }
  }

  Future<void> getAllLeadDetailsPatchA(id) async {
    pageState.value = PageState.loading;
    try {
      print("Making API call for lead ID: $id");
      final response = await DioApi().getAllLeadDetailsPatchA(id);
      print("API Response: $response");

      if (response.success == true) {
        allLeadDetailRes.value = response;
        pageState.value = PageState.stable;
      } else {
        print("API returned success=false");
      }
    } catch (e) {
      pageState.value = PageState.error;
      print("Error in getAllLeadDetails: $e");
      rethrow; // This will allow the error to propagate up
    }
  }

  Future<void> getAllLeadDetailsPatchD(id) async {
    pageState.value = PageState.loading;
    try {
      print("Making API call for lead ID: $id");
      final response = await DioApi().getAllLeadDetailsPatchD(id);
      print("API Response: $response");

      if (response.success == true) {
        allLeadDetailRes.value = response;
        pageState.value = PageState.stable;
      } else {
        print("API returned success=false");
      }
    } catch (e) {
      pageState.value = PageState.error;
      print("Error in getAllLeadDetails: $e");
      rethrow; // This will allow the error to propagate up
    }
  }

  //

  Future<void> requestPermissions() async {
    await Permission.phone.request();
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  Future createCall(data) async {
    try {
      final response = await DioApi().createCallHistory(data);
      print(response);
    } catch (e) {
      rethrow;
    }
  }
}
