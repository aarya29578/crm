import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/pages/Allocations/components/callLogCard.dart';
import 'package:crm_flutter/pages/Allocations/missedFollowUps/missed_followups_controller.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/widgets/show_call_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MissedFollowupsPage extends StatefulWidget {
  const MissedFollowupsPage({super.key});

  @override
  State<MissedFollowupsPage> createState() => _MissedFollowupsPageState();
}

class _MissedFollowupsPageState extends State<MissedFollowupsPage> {
  final ScrollController _scrollController = ScrollController();
  final AllMissFUpsController _allMissFUpsController = Get.put(
    AllMissFUpsController(),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _allMissFUpsController.getAllMissedFUps(isRefresh: true);
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
        title: Text(
          "Missed FollowUp's",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: ColorConstants.MainPurpleBackground,
        actions: [
          IconButton(
            onPressed: () {
              _allMissFUpsController.getAllMissedFUps(isRefresh: true);
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
              Expanded(
                child: _allMissFUpsController.isLoading.value == true
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black87,
                          strokeWidth: 2,
                        ),
                      )
                    : leads.isEmpty
                    ? const Center(
                        child: Text(
                          "No Missed Follow-up found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _allMissFUpsController
                            .getAllMissedFUps(isRefresh: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: leads.length + 1,
                          itemBuilder: (context, index) {
                            if (index < leads.length) {
                              final data = leads[index];
                              return Container(
                                // color: Colors.amber,
                                child: CallLogCard(
                                  isMissedFUps: true,
                                  name:
                                      "${data.name?.first ?? ''} ${data.name?.last ?? ''}",
                                  leadId: data.sId,
                                  timelineData: data.timeline,
                                  campaign:
                                      data.compaignName?.name ?? 'no campaign',
                                  tag: data.leadStageId?.name ?? '',
                                  // assignedTo: data.assignedTo,
                                  time: data.updatedAt ?? '',
                                  followUp: data.followUpDate,
                                  phone: data.phone ?? 0,
                                  onCallBack: () async {
                                    final phone = data.phone?.toString() ?? '';
                                    if (phone.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Phone number not available",
                                          ),
                                        ),
                                      );

                                      return;
                                    }
                                    // requestPermissions();
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
