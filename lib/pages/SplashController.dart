import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Auth/LoginPage.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final a = 10.obs;

  @override
  void onInit() {
    super.onInit();

    Future.delayed(const Duration(seconds: 2), () async {
      await LocalStorage.sharedPreferences?.remove("token");

      Get.offAll(() => const LoginPage());
    });
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
}
