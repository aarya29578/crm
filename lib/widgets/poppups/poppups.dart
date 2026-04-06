import 'dart:ui';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/Allocations/WhatsappSMS/whatsapp_sms_controller.dart';
import 'package:flutter/material.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Auth/LoginPage.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';

logoutpoppup(context) {
  return showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CircleAvatar(
                  backgroundColor: "#D9D9D9".toColor(),
                  child: const Icon(Icons.close, color: Colors.black, size: 25),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom + 240,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.only(right: 5, left: 5, top: 10),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              height: 5,
                              width: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: ColorConstants.LightLabelGrey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        ' Are you sure ?',
                                        style: TextStyle(
                                          color: ColorConstants.MainGreyText,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Roboto-Light.ttf',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'You\'ll be logged out of all devices.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: ColorConstants.MainGreyText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Roboto-Regular.ttf',
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    height: 40,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[600],
                                      ),
                                      onPressed: () {
                                        LocalStorage.sharedPreferences!.clear();
                                        Get.offAll(LoginPage());
                                      },
                                      child: const Text(
                                        'YES, LOGOUT',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  InkWell(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: ColorConstants.MainGreyText,
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'CANCEL',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: ColorConstants.MainGreyText,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

contestTimeout(context) {
  return showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom + 280,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.only(right: 5, left: 5, top: 10),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        ' Deadline Passed!',
                                        style: TextStyle(
                                          color: ColorConstants.MainGreyText,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Roboto-Light.ttf',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Icon(
                                    Icons.error_outline_sharp,
                                    color: Colors.red,
                                    size: 100,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'You can\'t join contests for this match anymore. Select another match to play.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: ColorConstants.LightLabelGrey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Roboto-Regular.ttf',
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    height: 40,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[600],
                                      ),
                                      onPressed: () {
                                        Get.back();
                                        Get.back();
                                      },
                                      child: const Text(
                                        'VIEW UPCOMING MATCHES',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void errorPopup(BuildContext context, String message) {
  if (!Get.isSnackbarOpen) {
    GetBar(
      message: message,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.error_outline, color: Colors.red),
      shouldIconPulse: false,
      backgroundColor: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 10,
      margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
      forwardAnimationCurve: Curves.bounceIn,
      messageText: Text(
        message,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.0, // Line height equivalent to 16px
          letterSpacing: 0.0,
          color: Colors.red, // Text color set to red
        ),
      ),
    ).show();
  }
}

void successPopup(BuildContext context, String message) {
  if (!Get.isSnackbarOpen) {
    GetBar(
      message: message,
      duration: const Duration(seconds: 2),
      icon: const Icon(
        Icons.check_circle_outline_outlined,
        color: Colors.white,
      ),
      shouldIconPulse: false,
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      borderRadius: 10,
      margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
      forwardAnimationCurve: Curves.bounceIn,
      messageText: Text(
        message,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.0, // Line height equivalent to 16px
          letterSpacing: 0.0,
          color: Colors.white, // Text color set to red
        ),
      ),
    ).show();
  }
}

void warnigPopup(BuildContext context, String message) {
  if (!Get.isSnackbarOpen) {
    GetBar(
      message: message,
      duration: const Duration(seconds: 2),
      icon: Icon(Icons.warning_outlined, color: '#47484A'.toColor()),
      shouldIconPulse: false,
      backgroundColor: "#FDF656".toColor(),
      snackPosition: SnackPosition.TOP,
      borderRadius: 10,
      margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
      forwardAnimationCurve: Curves.bounceIn,
      messageText: Text(
        message,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.0, // Line height equivalent to 16px
          letterSpacing: 0.0,
          color: '#47484A'.toColor(), // Text color set to red
        ),
      ),
    ).show();
  }
}

void alertDialog(
  Future<void> Function() onPress,
  BuildContext context,
  WhatsappSmsController controller, {
  String? whichSource,
  Widget? content,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // prevent outside tap close
    builder: (dialogContext) {
      return PopScope(
        // prevent back button close
        canPop: false,
        child: AlertDialog(
          title: Text(whichSource ?? ''),
          content: content,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text("Cancel"),
            ),

            Obx(() {
              if (controller.isLoading.value == PageState.loading) {
                return SizedBox(); // hide while loading
              }

              if (controller.wsData.isEmpty) {
                return SizedBox(); // hide if no data
              }

              return ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);

                  await onPress();
                },
                child: Text("Yes"),
              );
            }),
          ],
        ),
      );
    },
  );
}
