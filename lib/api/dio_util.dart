import 'package:dio/dio.dart';
import 'package:crm_flutter/access_storage/access_storage.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Auth/LoginPage.dart';
import 'package:crm_flutter/widgets/poppups/poppups.dart';
import 'package:crm_flutter/pages/home/HomeController.dart';
import 'package:get/get.dart';

class DioUtil {
  static late Dio dio;

  static Future init() async {
    dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (
                RequestOptions requestOptions,
                RequestInterceptorHandler requestInterceptorHandler,
              ) async {
                if (requestOptions.uri.toString().contains(
                  'customer/contacts',
                )) {
                } else {
                  // EasyLoading.show();
                }

                var token = LocalStorage.sharedPreferences!.getString("token");

                if (token != null) {
                  requestOptions.headers['Authorization'] = "Bearer $token";
                }

                // Global Campaign Injection
                try {
                  if (Get.isRegistered<HomeController>()) {
                    final homeController = Get.find<HomeController>();
                    final selectedCampaignId =
                        homeController.selectedCampaignId;

                    if (selectedCampaignId != null &&
                        selectedCampaignId.isNotEmpty &&
                        !requestOptions.uri.path.contains('/campaign/all')) {
                      // Append campaign if not already present
                      if (!requestOptions.queryParameters.containsKey(
                        'campaign',
                      )) {
                        requestOptions.queryParameters['campaign'] =
                            selectedCampaignId;
                      }
                    }
                  }
                } catch (e) {
                  print('Error appending global campaign: $e');
                }

                requestInterceptorHandler.next(requestOptions);
              },
          onResponse: (e, handler) {
            if (e.statusCode == 401) {
              LocalStorage.sharedPreferences!.remove('token');
              Get.offAll(LoginPage());
            }

            if (e.statusCode != 200 && e.statusCode != 201) {
              final context =
                  AccessStorageController.navigatorKey.currentContext;
              if (context != null) {
                if (e.statusCode == 500) {
                  errorPopup(context, 'Server Error!!');
                } else {
                  final detail = e.data is Map ? e.data['detail'] : null;
                  errorPopup(context, detail ?? 'Something went wrong');
                }
              }
            }

            handler.next(e);
          },
          onError: (error, req) {
            if (error.response?.statusCode == 401) {
              LocalStorage.sharedPreferences!.remove('token');
              Get.offAll(LoginPage());
            }

            final context = AccessStorageController.navigatorKey.currentContext;
            if (context != null) {
              errorPopup(context, error.toString());
            }
 
            req.next(error);
          },
        ),
      );
  }
}
