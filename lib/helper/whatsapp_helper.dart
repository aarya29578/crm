import 'dart:async';
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/Allocations/WhatsappSMS/whatsapp_sms_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  /// Test hooks for url_launcher
  static Future<bool> Function(Uri url, LaunchMode mode)? defaultLauncher;
  static Future<bool> Function(Uri url)? defaultCanLaunchChecker;

  /// Substitutes template placeholders with customer and agent names.
  static String processTemplate(String body, {required String customerName}) {
    String message = body;
    final agentName =
        LocalStorage.sharedPreferences?.getString('user_name') ?? "User";

    message = message.replaceAll(
      RegExp(
        r'[\{\[\<]+\s*(?:customer_name|customer name|name|lead_name|customer)\s*[\}\]\>]+',
        caseSensitive: false,
      ),
      customerName,
    );
    message = message.replaceAll(
      RegExp(
        r'[\{\[\<]+\s*(?:agent_name|agent name|agent)\s*[\}\]\>]+',
        caseSensitive: false,
      ),
      agentName,
    );
    return message;
  }

  /// Opens WhatsApp with the given phone and message, with browser fallback.
  static Future<void> openWhatsApp(
    String phone,
    String message, {
    Future<bool> Function(Uri url, LaunchMode mode)? launcher,
    Future<bool> Function(Uri url)? canLaunchChecker,
  }) async {
    final cleanPhone = phone.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final encodedMessage = Uri.encodeComponent(message);

    final uri = Uri.parse(
      "whatsapp://send?phone=91$cleanPhone&text=$encodedMessage",
    );

    print("whatsappURL : $uri");

    final canLaunchFn =
        canLaunchChecker ?? defaultCanLaunchChecker ?? canLaunchUrl;
    final launchFn = launcher ??
        defaultLauncher ??
        ((url, mode) => launchUrl(url, mode: mode));

    if (await canLaunchFn(uri)) {
      await launchFn(
        uri,
        LaunchMode.externalApplication,
      );
    } else {
      print("WhatsApp not installed or cannot open");

      /// Fallback to browser (always works)
      final fallback = Uri.parse(
        "https://wa.me/91$cleanPhone?text=$encodedMessage",
      );

      await launchFn(fallback, LaunchMode.externalApplication);
    }
  }

  /// Shows the campaign-specific WhatsApp templates dialog.
  static void showWhatsAppTemplates({
    required BuildContext context,
    required String? leadId,
    required String? campaignId,
    required String? phone,
    required String customerName,
    Future<void> Function()? onTemplateSent,
    Future<bool> Function(Uri url, LaunchMode mode)? launcher,
    Future<bool> Function(Uri url)? canLaunchChecker,
  }) {
    final phoneStr = (phone ?? '').trim();
    final cleanPhone = phoneStr.replaceAll(RegExp(r'[^0-9]'), '');

    if (phoneStr.isEmpty ||
        phoneStr == 'no number found' ||
        cleanPhone.isEmpty ||
        cleanPhone == '0') {
      Get.snackbar(
        "Error",
        "Phone number is not available",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (campaignId == null || campaignId.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Campaign ID is not available",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final controller = Get.isRegistered<WhatsappSmsController>()
        ? Get.find<WhatsappSmsController>()
        : Get.put(WhatsappSmsController());

    controller.reset(campaignId: campaignId);
    controller.isLoading.value = PageState.loading;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.message, color: Colors.green.shade700, size: 24),
                const SizedBox(width: 10),
                Text(
                  'WhatsApp Templates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.only(top: 10, bottom: 0),
          content: Obx(() {
            if (controller.isLoading.value == PageState.loading &&
                controller.wsData.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                    SizedBox(height: 15),
                    Text("Loading templates..."),
                  ],
                ),
              );
            }

            if (controller.isLoading.value == PageState.error) {
              return const Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  "Failed to load templates",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            if (controller.wsData.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  "No templates available",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            return Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Scrollbar(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: controller.wsData.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final templateData = controller.wsData[index];
                    final templateBody = templateData.body ?? '';
                    final templateName =
                        templateData.name ?? 'Template ${index + 1}';

                    final processedMessage = processTemplate(
                      templateBody,
                      customerName: customerName,
                    );

                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        try {
                          if (leadId == null || leadId.trim().isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Lead ID is not available",
                              snackPosition: SnackPosition.TOP,
                            );
                            return;
                          }

                          final templateId = templateData.sId;

                          if (templateId == null || templateId.trim().isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Template ID is not available",
                              snackPosition: SnackPosition.TOP,
                            );
                            return;
                          }

                          // Record template usage
                          final dioApi = Get.isRegistered<DioApi>()
                              ? Get.find<DioApi>()
                              : DioApi();
                          final response = await dioApi.recordTemplateUsage(
                            leadId: leadId,
                            templateId: templateId,
                            channel: "whatsapp",
                          );

                          print(
                            "========== TEMPLATE USAGE RESPONSE ==========",
                          );
                          print(response);
                          print(
                            "=============================================",
                          );

                          if (onTemplateSent != null) {
                            await onTemplateSent();
                          }

                          // Close template dialog
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }

                          // Open WhatsApp only once
                          await openWhatsApp(
                            phoneStr,
                            processedMessage,
                            launcher: launcher,
                            canLaunchChecker: canLaunchChecker,
                          );
                        } catch (e) {
                          print("Template usage error: $e");

                          Get.snackbar(
                            "Error",
                            "Failed to record template usage: $e",
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    templateName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    processedMessage,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.send,
                                color: Colors.green.shade600,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ),
          ],
        );
      },
    );

    /// CALL API AFTER DIALOG OPENS
    Future.microtask(() {
      controller.getWhatsSms(
        whichSource: 'whatsapp',
        campaignId: campaignId,
      );
    });
  }
}

