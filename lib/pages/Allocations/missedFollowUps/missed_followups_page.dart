import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/helper/lead_edit_helper.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart' as lead_model;
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
    _allMissFUpsController = Get.put(AllMissFUpsController());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Obx(
          () => Text(
            "${_allMissFUpsController.followUpType.value} FollowUp's",
            style: TextStyle(
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
            },
            icon: Icon(Icons.refresh, color: Colors.white),
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
                        child: Text("All"),
                      ),
                    ),
                    SizedBox(width: 10),
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
                        child: Text("Missed"),
                      ),
                    ),
                  ],
                ),
              ),
              // Date Filter UI
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
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
                        onRefresh: () =>
                            _allMissFUpsController.fetchData(isRefresh: true),
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
