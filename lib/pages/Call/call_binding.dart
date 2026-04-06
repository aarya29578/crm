import 'package:get/get.dart';
import 'package:crm_flutter/pages/calls_history/calls_history_controller.dart';

class CallBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CallsHistoryController>(CallsHistoryController(), permanent: true);
  }
}
