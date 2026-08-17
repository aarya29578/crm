import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/Patham/PrathamController.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:phone_state/phone_state.dart';
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';

class PrathamPage extends StatefulWidget {
  final String phoneNumber;
  final String leadId;

  const PrathamPage({super.key, required this.phoneNumber, required this.leadId});

  @override
  _PrathamPageState createState() => _PrathamPageState();
}

class _PrathamPageState extends State<PrathamPage> {
  PrathamController controller = Get.put(PrathamController());
  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  bool callStarted = false;

  String? lastCallNumber;
  String? lastCallType;
  String? lastCallDuration;
  String? lastCallTime;

  @override
  void initState() {
    super.initState();
    requestPermissions();

    PhoneState.stream.listen((event) async {
      setState(() {
        status = event.status;
      });

      if (event.status == PhoneStateStatus.CALL_STARTED) {
        callStarted = true;
      }

      if (event.status == PhoneStateStatus.CALL_ENDED && callStarted) {
        callStarted = false;
        await Future.delayed(Duration(seconds: 1));
        fetchLatestCallLog();
      }
        });
  }

  Future<void> requestPermissions() async {
    await Permission.phone.request();
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  Future<void> fetchLatestCallLog() async {
    Iterable<CallLogEntry> entries = await CallLog.get();

    if (entries.isNotEmpty) {
      final recent = entries.first;

      setState(() {
        lastCallNumber = recent.number;
        lastCallType = recent.callType.toString();
        lastCallDuration = '${recent.duration} seconds';
        lastCallTime = DateTime.fromMillisecondsSinceEpoch(
          recent.timestamp ?? 0,
        ).toString();
      });
      final Map<String, dynamic> callData = {
        "lead_id": widget.leadId,
        "to_number": recent.number ?? "Unknown number",
        "from_number": '9004364838',
        "duration": recent.duration ?? 0,
        "direction": recent.callType == CallType.outgoing
            ? "outbound"
            : recent.callType == CallType.incoming
            ? "inbound"
            : "Unknown",
        "started_at": recent.timestamp ?? 0,
        "ended_at": recent.timestamp ?? 0,
        "recording_url": "https://google.com/",
        "disposition": recent.callType == CallType.answeredExternally
            ? "answered"
            : recent.callType == CallType.rejected
            ? "busy"
            : recent.callType == CallType.missed
            ? "no answer"
            : recent.callType == CallType.incoming
            ? "interested"
            : "unknown", // answered, no answer, busy, interested
        "status": recent.callType == CallType.missed
            ? "missed"
            : recent.callType == CallType.rejected
            ? "failed"
            : recent.callType == CallType.outgoing
            ? "completed"
            : "unknown", // completed, failed, missed
      };
      controller.createCall(callData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Call Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => makePhoneCall(widget.phoneNumber),
              child: Text('Call ${widget.phoneNumber}'),
            ),
            SizedBox(height: 30),
            Text(
              '📞 Last Call Info:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (lastCallNumber != null) ...[
              SizedBox(height: 10),
              Text("👤 Number: $lastCallNumber"),
              Text("📞 Type: $lastCallType"),
              Text("⏱ Duration: $lastCallDuration"),
              Text("🕒 Time: $lastCallTime"),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text("No call log fetched yet."),
              ),
          ],
        ),
      ),
    );
  }
}
