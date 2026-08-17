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

import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/calls_history/calls_history_controller.dart';
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

            final callsHistoryList = response.data!;

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
                  final callGroup = callsHistoryList[index];
                  final lead = callGroup.lead;
                  final leadName = (lead?.name?.first != null || lead?.name?.last != null)
                      ? "${lead?.name?.first ?? ""} ${lead?.name?.last ?? ""}".trim()
                      : (lead != null ? "Unnamed Lead" : "External Contact");
                  final phone = lead?.phone?.toString() ?? "No Contact Number";
                  final priority = lead?.priority ?? "Normal";
                  final agentName = callGroup.calledBy?.name ?? "Unknown Agent";
                  
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
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.history,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            leadName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            phone,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade700,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${callGroup.callCount ?? 0} Calls",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Text(
                                        callGroup.date ?? "Unknown Date",
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Last: ${_formatLastCallAt(callGroup.lastCallAt)}",
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (priority.isNotEmpty)
                                _buildStatusChip(
                                  icon: Icons.star_outline,
                                  text: priority,
                                  color: _getPriorityColor(priority),
                                ),
                            ],
                          ),
                          if (lead?.leadStage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _parseColor(lead?.leadStage?.color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                lead?.leadStage?.name ?? "",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _parseColor(lead?.leadStage?.color),
                                ),
                              ),
                            ),
                          ],
                          const Divider(height: 16),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                "Agent: $agentName",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
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

  String _formatLastCallAt(String? lastCallAt) {
    if (lastCallAt == null) return "Never";
    try {
      DateTime dateTime = DateTime.parse(lastCallAt);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return lastCallAt;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'hot':
      case 'very hot':
        return Colors.red;
      case 'warm':
        return Colors.orange;
      case 'cold':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null || !colorStr.startsWith('#')) return Colors.blue;
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}
