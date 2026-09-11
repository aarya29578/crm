import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/notifications/notifications_controller.dart';
import 'package:crm_flutter/pages/Auth/LoginPage.dart';
import 'package:crm_flutter/pages/bottom_navigation_bar/BottomNavigationBarPage.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    checkLogin();
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = LocalStorage.sharedPreferences?.getString("token");

    print(
      "🔐 Saved token exists: "
      "${token != null && token.isNotEmpty}",
    );

    if (token != null && token.isNotEmpty) {
      print("✅ User already logged in");

      // Start notifications for restored session.
      if (Get.isRegistered<NotificationController>()) {
        print("🔔 Starting notification polling...");

        Get.find<NotificationController>().startNotificationPolling();
      } else {
        print("❌ NotificationController is not registered");
      }

      Get.offAll(() => BottomNavigationBarPage());
    } else {
      print("❌ User is not logged in");

      Get.offAll(() => const LoginPage());
    }
  }
}
