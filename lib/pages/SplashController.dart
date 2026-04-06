import 'package:crm_flutter/common_widgets/notificationService.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Auth/LoginPage.dart';
import 'package:crm_flutter/pages/bottom_navigation_bar/BottomNavigationBarPage.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final a = 10.obs;

  @override
  void onInit() {
    super.onInit();

    Future.delayed(Duration(seconds: 2), () {
      String token = LocalStorage.sharedPreferences?.getString("token") ?? "";
      print(token);
      if (token == null || token == "") {
        Get.offAll(LoginPage());
      } else {
        Get.off(BottomNavigationBarPage());
      }
      // Get.off(
      // () => const BottomNavigationBarPage(),
      //() => const LoginPage(),
      // ); // Replaces the splash with MainPage
    });

    // NotificationService.init();
    // NotificationService.requestPermission();
  }
}
