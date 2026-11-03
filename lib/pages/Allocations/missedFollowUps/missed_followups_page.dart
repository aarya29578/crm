import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/helper/lead_edit_helper.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart' as lead_model;
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/Allocations/components/callLogCard.dart';
import 'package:crm_flutter/pages/Allocations/components/edit_allocation_lead_dialog.dart';
import 'package:crm_flutter/pages/Allocations/missedFollowUps/missed_followups_controller.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/pages/home/components/time_tab.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MissedFollowupsPage extends StatefulWidget {
  final String initialType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? timeRange;
  const MissedFollowupsPage({
    super.key,
    this.initialType = 'Missed',
    this.startDate,
    this.endDate,
    this.timeRange,
  });

  @override
  State<MissedFollowupsPage> createState() => _MissedFollowupsPageState();
}

class _MissedFollowupsPageState extends State<MissedFollowupsPage> {
  final ScrollController _scrollController = ScrollController();
  late final AllMissFUpsController _allMissFUpsController;
  final Set<String> _editingLeadIds = {};

  Future<void> _editLead(String? leadId) async {
    if (leadId == null || leadId.trim().isEmpty) {
      _showEditError('Lead ID is not available');
      return;
    }
    if (!_editingLeadIds.add(leadId)) return;
    setState(() {});

    try {
      final lead = await LeadEditHelper.fetchLeadForEditing(leadId);
      if (!mounted) return;
      final updatedLead = await showDialog<lead_model.Data>(
        context: context,
        builder: (_) => EditAllocationLeadDialog(lead: lead),
      );
      if (updatedLead != null && mounted) {
        await _allMissFUpsController.fetchData(isRefresh: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lead updated successfully')),
          );
        }
      }
    } catch (error) {
      _showEditError('Unable to load lead for editing: $error');
    } finally {
      _editingLeadIds.remove(leadId);
      if (mounted) setState(() {});
    }
  }

  void _showEditError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _allMissFUpsController = Get.isRegistered<AllMissFUpsController>()
        ? Get.find<AllMissFUpsController>()
        : Get.put(AllMissFUpsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _allMissFUpsController.followUpType.value = widget.initialType;

      // Apply date filter from home page if provided
      if (widget.startDate != null && widget.endDate != null) {
        _allMissFUpsController.selectedStartDate.value = widget.startDate;
        _allMissFUpsController.selectedEndDate.value = widget.endDate;
        _allMissFUpsController.selectedTimeRange.value =
            widget.timeRange ?? 'Today';
      }

      _allMissFUpsController.fetchData(isRefresh: true);
      _allMissFUpsController.fetchLeadStages();
    });

    _scrollController.addListener(_loadMore);
  }

  void _loadMore() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_allMissFUpsController.isMoreDataAvailable.value &&
          !_allMissFUpsController.isInitialLoading.value &&
          !_allMissFUpsController.isLoadingMore.value) {
        _allMissFUpsController.fetchData();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildStatusBreakdownSection() {
    return Obx(() {
      final state = _allMissFUpsController.stageCountLoading.value;
      final stages = _allMissFUpsController.allLeadStageRes.value.data ?? [];
      final isExpanded = _allMissFUpsController.isStatusBreakdownExpanded.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                _allMissFUpsController.isStatusBreakdownExpanded.toggle();
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Leads Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        if (stages.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ColorConstants.MainPurpleBackground
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${stages.length} Statuses',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: ColorConstants.MainPurpleBackground,
                              ),
                            ),
                          ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey.shade700,
                          size: 22,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              if (state == PageState.loading && stages.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorConstants.MainPurpleBackground,
                      ),
                    ),
                  ),
                )
              else if (state == PageState.error && stages.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 14.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Failed to load status counts',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _allMissFUpsController
                            .fetchLeadStages(forceRefresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (stages.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      'No status data available',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    itemCount: stages.length,
                    itemBuilder: (context, index) {
                      final data = stages[index];
                      return Card(
                        elevation: 0,
                        surfaceTintColor: Colors.transparent,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        color: ColorConstants.MainPurpleBackground.withValues(
                          alpha: 0.01,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          height: 48,
                          decoration: BoxDecoration(
                            color: ColorConstants.MainPurpleBackground
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data.name?.toString() ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                data.count?.toString() ?? '0',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 6),
            ],
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Obx(
          () => Text(
            "${_allMissFUpsController.followUpType.value} FollowUp's",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: ColorConstants.MainPurpleBackground,
        actions: [
          IconButton(
            onPressed: () {
              _allMissFUpsController.fetchData(isRefresh: true);
              _allMissFUpsController.fetchLeadStages(forceRefresh: true);
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Obx(() {
        final leads = _allMissFUpsController.leads;
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _allMissFUpsController.followUpType.value == 'All'
                                  ? ColorConstants.MainPurpleBackground
                                  : Colors.white,
                          foregroundColor:
                              _allMissFUpsController.followUpType.value == 'All'
                                  ? Colors.white
                                  : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: ColorConstants.MainPurpleBackground,
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (_allMissFUpsController.followUpType.value ==
                              'All') {
                            return;
                          }
                          _allMissFUpsController.followUpType.value = 'All';
                          _allMissFUpsController.fetchData(isRefresh: true);
                        },
                        child: const Text("All"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _allMissFUpsController.followUpType.value ==
                                      'Missed'
                                  ? ColorConstants.MainPurpleBackground
                                  : Colors.white,
                          foregroundColor:
                              _allMissFUpsController.followUpType.value ==
                                      'Missed'
                                  ? Colors.white
                                  : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: ColorConstants.MainPurpleBackground,
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (_allMissFUpsController.followUpType.value ==
                              'Missed') {
                            return;
                          }
                          _allMissFUpsController.followUpType.value = 'Missed';
                          _allMissFUpsController.fetchData(isRefresh: true);
                        },
                        child: const Text("Missed"),
                      ),
                    ),
                  ],
                ),
              ),
              // Date Filter UI
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      TimeTab(
                        text: 'Today',
                        first: true,
                        isSelected:
                            _allMissFUpsController.selectedTimeRange.value ==
                            'Today',
                        onTap: () => _allMissFUpsController.selectTimeRange(
                          'Today',
                          context,
                        ),
                      ),
                      TimeTab(
                        text: 'Yesterday',
                        isSelected:
                            _allMissFUpsController.selectedTimeRange.value ==
                            'Yesterday',
                        onTap: () => _allMissFUpsController.selectTimeRange(
                          'Yesterday',
                          context,
                        ),
                      ),
                      TimeTab(
                        text: 'Last 30 Days',
                        isSelected:
                            _allMissFUpsController.selectedTimeRange.value ==
                            'Last 30 Days',
                        onTap: () => _allMissFUpsController.selectTimeRange(
                          'Last 30 Days',
                          context,
                        ),
                      ),
                      TimeTab(
                        text: 'Select Range',
                        last: true,
                        isSelected:
                            _allMissFUpsController.selectedTimeRange.value ==
                            'Select Range',
                        onTap: () => _allMissFUpsController.selectTimeRange(
                          'Select Range',
                          context,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Overall Status-Wise Lead Count Section (matching Home dashboard)
              _buildStatusBreakdownSection(),
              Expanded(
                child:
                    _allMissFUpsController.isInitialLoading.value &&
                        leads.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black87,
                          strokeWidth: 2,
                        ),
                      )
                    : leads.isEmpty
                    ? Center(
                        child: _allMissFUpsController.hasMoreError.value
                            ? TextButton(
                                onPressed: () =>
                                    _allMissFUpsController.fetchData(),
                                child: const Text(
                                  'Could not load follow-ups. Retry',
                                ),
                              )
                            : const Text(
                                "No Follow-up found",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await Future.wait([
                            _allMissFUpsController.fetchData(isRefresh: true),
                            _allMissFUpsController.fetchLeadStages(
                              forceRefresh: true,
                            ),
                          ]);
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount:
                              leads.length +
                              (_allMissFUpsController.isLoadingMore.value ||
                                      _allMissFUpsController.hasMoreError.value
                                  ? 1
                                  : 0),
                          itemBuilder: (context, index) {
                            if (index == leads.length) {
                              if (_allMissFUpsController.hasMoreError.value) {
                                return Center(
                                  child: TextButton(
                                    onPressed: () =>
                                        _allMissFUpsController.fetchData(),
                                    child: const Text(
                                      'Could not load more. Retry',
                                    ),
                                  ),
                                );
                              }
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final data = leads[index];
                            final name = data.name is String
                                ? data.name
                                : "${data.name?.first ?? ''} ${data.name?.last ?? ''}";

                            return Container(
                              child: CallLogCard(
                                isMissedFUps: true,
                                isEditing: _editingLeadIds.contains(data.sId),
                                name: name,
                                leadId: data.sId,
                                campaignId: data.compaignName is String
                                    ? ''
                                    : (data.compaignName?.sId ?? ''),
                                campaign: data.compaignName is String
                                    ? data.compaignName
                                    : (data.compaignName?.name ??
                                          'no campaign'),
                                tag: data.leadStageId is String
                                    ? data.leadStageId
                                    : (data.leadStageId?.name ?? ''),
                                time: data.updatedAt ?? '',
                                followUp: data.followUpDate is String
                                    ? DateTime.tryParse(data.followUpDate)
                                    : data.followUpDate,
                                phone: data.phone ?? 0,
                                stageFieldValues: data.stageFieldValues,
                                onEdit: () => _editLead(data.sId),
                                onCallBack: () async {
                                  final phone = data.phone?.toString() ?? '';
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

                                  await CallHelper.callAndTrack(
                                    phone,
                                    data.sId ?? '',
                                    (data.leadStageId is String
                                            ? data.leadStageId
                                            : data.leadStageId?.name) ??
                                        '',
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
