import 'package:crm_flutter/api/dio_api.dart';
import 'package:get/get.dart';

class PrathamController extends GetxController {
  Future createCall(data) async {
    try {
      final response = await DioApi().createCallHistory(data);
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
    } catch (e) {
      rethrow;
    }
  }
}
