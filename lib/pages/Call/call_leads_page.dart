import 'package:crm_flutter/api/response/all_calls_history_response.dart';
import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/Allocations/components/callLogCard.dart';
import 'package:crm_flutter/pages/Call/call_leads_controller.dart';
import 'package:crm_flutter/pages/Call/edit_call_client_details_dialog.dart';
import 'package:crm_flutter/pages/home/components/time_tab.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CallLeadsPage extends StatefulWidget {
  final CallLeadType callType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? timeRange;

  const CallLeadsPage({
    super.key,
    required this.callType,
    this.startDate,
    this.endDate,
    this.timeRange,
  });

  @override
  State<CallLeadsPage> createState() => _CallLeadsPageState();
}

class _CallLeadsPageState extends State<CallLeadsPage> {
  late final String _controllerTag;
  late final CallLeadsController _controller;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _updatingLeadIds = {};

  @override
  void initState() {
    super.initState();
    _controllerTag =
        'call_leads_${widget.callType.name}_${DateTime.now().millisecondsSinceEpoch}';
    _controller = Get.put(
      CallLeadsController(callType: widget.callType),
      tag: _controllerTag,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.startDate != null && widget.endDate != null) {
        _controller.selectedStartDate.value = widget.startDate;
        _controller.selectedEndDate.value = widget.endDate;
        _controller.selectedTimeRange.value = widget.timeRange ?? 'Today';
      }
      _controller.fetchCalls(
        startDate: widget.startDate,
        endDate: widget.endDate,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    Get.delete<CallLeadsController>(tag: _controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search by lead name, phone, or agent...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  _controller.searchQuery.value = value;
                },
              )
            : Text(
                widget.callType.title,
                style: const TextStyle(
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
                  _controller.searchQuery.value = '';
                } else {
                  _isSearchVisible = true;
                }
              });
            },
            tooltip: _isSearchVisible ? 'Close Search' : 'Search',
          ),
          if (!_isSearchVisible)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _controller.refreshData(),
              tooltip: 'Refresh',
            ),
        ],
        backgroundColor: ColorConstants.MainPurpleBackground,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Time range tabs
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 6.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(
                  () => Row(
                    children: [
                      const SizedBox(width: 10),
                      TimeTab(
                        text: 'Today',
                        first: true,
                        isSelected:
                            _controller.selectedTimeRange.value == 'Today',
                        onTap: () =>
                            _controller.selectTimeRange('Today', context),
                      ),
                      TimeTab(
                        text: 'Yesterday',
                        isSelected:
                            _controller.selectedTimeRange.value == 'Yesterday',
                        onTap: () =>
                            _controller.selectTimeRange('Yesterday', context),
                      ),
                      TimeTab(
                        text: 'Last 30 Days',
                        isSelected:
                            _controller.selectedTimeRange.value ==
                            'Last 30 Days',
                        onTap: () => _controller.selectTimeRange(
                          'Last 30 Days',
                          context,
                        ),
                      ),
                      TimeTab(
                        text: 'Select Range',
                        last: true,
                        isSelected:
                            _controller.selectedTimeRange.value ==
                            'Select Range',
                        onTap: () => _controller.selectTimeRange(
                          'Select Range',
                          context,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Obx(() {
                if (_controller.callApiState.value == PageState.loading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.black87,
                          strokeWidth: 2,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading ${widget.callType.title.toLowerCase()}...',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (_controller.callApiState.value == PageState.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load call leads',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'An error occurred while fetching calls. Please try again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _controller.refreshData(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  ColorConstants.MainPurpleBackground,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final leads = _controller.filteredLeads;
                if (leads.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _controller.refreshData();
                    await Future.delayed(const Duration(milliseconds: 300));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: leads.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final callGroup = leads[index];
                      return _buildLeadCard(callGroup, context);
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

  Widget _buildEmptyState() {
    final isSearching = _controller.searchQuery.value.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.call_end_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'No matching call leads'
                  : 'No ${widget.callType.title.toLowerCase()} found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try searching with a different name or phone number'
                  : 'There are no call records available for this time range.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _controller.refreshData(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeadCard(CallHistoryGroup callGroup, BuildContext context) {
    final lead = callGroup.lead;
    final leadName = _formatLeadName(lead);
    final phone = lead?.phone?.toString() ?? "No Contact Number";

    final direction = (callGroup.callLog?.direction ?? '').trim().toLowerCase();
    final status = (callGroup.callLog?.status ?? '').trim().toLowerCase();

    final String callTypeLabel;
    if (status == 'missed') {
      callTypeLabel = 'Missed';
    } else if (direction == 'inbound') {
      callTypeLabel = 'Inbound';
    } else if (direction == 'outbound') {
      callTypeLabel = 'Outbound';
    } else {
      callTypeLabel = 'Call';
    }

    final isMissed = callTypeLabel == 'Missed';
    final isInbound = callTypeLabel == 'Inbound';
    final durationSeconds = callGroup.callLog?.duration;
    final durationText = _formatDuration(durationSeconds);
    final formattedTime = _formatCallTime(callGroup.lastCallAt);
    final agentName = callGroup.calledBy?.name ?? "Unknown Agent";
    final stageName = lead?.leadStage?.name;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isMissed
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (lead == null || lead.sId == null || lead.sId!.isEmpty) {
            Get.snackbar(
              'Lead details',
              'Lead details are unavailable for this call record',
              snackPosition: SnackPosition.TOP,
            );
            return;
          }

          if (!context.mounted) return;

          final detailsCard = CallLogCard(
            name: leadName,
            leadId: lead.sId,
            tag: stageName ?? '',
          );

          detailsCard.openBottomSheet(context, lead.sId);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Avatar, Name & Edit, Call Type Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Call Type Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isMissed
                          ? Colors.red.shade100
                          : isInbound
                          ? Colors.green.shade100
                          : Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isMissed
                          ? Icons.phone_missed
                          : isInbound
                          ? Icons.phone_callback
                          : Icons.phone_forwarded,
                      color: isMissed
                          ? Colors.red.shade700
                          : isInbound
                          ? Colors.green.shade700
                          : Colors.blue.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name, Call Time, and Edit button
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
                            if (lead?.sId != null && lead!.sId!.isNotEmpty)
                              IconButton(
                                key: ValueKey('edit-call-lead-${lead.sId}'),
                                tooltip: 'Edit client details',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: _updatingLeadIds.contains(lead.sId)
                                    ? null
                                    : () => _editClientDetails(callGroup),
                                icon: _updatingLeadIds.contains(lead.sId)
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                      ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 13,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                formattedTime,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Call Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isMissed
                          ? Colors.red.shade50
                          : isInbound
                          ? Colors.green.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isMissed
                            ? Colors.red.shade200
                            : isInbound
                            ? Colors.green.shade200
                            : Colors.blue.shade200,
                      ),
                    ),
                    child: Text(
                      callTypeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isMissed
                            ? Colors.red.shade700
                            : isInbound
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Chips Row: Phone, Duration, Stage/Call Count
              Row(
                children: [
                  // Phone Number Chip
                  Expanded(
                    flex: 3,
                    child: _buildInfoChip(
                      icon: Icons.phone,
                      text: phone,
                      color: Colors.blue.shade50,
                      iconColor: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Call Duration Chip
                  Expanded(
                    flex: 2,
                    child: _buildInfoChip(
                      icon: Icons.timer_outlined,
                      text: durationText,
                      color: Colors.purple.shade50,
                      iconColor: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Call Count or Stage
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.repeat,
                          size: 13,
                          color: Colors.orange.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${callGroup.callCount ?? 1} Calls',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Bottom Row: Agent & Direct Call button
              Row(
                children: [
                  // Agent Name Chip
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.person_outline,
                      text: agentName,
                      color: Colors.grey.shade100,
                      iconColor: Colors.grey.shade700,
                    ),
                  ),
                  if (stageName != null && stageName.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.teal.shade200),
                      ),
                      child: Text(
                        stageName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.teal.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(width: 10),

                  // Call Action Button
                  IconButton(
                    tooltip: 'Call lead',
                    onPressed: () async {
                      if (phone == "No Contact Number" ||
                          phone.trim().replaceAll(RegExp(r'\D'), '').isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Phone number not available"),
                          ),
                        );
                        return;
                      }
                      await CallHelper.callAndTrack(
                        phone,
                        lead?.sId,
                        stageName ?? '',
                      );
                    },
                    icon: Container(
                      width: 38,
                      height: 38,
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
                            color: Colors.blue.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.phone,
                        color: Colors.green.shade800,
                        size: 18,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 38,
                      minHeight: 38,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editClientDetails(CallHistoryGroup callGroup) async {
    final lead = callGroup.lead;
    final leadId = lead?.sId;
    if (lead == null || leadId == null || leadId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client details cannot be edited without a lead ID'),
        ),
      );
      return;
    }
    if (!_updatingLeadIds.add(leadId)) return;
    setState(() {});

    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (_) => EditCallClientDetailsDialog(
          clientName: _formatLeadName(lead),
          mobileNumber: lead.phone?.toString() ?? '',
          onSave: (clientName, mobileNumber) => _controller.updateClientDetails(
            leadId: leadId,
            clientName: clientName,
            mobileNumber: mobileNumber,
          ),
        ),
      );
      if (saved == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client details updated successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to update client details: $error')),
        );
      }
    } finally {
      _updatingLeadIds.remove(leadId);
      if (mounted) setState(() {});
    }
  }

  String _formatLeadName(Lead? lead) {
    if (lead == null) return 'External Contact';
    final name = [
      lead.name?.first,
      lead.name?.middle,
      lead.name?.last,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');
    return name.isNotEmpty ? name : 'Unnamed Lead';
  }

  String _formatCallTime(String? timestamp) {
    if (timestamp == null || timestamp.trim().isEmpty) return 'Time unknown';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      return DateFormat('MMM dd, yyyy • HH:mm').format(date);
    } catch (_) {
      return timestamp;
    }
  }

  String _formatDuration(int? durationInSeconds) {
    if (durationInSeconds == null || durationInSeconds <= 0) return '0s';
    final hours = durationInSeconds ~/ 3600;
    final remaining = durationInSeconds % 3600;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;

    if (hours > 0) {
      if (minutes > 0) return '${hours}h ${minutes}m';
      return '${hours}h';
    }
    if (minutes > 0 && seconds > 0) return '${minutes}m ${seconds}s';
    if (minutes > 0) return '${minutes}m';
    return '${seconds}s';
  }
}

