import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/call_log_response.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:get/get.dart';
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';

class CallLogController extends GetxController {
  var callLogs = <CallLogEntry>[].obs;
  var isLoading = true.obs;

  Rx<CallLogsResponse> callLogsResponse = CallLogsResponse().obs;
  Rx<PageState> callApiState = PageState.loading.obs;

  Future getApi() async {
    try {
      callApiState.value = PageState.loading;
      await Future.delayed(Duration(seconds: 1));
      final response = await DioApi().getAllCallApi();
      //SORT BY DATE (latest first)
      response.data?.sort((a, b) {
        if (a.startedAt == null || b.startedAt == null) return 0;

        final dateA = DateTime.parse(a.startedAt!).toLocal();
        final dateB = DateTime.parse(b.startedAt!).toLocal();

        return dateB.compareTo(
          dateA,
        ); // (now)newest on top -> dateA /// for oldest on top -> use dateB
      });
      callLogsResponse.value = response;
      callApiState.value = PageState.stable;
    } catch (e) {
      callApiState.value = PageState.error;
      print(e);
    }
  }

  Future<void> fetchCallLogs() async {
    try {
      isLoading(true);

      // Check and request permission
      if (await Permission.phone.request().isGranted) {
        // Get call logs
        Iterable<CallLogEntry> entries = await CallLog.get();
        callLogs.assignAll(entries);
        print('Name: ${callLogs[0].name}');
        print('Number: ${callLogs[0].number}');
        print('Formatted Number: ${callLogs[0].formattedNumber}');
        print('Call Type: ${callLogs[0].callType}');
        print('Duration: ${callLogs[0].duration}');
        print('Timestamp: ${callLogs[0].timestamp}');
        print('Cached Number Type: ${callLogs[0].cachedNumberType}');
        print('Cached Number Label: ${callLogs[0].cachedNumberLabel}');
        print('SIM Display Name: ${callLogs[0].simDisplayName}');
        print('Phone Account ID: ${callLogs[0].phoneAccountId}');
        print('ID: ${callLogs[0].id}');
      } else {
        Get.snackbar(
          'Permission denied',
          'Cannot access call logs without permission',
        );
      }
    } finally {
      isLoading(false);
    }
  }
}
