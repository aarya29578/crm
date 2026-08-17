import 'package:call_log/call_log.dart';
import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/widgets/show_call_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsPage.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:get/get.dart';
import 'package:phone_state/phone_state.dart';

class LeadDetailsBottomNavigationBarPage extends StatefulWidget {
  final String LeadID;
  const LeadDetailsBottomNavigationBarPage({super.key, required this.LeadID});

  @override
  State<LeadDetailsBottomNavigationBarPage> createState() =>
      _LeadDetailsBottomNavigationBarPageState();
}

class _LeadDetailsBottomNavigationBarPageState
    extends State<LeadDetailsBottomNavigationBarPage> {
  final Leaddetailscontroller leadDetailsController = Get.put(
    Leaddetailscontroller(),
  );
  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  bool callStarted = false;
  String? lastCallNumber;
  String? lastCallType;
  String? lastCallDuration;
  String? lastCallTime;
  @override
  void initState() {
    leadDetailsController.requestPermissions();

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
      }
        });
    super.initState();
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
      print("ToNumberfromdetailnav:${recent.number}");
      final Map<String, dynamic> callData = {
        "lead_id": widget.LeadID,
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
      leadDetailsController.createCall(callData);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("LEADIDFROMNAVI: ${widget.LeadID}");
    return Scaffold(
      body: LeadDetailsPage(leadId: widget.LeadID), // Only one main screen
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(
            top: 5,
            left: 15,
            right: 15,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 2.0,
                spreadRadius: 0.5,
                offset: Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Expanded(
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Get.to(CallsHistoryPage(leadId: widget.LeadID));
              //     },
              //     style: ElevatedButton.styleFrom(
              //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              //       backgroundColor: ColorConstants.MainPurpleBackground,
              //       foregroundColor: Colors.white,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(Icons.message),
              //         SizedBox(width: 5),
              //         Text("Call History", style: TextStyle(fontSize: 16)),
              //       ],
              //     ),
              //   ),
              // ),
              // SizedBox(width: 12),
              Expanded(
                child: // In LeadDetailsBottomNavigationBarPage
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final response =
                          leadDetailsController.allLeadDetailRes.value;

                      // Get phone number with proper null safety
                      // final person_no =
                      //     response.data?.personId?.contactNumbers?.firstWhere(
                      //       (number) => number != null && number.isNotEmpty,
                      //       orElse: () => "9998979695",
                      //     ) ??
                      //     "9998979695";
                      Iterable<CallLogEntry> entries = await CallLog.get();

                      final recent = entries.isNotEmpty ? entries.first : null;

                      final exactNumber = leadDetailsController
                          .allLeadDetailRes
                          .value
                          .data
                          ?.phone;
                      final exactLeadId = leadDetailsController
                          .allLeadDetailRes
                          .value
                          .data
                          ?.phone;

                      // Prepare call data before making the call
                      final callData = {
                        "lead_id": widget.LeadID,
                        "to_number": exactNumber ?? "Unknown number",
                        "from_number": '9004364838',
                        "direction": "outbound",
                        "status": "initiated",
                        "started_at": DateTime.now().millisecondsSinceEpoch,
                      };

                      // Make the call
                      // await leadDetailsController.makePhoneCall(person_no);

                      // Update call data after call completes
                      final updatedCallData = {
                        ...callData,
                        "status": "completed",
                        "ended_at": DateTime.now().millisecondsSinceEpoch,
                        // Duration will be updated after we fetch call log
                      };

                      // Fetch call log after a delay to ensure call is recorded
                      // Future.delayed(Duration(seconds: 2), () async {
                      //   await fetchLatestCallLog();
                      //   await leadDetailsController.createCall(updatedCallData);
                      //   // if (recent.number != null)
                      //   if (!context.mounted) return;
                      //   if (exactNumber != null) {
                      //     showCallAlertDialog(
                      //       context,
                      //       'Call',
                      //       'Are you sure want to call to ${exactNumber} number?',
                      //       () async {
                      //         await CallHelper.callAndTrack(
                      //           exactNumber.toString(),
                      //         );
                      //         // Navigator.pop(context);
                      //       },
                      //       Colors.blue,
                      //     );
                      //     // await CallHelper.callAndTrack(recent.number!);
                      //     print("callingg***********");
                      //   } else {
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(content: Text("No number found!")),
                      //     );
                      //     Get.snackbar("Error", "Failed to make call");
                      //     print("Number not found from user detail product");
                      //   }
                      // });

                      if (!context.mounted) return;
                      if (exactNumber != null) {
                        showCallAlertDialog(
                          context,
                          'Call',
                          'Are you sure want to call to $exactNumber number?',
                          () async {
                            await CallHelper.callAndTrack(
                              exactNumber.toString(),
                              widget.LeadID,
                              '',
                            );
                            // Navigator.pop(context);
                          },
                          Colors.blue,
                        );
                        // await CallHelper.callAndTrack(recent.number!);
                        print("callingg***********");
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("No number found!")),
                        );
                      }
                    } catch (e) {
                      print("Error making call: $e");
                      Get.snackbar(
                        "Error",
                        "Failed to make call: ${e.toString()}",
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    backgroundColor: ColorConstants.MainPurpleBackground,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call),
                      SizedBox(width: 5),
                      Text("Call", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
