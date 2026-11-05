import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/common_widgets/notificationService.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/local_storage/up_coming_followups_controller.dart';
import 'package:crm_flutter/notifications/notifications_controller.dart';
import 'package:crm_flutter/pages/Auth/LoginPage.dart';
import 'package:crm_flutter/pages/bottom_navigation_bar/BottomNavigationBarPage.dart';
import 'package:crm_flutter/widgets/poppups/poppups.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  RxBool isLogin = true.obs;
  RxBool showPass = true.obs;


  // ============================================================
  // CHECK LOGIN STATUS
  // ============================================================

  Future<bool> isLoggedIn() async {
    final token = LocalStorage.sharedPreferences?.getString('token');

    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // REQUEST REQUIRED PERMISSIONS AFTER LOGIN
  // ============================================================

  Future<void> requestRequiredPermissions() async {
// Old comments , before Nov 3 2026 Tuesday.
    // print("🔐 Requesting required permissions...");

    final statuses = await [
      Permission.phone,
      Permission.contacts,
    ].request();

// Old comments , before Nov 3 2026 Tuesday.
    // print("📱 Phone permission: ${statuses[Permission.phone]}");
// Old comments , before Nov 3 2026 Tuesday.
    // print("👤 Contacts permission: ${statuses[Permission.contacts]}");

// Old comments , before Nov 3 2026 Tuesday.
    // print("✅ Permission request completed");
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
// Old comments , before Nov 3 2026 Tuesday.
      // print("Register Error : $e");
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future login(data, context) async {
// Old comments , before Nov 3 2026 Tuesday.
    // print("🔥 LOGIN BUTTON HAS CALLED SUCCESSFULLY");
// Old comments , before Nov 3 2026 Tuesday.
    // print("🔥 LOGIN DATA: $data");

    try {
// Old comments , before Nov 3 2026 Tuesday.
      // print("🔥 CALLING LOGIN API...");

      final response = await DioApi().login(data);

// Old comments , before Nov 3 2026 Tuesday.
      // print("🔥 LOGIN API RESPONSE: $response");

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
        // Password Manager
        // ------------------------------------------------------

        await Future.delayed(const Duration(milliseconds: 800));

        TextInput.finishAutofillContext();

        // ------------------------------------------------------
        // Re-init Follow-up Reminders
        // ------------------------------------------------------

        if (Get.isRegistered<FollowUpController>()) {
          await Get.find<FollowUpController>().init();
        }

        // ======================================================
        // START NOTIFICATION POLLING
        // ======================================================

        if (Get.isRegistered<NotificationController>()) {
// Old comments , before Nov 3 2026 Tuesday.
          // print("🔔 Starting notification polling after login...");

          Get.find<NotificationController>().startNotificationPolling();
        } else {
// Old comments , before Nov 3 2026 Tuesday.
          // print("❌ NOTIFICATION CONTROLLER NOT REGISTERED.");
        }

        // ------------------------------------------------------
              // ------------------------------------------------------
        // REQUEST REQUIRED PERMISSIONS
        // ------------------------------------------------------

        await requestRequiredPermissions();

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

// Old comments , before Nov 3 2026 Tuesday.
      // print("LOGIN ERROR STATUS: $status");

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

// Old comments , before Nov 3 2026 Tuesday.
      // print("TYPE: ${e.type}");
// Old comments , before Nov 3 2026 Tuesday.
      // print("STATUS: ${e.response?.statusCode}");
// Old comments , before Nov 3 2026 Tuesday.
      // print("DATA: ${e.response?.data}");
// Old comments , before Nov 3 2026 Tuesday.
      // print("MESSAGE: ${e.message}");
// Old comments , before Nov 3 2026 Tuesday.
      // print("ERROR OBJECT: ${e.error}");
    }
    // ============================================================
    // GENERAL ERROR
    // ============================================================
    catch (e, stackTrace) {
// Old comments , before Nov 3 2026 Tuesday.
      // print("Login Error: $e");
// Old comments , before Nov 3 2026 Tuesday.
      // print("Stack Trace: $stackTrace");

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
// Old comments , before Nov 3 2026 Tuesday.
      // print("Starting Logout...");

      // ========================================================
      // BACKEND LOGOUT
      // ========================================================

      try {
        final response = await DioApi().logout();

// Old comments , before Nov 3 2026 Tuesday.
        // print("Logout API Response: $response");
      } on DioException catch (e) {
// Old comments , before Nov 3 2026 Tuesday.
        // print("Logout API Error: ${e.response?.data}");

        // Continue local logout even if API fails.
      }

      // ========================================================
      // STOP NOTIFICATION POLLING
      // ========================================================

      if (Get.isRegistered<NotificationController>()) {
// Old comments , before Nov 3 2026 Tuesday.
        // print("🛑 Stopping notification polling...");

        Get.find<NotificationController>().stopNotificationPolling();

        Get.find<NotificationController>().clearKnownNotificationIds();
      }

      await NotificationService.cancelAllScheduledNotifications();

      if (Get.isRegistered<FollowUpController>()) {
        await Get.find<FollowUpController>().stop();
      }

      await LocalStorage.sharedPreferences?.remove('token');

      await LocalStorage.sharedPreferences?.remove('user_name');

      await LocalStorage.sharedPreferences?.remove('user_Id');

      await LocalStorage.sharedPreferences?.remove('user_campaign');

      await LocalStorage.sharedPreferences?.remove('phone_number');

      final token = LocalStorage.sharedPreferences?.getString('token');

// Old comments , before Nov 3 2026 Tuesday.
      // print("TOKEN AFTER LOGOUT: $token");

      Get.offAll(() => const LoginPage());

// Old comments , before Nov 3 2026 Tuesday.
      // print("Logout completed");
    } catch (e) {
// Old comments , before Nov 3 2026 Tuesday.
      // print("Logout Error: $e");

      Get.snackbar(
        "Logout Error",
        "Unable to logout. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
