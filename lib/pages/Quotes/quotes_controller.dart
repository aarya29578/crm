import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_quotes_response.dart';
import 'package:get/get.dart';

class QuotesController extends GetxController {
  Rx<AllQuoteResponse> allQuotesRes = AllQuoteResponse().obs;
  final RxList<Items> items = <Items>[].obs;

  RxInt subTotal = 0.obs;
  RxInt finalDiscountAmount = 0.obs;
  RxInt finalTaxAmount = 0.obs;
  RxInt grandTotal = 0.obs;
  RxInt discountAmount = 0.obs;
  RxInt taxAmount = 0.obs;
  RxInt totalAmount = 0.obs;

  Future getAllQuotes() async {
    try {
      final response = await DioApi().getAllQuotes();
      print(response);
      if (response.status == 200) {
        allQuotesRes.value = response;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future createQuote(data) async {
    try {
      final response = await DioApi().createProduct(data);
      print(response);

      if (response['success'] == true) {
        Get.back();
        await getAllQuotes(); // Refresh the list
      }
    } catch (e) {}
  }
}
