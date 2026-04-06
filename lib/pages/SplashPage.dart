import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_flutter/pages/SplashController.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SplashController controller = Get.find<SplashController>();
    return Scaffold(body: Center(child: Text("Wait for 2 minutes")));
  }
}
