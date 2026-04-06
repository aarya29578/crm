import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/bottom_navigation_bar/BottomNavigationBarPage.dart';
import 'package:crm_flutter/widgets/poppups/poppups.dart';
import 'package:dio/dio.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  RxBool isLogin = true.obs;
  RxBool showPass = true.obs;

  Future register(data, context) async {
    try {
      final response = await DioApi().register(data);
      if (response['status'] == "success") {
        isLogin.value = true;
        successPopup(context, "User registered Successfully.");
      }
    } catch (e) {
      print("Register Error : $e");
    }
  }

  // Future login(data, context) async {
  //   try {
  //     final response = await DioApi().login(data);
  //     print(response);
  //     if (response['status'] == "success" || response.status == 200) {
  //       LocalStorage.sharedPreferences!.setString('token', response['token']);
  //       LocalStorage.sharedPreferences!.setString(
  //         'user_name',
  //         response['user']['name'],
  //       ); // Adjust based on your API response structure
  //       final phone = response['user']?['phone'];

  //       if (phone != null) {
  //         LocalStorage.sharedPreferences?.setInt('phone_number', phone);
  //       }

  //       // Get.snackbar(
  //       //   "Success",
  //       //   "User logged in Successfully",
  //       //   snackPosition: SnackPosition.BOTTOM,
  //       //   backgroundColor: Colors.black87,
  //       //   colorText: Colors.white,
  //       // );

  //       // successPopup(context, "User logged in Successfully.");
  //       ScaffoldMessenger.of(Get.context!).showSnackBar(
  //         const SnackBar(content: Text("User logged in Successfully")),
  //       );
  //       await Future.delayed(const Duration(milliseconds: 800));
  //       Get.offAll(BottomNavigationBarPage());
  //     } else if (response['status'] == "fail" && response.status == 400) {
  //       // floatingSnackBar(message: 'user no found!', context: context);
  //       ScaffoldMessenger.of(
  //         Get.context!,
  //       ).showSnackBar(const SnackBar(content: Text("User not found!")));
  //     } else if (response['status'] == "fail" && response.status == 404) {
  //       // floatingSnackBar(
  //       //   message: 'Incorrect email or password!',
  //       //   context: context,
  //       // );
  //       ScaffoldMessenger.of(Get.context!).showSnackBar(
  //         const SnackBar(content: Text("Incorrect email or password!")),
  //       );
  //     }
  //   } catch (e) {
  //     print("Register Error : $e");
  //   }
  // }

  Future login(data, context) async {
    try {
      final response = await DioApi().login(data);

      // SUCCESS (200 only)
      if (response['status'] == "success") {
        LocalStorage.sharedPreferences!.setString('token', response['token']);
        LocalStorage.sharedPreferences!.setString(
          'user_name',
          response['user']['name'],
        );
        LocalStorage.sharedPreferences!.setString(
          'user_Id',
          response['user']['id'],
        );

        final campaign = response['user']?['campaign']?['name'];

        if (campaign != null) {
          await LocalStorage.sharedPreferences!.setString(
            'user_campaign',
            campaign,
          );
        }

        final phone = response['user']?['phone'];

        if (phone != null) {
          await LocalStorage.sharedPreferences!.setInt('phone_number', phone);
        }

        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(content: Text("User logged in Successfully")),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        Get.offAll(() => BottomNavigationBarPage());
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      print("LOGIN ERROR STATUS: $status");

      if (status == 400) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(const SnackBar(content: Text("User not found!")));
      } else if (status == 404) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(content: Text("Incorrect email or password!")),
        );
      } else {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(const SnackBar(content: Text("Server error")));
      }
      print("TYPE: ${e.type}");
      print("STATUS: ${e.response?.statusCode}");
      print("DATA: ${e.response?.data}");
      print("MESSAGE: ${e.message}");
    } catch (e) {
      print("Login Error: $e");

      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }
}
