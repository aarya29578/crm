import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/common_widgets/call_storage.dart';
import 'package:crm_flutter/common_widgets/popup_after_call_ui.dart';

class IncomingCallService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.crm_flutter/call',
  );

  static final DioApi _dioApi = DioApi();

  static void initialize() {
    print("🔥 IncomingCallService initialized");

    _channel.setMethodCallHandler((call) async {
      print("🔥 MethodChannel event received: ${call.method}");
      print("🔥 Arguments: ${call.arguments}");

      if (call.method == 'incomingCallEnded') {
        try {
          final data = Map<String, dynamic>.from(call.arguments);

          print("📞 Incoming call received from Android");
          print(data);

          // ============================================
          // EXISTING SYNC API - DO NOT CHANGE
          // ============================================

          final payload = {
            "calls": [data],
          };

          print("🚀 ABOUT TO HIT API");
          print("🚀 Payload: $payload");

         // final response = await _dioApi.syncIncomingCall(payload);

          //print("✅ API RESPONSE: $response");

          // ============================================
          // GET PHONE NUMBER
          // ============================================

          final phoneNumber = data['phone_number']?.toString() ?? '';

          if (phoneNumber.isEmpty) {
            print("❌ Phone number is empty");
            return;
          }

          print("📱 Incoming phone number: $phoneNumber");

          // ============================================
          // GET FLUTTER CONTEXT
          // ============================================

          final context = Get.context;

          if (context == null) {
            print("❌ Flutter context is not available");
            return;
          }

          // ============================================
          // FIRST POPUP
          // ============================================

          final isWorkRelated = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text(
                  "Call Related?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  "Was this call work related?\n\n$phoneNumber",
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                    child: const Text(
                      "NO",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                    child: const Text(
                      "YES",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );

          // ============================================
          // NO → CLOSE
          // ============================================

          if (isWorkRelated != true) {
            print("❌ Call marked as NOT work related");
            return;
          }

          print("✅ Call marked as WORK RELATED");

          // ============================================
          // YES → FIND EXISTING LEAD
          // ============================================

          print("🟡 YES pressed - starting lead search");
          print("📱 Searching lead for: $phoneNumber");

          dynamic matchedLead;

          final incomingPhone = _normalizePhone(phoneNumber);

          print("📱 Normalized incoming phone: $incomingPhone");

          // ============================================
          // GET ALL LEADS PAGE BY PAGE
          // ============================================

          int page = 1;
          int totalPages = 1;

          while (page <= totalPages && matchedLead == null) {
            print("📄 Fetching leads page: $page");

            final leadsResponse = await _dioApi.getAllLeads(
              page: page,
            );

            final leads = leadsResponse.data ?? [];

            print(
              "🔎 Leads found on page $page: ${leads.length}",
            );

            // Get total pages from API response
            totalPages = leadsResponse.totalPages ?? 1;

            print("📚 Total pages: $totalPages");

            // ============================================
            // COMPARE PHONE NUMBERS
            // ============================================

            for (final lead in leads) {
              final leadPhone = _normalizePhone(
                lead.phone?.toString() ?? '',
              );

              print(
                "🔍 Comparing incoming: $incomingPhone "
                "with lead: $leadPhone",
              );

              if (incomingPhone == leadPhone) {
                matchedLead = lead;

                print(
                  "✅ MATCH FOUND: ${lead.sId}",
                );

                break;
              }
            }

            page++;
          }

          // ============================================
          // CHECK MATCHED LEAD
          // ============================================

          print("🟣 Matched lead: $matchedLead");

          if (matchedLead == null) {
            print(
              "❌ No lead found for phone number: $phoneNumber",
            );
            return;
          }

          if (matchedLead.sId == null) {
            print("❌ Matched lead does not have an ID");
            return;
          }

          print("✅ Lead matched");
          print("🆔 Lead ID: ${matchedLead.sId}");
          print(
            "📌 Stage: ${matchedLead.leadStageId?.name}",
          );

          // ============================================
          // PENDING CALL DATA
          // ============================================

          PendingCallData.data = {
            ...data,
            "lead_id": matchedLead.sId,
          };

          print(
            "💾 PendingCallData saved: ${PendingCallData.data}",
          );

          // ============================================
          // YES → EXISTING CRM POPUP
          // ============================================

          final latestContext = Get.context;

          if (latestContext == null) {
            print(
              "❌ Context unavailable for CRM popup",
            );
            return;
          }

          print("🚀 Opening existing CRM popup");

          await showDialog(
            context: latestContext,
            barrierDismissible: false,
            builder: (dialogContext) {
              return PopScope(
                canPop: false,
                child: Dialog(
                  insetPadding: const EdgeInsets.all(20),
                  child: PopupAfterCallUi(
                    leadId: matchedLead.sId!,
                    stageName: matchedLead.leadStageId?.name,
                    isIncoming: true,
                  ),
                ),
              );
            },
          );

          print(
            "✅ Existing PopupAfterCallUi closed",
          );
        } catch (e, stackTrace) {
          print(
            "❌ Incoming call processing failed: $e",
          );
          print(stackTrace);
        }
      }
    });
  }

  // ============================================
  // NORMALIZE PHONE NUMBER
  // ============================================

  static String _normalizePhone(String phone) {
    String normalized = phone.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (normalized.length > 10) {
      normalized = normalized.substring(
        normalized.length - 10,
      );
    }

    return normalized;
  }
}