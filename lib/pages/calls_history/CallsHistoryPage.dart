// import 'package:call_log/call_log.dart';
// import 'package:flutter/material.dart';
// import 'package:crm_flutter/pages/calls_history/calls_history_controller.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:get/get.dart';

// //blue theme
// class CallsHistoryPage extends StatefulWidget {
//   final String leadId;
//   const CallsHistoryPage({super.key, required this.leadId});

//   @override
//   State<CallsHistoryPage> createState() => _CallsHistoryPageState();
// }

// class _CallsHistoryPageState extends State<CallsHistoryPage> {
//   CallsHistoryController callsHistoryController = Get.put(
//     CallsHistoryController(),
//   );

//   @override
//   void initState() {
//     super.initState();
//     //callsHistoryController.checkLastCall(widget.leadId);
//     callsHistoryController.getAllCallsHistory(widget.leadId);
//     print("Leadfromcallhistory: ${widget.leadId}");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Calls History"),
//         surfaceTintColor: Colors.white,
//       ),
//       body: Obx(() {
//         final response = callsHistoryController.allCallsHistoryRes.value;

//         print("responsefromhistory: ${response.data}");

//         if (response.data == null) {
//           print("responsefromhistoryNull: ${response.data}");
//           return const Center(child: CircularProgressIndicator());
//         }

//         final callsHistoryList = response.data!.reversed.toList();

//         return ListView.builder(
//           itemCount: callsHistoryList.length,
//           itemBuilder: (context, index) {
//             final callHistory = callsHistoryList[index];
//             return Card(
//               margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//               child: ListTile(
//                 title: Row(
//                   children: [
//                     Expanded(child: Text(callHistory.toNumber ?? "No number")),
//                     SizedBox(width: 5),

//                     IconButton(
//                       onPressed: () {
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               title: Text("Delete Call Log"),
//                               content: Text(
//                                 "Are you sure you want to delete this number?",
//                               ),
//                               actions: [
//                                 TextButton(
//                                   child: Text("Cancel"),
//                                   onPressed: () => Navigator.of(context).pop(),
//                                 ),
//                                 TextButton(
//                                   child: Text("Delete"),
//                                   onPressed: () {
//                                     callsHistoryController.deleteCallLog(
//                                       callHistory.sId!,
//                                       widget.leadId,
//                                     );
//                                     Navigator.of(context).pop();
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text("Call log deleted"),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       },
//                       icon: Icon(
//                         Icons.delete,
//                         size: 16,
//                         color: Colors.redAccent,
//                       ),
//                     ),
//                   ],
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("From: ${callHistory.fromNumber ?? "Unknown number"}"),
//                     Text(
//                       "Call Direction: ${callHistory.direction ?? "No direction"}",
//                     ),
//                     Text("Duration: ${callHistory.duration ?? 0} seconds"),
//                     Text("Status: ${callHistory.disposition ?? "Unknown"}"),
//                     if (callHistory.startedAt != null)
//                       _buildDateTimeDisplay(callHistory.startedAt!),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }

//   Widget _buildDateTimeDisplay(String timestamp) {
//     try {
//       // Try parsing as milliseconds first (if it's a numeric string)
//       final milliseconds = int.tryParse(timestamp);
//       if (milliseconds != null) {
//         return Text(
//           "Time: ${DateTime.fromMillisecondsSinceEpoch(milliseconds)}",
//         );
//       }

//       // If not a numeric string, try parsing as ISO string directly
//       return Text("Time: ${DateTime.tryParse(timestamp) ?? timestamp}");
//     } catch (e) {
//       // Fallback to showing the raw string if parsing fails
//       return Text("Time: $timestamp");
//     }
//   }
// }

import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/calls_history/calls_history_controller.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

//blue theme
class CallsHistoryPage extends StatefulWidget {
  final String leadId;
  const CallsHistoryPage({super.key, required this.leadId});

  @override
  State<CallsHistoryPage> createState() => _CallsHistoryPageState();
}

class _CallsHistoryPageState extends State<CallsHistoryPage> {
  CallsHistoryController callsHistoryController = Get.put(
    CallsHistoryController(),
  );

  @override
  void initState() {
    super.initState();
    //callsHistoryController.checkLastCall(widget.leadId);
    callsHistoryController.getAllCallsHistory(widget.leadId);
    print("Leadfromcallhistory: ${widget.leadId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call History"),
        centerTitle: true,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              callsHistoryController.getAllCallsHistory(widget.leadId);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade50,
          child: Obx(() {
            final response = callsHistoryController.allCallsHistoryRes.value;

            print("responsefromhistory: ${response.data}");

            if (response.data == null) {
              print("responsefromhistoryNull: ${response.data}");
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "Loading call history...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            if (response.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_disabled,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No calls found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "No call history available for this lead",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            final callsHistoryList = response.data!.reversed.toList();

            return RefreshIndicator(
              onRefresh: () async {
                await callsHistoryController.getAllCallsHistory(widget.leadId);
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: callsHistoryList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final callHistory = callsHistoryList[index];
                  final isIncoming =
                      callHistory.direction?.toLowerCase() == 'incoming';
                  final isMissed =
                      callHistory.disposition?.toLowerCase() == 'missed';
                  final isAnswered =
                      callHistory.disposition?.toLowerCase() == 'answered' ||
                      callHistory.disposition?.toLowerCase() == 'completed';

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: _getCallTypeColor(
                                          isIncoming,
                                          isMissed,
                                          isAnswered,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getCallTypeIcon(
                                          isIncoming,
                                          isMissed,
                                          isAnswered,
                                        ),
                                        size: 18,
                                        color: _getCallTypeColor(
                                          isIncoming,
                                          isMissed,
                                          isAnswered,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            callHistory.toNumber ??
                                                "Unknown number",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (callHistory.fromNumber != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 2,
                                              ),
                                              child: Text(
                                                "From: ${callHistory.fromNumber}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _showDeleteDialog(callHistory);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: Colors.red.shade400,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Colors.red.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.more_vert,
                                    size: 20,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStatusChip(
                                icon: Icons.access_time,
                                text: "${callHistory.duration ?? 0}s",
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              _buildStatusChip(
                                icon: _getStatusIcon(callHistory.disposition),
                                text: callHistory.disposition ?? "Unknown",
                                color: _getStatusColor(callHistory.disposition),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_callback,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Direction: ${callHistory.direction ?? "No direction"}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          if (callHistory.startedAt != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _formatDateTime(callHistory.startedAt!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(dynamic callHistory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Text("Delete Call Log"),
            ],
          ),
          content: const Text(
            "Are you sure you want to delete this call log? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                callsHistoryController.deleteCallLog(
                  callHistory.sId!,
                  widget.leadId,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Call log deleted successfully"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Color _getCallTypeColor(bool isIncoming, bool isMissed, bool isAnswered) {
    if (isIncoming) {
      if (isMissed) return Colors.orange;
      if (isAnswered) return Colors.green;
      return Colors.blue;
    } else {
      // Outgoing
      if (isAnswered) return Colors.green;
      return Colors.purple;
    }
  }

  IconData _getCallTypeIcon(bool isIncoming, bool isMissed, bool isAnswered) {
    if (isIncoming) {
      if (isMissed) return Icons.call_missed;
      if (isAnswered) return Icons.call_received;
      return Icons.call;
    } else {
      // Outgoing
      if (isAnswered) return Icons.call_made;
      return Icons.call_made;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'answered':
      case 'completed':
        return Colors.green;
      case 'missed':
        return Colors.orange;
      case 'busy':
        return Colors.red;
      case 'failed':
        return Colors.redAccent;
      case 'no answer':
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getStatusIcon(String? status) {
    if (status == null) return Icons.help_outline;

    switch (status.toLowerCase()) {
      case 'answered':
      case 'completed':
        return Icons.check_circle;
      case 'missed':
        return Icons.call_missed;
      case 'busy':
        return Icons.phone_callback;
      case 'failed':
        return Icons.error_outline;
      case 'no answer':
        return Icons.phone_missed;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDateTime(String timestamp) {
    try {
      DateTime dateTime;

      // Try parsing as milliseconds first
      final milliseconds = int.tryParse(timestamp);
      if (milliseconds != null) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      } else {
        // Try parsing as ISO string
        dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final callDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      String datePrefix;
      if (callDate == today) {
        datePrefix = "Today";
      } else if (callDate == yesterday) {
        datePrefix = "Yesterday";
      } else {
        datePrefix = DateFormat('MMM d, yyyy').format(dateTime);
      }

      return "Time: $datePrefix at ${DateFormat('h:mm a').format(dateTime)}";
    } catch (e) {
      return "Time: $timestamp";
    }
  }
}
