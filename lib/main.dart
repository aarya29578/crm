import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/common_widgets/notificationService.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Allocations/WhatsappSMS/whatsapp_sms_controller.dart';
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/Auth/AuthController.dart';
import 'package:crm_flutter/pages/SplashController.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
import 'package:flutter/material.dart';
import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/pages/SplashPage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DioUtil.init();
  LocalStorage.sharedPreferences = await SharedPreferences.getInstance();

  await NotificationService.init();
  await NotificationService.requestPermission();

  await SystemChrome.setPreferredOrientations([
    ///Lock app to Portrait only
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown,

    ///Lock app to Landscape only
    // DeviceOrientation.landscapeLeft,
    // DeviceOrientation.landscapeRight,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
        Get.put(SplashController(), permanent: true);
        Get.put(DioApi());
        Get.put(AllocationController());
        Get.put(Leaddetailscontroller());
        Get.put(NotificationService());
        Get.put(WhatsappSmsController());
      }),
      home: SplashPage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: AppBarTheme(backgroundColor: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
