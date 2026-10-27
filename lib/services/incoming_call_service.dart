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

  static void _log(String event) {
    debugPrint(
      '[incoming-call] ${DateTime.now().toIso8601String()} event=$event',
    );
  }

  static void initialize() {
    _log('initialized');

    _channel.setMethodCallHandler((call) async {
      _log('method_channel_event_${call.method}');

      if (call.method == 'incomingCallEnded') {
        try {
          final data = Map<String, dynamic>.from(call.arguments);

          _log('incoming_call_received');

          // ============================================
          // EXISTING SYNC API - DO NOT CHANGE
          // ============================================

          _log('incoming_call_payload_prepared');

          // final response = await _dioApi.syncIncomingCall(payload);

          //print("✅ API RESPONSE: $response");

          // ============================================
          // GET PHONE NUMBER
          // ============================================

          final phoneNumber = data['phone_number']?.toString() ?? '';

          if (phoneNumber.isEmpty) {
            _log('incoming_phone_number_missing');
            return;
          }

          _log('incoming_phone_number_available');

          // ============================================
          // GET FLUTTER CONTEXT
          // ============================================

          final context = Get.context;

          if (context == null) {
            _log('flutter_context_unavailable');
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  "Was this call work related?\n\n$phoneNumber",
                  style: const TextStyle(fontSize: 15),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
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
            _log('call_marked_not_work_related');
            return;
          }

          _log('call_marked_work_related');

          // ============================================
          // YES → FIND EXISTING LEAD
          // ============================================

          _log('lead_search_started');

          dynamic matchedLead;

          final incomingPhone = _normalizePhone(phoneNumber);

          // ============================================
          // GET ALL LEADS PAGE BY PAGE
          // ============================================

          int page = 1;
          int totalPages = 1;

          while (page <= totalPages && matchedLead == null) {
            _log('lead_search_page_requested');

            final leadsResponse = await _dioApi.getAllLeads(page: page);

            final leads = leadsResponse.data ?? [];

            _log('lead_search_page_received');

            // Get total pages from API response
            totalPages = leadsResponse.totalPages ?? 1;

            // ============================================
            // COMPARE PHONE NUMBERS
            // ============================================

            for (final lead in leads) {
              final leadPhone = _normalizePhone(lead.phone?.toString() ?? '');

              if (incomingPhone == leadPhone) {
                matchedLead = lead;
                _log('lead_match_found');

                break;
              }
            }

            page++;
          }

          // ============================================
          // CHECK MATCHED LEAD
          // ============================================

          if (matchedLead == null) {
            _log('lead_match_not_found');

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("This number is not in the leads."),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            return;
          }

          if (matchedLead.sId == null) {
            _log('matched_lead_id_missing');
            return;
          }

          _log('lead_match_confirmed');

          // ============================================
          // PENDING CALL DATA
          // ============================================

          PendingCallData.data = {...data, "lead_id": matchedLead.sId};
          PendingCallData.outboundSessionId = null;

          _log('incoming_call_data_staged');

          // ============================================
          // YES → EXISTING CRM POPUP
          // ============================================

          final latestContext = Get.context;

          if (latestContext == null) {
            _log('crm_popup_context_unavailable');
            return;
          }

          _log('crm_popup_opening');

          await showDialog(
            context: latestContext,
            barrierDismissible: false,
            builder: (dialogContext) {
              return Dialog(
                insetPadding: const EdgeInsets.all(20),
                child: PopupAfterCallUi(
                  leadId: matchedLead.sId!,
                  stageName: matchedLead.leadStageId?.name,
                  isIncoming: true,
                ),
              );
            },
          );

          _log('crm_popup_closed');
        } catch (e) {
          _log('incoming_call_processing_failed_${e.runtimeType}');
        }
      }
    });
  }

  // ============================================
  // NORMALIZE PHONE NUMBER
  // ============================================

  static String _normalizePhone(String phone) {
    String normalized = phone.replaceAll(RegExp(r'\D'), '');

    if (normalized.length > 10) {
      normalized = normalized.substring(normalized.length - 10);
    }

    return normalized;
  }
}
