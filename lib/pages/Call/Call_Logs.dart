import 'package:crm_flutter/api/response/all_calls_history_response.dart';
import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/widgets/show_call_alert_dialog.dart';
import 'package:crm_flutter/pages/home/components/time_tab.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_flutter/pages/Call/call_controller.dart';
import 'package:intl/intl.dart';

class CallLogs extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? timeRange;
  const CallLogs({super.key, this.startDate, this.endDate, this.timeRange});

  @override
  State<CallLogs> createState() => _CallLogsState();
}

class _CallLogsState extends State<CallLogs> {
  final CallLogController controller = Get.put(CallLogController());
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If dates are passed from Home, mark the correct time range chip
      if (widget.startDate != null && widget.endDate != null) {
        controller.selectedStartDate.value = widget.startDate;
        controller.selectedEndDate.value = widget.endDate;
        controller.selectedTimeRange.value = widget.timeRange ?? 'Today';
      }
      controller.getApi(startDate: widget.startDate, endDate: widget.endDate);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search by name or phone...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  controller.searchQuery.value = value;
                },
              )
            : const Text(
                'Call Logs',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_isSearchVisible) {
                  _isSearchVisible = false;
                  _searchController.clear();
                  controller.searchQuery.value = '';
                } else {
                  _isSearchVisible = true;
                }
              });
            },
            tooltip: 'Search',
          ),
          if (!_isSearchVisible)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => controller.refreshData(),
              tooltip: 'Refresh',
            ),
        ],
        backgroundColor: ColorConstants.MainPurpleBackground,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Date Filter Chips
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 6.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() => Row(
                  children: [
                    const SizedBox(width: 10),
                    TimeTab(
                      text: 'Today',
                      first: true,
                      isSelected: controller.selectedTimeRange.value == 'Today',
                      onTap: () => controller.selectTimeRange('Today', context),
                    ),
                    TimeTab(
                      text: 'Yesterday',
                      isSelected: controller.selectedTimeRange.value == 'Yesterday',
                      onTap: () => controller.selectTimeRange('Yesterday', context),
                    ),
                    TimeTab(
                      text: 'Last 30 Days',
                      isSelected: controller.selectedTimeRange.value == 'Last 30 Days',
                      onTap: () => controller.selectTimeRange('Last 30 Days', context),
                    ),
                    TimeTab(
                      text: 'Select Range',
                      last: true,
                      isSelected: controller.selectedTimeRange.value == 'Select Range',
                      onTap: () => controller.selectTimeRange('Select Range', context),
                    ),
                  ],
                )),
              ),
            ),
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

                final filteredLogs = controller.filteredCallLogs;
                if (filteredLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No matching call logs',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    controller.getApi();
                    return Future.delayed(const Duration(milliseconds: 300));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredLogs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final callGroup = filteredLogs[index];
                      return _buildCallLogCard(callGroup, context);
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

  Widget _buildCallLogCard(CallHistoryGroup? callGroup, BuildContext context) {
    if (callGroup == null) return const SizedBox();

    final lead = callGroup.lead;
    final leadName = (lead?.name?.first != null || lead?.name?.last != null)
        ? "${lead?.name?.first ?? ""} ${lead?.name?.last ?? ""}".trim()
        : (lead != null ? "Unnamed Lead" : "External Contact");
    final phone = lead?.phone?.toString() ?? "No Contact Number";
    final isMissed = lead?.leadStage?.connected?.toLowerCase() == 'not connected';
    final agentName = callGroup.calledBy?.name ?? "Unknown Agent";

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
        onTap: () => _showCallDetails(callGroup, context),
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
                                leadName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          callGroup.lastCallAt != null
                              ? _formatRelativeTime(callGroup.lastCallAt.toString())
                              : 'Time unknown',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action
                  IconButton(
                    onPressed: () async {
                      if (phone == "No Contact Number") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Phone number not available"),
                          ),
                        );
                        return;
                      }

                      showCallAlertDialog(
                        context,
                        'Call $leadName',
                        'Are you sure want to call to $phone number?',
                        () async {
                          await CallHelper.callAndTrack(
                            phone,
                            lead?.sId,
                            '',
                          );
                        },
                        Colors.blue,
                      );
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

              const SizedBox(height: 12),

              // Quick Info Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildInfoChip(
                      icon: Icons.phone,
                      text: phone,
                      color: Colors.blue.shade50,
                      iconColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 2,
                    child: _buildInfoChip(
                      icon: Icons.person_outline,
                      text: agentName,
                      color: Colors.grey.shade100,
                      iconColor: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.repeat, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${callGroup.callCount ?? 1} Calls',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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


  // Helper Methods
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

  void _showCallDetails(CallHistoryGroup callGroup, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailsSheet(callGroup),
    );
  }

  Widget _buildDetailsSheet(CallHistoryGroup callGroup) {
    final lead = callGroup.lead;
    final leadName = (lead?.name?.first != null || lead?.name?.last != null)
        ? "${lead?.name?.first ?? ""} ${lead?.name?.last ?? ""}".trim()
        : (lead != null ? "Unnamed Lead" : "External Contact");
    final isMissed = lead?.leadStage?.connected?.toLowerCase() == 'not connected';

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
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
                          leadName.isNotEmpty ? leadName[0].toUpperCase() : "U",
                          style: const TextStyle(
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
                    child: Text(
                      leadName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      lead?.email ?? 'No email available',
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
                    title: 'Contact Number',
                    value: lead?.phone?.toString() ?? 'N/A',
                  ),
                  _buildDetailItem(
                    icon: Icons.person_outline,
                    title: 'Called By (Agent)',
                    value: callGroup.calledBy?.name ?? 'Unknown Agent',
                  ),
                  _buildDetailItem(
                    icon: Icons.calendar_today,
                    title: 'Date',
                    value: callGroup.date ?? 'N/A',
                  ),
                  _buildDetailItem(
                    icon: Icons.access_time,
                    title: 'Last Call Time',
                    value: formatDateTime(callGroup.lastCallAt ?? ''),
                  ),
                  _buildDetailItem(
                    icon: Icons.format_list_numbered,
                    title: 'Total Calls',
                    value: '${callGroup.callCount ?? 0}',
                  ),
                  if (lead?.priority != null)
                    _buildDetailItem(
                      icon: Icons.star_outline,
                      title: 'Priority',
                      value: lead!.priority!,
                    ),
                  if (lead?.leadStage != null)
                    _buildDetailItem(
                      icon: Icons.sync,
                      title: 'Current Stage',
                      value: lead!.leadStage!.name ?? 'N/A',
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
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
        ],
      ),
    );
  }
}
