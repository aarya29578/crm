import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_products_response.dart';
import 'package:get/get.dart';

class ProductsController extends GetxController {
  Rx<AllProductResponse> allProductsRes = AllProductResponse().obs;

  Future getAllProducts() async {
    try {
      final response = await DioApi().getAllProducts();
      print("+++++++++++++++++++++++++++++++++++++++++++++++++++");
      print(response.toJson());
      print("+++++++++++++++++++++++++++++++++++++++++++++++++++");
      if (response.success == true) {
        allProductsRes.value = response;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> createProduct(req) async {
    try {
      var data = req;
      print(data);
      final response = await DioApi().createProduct(data);
      print(response);

      if (response['success'] == true || response['success'] == 201) {
        Get.back();
        await getAllProducts(); // Refresh the list
      }
    } catch (e) {
      throw e;
    }
  }

  Future updateProduct(data, id) async {
    try {
      print(data);
      final response = await DioApi().updateProduct(data, id);

      print(response);
      if (response['success'] == true) {
        Get.back();
        await getAllProducts(); // Refresh the list
      }
    } catch (e) {
      throw e;
    }
  }

  Future deleteProduct(String productId) async {
    try {
      final response = await DioApi().deleteProduct(productId);
      if (response['success'] == false) {
        await getAllProducts();
      }
    } catch (e) {
      throw e;
    }
  }
}
