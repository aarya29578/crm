// import 'package:call_log/call_log.dart';
// import 'package:crm_flutter/models/enums.dart';
// import 'package:crm_flutter/styles/color_palette.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:crm_flutter/pages/Call/call_controller.dart';

// class CallLogs extends StatefulWidget {
//   const CallLogs({super.key});
//   @override
//   State<CallLogs> createState() => _CallLogsState();
// }
// class _CallLogsState extends State<CallLogs> {
//   final CallLogController controller = Get.put(CallLogController());
//   @override
//   void initState() {
//     controller.getApi();
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('sCall Logs', style: TextStyle(color: Colors.white)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: controller.getApi,
//           ),
//         ],
//         backgroundColor: ColorConstants.MainPurpleBackground,
//       ),
//       body: SafeArea(
//         child: Obx(() {
//           if (controller.callApiState.value == PageState.loading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (controller.callLogsResponse.value.data?.isEmpty ?? true) {
//             return const Center(child: Text('No call logs found'));
//           }
//           return Container(
//             color: ColorConstants.MainPurpleBackground.withValues(alpha: 0.06),
//             child: ListView.builder(
//               itemCount: controller.callLogsResponse.value.data?.length ?? 0,
//               itemBuilder: (context, index) {
//                 final log = controller.callLogsResponse.value.data![index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 6,
//                   ),
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 10,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Header row with call type icon and basic info
//                         Row(
//                           children: [
//                             // Call type icon
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: _getCallTypeColor(CallType.incoming),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Icon(
//                                 _getCallTypeIcon(log.direction.toString()),
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             // Name/Number and time
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     '${log.leadId?.name?.first} ${log.leadId?.name?.last}',
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   if (log.startedAt != null)
//                                     Text(
//                                       formatDateTime(log.startedAt.toString()),
//                                       style: TextStyle(
//                                         color: Colors.grey[600],
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                             // Duration
//                             Text(
//                               log.duration != null
//                                   ? '${log.duration} sec'
//                                   : '--',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         // Detailed information section
//                         _buildDetailRow(
//                           Icons.directions,
//                           'Direction',
//                           log.direction ?? 'Unknown',
//                         ),
//                         _buildDetailRow(
//                           Icons.call_made_rounded,
//                           'From',
//                           log.fromNumber ?? 'Unknown',
//                         ),
//                         _buildDetailRow(
//                           Icons.call_received,
//                           'To',
//                           log.toNumber ?? 'Unknown',
//                         ),
//                         _buildDetailRow(
//                           Icons.timer,
//                           'Duration',
//                           '${log.duration ?? 0} sec',
//                         ),
//                         _buildDetailRow(
//                           Icons.check_circle,
//                           'Status',
//                           log.status ?? 'Unknown',
//                         ),
//                         _buildDetailRow(
//                           Icons.play_arrow,
//                           'Started At',
//                           formatDateTime(log.startedAt ?? ''),
//                         ),
//                         _buildDetailRow(
//                           Icons.stop,
//                           'Ended At',
//                           formatDateTime(log.endedAt ?? ''),
//                         ),
//                         // Lead details
//                         if (log.leadId != null) ...[
//                           const SizedBox(height: 10),
//                           if (log.leadId!.email != null)
//                             _buildDetailRow(
//                               Icons.email,
//                               'Email',
//                               log.leadId!.email!,
//                             ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         }),
//       ),
//     );
//   }
//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Colors.blueGrey),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(color: Colors.grey[600], fontSize: 13),
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }
//   String _formatDateTime(int timestamp) {
//     final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
//     return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//   }
//   String formatDateTime(String timestamp) {
//     final date = DateTime.parse(
//       timestamp,
//     ).toLocal(); // Parse ISO string & convert to local time
//     return '${date.day}/${date.month}/${date.year} '
//         '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//   }
//   IconData _getCallTypeIcon(String? direction) {
//     if (direction == null) return Icons.call;
//     switch (direction) {
//       case 'incoming':
//         return Icons.call_received;
//       case 'outgoing':
//         return Icons.call_made;
//       default:
//         return Icons.call;
//     }
//   }
//   Color _getCallTypeColor(CallType? type) {
//     if (type == null) return Colors.grey;
//     switch (type) {
//       default:
//         return Colors.grey;
//     }
//   }
//   String _getCallTypeText(CallType type) {
//     switch (type) {
//       case CallType.incoming:
//         return 'Incoming';
//       case CallType.outgoing:
//         return 'Outgoing';
//       case CallType.missed:
//         return 'Missed';
//       case CallType.voiceMail:
//         return 'Voicemail';
//       case CallType.rejected:
//         return 'Rejected';
//       case CallType.blocked:
//         return 'Blocked';
//       case CallType.answeredExternally:
//         return 'Answered Externally';
//       case CallType.wifiIncoming:
//         return 'WiFi Incoming';
//       case CallType.wifiOutgoing:
//         return 'WiFi Outgoing';
//       default:
//         return 'Unknown';
//     }
//   }
// }

import 'package:call_log/call_log.dart';
import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/widgets/show_call_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_flutter/pages/Call/call_controller.dart';
import 'package:intl/intl.dart';

class CallLogs extends StatefulWidget {
  const CallLogs({super.key});

  @override
  State<CallLogs> createState() => _CallLogsState();
}

class _CallLogsState extends State<CallLogs> {
  final CallLogController controller = Get.put(CallLogController());

  @override
  void initState() {
    controller.getApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Call Logs',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.search, color: Colors.white),
          //   onPressed: () => _showSearchDialog(),
          // ),
          // IconButton(
          //   icon: const Icon(Icons.filter_list, color: Colors.white),
          //   onPressed: () => _showFilterDialog(),
          // ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.getApi,
            tooltip: 'Refresh',
          ),
        ],
        backgroundColor: ColorConstants.MainPurpleBackground,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// Stats Summary
            // Obx(() => _buildStatsSummary()),

            // Call Logs List
            Expanded(
              child: Obx(() {
                if (controller.callApiState.value == PageState.loading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.black87,
                          strokeWidth: 2,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading call logs...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.callLogsResponse.value.data?.isEmpty ?? true) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    controller.getApi();
                    return Future.delayed(const Duration(milliseconds: 300));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        controller.callLogsResponse.value.data?.length ?? 0,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final log =
                          controller.callLogsResponse.value.data?[index];
                      return _buildCallLogCard(log, context);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    final logs = controller.callLogsResponse.value.data ?? [];
    if (logs.isEmpty) return const SizedBox();

    final incoming = logs.where((log) => log.direction == 'incoming').length;
    final outgoing = logs.where((log) => log.direction == 'outgoing').length;
    final totalDuration = logs.fold<int>(
      0,
      (sum, log) => sum + (log.duration ?? 0),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: ColorConstants.MainPurpleBackground.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.call_received,
            value: incoming.toString(),
            label: 'Incoming',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.call_made,
            value: outgoing.toString(),
            label: 'Outgoing',
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.timer,
            value: '${(totalDuration / 60).ceil()} min',
            label: 'Total Time',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildCallLogCard(dynamic log, BuildContext context) {
    // final isMissed = log.status?.toLowerCase().contains('missed') ?? false;
    final isMissed = log.disposition == 'not connected' ?? false;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isMissed ? Colors.red.withOpacity(0.3) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showCallDetails(log, context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Call Type Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isMissed ? Colors.red : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isMissed ? Icons.phone_missed_sharp : Icons.phone,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${log.leadId?.name?.first ?? ''} ${log.leadId?.name?.last ?? 'Unknown Contact'}'
                                    .trim(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isMissed)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Not Connected',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          log.startedAt != null
                              ? _formatRelativeTime(log.startedAt.toString())
                              : 'Time unknown',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Duration and Action
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${log.duration ?? 0}s',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 8),
                      // IconButton(
                      //   icon: Icon(
                      //     Icons.phone,
                      //     color: ColorConstants.MainPurpleBackground,
                      //     size: 20,
                      //   ),
                      //   onPressed: () => _callContact(log),
                      //   padding: EdgeInsets.zero,
                      //   constraints: const BoxConstraints(),
                      //   tooltip: 'Call back',
                      // ),
                      IconButton(
                        onPressed: () async {
                          final phone = log.toNumber?.toString() ?? '';
                          if (phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Phone number not available"),
                              ),
                            );

                            return;
                          }

                          showCallAlertDialog(
                            context,
                            'Call ${log.leadId?.name?.first ?? ''}',
                            'Are you sure want to call to $phone number?',
                            () async {
                              await CallHelper.callAndTrack(
                                phone,
                                log.leadId?.sId,
                                '',
                              );
                              // Navigator.pop(context);
                            },
                            Colors.blue,
                          );
                          // requestPermissions();
                          // await CallHelper.callAndTrack(phone);
                        },
                        icon: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade100,
                                Colors.green.shade200,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.phone,
                            color: Colors.green.shade800,
                            size: 20,
                          ),
                        ),
                        splashRadius: 24,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Quick Info Row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.phone,
                      text: log.toNumber ?? 'Unknown',
                      color: Colors.blue.shade50,
                      iconColor: Colors.blue,
                    ),
                  ),
                  // const SizedBox(width: 8),
                  // if (log.leadId?.email != null)
                  //   Expanded(
                  //     child: _buildInfoChip(
                  //       icon: Icons.email,
                  //       text: log.leadId!.email!,
                  //       color: Colors.green.shade50,
                  //       iconColor: Colors.green,
                  //     ),
                  //   ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call_missed_outgoing,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            'No Call logs found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Make your first call to see it here',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          // ElevatedButton.icon(
          //   onPressed: () => _showCallOptions(context),
          //   icon: const Icon(Icons.add_call),
          //   label: const Text('Make a Call'),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: ColorConstants.MainPurpleBackground,
          //     foregroundColor: Colors.white,
          //   ),
          // ),
        ],
      ),
    );
  }

  // Helper Methods (keep existing logic)
  IconData _getCallTypeIcon(String? direction) {
    if (direction == null) return Icons.call;
    switch (direction.toLowerCase()) {
      case 'incoming':
        return Icons.call_received;
      case 'outgoing':
        return Icons.call_made;
      default:
        return Icons.call;
    }
  }

  Color _getCallTypeColor(String? direction) {
    if (direction == null) return Colors.grey;
    switch (direction.toLowerCase()) {
      case 'incoming':
        return Colors.green;
      case 'outgoing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String formatDateTime(String timestamp) {
    if (timestamp.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      return DateFormat('MMM dd, yyyy • HH:mm').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatRelativeTime(String timestamp) {
    if (timestamp.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return DateFormat('MMM d, yyyy').format(date);
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  // New UI Methods
  void _showCallDetails(dynamic log, BuildContext context) {
    // if (log == null) {
    //   showModalBottomSheet(
    //     context: context,
    //     isScrollControlled: true,
    //     backgroundColor: Colors.transparent,
    //     builder: (context) => Center(child: Text(""),)
    //   );
    // }
    if (log != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildDetailsSheet(log),
      );
    }
  }

  Widget _buildDetailsSheet(dynamic log) {
    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 0.7,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        final isMissed = log.disposition == 'not connected' ?? false;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header
                    Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isMissed ? Colors.red : Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            log.leadId?.name?.first[0].toUpperCase() ?? "U",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${log.leadId?.name?.first ?? ''} ${log.leadId?.name?.last ?? 'Unknown'}'
                                .trim(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Container(
                            width: 30,
                            height: 30,
                            // decoration: BoxDecoration(
                            //   color: isMissed ? Colors.red : Colors.blue,
                            //   shape: BoxShape.circle,
                            // ),
                            child: Icon(
                              isMissed ? Icons.phone_missed_sharp : Icons.phone,
                              color: isMissed ? Colors.red : Colors.blue,
                              size: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        log.leadId?.email ?? 'No email',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Details
                    _buildDetailItem(
                      icon: Icons.phone,
                      title: 'From Number',
                      value: log.fromNumber ?? 'Unknown',
                    ),
                    _buildDetailItem(
                      icon: Icons.call_made,
                      title: 'To Number',
                      value: log.toNumber ?? 'Unknown',
                    ),
                    _buildDetailItem(
                      icon: Icons.timer,
                      title: 'Duration',
                      value: '${log.duration ?? 0} seconds',
                    ),
                    _buildDetailItem(
                      icon: Icons.calendar_today,
                      title: 'Started',
                      value: formatDateTime(log.startedAt ?? ''),
                    ),
                    _buildDetailItem(
                      icon: Icons.check_circle,
                      title: 'Status',
                      value: log.status ?? 'Unknown',
                    ),

                    const SizedBox(height: 40),
                    // const Spacer(),

                    /// Action Buttons
                    Row(
                      children: [
                        SizedBox(
                          height: 50,
                          width: 100,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final phone = log.toNumber?.toString() ?? '';
                                if (phone.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Phone number not available",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                // requestPermissions();
                                showCallAlertDialog(
                                  context,
                                  'Call again - ${log.leadId?.name?.first ?? ''}',
                                  'Are you sure want to call to $phone number?',
                                  () async {
                                    await CallHelper.callAndTrack(
                                      phone,
                                      log.leadId?.sId,
                                      '',
                                    );
                                    // Navigator.pop(context);
                                  },
                                  Colors.blue,
                                );
                              },
                              icon: const Icon(Icons.phone),
                              label: const Text('Call Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    ColorConstants.MainPurpleBackground,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(width: 12),
                        // Expanded(
                        //   child: OutlinedButton.icon(
                        //     onPressed: () => _addNote(log),
                        //     icon: const Icon(Icons.note_add),
                        //     label: const Text('Add Note'),
                        //     style: OutlinedButton.styleFrom(
                        //       padding: const EdgeInsets.symmetric(vertical: 16),
                        //       side: BorderSide(
                        //         color: ColorConstants.MainPurpleBackground,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    // Implement search functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Calls'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Search by name, number, or email...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // Implement search logic
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // Implement filter functionality
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Calls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Add filter options here
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.phone,
                color: ColorConstants.MainPurpleBackground,
              ),
              title: const Text('Make a new call'),
              onTap: () {
                Navigator.pop(context);
                // Implement new call
              },
            ),
            ListTile(
              leading: const Icon(Icons.contacts, color: Colors.green),
              title: const Text('Call from contacts'),
              onTap: () {
                Navigator.pop(context);
                // Implement contact picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.orange),
              title: const Text('Recent calls'),
              onTap: () {
                Navigator.pop(context);
                // Show recent calls
              },
            ),
          ],
        ),
      ),
    );
  }

  void _callContact(dynamic log) {
    // Implement call functionality
    final number = log.toNumber ?? log.fromNumber;
    if (number != null) {
      // Make call
    }
  }

  void _addNote(dynamic log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter notes about this call...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save note logic
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
