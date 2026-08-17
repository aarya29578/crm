import 'dart:async';
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/common_widgets/popup_after_call_ui.dart';
import 'package:crm_flutter/common_widgets/call_storage.dart';
import 'package:crm_flutter/helper/bottom_sheet_helper.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:call_log/call_log.dart';

class CallHelper {
  static bool _startApiSent = false;

  static StreamSubscription<PhoneState>? _subscription;
  static bool _isCallInProgress = false;

  /// Initiates a phone call and tracks it until completion.
  static Future<void> callAndTrack(
    String number,
    String? leadId,
    String? stageName,
  ) async {
    _isCallInProgress = false;
    _startApiSent = false; // IMPORTANT

    // ✅ Request permissions
    await _requestPermissions();

    // Reset state
    _isCallInProgress = false;
    // ✅ Start listening to phone state before the call
    _subscription = PhoneState.stream.listen((event) async {
      print("📞 Phone State: ${event.status}");

      switch (event.status) {
        case PhoneStateStatus.CALL_INCOMING:
          _isCallInProgress = true;
          break;
        // case PhoneStateStatus.CALL_STARTED:
        //   // _isCallInProgress = true;
        //   // print("📞 Call started/connected");
        //   // await DioApi().startPostPhoneCall();
        //   // break;
        //   _isCallInProgress = true;
        //   print("📞 Call started/connected");

        //   try {
        //     await DioApi().startPostPhoneCall(); // ✅ API HIT
        //     print("✅ Start call API sent");
        //   } catch (e) {
        //     print("❌ Start call API failed: $e");
        //   }
        //   break;
        case PhoneStateStatus.CALL_STARTED:
          if (_startApiSent) return; // ✅ STOP DUPLICATES

          _startApiSent = true;
          _isCallInProgress = true;

          print("📞 Call started/connected");

          try {
            await DioApi().startPostPhoneCall();
            print("✅ Start call API sent");
          } catch (e) {
            print("❌ Start call API failed: $e");
          }
          break;

        // case PhoneStateStatus.CALL_ENDED:
        //   if (_isCallInProgress) {
        //     print("✅ Call ended. Fetching call log...");
        //     _isCallInProgress = false;

        //     // Wait for system to update call logs
        //     await Future.delayed(const Duration(seconds: 3));

        //     try {
        //       // ✅ Show Bottom Sheet
        //       final context = AppNavigator.key.currentContext;
        //       // if (context != null) {
        //       //   showModalBottomSheet(
        //       //     context: context,
        //       //     isDismissible: false, // ❌ Disable outside tap
        //       //     enableDrag: false, // ❌ Disable swipe down
        //       //     isScrollControlled: true, //for full screen
        //       //     builder: (context) {
        //       //       return BottomSheetUi();
        //       //     },
        //       //   );
        //       // }

        //       if (context != null) {
        //         showDialog(
        //           context: context,
        //           barrierDismissible: false, // ❌ Disable outside tap
        //           builder: (context) {
        //             return Dialog(
        //               insetPadding: EdgeInsets.all(
        //                 20,
        //               ), // spacing from screen edges
        //               child: BottomSheetUi(), // ✅ Reuse same widget
        //             );
        //           },
        //         );
        //       }

        //       var now = DateTime.now();
        //       int from = now
        //           .subtract(Duration(hours: 1))
        //           .millisecondsSinceEpoch;
        //       int to = now.millisecondsSinceEpoch;
        //       final Iterable<CallLogEntry> entries = await CallLog.query(
        //         number: number,
        //         dateFrom: from,
        //         dateTo: to,
        //       );

        //       if (entries.isNotEmpty) {
        //         // Get the most recent call log for this number

        //         ;

        //         final log = entries.first;

        //         print("📋 Call Log Found:");

        //         print("Number: ${log.number}");
        //         print("Duration: ${log.duration} seconds");
        //         print(
        //           "Timestamp: ${DateTime.fromMillisecondsSinceEpoch(log.timestamp ?? 0)}",
        //         );
        //         print("Call Type: ${log.callType}");
        //         //
        //         print('Name: ${log.name}');
        //         print('Number: ${log.number}');

        //         print('Formatted Number: ${log.formattedNumber}');
        //         print('Call Type: ${log.callType}');
        //         print('Duration: ${log.duration}');
        //         print('Timestamp: ${log.timestamp}');
        //         print('Cached Number Type: ${log.cachedNumberType}');
        //         print('Cached Number Label: ${log.cachedNumberLabel}');
        //         print('SIM Display Name: ${log.simDisplayName}');
        //         print('Phone Account ID: ${log.phoneAccountId}');
        //         print('ID: ${log.id}');
        //         final int timestampMilliseconds = log.timestamp ?? 0;
        //         final DateTime callStartTime =
        //             DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);
        //         final int durationSeconds = log?.duration ?? 0;
        //         final DateTime endedAt = callStartTime.add(
        //           Duration(seconds: durationSeconds),
        //         );
        //         //

        //         String status;
        //         String disposition;

        //         // Logic to determine status and disposition
        //         switch (log.callType) {
        //           case CallType.incoming:
        //           case CallType.wifiIncoming:
        //             // If incoming call has a duration, it was answered/completed
        //             if (log.duration! > 0) {
        //               status = 'completed';
        //               disposition = 'answered';
        //             } else {
        //               // If duration is 0, it was missed/not answered
        //               status = 'missed';
        //               disposition = 'no answer';
        //             }
        //             break;

        //           case CallType.outgoing:
        //           case CallType.wifiOutgoing:
        //             // If outgoing call has a duration, it was connected/completed
        //             if (log.duration! > 0) {
        //               status = 'completed';
        //               disposition = 'connected';
        //             } else {
        //               // If duration is 0, it likely failed or wasn't answered
        //               status = 'failed';
        //               disposition =
        //                   'not connected'; // Use 'not connected' or 'no answer'
        //             }
        //             break;

        //           case CallType.missed:
        //             status = 'missed';
        //             disposition = 'no answer';
        //             break;

        //           case CallType.rejected:
        //             status =
        //                 'missed'; // Treat as missed since the call didn't complete
        //             disposition = 'rejected';
        //             break;

        //           case CallType.answeredExternally:
        //             status = 'completed';
        //             disposition = 'answered externally';
        //             break;

        //           case CallType.blocked:
        //             status = 'failed';
        //             disposition = 'blocked';
        //             break;

        //           case CallType.voiceMail:
        //             status = 'failed';
        //             disposition = 'voicemail';
        //             break;

        //           case CallType.unknown:
        //           default:
        //             status = 'failed';
        //             disposition = 'unknown';
        //             break;
        //         }
        //         // Send data to API
        //         final data = {
        //           "to_number": log.number,
        //           "from_number":
        //               LocalStorage.sharedPreferences!.getInt('phone_number') ??
        //               "no number found",
        //           "direction": "outbound",
        //           "duration": log.duration,
        //           "recording_url": "",
        //           "status": status,
        //           "userStatus": "idle",
        //           // "lead_stage_id":,
        //           "disposition": disposition,
        //           "started_at": callStartTime.toIso8601String(),
        //           "ended_at": endedAt.toIso8601String(),
        //         };

        //         print('num1: ${log.formattedNumber}');
        //         print('num2: ${log.cachedNumberType}');
        //         print('num3: ${log.cachedNumberLabel}');

        //         // await DioApi().postPhoneCall(data);
        //         PendingCallData.data = data;

        //         print("✅ DATA STORED: ${PendingCallData.data}");
        //         print("✅ Call data stored. Waiting for user action.");
        //         print("Call details sent to server successfully.");
        //       } else {
        //         print("No call log found for $number");

        //         // Fallback: Send basic call data even if log isn't found
        //         final data = {
        //           "number": number,
        //           "duration": 0,
        //           "timestamp": DateTime.now().millisecondsSinceEpoch,
        //           "callType": "OUTGOING",
        //           "userStatus": "idle",
        //           "note": "Call log not found",
        //         };
        //         // await DioApi().postPhoneCall(data);
        //         PendingCallData.data = data;
        //         print("✅ DATA STORED: ${PendingCallData.data}");
        //         print("✅ Call data stored. Waiting for user action.");
        //       }
        //     } catch (e) {
        //       print("Error fetching call log: $e");

        //       // Fallback on error
        //       final data = {
        //         "number": number,
        //         "duration": 0,
        //         "timestamp": DateTime.now().millisecondsSinceEpoch,
        //         "callType": "OUTGOING",
        //         "userStatus": "idle",
        //         "note": "Error: $e",
        //       };
        //       // await DioApi().postPhoneCall(data);
        //       PendingCallData.data = data;
        //       print("✅ DATA STORED: ${PendingCallData.data}");
        //       print("✅ Call data stored. Waiting for user action.");
        //     }

        //     // Stop listening after call ends
        //     await _subscription?.cancel();
        //     _subscription = null;
        //   }
        //   break;

        case PhoneStateStatus.CALL_ENDED:
          if (!_isCallInProgress) return; // ✅ Prevent duplicate triggers

          print("✅ Call ended. Fetching call log...");

          _isCallInProgress = false;

          await Future.delayed(const Duration(seconds: 3));

          try {
            var now = DateTime.now();
            int from = now.subtract(Duration(hours: 1)).millisecondsSinceEpoch;
            int to = now.millisecondsSinceEpoch;

            final Iterable<CallLogEntry> entries = await CallLog.query(
              number: number,
              dateFrom: from,
              dateTo: to,
            );

            Map<String, dynamic> data;

            if (entries.isNotEmpty) {
              final log = entries.first;

              final int timestampMilliseconds = log.timestamp ?? 0;
              final DateTime callStartTime =
                  DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

              final int durationSeconds = log.duration ?? 0;
              final DateTime endedAt = callStartTime.add(
                Duration(seconds: durationSeconds),
              );

              String status;
              String disposition;

              switch (log.callType) {
                case CallType.outgoing:
                case CallType.wifiOutgoing:
                  if (log.duration! > 0) {
                    status = 'completed';
                    disposition = 'connected';
                  } else {
                    status = 'failed';
                    disposition = 'not connected';
                  }
                  break;

                case CallType.incoming:
                case CallType.wifiIncoming:
                  if (log.duration! > 0) {
                    status = 'completed';
                    disposition = 'answered';
                  } else {
                    status = 'missed';
                    disposition = 'no answer';
                  }
                  break;

                default:
                  status = 'failed';
                  disposition = 'unknown';
              }

              data = {
                "lead_id": leadId,
                "to_number": log.number,
                "from_number":
                    LocalStorage.sharedPreferences!.getInt('phone_number') ??
                    "no number found",
                "direction": "outbound",
                "duration": log.duration,
                "recording_url": "",
                "status": status,
                "userStatus": "idle",
                "disposition": disposition,
                "started_at": callStartTime.toIso8601String(),
                "ended_at": endedAt.toIso8601String(),
              };
            } else {
              print("No call log found");

              data = {
                "lead_id": leadId,
                "number": number,
                "duration": 0,
                "timestamp": DateTime.now().millisecondsSinceEpoch,
                "callType": "OUTGOING",
                "userStatus": "idle",
                "note": "Call log not found",
              };
            }

            /// ✅ STORE DATA FIRST 🔥
            PendingCallData.data = data;

            print("✅ DATA STORED: ${PendingCallData.data}");

            /// ✅ SHOW DIALOG AFTER DATA EXISTS 🔥
            final context = AppNavigator.key.currentContext;

            if (context != null) {
              // showDialog(
              //   context: context,
              //   barrierDismissible: false,
              //   builder: (context) {
              //     onWillPop:
              //     () async => false;
              //     return Dialog(
              //       insetPadding: EdgeInsets.all(20),
              //       child: BottomSheetUi(),
              //     );
              //   },
              // );
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return PopScope(
                    canPop: false, //  BLOCK BACK BUTTON
                    child: Dialog(
                      insetPadding: EdgeInsets.all(20),
                      child: PopupAfterCallUi(
                        leadId: leadId!,
                        stageName: stageName,
                      ),
                    ),
                  );
                },
              );
            }
          } catch (e) {
            print("Error fetching call log: $e");

            PendingCallData.data = {
              "lead_id": leadId,
              "number": number,
              "duration": 0,
              "timestamp": DateTime.now().millisecondsSinceEpoch,
              "callType": "OUTGOING",
              "userStatus": "idle",
              "note": "Error: $e",
            };

            print("✅ FALLBACK DATA STORED");
          }

          await _subscription?.cancel();
          _subscription = null;

          break;

        default:
          break;
      }
    });

    // Initiate call
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
    print("Call initiated: $res");
  }

  /// Requests necessary permissions for calling and call log access
  static Future<void> _requestPermissions() async {
    // Request all permissions at once
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.contacts,
    ].request();

    // Check if all permissions are granted
    if (statuses[Permission.phone] != PermissionStatus.granted ||
        statuses[Permission.contacts] != PermissionStatus.granted) {
      throw Exception("Required permissions not granted");
    }
  }

  /// Disposes of the phone state listener
  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _isCallInProgress = false;
  }
}
