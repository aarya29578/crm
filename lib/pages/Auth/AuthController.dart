import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Auth/LoginPage.dart';
import 'package:crm_flutter/pages/bottom_navigation_bar/BottomNavigationBarPage.dart';
import 'package:crm_flutter/widgets/poppups/poppups.dart';
import 'package:crm_flutter/common_widgets/notificationService.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  RxBool isLogin = true.obs;
  RxBool showPass = true.obs;

  Future<bool> isLoggedIn() async {
    final token = LocalStorage.sharedPreferences?.getString('token');

    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // REGISTER
  // ============================================================

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

  // ============================================================
  // LOGIN
  // ============================================================

  Future login(data, context) async {
    try {
      final response = await DioApi().login(data);

      // ========================================================
      // LOGIN SUCCESS
      // ========================================================

      if (response['status'] == "success") {
        // ------------------------------------------------------
        // Save Token
        // ------------------------------------------------------

        final token = response['token'];

        if (token != null) {
          await LocalStorage.sharedPreferences!.setString('token', token);
        }

        // ------------------------------------------------------
        // Save User Name
        // ------------------------------------------------------

        final userName = response['user']?['name'];

        if (userName != null) {
          await LocalStorage.sharedPreferences!.setString(
            'user_name',
            userName,
          );
        }

        // ------------------------------------------------------
        // Save User ID
        // ------------------------------------------------------

        final userId = response['user']?['id'] ?? response['user']?['_id'];

        if (userId != null) {
          await LocalStorage.sharedPreferences!.setString('user_Id', userId);
        }

        // ------------------------------------------------------
        // Save Campaign
        // ------------------------------------------------------

        final campaignData = response['user']?['campaign'];

        String? campaignName;

        if (campaignData is List && campaignData.isNotEmpty) {
          campaignName = campaignData[0]['name'];
        } else if (campaignData is Map) {
          campaignName = campaignData['name'];
        }

        if (campaignName != null) {
          await LocalStorage.sharedPreferences!.setString(
            'user_campaign',
            campaignName,
          );
        }

        // ------------------------------------------------------
        // Save Phone Number
        // ------------------------------------------------------

        final phone = response['user']?['phone'];

        if (phone != null) {
          if (phone is int) {
            await LocalStorage.sharedPreferences!.setInt('phone_number', phone);
          } else if (phone is String) {
            await LocalStorage.sharedPreferences!.setInt(
              'phone_number',
              int.tryParse(phone) ?? 0,
            );
          } else if (phone is double) {
            await LocalStorage.sharedPreferences!.setInt(
              'phone_number',
              phone.toInt(),
            );
          }
        }

        // ------------------------------------------------------
        // Login Success Message
        // ------------------------------------------------------

        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(content: Text("User logged in Successfully")),
        );

        // ------------------------------------------------------
        // Give Password Manager time to process autofill
        // ------------------------------------------------------

        await Future.delayed(const Duration(milliseconds: 800));

        // ------------------------------------------------------
        // Finish Autofill Context
        // This allows Android/iOS password manager to
        // offer saving the email/password.
        // ------------------------------------------------------

        TextInput.finishAutofillContext();

        // ------------------------------------------------------
        // Navigate to Main App
        // ------------------------------------------------------

        Get.offAll(() => BottomNavigationBarPage());
      }
    }
    // ============================================================
    // DIO ERROR
    // ============================================================
    on DioException catch (e) {
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
      print("ERROR OBJECT: ${e.error}");
    }
    // ============================================================
    // GENERAL ERROR
    // ============================================================
    catch (e, stackTrace) {
      print("Login Error: $e");
      print("Stack Trace: $stackTrace");

      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text("Something went wrong: ${e.toString()}")),
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      print("Starting Logout...");

      // 1. Call backend logout API
      try {
        final response = await DioApi().logout();
        print("Logout API Response: $response");
      } on DioException catch (e) {
        print("Logout API Error: ${e.response?.data}");
        // Continue clearing local session even if API fails
      }

      // 2. Cancel scheduled notifications
      await NotificationService.cancelAllScheduledNotifications();

      // 3. Remove login/session data
      await LocalStorage.sharedPreferences?.remove('token');
      await LocalStorage.sharedPreferences?.remove('user_name');
      await LocalStorage.sharedPreferences?.remove('user_Id');
      await LocalStorage.sharedPreferences?.remove('user_campaign');
      await LocalStorage.sharedPreferences?.remove('phone_number');

      // 4. Verify token was removed
      final token = LocalStorage.sharedPreferences?.getString('token');

      print("TOKEN AFTER LOGOUT: $token");

      // 5. Go to login
      Get.offAll(() => const LoginPage());

      print("Logout completed");
    } catch (e) {
      print("Logout Error: $e");

      Get.snackbar(
        "Logout Error",
        "Unable to logout. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
