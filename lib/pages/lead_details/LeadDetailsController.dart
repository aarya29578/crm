
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_lead_details_response.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class Leaddetailscontroller extends GetxController {
  RxBool addressEnabled = false.obs;

  Rx<AllLeadDetailResponse> allLeadDetailRes =
      AllLeadDetailResponse().obs;

  Rx<PageState> pageState = PageState.loading.obs;

  Future<void> getAllLeadDetails(context, id) async {
    pageState.value = PageState.loading;

    try {
// Old comments , before Nov 3 2026 Tuesday.
      // print("Making API call for lead ID: $id");

      final response = await DioApi().getAllLeadDetails(id);

// Old comments , before Nov 3 2026 Tuesday.
      // print("API Response: $response");

      if (response.success == true) {
        // DEBUG: Check whether the API response contains timeline data.
        try {
          final responseData = response.data;

          if (responseData == null) {
// Old comments , before Nov 3 2026 Tuesday.
            // print("LEAD DETAILS TIMELINE: response.data is null");
          } else {
            final jsonData = responseData.toJson();
// Old comments , before Nov 3 2026 Tuesday.
            // print("LEAD DETAILS RESPONSE KEYS: ${jsonData.keys.toList()}");
// Old comments , before Nov 3 2026 Tuesday.
            // print("LEAD DETAILS TIMELINE: ${jsonData['timeline']}");
          }
        } catch (e) {
// Old comments , before Nov 3 2026 Tuesday.
          // print("Could not inspect timeline in response: $e");
        }

        allLeadDetailRes.value = response;
        pageState.value = PageState.stable;
      } else {
// Old comments , before Nov 3 2026 Tuesday.
        // print("API returned success=false");

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
// Old comments , before Nov 3 2026 Tuesday.
      // print("Error in getAllLeadDetails: $e");
      rethrow;
    }
  }

  Future<void> getAllLeadDetailsPatchA(id) async {
    pageState.value = PageState.loading;

    try {
// Old comments , before Nov 3 2026 Tuesday.
      // print("Making API call for lead ID: $id");

      final response = await DioApi().getAllLeadDetailsPatchA(id);

// Old comments , before Nov 3 2026 Tuesday.
      // print("API Response: $response");

      if (response.success == true) {
        allLeadDetailRes.value = response;
        pageState.value = PageState.stable;
      } else {
// Old comments , before Nov 3 2026 Tuesday.
        // print("API returned success=false");
      }
    } catch (e) {
      pageState.value = PageState.error;
// Old comments , before Nov 3 2026 Tuesday.
      // print("Error in getAllLeadDetails: $e");
      rethrow;
    }
  }

  Future<void> getAllLeadDetailsPatchD(id) async {
    pageState.value = PageState.loading;

    try {
// Old comments , before Nov 3 2026 Tuesday.
      // print("Making API call for lead ID: $id");

      final response = await DioApi().getAllLeadDetailsPatchD(id);

// Old comments , before Nov 3 2026 Tuesday.
      // print("API Response: $response");

      if (response.success == true) {
        allLeadDetailRes.value = response;
        pageState.value = PageState.stable;
      } else {
// Old comments , before Nov 3 2026 Tuesday.
        // print("API returned success=false");
      }
    } catch (e) {
      pageState.value = PageState.error;
// Old comments , before Nov 3 2026 Tuesday.
      // print("Error in getAllLeadDetails: $e");
      rethrow;
    }
  }

  Future<void> requestPermissions() async {
    await Permission.phone.request();
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  Future createCall(data) async {
    try {
      final response = await DioApi().createCallHistory(data);
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
    } catch (e) {
      rethrow;
    }
  }
}
