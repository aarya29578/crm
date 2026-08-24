import 'package:crm_flutter/local_storage/local_storage.dart';
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
    // Keep splash screen for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Get saved token
    final token = LocalStorage.sharedPreferences?.getString("token");

    print("SAVED TOKEN: $token");

    if (token != null && token.isNotEmpty) {
      print("User already logged in");

      Get.offAll(() => BottomNavigationBarPage());
    } else {
      print("User is not logged in");

      Get.offAll(() => const LoginPage());
    }
  }
}
  // SESSION MANAGEMENT

  // void onInit() {
  //   super.onInit();

  //   Future.delayed(Duration(seconds: 2), () {
  //     String token = LocalStorage.sharedPreferences?.getString("token") ?? "";
  //     print(token);
  //     if (token == "") {
  //       Get.offAll(LoginPage());
  //     } else {
  //       Get.off(BottomNavigationBarPage());
  //     }
  //     // Get.off(
  //     // () => const BottomNavigationBarPage(),
  //     //() => const LoginPage(),
  //     // ); // Replaces the splash with MainPage
  //   });

  //   // NotificationService.init();
  //   // NotificationService.requestPermission();
  // }
