import 'package:crm_flutter/api/dio_api.dart';
import 'package:get/get.dart';

class PrathamController extends GetxController {
  Future createCall(data) async {
    try {
      final response = await DioApi().createCallHistory(data);
      print(response);
    } catch (e) {
      throw e;
    }
  }
}
