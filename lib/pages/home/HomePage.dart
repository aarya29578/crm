import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/home/components/time_tab.dart';
import 'package:crm_flutter/pages/home/components/type_tab.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/home/HomeController.dart';
import 'package:crm_flutter/pages/ignored_leads/IgnoredLeadsPage.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:crm_flutter/widgets/ColorCountLabelCard.dart';
import 'package:crm_flutter/widgets/CountLabelCard.dart';
import 'package:crm_flutter/widgets/ListTileCard.dart';
import 'package:get/get.dart';
import 'package:crm_flutter/pages/follow_up/TodayFollowUpPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    // home_controller.getAllLeadStage();
    homeController.selectTimeRange('Today', context);
    homeController.getAllLeads();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.MainPurpleBackground.withValues(
        alpha: 0.06,
      ),

      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Obx(() {
          return homeController.dashboardLoading.value == PageState.loading
              ? Container(
                  height: MediaQuery.of(context).size.height - 150,
                  child: Center(child: CircularProgressIndicator()),
                )
              : homeController.dashboardLoading.value == PageState.error
              ? Center(child: Text("Error loading data"))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text("Upcoming events for today", style: greyHeading),
                    // const SizedBox(height: 8),
                    // GestureDetector(
                    //   onTap: () {
                    //     Get.to(TodayFollowUpPage());
                    //   },
                    //   child: ColorCountLabelCard(context),
                    // ),
                    // //ColorCountLabelCard(context),
                    // const SizedBox(height: 16),

                    // Text("Action Required", style: greyHeading),
                    // const SizedBox(height: 8),
                    // GestureDetector(
                    //   onTap: () {
                    //     Get.to(IgnoredLeadsPage());
                    //   },
                    //   child: ListTileCard(),
                    // ),

                    // const SizedBox(height: 16),

                    // Text("Leads Summary", style: greyHeading),
                    // const SizedBox(height: 8),
                    // if ((homeController
                    //         .allLeadStageRes
                    //         .value
                    //         .data
                    //         ?.isNotEmpty ??
                    //     false))
                    //   GridView.builder(
                    //     shrinkWrap: true,
                    //     itemCount:
                    //         homeController.allLeadStageRes.value.data!.length,
                    //     physics: const NeverScrollableScrollPhysics(),
                    //     gridDelegate:
                    //         const SliverGridDelegateWithFixedCrossAxisCount(
                    //           crossAxisCount: 2,
                    //           mainAxisSpacing: 12,
                    //           crossAxisSpacing: 12,
                    //           childAspectRatio: 2.4,
                    //         ),
                    //     itemBuilder: (context, index) {
                    //       final item =
                    //           homeController.allLeadStageRes.value.data![index];
                    //       print("++++++++++++++++++++++++++++++++++++++++");
                    //       print(item.toJson());
                    //       print("++++++++++++++++++++++++++++++++++++++++");
                    //       return countLabelCard(
                    //         item.count.toString(),
                    //         item.name,
                    //       );
                    //     },
                    //   ),
                    const SizedBox(height: 10),
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
                              onTap: () => homeController.selectTimeRange(
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
                              onTap: () => homeController.selectTimeRange(
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
                              onTap: () => homeController.selectTimeRange(
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
                              onTap: () => homeController.selectTimeRange(
                                'Select Range',
                                context,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //
                    const SizedBox(height: 10),

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
                          color: ColorConstants.MainPurpleBackground.withValues(
                            alpha: 0.06,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Expanded(
                            //   child: buildTab(
                            //     "Overall - ${homeController.dashboardData.value.data?.callStats?.overall ?? 0}",
                            //     1,
                            //   ),
                            // ),
                            Expanded(
                              child: _buildStatTab(
                                context: context,
                                label: 'Overall',
                                count:
                                    homeController
                                        .dashboardData
                                        .value
                                        .data
                                        ?.callStats
                                        ?.overall ??
                                    0,
                                // index: 1,
                                isFirst: true,
                                isLast: false,
                              ),
                            ),
                            // Expanded(
                            //   child: buildTab(
                            //     "Outbound -  ${homeController.dashboardData.value.data?.callStats?.outbound ?? 0}",
                            //     2,
                            //   ),
                            // ),
                            _buildStatTab(
                              context: context,
                              label: 'Outbound',
                              count:
                                  homeController
                                      .dashboardData
                                      .value
                                      .data
                                      ?.callStats
                                      ?.outbound ??
                                  0,
                              // index: 2,
                              isFirst: false,
                              isLast: false,
                            ),
                            // Expanded(
                            //   child: buildTab(
                            //     "Inbound -  ${homeController.dashboardData.value.data?.callStats?.inbound ?? 0}",
                            //     3,
                            //   ),
                            // ),
                            _buildStatTab(
                              context: context,
                              label: 'Inbound',
                              count:
                                  homeController
                                      .dashboardData
                                      .value
                                      .data
                                      ?.callStats
                                      ?.inbound ??
                                  0,
                              // index: 3,
                              isFirst: false,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // SizedBox(height: 10),

                    // // Tab Content
                    // // if (home_controller.selectedTab.value == 1) ...[
                    // if (homeController
                    //         .dashboardData
                    //         .value
                    //         .data!
                    //         .leadCountByConnected!
                    //         .length >
                    //     0)
                    //   Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 10),
                    //     child: Row(
                    //       children:
                    //           homeController
                    //               .dashboardData
                    //               .value
                    //               .data!
                    //               .leadCountByConnected!
                    //               .expand(
                    //                 (e) => [
                    //                   Expanded(
                    //                     child: CallCountInfo(
                    //                       count: e.count.toString() ?? "",
                    //                       percentage:
                    //                           e.percentage.toString() ?? "",
                    //                       status: e.connected.toString() ?? "",
                    //                     ),
                    //                   ),
                    //                   const SizedBox(width: 10), // Separator
                    //                 ],
                    //               )
                    //               .toList()
                    //             ..removeLast(), // Remove the last SizedBox
                    //     ),
                    //   ),

                    // ] else if (home_controller.selectedTab.value == 2) ...[
                    //   Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 10),

                    //     child: Row(
                    //       children: [
                    //         Expanded(
                    //           child: CallCountInfo(
                    //             count: '15',
                    //             percentage: '25%',
                    //             status: 'Connected',
                    //           ),
                    //         ),
                    //         SizedBox(width: 10),
                    //         Expanded(
                    //           child: CallCountInfo(
                    //             count: '15',
                    //             percentage: '25%',
                    //             status: 'Connected',
                    //           ),
                    //         ),
                    //         SizedBox(width: 10),
                    //         Expanded(
                    //           child: CallCountInfo(
                    //             count: '15',
                    //             percentage: '25%',
                    //             status: 'Connected',
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ] else if (home_controller.selectedTab.value == 3) ...[
                    //   Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 10),

                    //     child: Row(
                    //       children: [
                    //         Expanded(
                    //           child: CallCountInfo(
                    //             count: '15',
                    //             percentage: '25%',
                    //             status: 'Connected',
                    //           ),
                    //         ),
                    //         SizedBox(width: 10),
                    //         Expanded(
                    //           child: CallCountInfo(
                    //             count: '15',
                    //             percentage: '25%',
                    //             status: 'Connected',
                    //           ),
                    //         ),
                    //         SizedBox(width: 10),
                    //         Expanded(
                    //           child: CallCountInfo(
                    //             count: '15',
                    //             percentage: '25%',
                    //             status: 'Connected',
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ]
                    // ,

                    // Talk Time  Description
                    // if (homeController
                    //         .dashboardData
                    //         .value
                    //         .data!
                    //         .callStats.
                    //     0)
                    SizedBox(height: 10),

                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    ColorConstants
                                        .MainPurpleBackground.withValues(
                                      alpha: 0.1,
                                    ),
                                // Colors.blue.shade50,
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
                                color:
                                    ColorConstants
                                        .MainPurpleBackground.withValues(
                                      alpha: 0.1,
                                    ),
                                // Colors.blue.shade50,
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
                    // Customers Section Data
                    SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// Total Customers Section
                          // Container(
                          //   padding: const EdgeInsets.all(12),
                          //   decoration: BoxDecoration(
                          //     color: //Colors.blue.shade50,
                          //     ColorConstants.MainPurpleBackground.withValues(
                          //       alpha: 0.1,
                          //     ),
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   child: Column(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       Row(
                          //         // mainAxisAlignment:
                          //         //     MainAxisAlignment.spaceEvenly,
                          //         mainAxisSize: MainAxisSize.min,
                          //         children: [
                          //           Icon(
                          //             Icons.people,
                          //             color: Colors.blue.shade700,
                          //             size: 20,
                          //           ),
                          //           const SizedBox(width: 8),
                          //           Text(
                          //             '${homeController.dashboardData.value.data?.totalLeads ?? 0}',
                          //             style: TextStyle(
                          //               fontSize: 18,
                          //               fontWeight: FontWeight.bold,
                          //               color: Colors.blue.shade800,
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //       const SizedBox(height: 4),
                          //       Text(
                          //         'Total Leads',
                          //         style: TextStyle(
                          //           fontSize: 12,
                          //           color: Colors.grey.shade600,
                          //           fontWeight: FontWeight.w500,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: //Colors.blue.shade50,
                              ColorConstants.MainPurpleBackground.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.people,
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
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: //Colors.blue.shade50,
                              ColorConstants.MainPurpleBackground.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.people,
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
                                  'Follow Up',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: //Colors.blue.shade50,
                              ColorConstants.MainPurpleBackground.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.people,
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

                          // const SizedBox(width: 16),

                          // Customer Ranges Section
                          // Expanded(
                          //   child: Column(
                          //     children: [
                          //       ...(homeController
                          //                   .dashboardData
                          //                   .value
                          //                   .data
                          //                   ?.leadCountBystages ??
                          //               [])
                          //           .map(
                          //             (e) => CustomerRangeRow(
                          //               text: e.stage?.name ?? '',
                          //               percentage:
                          //                   double.tryParse(
                          //                     e.percentage
                          //                             ?.toString()
                          //                             .replaceAll('%', '') ??
                          //                         '',
                          //                   ) ??
                          //                   0,
                          //               count: e.count?.toString() ?? '0',
                          //             ),
                          //           )
                          //           .toList(),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    // Open ACtions
                    // SizedBox(height: 10),
                    // Container(
                    //   decoration: BoxDecoration(color: Colors.white),
                    //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         'Open Actions',
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //       ),
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           OpenActionTab(
                    //             icon: Icons.file_copy_outlined,
                    //             count: '15',
                    //             text: 'Documents',
                    //             iconColor: Colors.blue,
                    //           ),
                    //           OpenActionTab(
                    //             icon: Icons.task_outlined,
                    //             count: '8',
                    //             text: 'Tasks',
                    //             iconColor: Colors.green,
                    //           ),
                    //           OpenActionTab(
                    //             icon: Icons.calendar_today_outlined,
                    //             count: '3',
                    //             text: 'Meetings',
                    //             iconColor: Colors.orange,
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 10),

                    //  Statuses Section
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
                        decoration: BoxDecoration(color: Colors.white),
                        child: Column(
                          children: [
                            Text(
                              'Status',
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
                              // separatorBuilder: (context, index) =>
                              //     Divider(color: Colors.grey.shade500),
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
                                  surfaceTintColor:
                                      Colors.transparent, // VERY IMPORTANT
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  color:
                                      ColorConstants
                                          .MainPurpleBackground.withValues(
                                        alpha: 0.01,
                                      ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 20,
                                    ),
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color:
                                          ColorConstants
                                              .MainPurpleBackground.withValues(
                                            alpha: 0.12,
                                          ),
                                      //border: Border.all(color: Colors.black),
                                      //boxShadow: [BoxShadow(color: Colors.black)],
                                      borderRadius: BorderRadius.circular(12),
                                    ),

                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          data.name.toString(),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          data.count.toString(),
                                          style: TextStyle(
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
                          ],
                        ),
                      ),

                    //
                  ],
                );
        }),
      ),
    );
  }
}

Widget _buildStatTab({
  required BuildContext context,
  required String label,
  required int count,
  // required int index,
  required bool isFirst,
  required bool isLast,
}) {
  final HomeController homeController = Get.find();
  // final isSelected = homeController.selectedTab.value == index;

  return Expanded(
    child: Container(
      margin: EdgeInsets.only(left: isFirst ? 0 : 4, right: isLast ? 0 : 4),
      child: Material(
        // color: isSelected ? Theme.of(context).primaryColor : Colors.white,
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          // onTap: () => homeController.selectedTab.value = index,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Count - emphasized for large numbers
                Text(
                  _formatNumber(count),
                  style: TextStyle(
                    fontSize: _getFontSizeForCount(count),
                    fontWeight: FontWeight.w700,
                    // color: isSelected
                    //     ? Colors.white
                    //     : const Color(0xFF1A237E), //Try it amazing
                    color: const Color(0xFF1A237E),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Label
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    // color: isSelected
                    //     ? Colors.white.withOpacity(0.9)
                    //     : Colors.grey[600],
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
    ),
  );
}

String _formatNumber(int number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  }
  return number.toString();
}

double _getFontSizeForCount(int count) {
  final digits = count.toString().length;
  if (digits >= 4) return 14;
  if (digits >= 3) return 15;
  return 16;
}
