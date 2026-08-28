import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/home/components/time_tab.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/home/HomeController.dart';
import 'package:get/get.dart';
import 'package:crm_flutter/pages/Call/Call_Logs.dart';
import 'package:crm_flutter/pages/claimed/ClaimedController.dart';
import 'package:crm_flutter/pages/Allocations/missedFollowUps/missed_followups_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController homeController = Get.put(HomeController());

  // Search controller
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    homeController.fetchAllCampaigns();
    homeController.selectTimeRange('Today', context);
    homeController.getAllLeads();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.MainPurpleBackground.withValues(
        alpha: 0.06,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            await homeController.getAllLeadStage();
            await homeController.getAllLeads();
            homeController.refreshData();
          } catch (e) {
            print("Error refreshing home page: $e");
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard content wrapped in Obx
              Obx(() {
                if (homeController.dashboardLoading.value ==
                    PageState.loading) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 250,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (homeController.dashboardLoading.value ==
                    PageState.error) {
                  return const Center(
                    child: Text("Error loading data"),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------------------------------------------------------
                    // TIME RANGE TABS
                    // -------------------------------------------------------
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(width: 10),

                          Obx(
                            () => TimeTab(
                              text: 'Today',
                              first: true,
                              isSelected:
                                  homeController.selectedTimeRange.value ==
                                  'Today',
                              onTap: () =>
                                  homeController.selectTimeRange(
                                'Today',
                                context,
                              ),
                            ),
                          ),

                          Obx(
                            () => TimeTab(
                              text: 'Yesterday',
                              isSelected:
                                  homeController.selectedTimeRange.value ==
                                  'Yesterday',
                              onTap: () =>
                                  homeController.selectTimeRange(
                                'Yesterday',
                                context,
                              ),
                            ),
                          ),

                          Obx(
                            () => TimeTab(
                              text: 'Last 30 Days',
                              isSelected:
                                  homeController.selectedTimeRange.value ==
                                  'Last 30 Days',
                              onTap: () =>
                                  homeController.selectTimeRange(
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
                                  homeController.selectedTimeRange.value ==
                                  'Select Range',
                              onTap: () =>
                                  homeController.selectTimeRange(
                                'Select Range',
                                context,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // -------------------------------------------------------
                    // CALL STATS
                    // -------------------------------------------------------
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      color: Colors.white,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: ColorConstants.MainPurpleBackground
                              .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: _buildStatTab(
                                context: context,
                                label: 'Overall',
                                count: homeController
                                        .dashboardData
                                        .value
                                        .data
                                        ?.callStats
                                        ?.overall ??
                                    0,
                                isFirst: true,
                                isLast: false,
                              ),
                            ),

                            _buildStatTab(
                              context: context,
                              label: 'Outbound',
                              count: homeController
                                      .dashboardData
                                      .value
                                      .data
                                      ?.callStats
                                      ?.outbound ??
                                  0,
                              isFirst: false,
                              isLast: false,
                            ),

                            _buildStatTab(
                              context: context,
                              label: 'Inbound',
                              count: homeController
                                      .dashboardData
                                      .value
                                      .data
                                      ?.callStats
                                      ?.inbound ??
                                  0,
                              isFirst: false,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // -------------------------------------------------------
                    // TALK TIME
                    // -------------------------------------------------------
                    SizedBox(height: 10),

                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ColorConstants.MainPurpleBackground
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${homeController.dashboardData.value.data!.callStats!.totalDuration.toString()}s',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'in Sec\'s',
                                    style: TextStyle(fontSize: 12.9),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(width: 25),

                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ColorConstants.MainPurpleBackground
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    homeController
                                            .dashboardData
                                            .value
                                            .data!
                                            .callStats!
                                            .formattedTotalDuration ??
                                        '0h 0m 0s',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Total Talk Time',
                                    style: TextStyle(fontSize: 12.9),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // -------------------------------------------------------
                    // CALL / FOLLOW-UP CARDS
                    // -------------------------------------------------------
                    SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.2,
                        children: [
                          // TOTAL CALLS
                          GestureDetector(
                            onTap: () => Get.to(
                              () => CallLogs(
                                startDate:
                                    homeController.selectedStartDate.value,
                                endDate:
                                    homeController.selectedEndDate.value,
                                timeRange:
                                    homeController.selectedTimeRange.value,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ColorConstants.MainPurpleBackground
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.call,
                                        color: Colors.blue.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${homeController.dashboardData.value.data?.callStats?.callCount ?? 0}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total Calls',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // CONNECTED
                          GestureDetector(
                            onTap: () => Get.to(
                              () => CallLogs(
                                startDate:
                                    homeController.selectedStartDate.value,
                                endDate:
                                    homeController.selectedEndDate.value,
                                timeRange:
                                    homeController.selectedTimeRange.value,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ColorConstants.MainPurpleBackground
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.headset_mic,
                                        color: Colors.blue.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${homeController.dashboardData.value.data?.callStats?.connCount ?? 0}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Connected',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // REMINDER FOLLOW UP
                          GestureDetector(
                            onTap: () => Get.to(
                              () => MissedFollowupsPage(
                                initialType: 'All',
                                startDate:
                                    homeController.selectedStartDate.value,
                                endDate:
                                    homeController.selectedEndDate.value,
                                timeRange:
                                    homeController.selectedTimeRange.value,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ColorConstants.MainPurpleBackground
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        color: Colors.blue.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${homeController.dashboardData.value.data?.callStats?.followUp ?? 0}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reminder Follow Up',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // MISSED
                          GestureDetector(
                            onTap: () => Get.to(
                              () => MissedFollowupsPage(
                                initialType: 'Missed',
                                startDate:
                                    homeController.selectedStartDate.value,
                                endDate:
                                    homeController.selectedEndDate.value,
                                timeRange:
                                    homeController.selectedTimeRange.value,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ColorConstants.MainPurpleBackground
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.phone_missed,
                                        color: Colors.blue.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${homeController.dashboardData.value.data?.callStats?.missedFollowUps ?? 0}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Missed',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // -------------------------------------------------------
                    // SPACING
                    // -------------------------------------------------------
                    SizedBox(height: 10),

                    // -------------------------------------------------------
                    // TOTAL LEADS BREAKDOWN
                    // -------------------------------------------------------
                    if ((homeController
                            .allLeadStageRes
                            .value
                            .data
                            ?.isNotEmpty ??
                        false))
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Total Leads Breakdown',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),

                            SizedBox(height: 10),

                            ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: homeController
                                  .allLeadStageRes
                                  .value
                                  .data!
                                  .length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                var data = homeController
                                    .allLeadStageRes
                                    .value
                                    .data![index];

                                return Card(
                                  elevation: 0,
                                  surfaceTintColor: Colors.transparent,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  color: ColorConstants.MainPurpleBackground
                                      .withValues(alpha: 0.01),
                                  child: GestureDetector(
                                    onTap: () {
                                      homeController.mainSelectedIndices
                                          .clear();

                                      homeController.mainSelectedIndices.add(
                                        index + 1,
                                      );

                                      final ccontroller =
                                          Get.find<Claimedcontroller>();

                                      homeController.loadLeadsForSelectedTab(
                                        ccontroller,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 20,
                                      ),
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: ColorConstants
                                            .MainPurpleBackground
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            data.name.toString(),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            data.count.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                    // -------------------------------------------------------
                    // SEARCH BAR - VERY BOTTOM
                    // -------------------------------------------------------
                    const SizedBox(height: 15),

                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search leads...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                          ),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color:
                                  ColorConstants.MainPurpleBackground,
                              width: 1,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// STAT TAB
// -------------------------------------------------------

Widget _buildStatTab({
  required BuildContext context,
  required String label,
  required int count,
  required bool isFirst,
  required bool isLast,
}) {
  final HomeController homeController = Get.find();

  return Container(
    margin: EdgeInsets.only(
      left: isFirst ? 0 : 4,
      right: isLast ? 0 : 4,
    ),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatNumber(count),
                style: TextStyle(
                  fontSize: _getFontSizeForCount(count),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A237E),
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 2),

              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// -------------------------------------------------------
// FORMAT NUMBER
// -------------------------------------------------------

String _formatNumber(int number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  }

  return number.toString();
}

// -------------------------------------------------------
// FONT SIZE
// -------------------------------------------------------

double _getFontSizeForCount(int count) {
  final digits = count.toString().length;

  if (digits >= 4) return 14;
  if (digits >= 3) return 15;

  return 16;
}