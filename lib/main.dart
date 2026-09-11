import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/common_widgets/notificationService.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/notifications/notifications_controller.dart';
import 'package:crm_flutter/pages/Allocations/WhatsappSMS/whatsapp_sms_controller.dart';
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/Auth/AuthController.dart';
import 'package:crm_flutter/pages/SplashController.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
import 'package:crm_flutter/pages/SplashPage.dart';
import 'package:crm_flutter/services/incoming_call_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DioUtil.init();

  LocalStorage.sharedPreferences = await SharedPreferences.getInstance();

  // Initialize local notifications
  await NotificationService.init();
  await NotificationService.requestPermission();

  // Initialize incoming call service
  IncomingCallService.initialize();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,

      initialBinding: BindingsBuilder(() {
        // Auth Controller
        Get.put(AuthController(), permanent: true);

        // Splash Controller
        Get.put(SplashController(), permanent: true);

        // API
        Get.put(DioApi());

        // Allocation Controller
        Get.put(AllocationController());

        // Lead Details Controller
        Get.put(Leaddetailscontroller());

        // Local Notification Service
        Get.put(NotificationService());

        // Notification API + Polling Controller
        Get.put(NotificationController(), permanent: true);

        // WhatsApp / SMS Controller
        Get.put(WhatsappSmsController());
      }),

      home: SplashPage(),

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
      ),

      debugShowCheckedModeBanner: false,
    );
  }
}
