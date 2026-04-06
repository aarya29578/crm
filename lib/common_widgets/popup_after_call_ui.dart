import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/common_widgets/call_storage.dart';
import 'package:crm_flutter/common_widgets/notificationService.dart';
import 'package:crm_flutter/local_storage/up_coming_followups_controller.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/Call/call_controller.dart';
import 'package:crm_flutter/pages/home/HomeController.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

class PopupAfterCallUi extends StatefulWidget {
  final String leadId;
  final String? stageName;
  const PopupAfterCallUi({super.key, required this.leadId, this.stageName});

  @override
  State<PopupAfterCallUi> createState() => _PopupAfterCallUiState();
}

class _PopupAfterCallUiState extends State<PopupAfterCallUi> {
  final TextEditingController notesController = TextEditingController();
  final HomeController homeController = Get.find<HomeController>();
  final AllocationController allocationController =
      Get.find<AllocationController>();
  final Leaddetailscontroller leadDetailsController =
      Get.find<Leaddetailscontroller>();
  final CallLogController callLogController = Get.put(CallLogController());
  String? selectedStage;
  String? selectedStageId;
  String? selectedSubStatusId;
  // bool? hasSubStatus;
  DateTime? dt;

  @override
  void initState() {
    super.initState();

    // homeController.getAllLeadStage();

    // print("leadId777:${widget.leadId}");

    // //CALL API WHEN BOTTOMSHEET OPENS
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   leadDetailsController.getAllLeadDetails(widget.leadId);
    // });
    Future.microtask(() async {
      await homeController.getAllLeadStage();
      await leadDetailsController.getAllLeadDetails(context, widget.leadId);
    });
  }

  Future<void> _pickDateTime() async {
    // final DateTime? date = await showDatePicker(
    //   context: context,
    //   initialDate: DateTime.now(),
    //   firstDate: DateTime.now(),
    //   lastDate: DateTime(2100),
    // );
    ///WITH COLOR THEME
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black, // Header + selected date
              onPrimary: Colors.white, // Text on header
              onSurface: Colors.black87, // Body text
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.orange),
            // dialogBackgroundColor: Colors.orange.shade700, // Background
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    // final TimeOfDay? time = await showTimePicker(
    //   context: context,
    //   initialTime: TimeOfDay.now(),
    // );

    // final TimeOfDay? time = await showTimePicker(
    //   context: context,
    //   initialTime: TimeOfDay.now(),
    //   builder: (context, child) {
    //     return MediaQuery(
    //       data: MediaQuery.of(context).copyWith(
    //         alwaysUse24HourFormat: false, // ✅ FORCE 12h
    //       ),
    //       child: child!,
    //     );
    //   },
    // );
    ///WITH COLOR THEME
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.black, // Dial + header
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
              dialogTheme: const DialogThemeData(
                backgroundColor: Colors.orange,
              ),
              // dialogBackgroundColor: Colors.orange.shade700,
            ),
            child: child!,
          ),
        );
      },
    );

    if (time == null) return;

    // setState(() {
    //   final combined = DateTime(
    //     date.year,
    //     date.month,
    //     date.day,
    //     time.hour,
    //     time.minute,
    //   );
    // });
    setState(() {
      dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final stages = homeController.allLeadStageRes.value.data ?? [];

    final selectedStageObj =
        stages.where((e) => e.sId == selectedStageId).isNotEmpty
        ? stages.firstWhere((e) => e.sId == selectedStageId)
        : null;

    final isFollowUp = selectedStageObj?.name == "Follow Up";

    final hasSubStatus = selectedStageObj?.hasSubStatus == true;

    // final stageChanged =
    //     selectedStageId != null && selectedStageId != currentStageId;

    // final followUpValid = !isFollowUp || dt != null;

    // final canSubmit = stageChanged && followUpValid;

    // final canSubmit = selectedStageId != null && (!isFollowUp || dt != null);

    // print("Stages from bottomsheetUi: ${stages[index].name}");
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Call Status",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                20.heightBox,

                Obx(() {
                  if (homeController.countLoading.value == PageState.loading) {
                    return const CircularProgressIndicator();
                  }

                  final stages =
                      homeController.allLeadStageRes.value.data ?? [];
                  final leadData =
                      leadDetailsController.allLeadDetailRes.value.data;

                  // final leadData =
                  //     leadDetailsController.allLeadDetailRes.value.data;
                  // final currentStageId = leadData?.leadStageId?.sId;

                  final currentStageId = leadData?.leadStageId?.sId;
                  final visitedStageIds = leadData?.visitedStageIds ?? [];

                  // initialize once
                  if (selectedStageId == null && currentStageId != null) {
                    selectedStageId = currentStageId;
                  }

                  return DropdownButton<String>(
                    value: selectedStageId,
                    items: stages.map((stage) {
                      final isVisited =
                          visitedStageIds.contains(stage.sId) &&
                          stage.sId != selectedStageId;

                      return DropdownMenuItem<String>(
                        value: stage.sId,
                        enabled: !isVisited,
                        child: Text(
                          stage.name ?? '',
                          style: TextStyle(
                            color: isVisited ? Colors.grey : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    // onChanged: (value) {
                    //   if (value != null) {
                    //     setState(() {
                    //       selectedStageId = value;
                    //     });

                    //     print("Selected Stage: $value");
                    //   }
                    // },
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() {
                          selectedStageId = value;
                          selectedSubStatusId = null; // reset substatus
                        });

                        final selectedStageObj = stages.firstWhere(
                          (e) => e.sId == value,
                        );

                        /// CALL API IF HAS SUBSTATUS
                        if (selectedStageObj.hasSubStatus == true) {
                          await homeController.getFailedSubLStage(
                            selectedStageId: value,
                          );
                        }
                      }
                    },
                  );
                }),

                if (hasSubStatus)
                  Obx(() {
                    if (homeController.subStageLoading.value ==
                        PageState.loading) {
                      return const CircularProgressIndicator();
                    }

                    final subStatuses =
                        homeController.allSubLStageRes.value.data ?? [];

                    if (subStatuses.isEmpty) {
                      return const Text("No Sub Status Available");
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: DropdownButtonFormField<String>(
                        value: selectedSubStatusId,
                        decoration: InputDecoration(
                          labelText: "Select Sub Status",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: subStatuses.map((sub) {
                          return DropdownMenuItem<String>(
                            value: sub.id,
                            child: Text(sub.name ?? ""),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSubStatusId = value;
                          });
                        },
                      ),
                    );
                  }),

                if (isFollowUp) ...[
                  const SizedBox(height: 17),
                  const Text("Format Date *"),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      // horizontal: 16,
                      vertical: 8,
                    ),
                    child: InkWell(
                      onTap: () => _pickDateTime(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                dt == null
                                    ? "Select Delivery Date & Time"
                                    : DateFormat(
                                        'dd/MM/yyyy  hh:mm a',
                                      ).format(dt!),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: dt == null
                                      ? Colors.grey.shade600
                                      : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.shade700,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                20.heightBox,
                Text(
                  "Notes(optional) :",
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                5.heightBox,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: notesController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Notes....",
                    ),
                  ),
                ),

                30.heightBox,

                ///Here will be the dropdown buttom using data(showing data in dropdown) stages[index].name
                // const Spacer(),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      // backgroundColor: selectedStageId != null
                      //     ? Colors.blue
                      //     : Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    ///Imp* check this
                    // onPressed: () async {
                    //   final callData = PendingCallData.data;
                    //   if (callData == null) {
                    //     print("❌ No pending call data");
                    //     Get.back();
                    //     return;
                    //   }
                    //   /// ✅ DECIDE VALUE
                    //   final leadStageValue =
                    //       selectedStageId ?? "Not selected by user";
                    //   callData["lead_stage_id"] = leadStageValue;
                    //   /// ✅ OPTIONAL NOTES
                    //   callData["notes"] = notesController.text;
                    //   print("✅ Final Payload: $callData");
                    //   try {
                    //     await DioApi().postPhoneCall(callData);
                    //     print("✅ API SUCCESS");
                    //     // await allocationController.getAllLeads();
                    //   } catch (e) {
                    //     print("❌ API FAILED: $e");
                    //   }
                    //   PendingCallData.data = null;
                    //   Get.back();
                    // },
                    // onPressed: () async {
                    //   final callData = PendingCallData.data;
                    //   if (callData == null) {
                    //     print("❌ No pending call data");
                    //     Get.back();
                    //     return;
                    //   }
                    //   /// 🚫 BLOCK if no stage selected
                    //   if (selectedStageId == null) {
                    //     Get.snackbar(
                    //       "Required",
                    //       "Please select Call Status",
                    //       snackPosition: SnackPosition.BOTTOM,
                    //       backgroundColor: Colors.red,
                    //       colorText: Colors.white,
                    //     );
                    //     return;
                    //   }
                    //   /// ✅ Mandatory lead stage
                    //   callData["lead_stage_id"] = selectedStageId;
                    //   /// ✅ Optional notes
                    //   callData["notes"] = notesController.text;
                    //   print("✅ Final Payload: $callData");
                    //   // try {
                    //   //   await DioApi().postPhoneCall(callData);
                    //   //   print("✅ API SUCCESS");
                    //   // } catch (e) {
                    //   //   print("❌ API FAILED: $e");
                    //   // }
                    //   // PendingCallData.data = null;
                    //   // Get.back();
                    //   try {
                    //     print("🚀 Hitting API...");
                    //     await DioApi().postPhoneCall(callData);
                    //     // await allocationController.getAllLeads();
                    //     allocationController.selectTimeRange(
                    //       allocationController.selectedTimeRange.value,
                    //       context,
                    //     );
                    //     callLogController.getApi();
                    //     print("✅ API SUCCESS");
                    //   } catch (e) {
                    //     print("❌ API FAILED: $e");
                    //   }
                    //   print("📦 Clearing pending data");
                    //   PendingCallData.data = null;
                    //   print("⬅️ Going back now...");
                    //   // Get.back();
                    //   Navigator.pop(context, true);
                    // },
                    onPressed: () async {
                      final callData = PendingCallData.data;

                      if (callData == null) {
                        print("No pending call data");
                        Navigator.pop(context);
                        return;
                      }

                      if (selectedStageId == null) {
                        // Get.snackbar(
                        //   "Required",
                        //   "Please select Call Status",
                        //   snackPosition: SnackPosition.BOTTOM,
                        //   backgroundColor: Colors.red,
                        //   colorText: Colors.white,
                        // );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please select Call Status"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (hasSubStatus && selectedSubStatusId == null) {
                        // Get.snackbar(
                        //   "Required",
                        //   "Please select Sub Status",
                        //   snackPosition: SnackPosition.BOTTOM,
                        //   backgroundColor: Colors.red,
                        //   colorText: Colors.white,
                        // );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please select Sub Status"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      /// BLOCK if Follow Up but no date selected
                      if (isFollowUp && dt == null) {
                        // Get.snackbar(
                        //   "Required",
                        //   "Please select Follow Up Date & Time",
                        //   snackPosition: SnackPosition.BOTTOM,
                        //   backgroundColor: Colors.red,
                        //   colorText: Colors.white,
                        // );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Please select Follow Up Date & Time",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      callData["lead_stage_id"] = selectedStageId;
                      callData["remarks"] = notesController.text;

                      callData["sub_status_id"] = hasSubStatus
                          ? selectedSubStatusId
                          : null;

                      if (isFollowUp) {
                        callData["followUpDate"] = dt!.toIso8601String();
                      }

                      print("Hitting API...");

                      try {
                        await DioApi().postPhoneCall(callData);
                        print("API SUCCESS");

                        PendingCallData.data = null;

                        await Get.find<FollowUpController>().syncWithApi();

                        /// CLOSE DIALOG FIRST
                        Navigator.pop(context);

                        /// Refresh AFTER dialog closes
                        Future.microtask(() {
                          print("Refreshing Screens");

                          allocationController.selectTimeRange(
                            allocationController.selectedTimeRange.value,
                            context,
                          );

                          callLogController.getApi();
                        });
                      } catch (e) {
                        print("API FAILED: $e");
                      }
                    },

                    child: Text(
                      // selectedStageId != null
                      "Continue with Changes",
                    ),
                    // child: const Text("Continue with Changes"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildNotesPlusMenunameSection(
  String? title,
  String? hintText,
  controller,
) {
  return Container(
    width: double.infinity,
    child: Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            title!.text.size(18).fontWeight(FontWeight.w400).make(),
            12.heightBox,
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.orange.shade700),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
