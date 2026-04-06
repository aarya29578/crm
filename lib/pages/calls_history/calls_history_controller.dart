import 'package:call_log/call_log.dart';
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_calls_history_response.dart';
import 'package:get/get.dart';

class CallsHistoryController extends GetxController {
  Rx<AllCallHistoryResponse> allCallsHistoryRes = AllCallHistoryResponse().obs;

  Future getAllCallsHistory(idLead) async {
    try {
      final response = await DioApi().getAllCallsHistory(idLead);
      print("CallsHistoryController:$response");
      if (response.success == true) {
        allCallsHistoryRes.value = response;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> createCallHistory(req) async {
    try {
      var data = req;
      print(data);
      final response = await DioApi().createCallHistory(data);
      print(response);
      if (response.success == true) {
        Get.back();
        await getAllCallsHistory(null);
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> checkLastCall(leadId) async {
    final lastCall = await getLastDialedCall();

    if (lastCall != null) {
      print("Last call was from: ${lastCall.number}");
      print("Call type: ${lastCall.callType}");
      print("Duration: ${lastCall.duration} seconds");
      print(
        "Time: ${DateTime.fromMillisecondsSinceEpoch(lastCall.timestamp!)}",
      );

      //3. Prepare data for API
      final Map<String, dynamic> callData = {
        "lead_id": leadId,
        "to_number": lastCall.number ?? "Unknown number",
        "from_number": '9004364838',
        "duration": lastCall.duration ?? 0,
        "direction": lastCall.callType == CallType.outgoing
            ? "outbound"
            : lastCall.callType == CallType.incoming
            ? "inbound"
            : "Unknown",
        "started_at": lastCall.timestamp ?? 0,
        "ended_at": lastCall.timestamp ?? 0,
        "recording_url": "https://google.com/",
        "disposition": lastCall.callType == CallType.answeredExternally
            ? "answered"
            : lastCall.callType == CallType.rejected
            ? "busy"
            : lastCall.callType == CallType.missed
            ? "no answer"
            : lastCall.callType == CallType.incoming
            ? "interested"
            : "unknown", //answered, no answer, busy, interested
        "status": lastCall.callType == CallType.missed
            ? "missed"
            : lastCall.callType == CallType.rejected
            ? "failed"
            : lastCall.callType == CallType.outgoing
            ? "completed"
            : "unknown", //completed, failed, missed
      };

      await createCallHistory(callData);
    } else {
      print("No call logs found.");
    }
  }

  Future<CallLogEntry?> getLastDialedCall() async {
    await CallLog.get();

    // Get all call logs
    final Iterable<CallLogEntry> callLogs = await CallLog.get();
    //print(callLogs);

    //Filter to only outgoing or wifiOutgoing calls
    final List<CallLogEntry> outgoingCalls = callLogs.where((log) {
      return log.callType == CallType.outgoing ||
          log.callType == CallType.wifiOutgoing;
    }).toList();

    if (outgoingCalls.isEmpty) {
      return null; // No outgoing calls found
    }

    // Sort by timestamp descending (most recent first)
    outgoingCalls.sort(
      (a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0),
    );

    // Return the most recent outgoing call
    print(outgoingCalls.first);
    return outgoingCalls.first;
  }

  Future<CallLogEntry?> getLastCallLog() async {
    final Iterable<CallLogEntry> callLogs = await CallLog.get();

    if (callLogs.isEmpty) {
      return null; // No call logs available
    }

    // Sort logs by timestamp (newest first) and pick the first one
    final lastCall = callLogs.toList()
      ..sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));
    print(lastCall.first);
    return lastCall.first;
  }

  Future deleteCallLog(String callId, String? idLead) async {
    try {
      final response = await DioApi().deleteCallLog(callId);
      if (response['success'] == true) {
        await getAllCallsHistory(idLead);
      }
    } catch (e) {
      throw (e);
    }
  }
}
