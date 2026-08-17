import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/Allocations/components/callLogCard.dart';
import 'package:crm_flutter/pages/Allocations/missedFollowUps/missed_followups_page.dart';
import 'package:crm_flutter/pages/Allocations/components/custom_chip.dart';
import 'package:crm_flutter/pages/home/components/time_tab.dart';
import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/widgets/show_call_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_flutter/widgets/add.dart';
import 'package:crm_flutter/pages/all_lead/add_lead_page.dart';
import 'package:permission_handler/permission_handler.dart';

class AllocationPage extends StatefulWidget {
  const AllocationPage({super.key});

  @override
  State<AllocationPage> createState() => _AllocationPageState();
}

class _AllocationPageState extends State<AllocationPage> {
  final AllocationController allocationController = Get.put(
    AllocationController(),
  );
  final Leaddetailscontroller leadDetailsController = Get.put(
    Leaddetailscontroller(),
  );
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      allocationController.selectTimeRange('Today', context);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Don't paginate in search mode
        if (!allocationController.isSearchMode.value &&
            allocationController.isMoreDataAvailable.value &&
            !allocationController.isPaginationLoading.value) {
          allocationController.getAllLeads();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
    if (_isSearchVisible) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _searchFocusNode.requestFocus();
      });
    } else {
      _searchController.clear();
      allocationController.clearSearch();
      _searchFocusNode.unfocus();
    }
  }

  Future<void> patchDataAccept(id) async {
    try {
      await leadDetailsController.getAllLeadDetailsPatchA(id);
    } catch (e) {
      print("Error in loadData: $e");
    }
  }

  Future<void> patchDataDecline(id) async {
    try {
      await leadDetailsController.getAllLeadDetailsPatchD(id);
    } catch (e) {
      print("Error in loadData: $e");
    }
  }

  // ── Loading State ─────────────────────────────────────────
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: ColorConstants.MainPurpleBackground,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading leads…',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ColorConstants.MainPurpleBackground.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: ColorConstants.MainPurpleBackground.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAcceptDialog(
    BuildContext context,
    String mainText,
    String leadName,
    VoidCallback onAccept,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('$mainText - $leadName'),
          content: Text("Are you sure you want to $mainText?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: mainText == 'Accept'
                    ? Colors.green.shade400
                    : Colors.red.shade300,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                onAccept();
              },
              child: Text(mainText),
            ),
          ],
        );
      },
    );
  }

  // ── Search Field ──────────────────────────────────────────
  Widget _buildSearchField() {
    return Container(
      key: const ValueKey('search'),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: 'Search by name, phone, email…',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
          suffixIcon: Obx(
            () => allocationController.searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      allocationController.clearSearch();
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.white.withOpacity(0.7),
                      size: 18,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: allocationController.onSearchChanged,
      ),
    );
  }

  // ── Search Results View ───────────────────────────────────
  Widget _buildSearchResultsView(Future<bool> Function() requestPermissions) {
    return Expanded(
      child: Column(
        children: [
          // Search stats bar
          Obx(() {
            final query = allocationController.searchQuery.value;
            final count = allocationController.searchResults.length;
            final isLoading = allocationController.isSearchLoading.value;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: ColorConstants.MainPurpleBackground.withOpacity(0.08),
                border: Border(
                  bottom: BorderSide(
                    color: ColorConstants.MainPurpleBackground.withOpacity(
                      0.15,
                    ),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isLoading ? Icons.hourglass_empty : Icons.search,
                    size: 16,
                    color: ColorConstants.MainPurpleBackground.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: isLoading
                        ? Text(
                            'Searching for "$query"…',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          )
                        : RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                              children: [
                                TextSpan(
                                  text: '$count result${count == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.MainPurpleBackground,
                                  ),
                                ),
                                TextSpan(text: ' for "$query"'),
                              ],
                            ),
                          ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      allocationController.clearSearch();
                      setState(() {
                        _isSearchVisible = false;
                      });
                    },
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('Clear', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: ColorConstants.MainPurpleBackground,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Results list
          Expanded(
            child: Obx(() {
              if (allocationController.isSearchLoading.value) {
                return _buildLoadingState();
              }

              if (allocationController.searchResults.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No results found',
                  subtitle:
                      'Try a different name, phone number, or email address',
                );
              }

              return _buildLeadList(
                allocationController.searchResults,
                requestPermissions,
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Shared Lead ListView ──────────────────────────────────
  Widget _buildLeadList(
    List leads,
    Future<bool> Function() requestPermissions,
  ) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: leads.length + 1,
      itemBuilder: (context, index) {
        if (index < leads.length) {
          final data = leads[index];
          return CallLogCard(
            name: "${data.name?.first ?? ''} ${data.name?.last ?? ''}",
            leadId: data.sId,
            timelineData: data.timeline,
            campaignId: data.compaignName?.sId ?? '',
            campaign: data.compaignName?.name ?? 'no campaign',
            tag: data.leadStageId?.name ?? '',
            assignedTo: data.assignedTo,
            source: data.leadSourceId?.name,
            subSource: data.leadSubSourceId?.name,
            // onTap: () {
            // },
            accept: () async {
              // ACCEPT
              showAcceptDialog(
                context,
                "Accept",
                data.name?.first ?? '',
                () async {
                  await patchDataAccept(data.sId);
                  allocationController.refreshData();
                },
              );
            },
            decline: () async {
              // DECLINE
              showAcceptDialog(
                context,
                "Reject",
                data.name?.first ?? '',
                () async {
                  await patchDataDecline(data.sId);
                  allocationController.refreshData();
                },
              );
            },
            time: data.updatedAt ?? '',
            followUp: data.followUpDate,
            stageFieldValues: data.stageFieldValues,
            phone: data.phone ?? 0,
            onCallBack: () async {
              final phone = data.phone?.toString() ?? '';
              if (phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Phone number not available")),
                );
                return;
              }
              requestPermissions();
              if (data.assignedTo != null) {
                showCallAlertDialog(
                  context,
                  'Call ${data.name?.first ?? ''}',
                  'Are you sure want to call to $phone number?',
                  () async {
                    await CallHelper.callAndTrack(
                      phone,
                      data.sId ?? '',
                      data.leadStageId?.name ?? '',
                    );
                  },
                  Colors.blue,
                );
              }
            },
          );
        }
        // Pagination loader (only in normal mode)
        if (!allocationController.isSearchMode.value &&
            allocationController.isPaginationLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.black54,
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> requestPermissions() async {
      PermissionStatus status = await Permission.contacts.status;
      if (status.isGranted) return true;
      status = await Permission.contacts.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      return false;
    }

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _isSearchVisible
              ? _buildSearchField()
              : Text(
                  "Allocations",
                  key: const ValueKey('title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
        ),
        backgroundColor: ColorConstants.MainPurpleBackground,

        actions: [
          // Plus Button
          AddButton(
            onPressed: () async {
              final result = await Get.to(
                () => AddLeadPage(),
                transition: Transition.rightToLeft,
              );

              if (result == true) {
                allocationController.refreshData();
              }
            },
          ),

          // Search Button
          IconButton(
            onPressed: _toggleSearch,
            tooltip: _isSearchVisible ? 'Close search' : 'Search leads',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isSearchVisible ? Icons.close : Icons.search,
                key: ValueKey(_isSearchVisible),
                color: _isSearchVisible ? Colors.orange.shade200 : Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Calendar Button
          IconButton(
            onPressed: () {
              Get.to(
                () => MissedFollowupsPage(),
                transition: Transition.rightToLeft,
              );
            },
            icon: const Icon(
              Icons.calendar_month,
              color: Colors.white,
              size: 26,
            ),
          ),

          const SizedBox(width: 4),

          // Refresh Button
          IconButton(
            onPressed: () {
              allocationController.refreshData();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),

          const SizedBox(width: 6),
        ],
      ),
      body: Obx(() {
        return Container(
          decoration: BoxDecoration(
            color: ColorConstants.MainPurpleBackground.withValues(alpha: 0.06),
          ),
          child: Column(
            children: [
              // ── Search Results Panel ──────────────────────────
              if (allocationController.isSearchMode.value)
                _buildSearchResultsView(requestPermissions)
              else ...[
                // ── Stage Chips ────────────────────────────────
                Obx(() {
                  if (allocationController.allLeadStages.isEmpty) {
                    return const SizedBox();
                  }
                  return Container(
                    height: 50,
                    margin: const EdgeInsets.only(top: 8),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: allocationController.allLeadStages.length,
                      itemBuilder: (context, index) {
                        final stageData =
                            allocationController.allLeadStages[index];
                        final isSelected = allocationController
                            .selectedStatusIds
                            .contains(stageData.sId);
                        return buildCustomChip(
                          text: stageData.name ?? 'Unknown',
                          isSelected: isSelected,
                          onTap: () => allocationController.toggleStatus(
                            stageData.sId ?? '',
                            context,
                          ),
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: 12),
                // ── Time Tabs ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 4,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Obx(
                          () => TimeTab(
                            text: 'Today',
                            first: true,
                            isSelected:
                                allocationController.selectedTimeRange.value ==
                                'Today',
                            onTap: () => allocationController.selectTimeRange(
                              'Today',
                              context,
                            ),
                          ),
                        ),
                        Obx(
                          () => TimeTab(
                            text: 'Yesterday',
                            isSelected:
                                allocationController.selectedTimeRange.value ==
                                'Yesterday',
                            onTap: () => allocationController.selectTimeRange(
                              'Yesterday',
                              context,
                            ),
                          ),
                        ),
                        Obx(
                          () => TimeTab(
                            text: 'Last 30 Days',
                            isSelected:
                                allocationController.selectedTimeRange.value ==
                                'Last 30 Days',
                            onTap: () => allocationController.selectTimeRange(
                              'Last 30 Days',
                              context,
                            ),
                          ),
                        ),
                        Obx(
                          () => TimeTab(
                            text: 'Select Range',
                            last: true,
                            isSelected:
                                allocationController.selectedTimeRange.value ==
                                'Select Range',
                            onTap: () => allocationController.selectTimeRange(
                              'Select Range',
                              context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Lead List ──────────────────────────────────
                Expanded(
                  child: allocationController.isLoading.value
                      ? _buildLoadingState()
                      : allocationController.leads.isEmpty
                      ? _buildEmptyState(
                          icon: Icons.inbox_outlined,
                          title: 'No Leads Found',
                          subtitle: 'Try changing your date range or filters',
                        )
                      : _buildLeadList(
                          allocationController.leads,
                          requestPermissions,
                        ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
