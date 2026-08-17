import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/Allocations/components/callLogCard.dart';
import 'package:crm_flutter/pages/Allocations/components/newAtemptedTab.dart';
import 'package:crm_flutter/pages/Allocations/missedFollowUps/missed_followups_page.dart';
import 'package:crm_flutter/pages/home/components/time_tab.dart';
import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/widgets/show_call_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:velocity_x/velocity_x.dart';

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

  @override
  void initState() {
    super.initState();
    print("On USE EFFECT");

    // allocationController.api;

    // Schedule the API call after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      allocationController.selectTimeRange('Today', context);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (allocationController.isMoreDataAvailable.value &&
            !allocationController.isPaginationLoading.value) {
          allocationController.getAllLeads();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> patchDataAccept(id) async {
    try {
      // print("leadiddetailpage:${widget.leadId}");
      await leadDetailsController.getAllLeadDetailsPatchA(id);
    } catch (e) {
      print("Error in loadData: $e");
      //   ScaffoldMessenger.of(
      //     context,
      //   ).showSnackBar(SnackBar(content: Text("Failed to load data: $e")));
    }
  }

  Future<void> patchDataDecline(id) async {
    try {
      // print("leadiddetailpage:${widget.leadId}");
      await leadDetailsController.getAllLeadDetailsPatchD(id);
    } catch (e) {
      print("Error in loadData: $e");
      //   ScaffoldMessenger.of(
      //     context,
      //   ).showSnackBar(SnackBar(content: Text("Failed to load data: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> requestPermissions() async {
      // 1. Define the specific permission you need
      // For example, if you need to access contacts to find a number:
      PermissionStatus status = await Permission.contacts.status;

      if (status.isGranted) {
        return true; // Already granted
      }

      // 2. Request the permission
      status = await Permission.contacts.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // 3. User denied and checked 'Don't ask again'
        // This is where you should show a dialog and direct them to app settings
        await openAppSettings();
        return false;
      }

      // All other non-granted states (denied, restricted, etc.)
      return false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Allocations",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: ColorConstants.MainPurpleBackground,
        actions: [
          Image.asset('assets/overdue.png', width: 30).onTap(() {
            Get.to(
              () => MissedFollowupsPage(),
              transition: Transition.rightToLeft,
            );
          }),
          // // Container(
          // //   width: 40,
          // //   height: 35,
          // //   // padding: const EdgeInsets.all(1),
          // //   decoration: BoxDecoration(
          // //     color: Colors.white,
          // //     borderRadius: BorderRadius.circular(40),
          // //   ),
          // //   child: IconButton(
          // //     onPressed: () {
          // //       Get.to(
          // //         () => MissedFollowupsPage(),
          // //         transition: Transition.rightToLeft,
          // //       );
          // //     },
          // //     icon: Icon(
          // //       Icons.call_missed,
          // //       color: Colors.red.shade300,
          // //       size: 20,
          // //     ),
          // //   ),
          // // ),
          const SizedBox(width: 15),
          IconButton(
            onPressed: () {
              allocationController.selectTimeRange(
                allocationController.selectedTimeRange.value,
                context,
              );
            },
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Obx(() {
        final leads = allocationController.leads;

        return Container(
          decoration: BoxDecoration(
            color: ColorConstants.MainPurpleBackground.withValues(alpha: 0.06),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 10),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: const [
              //       NewAttemptedTab(text: "New", count: 5),
              //       SizedBox(width: 10),
              //       NewAttemptedTab(text: "Attempted", count: 3),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(width: 10),
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
              SizedBox(height: 10),

              Expanded(
                child: allocationController.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black87,
                          strokeWidth: 2,
                        ),
                      )
                    : leads.isEmpty
                    ? const Center(
                        child: Text(
                          "No Leads found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: leads.length + 1,
                        itemBuilder: (context, index) {
                          if (index < leads.length) {
                            final data = leads[index];
                            return Container(
                              // color: Colors.amber,
                              child: CallLogCard(
                                name:
                                    "${data.name?.first ?? ''} ${data.name?.last ?? ''}",
                                leadId: data.sId,
                                timelineData: data.timeline,
                                campaignId: data.compaignName?.sId ?? '',
                                campaign:
                                    data.compaignName?.name ?? 'no campaign',
                                tag: data.leadStageId?.name ?? '',
                                assignedTo: data.assignedTo,
                                accept: () async {
                                  showAcceptDialog(
                                    context,
                                    "Accept",
                                    data.name?.first ?? '',
                                    () async {
                                      await patchDataAccept(data.sId);
                                      allocationController.selectTimeRange(
                                        allocationController
                                            .selectedTimeRange
                                            .value,
                                        context,
                                      );
                                    },
                                  );
                                },
                                decline: () async {
                                  showAcceptDialog(
                                    context,
                                    "Reject",
                                    data.name?.first ?? '',
                                    () async {
                                      await patchDataDecline(data.sId);
                                      allocationController.selectTimeRange(
                                        allocationController
                                            .selectedTimeRange
                                            .value,
                                        context,
                                      );
                                    },
                                  );
                                },
                                time: data.updatedAt ?? '',
                                followUp: data.followUpDate,
                                phone: data.phone ?? 0,
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
                                  requestPermissions();
                                  if (data.assignedTo != null) {
                                    showCallAlertDialog(
                                      context,
                                      'Call ${data.name?.first ?? ''}',
                                      'Are you sure want to call to $phone number?',
                                      () async {
                                        /////
                                        // await CallHelper.callAndTrack(phone);
                                        await CallHelper.callAndTrack(
                                          phone,
                                          data.sId ?? '',
                                          data.leadStageId?.name ?? '',
                                        );
                                        // Navigator.pop(context);
                                      },
                                      Colors.blue,
                                    );
                                  }
                                  // await CallHelper.callAndTrack(phone);
                                },
                              ),
                            );
                          }
                          return allocationController.isPaginationLoading.value
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.black54,
                                    ),
                                  ),
                                )
                              : const SizedBox();
                        },
                      ),
              ),
            ],
          ),
        );
      }),
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
      barrierDismissible: false, // user must tap button
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
                Navigator.pop(context); // close dialog
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
                Navigator.pop(context); // close dialog
                onAccept(); // perform action
              },
              child: Text(mainText),
            ),
          ],
        );
      },
    );
  }
}
