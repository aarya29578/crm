import 'dart:io';
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_lead_details_response.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/Allocations/WhatsappSMS/whatsapp_sms_controller.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
import 'package:crm_flutter/pages/home/HomeController.dart';
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class CallLogCard extends StatelessWidget {
  final context;
  final bool? isMissedFUps;
  final List<Timeline>? timelineData;
  final String name;
  final String? leadId;
  final String? campaignId;
  final String? campaign;
  final String tag;
  final AssignedTo? assignedTo;
  final VoidCallback? accept;
  final VoidCallback? decline;
  final DateTime? followUp;
  final String time;
  final int? phone;
  final String? source;
  final String? subSource;
  // final bool isMissedCall;
  final VoidCallback? onCallBack;
  final List<dynamic>? stageFieldValues;
  final VoidCallback? onTap;

  CallLogCard({
    super.key,
    this.context,
    this.isMissedFUps = false,
    this.timelineData,
    required this.name,
    this.leadId,
    this.campaignId,
    this.campaign,
    required this.tag,
    this.assignedTo,
    this.accept,
    this.decline,
    this.followUp,
    this.time = "no time found",
    this.onTap,
    this.phone,
    this.source,
    this.subSource,
    // this.isMissedCall = false,
    this.onCallBack,
    this.stageFieldValues,
  });

  final Leaddetailscontroller leadDetailsController = Get.put(
    Leaddetailscontroller(),
  );

  final HomeController homeController = Get.put(HomeController());

  final WhatsappSmsController _whatsappSmsController =
      Get.find<WhatsappSmsController>();

  final AllocationController allocationController =
      Get.find<AllocationController>();

  RxList<PlatformFile> selectedFiles = <PlatformFile>[].obs;
  RxList<String> removedFiles = <String>[].obs;
  final RxBool isSavingField = false.obs;
  final RxList<Timeline> updatedTimeline = <Timeline>[].obs;

  void openBottomSheet(
    BuildContext context,
    List<Timeline>? data,
    leadID,
  ) async {
    selectedFiles.clear();
    removedFiles.clear();

    // Use the class-level timeline
    updatedTimeline.assignAll(data ?? []);

    await homeController.getAllLeadStage();
    await leadDetailsController.getAllLeadDetails(context, leadID);

    final leadData = leadDetailsController.allLeadDetailRes.value.data;
    final currentStageId = leadData?.leadStageId?.sId;
    final stages = homeController.allLeadStageRes.value.data ?? [];
    final selectedStageObj =
        stages.where((e) => e.sId == currentStageId).isNotEmpty
        ? stages.firstWhere((e) => e.sId == currentStageId)
        : null;

    if (selectedStageObj?.hasSubStatus == true) {
      await homeController.getFailedSubLStage(selectedStageId: currentStageId);
    }

    final RxList<dynamic> stageFields = <dynamic>[].obs;
    final RxBool isLoadingFields = false.obs;
    final RxMap<String, DateTime> dynamicDates = <String, DateTime>{}.obs;
    final RxMap<String, TextEditingController> textControllers =
        <String, TextEditingController>{}.obs;

    Future<void> fetchStageFields(String stageId) async {
      isLoadingFields.value = true;
      stageFields.clear();

      try {
        final res = await DioApi().getLeadStageById(stageId);
        if (res['success'] == true) {
          final List<dynamic> fields = res['data']['fields'] ?? [];
          stageFields.assignAll(fields);

          // Pre-fill
          final leadData = leadDetailsController.allLeadDetailRes.value.data;
          if (leadData != null) {
            for (var field in fields) {
              final fieldId = field['_id'];
              final fieldType = field['fieldType'];

              if (fieldType == 'datetime') {
                if (leadData.followUpDate != null &&
                    leadData.followUpDate!.isNotEmpty) {
                  try {
                    dynamicDates[fieldId] = DateTime.parse(
                      leadData.followUpDate!,
                    ).toLocal();
                  } catch (e) {
                    print("Error parsing followUpDate: $e");
                  }
                }
              } else if (fieldType == 'text') {
                final savedValue = leadData.stageFieldValues?.firstWhere(
                  (f) => f['fieldId'] == fieldId,
                  orElse: () => null,
                );
                if (savedValue != null) {
                  textControllers[fieldId] = TextEditingController(
                    text: savedValue['value']?.toString() ?? '',
                  );
                } else {
                  textControllers[fieldId] = TextEditingController();
                }
              }
            }
          }
        }
      } catch (e) {
        print("Error fetching stage fields: $e");
      } finally {
        isLoadingFields.value = false;
      }
    }

    if (currentStageId != null) {
      await fetchStageFields(currentStageId);
    }

    // RxList documents = <dynamic>[].obs;
    RxList<Document> documents = <Document>[].obs;

    RxBool isDocumentExist = false.obs;
    // RxList<PlatformFile> selectedFiles = <PlatformFile>[].obs;

    // final getResponse =
    //     leadDetailsController.allLeadDetailRes.value.data?.documents;

    // documents.value = getResponse ?? [];
    // documents.assignAll(getResponse ?? []);
    // documents.assignAll(
    //   leadDetailsController.allLeadDetailRes.value.data?.documents ?? [],
    // );
    documents.value = List<Document>.from(
      leadDetailsController.allLeadDetailRes.value.data?.documents ?? [],
    );

    final originalDocuments = List<Document>.from(documents);

    // List documents = List.from(
    //   leadDetailsController.allLeadDetailRes.value.data?.documents ?? [],
    // );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String isoTime = time;
    final dateTime = DateTime.parse(isoTime).toLocal();
    final formattedTime = DateFormat('hh:mm a, dd MMM').format(dateTime);

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 1.0,
          minChildSize: 0.7,
          maxChildSize: 1.0,
          expand: true,

          builder: (context, scrollController) {
            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(Duration(seconds: 1));
                await leadDetailsController.getAllLeadDetails(context, leadID);

                // documents.assignAll(
                //   leadDetailsController
                //           .allLeadDetailRes
                //           .value
                //           .data
                //           ?.documents ??
                //       [],
                // );
                documents.value = List<Document>.from(
                  leadDetailsController
                          .allLeadDetailRes
                          .value
                          .data
                          ?.documents ??
                      [],
                );
                documents.refresh();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        /// drag handle
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ),
                        // const SizedBox(height: 20),

                        /// Name
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (phone != null)
                          Text(
                            phone.toString(),
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                        const SizedBox(height: 14),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Obx(() {
                            final leadData = leadDetailsController
                                .allLeadDetailRes
                                .value
                                .data;
                            final currentRating = leadData?.priority;
                            final List<String> ratingOptions = [
                              "Hot",
                              "Warm",
                              "Cold",
                              "Very Hot",
                              "Dead",
                            ];

                            return DropdownButtonFormField<String>(
                              initialValue:
                                  (currentRating != null &&
                                      ratingOptions.contains(currentRating))
                                  ? currentRating
                                  : null,
                              decoration: InputDecoration(
                                labelText: "Lead Rating",
                                prefixIcon: const Icon(
                                  Icons.star_outline,
                                  color: Colors.blue,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.grey[900]
                                    : Colors.grey.shade50,
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text("None"),
                                ),
                                ...ratingOptions.map((rating) {
                                  return DropdownMenuItem<String>(
                                    value: rating,
                                    child: Text(rating),
                                  );
                                }),
                              ],
                              onChanged: (value) async {
                                if (leadId != null) {
                                  try {
                                    await DioApi().patchLead(leadId!, {
                                      "priority": value,
                                    });
                                    // Refresh details
                                    await leadDetailsController
                                        .getAllLeadDetails(context, leadId!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Rating updated successfully",
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Failed to update rating: $e",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            );
                          }),
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Obx(() {
                            final stages =
                                homeController.allLeadStageRes.value.data ?? [];
                            final leadData = leadDetailsController
                                .allLeadDetailRes
                                .value
                                .data;
                            final currentStageId = leadData?.leadStageId?.sId;
                            final currentSubStatusId =
                                leadData?.subStatusId?.sId;

                            final selectedStageObj =
                                stages
                                    .where((e) => e.sId == currentStageId)
                                    .isNotEmpty
                                ? stages.firstWhere(
                                    (e) => e.sId == currentStageId,
                                  )
                                : null;
                            final hasSubStatus =
                                selectedStageObj?.hasSubStatus == true;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<String>(
                                  initialValue:
                                      stages.any((s) => s.sId == currentStageId)
                                      ? currentStageId
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: "Lead Status",
                                    prefixIcon: const Icon(
                                      Icons.layers_outlined,
                                      color: Colors.blue,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: isDark
                                        ? Colors.grey[900]
                                        : Colors.grey.shade50,
                                  ),
                                  items: stages.map((stage) {
                                    return DropdownMenuItem<String>(
                                      value: stage.sId,
                                      child: Text(
                                        stage.name ?? '',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) async {
                                    if (value != null && leadId != null) {
                                      try {
                                        final targetStageObj = stages
                                            .firstWhere((e) => e.sId == value);
                                        final newHasSubStatus =
                                            targetStageObj.hasSubStatus == true;

                                        await DioApi().patchLead(leadId!, {
                                          "lead_stage_id": value,
                                          "sub_status_id": null,
                                        });

                                        if (newHasSubStatus) {
                                          await homeController
                                              .getFailedSubLStage(
                                                selectedStageId: value,
                                              );
                                        }

                                        // Fetch new stage fields
                                        await fetchStageFields(value);

                                        // Refresh details
                                        await leadDetailsController
                                            .getAllLeadDetails(
                                              context,
                                              leadId!,
                                            );
                                        if (Get.isRegistered<
                                          AllocationController
                                        >()) {
                                          final allocationController =
                                              Get.find<AllocationController>();
                                          allocationController.selectTimeRange(
                                            allocationController
                                                .selectedTimeRange
                                                .value,
                                            context,
                                          );
                                        }
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Status updated successfully",
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Failed to update status: $e",
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),

                                if (hasSubStatus) ...[
                                  const SizedBox(height: 20),
                                  if (homeController.subStageLoading.value ==
                                      PageState.loading)
                                    const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  else ...[
                                    (() {
                                      final subStatuses =
                                          homeController
                                              .allSubLStageRes
                                              .value
                                              .data ??
                                          [];

                                      if (subStatuses.isEmpty) {
                                        return const Text(
                                          "No Sub Status Available",
                                        );
                                      }

                                      return DropdownButtonFormField<String>(
                                        initialValue:
                                            subStatuses.any(
                                              (sub) =>
                                                  sub.id == currentSubStatusId,
                                            )
                                            ? currentSubStatusId
                                            : null,
                                        decoration: InputDecoration(
                                          labelText: "Select Sub Status",
                                          prefixIcon: const Icon(
                                            Icons
                                                .subdirectory_arrow_right_rounded,
                                            color: Colors.blue,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.blue,
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: isDark
                                              ? Colors.grey[900]
                                              : Colors.grey.shade50,
                                        ),
                                        items: subStatuses.map((sub) {
                                          return DropdownMenuItem<String>(
                                            value: sub.id,
                                            child: Text(
                                              sub.name ?? '',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) async {
                                          if (val != null && leadId != null) {
                                            try {
                                              await DioApi().patchLead(
                                                leadId!,
                                                {"sub_status_id": val},
                                              );
                                              // Refresh details
                                              await leadDetailsController
                                                  .getAllLeadDetails(
                                                    context,
                                                    leadId!,
                                                  );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Sub Status updated successfully",
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Failed to update sub status: $e",
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      );
                                    })(),
                                  ],
                                ],

                                // Dynamic Fields Section
                                if (isLoadingFields.value)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else if (stageFields.isNotEmpty) ...[
                                  ...stageFields.map((field) {
                                    final fieldId = field['_id'];
                                    final fieldType = field['fieldType'];
                                    final fieldName =
                                        field['name'] ??
                                        (fieldType == 'datetime'
                                            ? 'Date & Time'
                                            : 'Field');

                                    if (fieldType == 'datetime') {
                                      final dateValue = dynamicDates[fieldId];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "$fieldName *",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            InkWell(
                                              onTap: () async {
                                                final now = DateTime.now();
                                                final date =
                                                    await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          dateValue ?? now,
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime(2100),
                                                    );
                                                if (date == null) return;

                                                final time =
                                                    await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          TimeOfDay.fromDateTime(
                                                            dateValue ??
                                                                DateTime.now(),
                                                          ),
                                                    );
                                                if (time == null) return;

                                                final combined = DateTime(
                                                  date.year,
                                                  date.month,
                                                  date.day,
                                                  time.hour,
                                                  time.minute,
                                                );
                                                if (combined.isBefore(
                                                  DateTime.now(),
                                                )) {
                                                  Get.snackbar(
                                                    "Error",
                                                    "Cannot select a past date or time",
                                                    snackPosition:
                                                        SnackPosition.TOP,
                                                    backgroundColor: Colors.red,
                                                    colorText: Colors.white,
                                                  );
                                                  return;
                                                }
                                                dynamicDates[fieldId] =
                                                    combined;

                                                // Save to backend immediately
                                                try {
                                                  await DioApi()
                                                      .patchLead(leadId!, {
                                                        "followUpDate": combined
                                                            .toIso8601String(),
                                                      });
                                                  await leadDetailsController
                                                      .getAllLeadDetails(
                                                        context,
                                                        leadId!,
                                                      );
                                                  Get.snackbar(
                                                    "Success",
                                                    "Date updated successfully",
                                                    snackPosition:
                                                        SnackPosition.TOP,
                                                    backgroundColor:
                                                        Colors.green,
                                                    colorText: Colors.white,
                                                  );
                                                } catch (e) {
                                                  Get.snackbar(
                                                    "Error",
                                                    "Failed to update date: $e",
                                                    snackPosition:
                                                        SnackPosition.TOP,
                                                    backgroundColor: Colors.red,
                                                    colorText: Colors.white,
                                                  );
                                                }
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 16,
                                                    ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: isDark
                                                      ? Colors.grey[900]
                                                      : Colors.grey.shade50,
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .calendar_month_outlined,
                                                      color: Colors.blue,
                                                      size: 22,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        dateValue == null
                                                            ? "Select $fieldName"
                                                            : DateFormat(
                                                                'dd MMM yyyy • hh:mm a',
                                                              ).format(
                                                                dateValue,
                                                              ),
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color:
                                                              dateValue == null
                                                              ? (isDark
                                                                    ? Colors
                                                                          .grey[400]
                                                                    : Colors
                                                                          .grey
                                                                          .shade600)
                                                              : (isDark
                                                                    ? Colors
                                                                          .white
                                                                    : Colors
                                                                          .black87),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
                                                      size: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (fieldType == 'text') {
                                      if (!textControllers.containsKey(
                                        fieldId,
                                      )) {
                                        textControllers[fieldId] =
                                            TextEditingController();
                                      }
                                      final controller =
                                          textControllers[fieldId]!;
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fieldName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: controller,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Enter $fieldName",
                                                      prefixIcon: const Icon(
                                                        Icons.edit_note_rounded,
                                                        color: Colors.blue,
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            borderSide:
                                                                BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                ),
                                                          ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            borderSide:
                                                                const BorderSide(
                                                                  color: Colors
                                                                      .blue,
                                                                  width: 2,
                                                                ),
                                                          ),
                                                      filled: true,
                                                      fillColor: isDark
                                                          ? Colors.grey[900]
                                                          : Colors.grey.shade50,
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 16,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Obx(
                                                  () => IconButton(
                                                    icon: isSavingField.value
                                                        ? const SizedBox(
                                                            width: 18,
                                                            height: 18,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          )
                                                        : const Icon(
                                                            Icons.save_rounded,
                                                            color: Colors.blue,
                                                          ),
                                                    onPressed:
                                                        isSavingField.value
                                                        ? null // disabled while a save is already in progress
                                                        : () async {
                                                            isSavingField
                                                                    .value =
                                                                true;
                                                            try {
                                                              final textFields =
                                                                  <
                                                                    Map<
                                                                      String,
                                                                      dynamic
                                                                    >
                                                                  >[];
                                                              for (var f
                                                                  in stageFields) {
                                                                final fId =
                                                                    f['_id'];
                                                                final fType =
                                                                    f['fieldType'];
                                                                if (fType ==
                                                                    'text') {
                                                                  final c =
                                                                      textControllers[fId];
                                                                  if (c !=
                                                                          null &&
                                                                      c
                                                                          .text
                                                                          .isNotEmpty) {
                                                                    textFields.add({
                                                                      "fieldId":
                                                                          fId,
                                                                      "fieldType":
                                                                          "text",
                                                                      "value": c
                                                                          .text,
                                                                    });
                                                                  }
                                                                }
                                                              }
                                                              await DioApi().patchLead(
                                                                leadId!,
                                                                {
                                                                  "stageFieldValues":
                                                                      textFields,
                                                                },
                                                              );
                                                              await leadDetailsController
                                                                  .getAllLeadDetails(
                                                                    context,
                                                                    leadId!,
                                                                  );
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                    "Field saved successfully",
                                                                  ),
                                                                ),
                                                              );
                                                            } catch (e) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    "Failed to save field: $e",
                                                                  ),
                                                                ),
                                                              );
                                                            } finally {
                                                              isSavingField
                                                                      .value =
                                                                  false; // always reset, success or fail
                                                            }
                                                          },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  }),
                                ],
                              ],
                            );
                          }),
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: InkWell(
                            focusColor: Colors.grey,
                            splashColor: Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => uploadFile(context),
                            /**
                             * {
  "status": "fail",
  "error": {
    "statusCode": 403,
    "status": "fail",
    "errorCode": null,
    "isOperational": true
  },
  "message": "Permission denied",
  "stack": "Error: Permission denied\n    at /opt/crm_backend/middleware/permissionMiddleware.js:29:21\n    at process.processTicksAndRejections (node:internal/process/task_queues:105:5)"
}
                             */
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("Click to upload your documents - "),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.link,
                                      size: 14,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Select Files",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          if (selectedFiles.isEmpty) return const SizedBox();

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Selected Files",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    if (selectedFiles.isNotEmpty)
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              selectedFiles.clear();
                                            },
                                            child: const Text("Cancel"),
                                          ),

                                          ElevatedButton(
                                            onPressed: () async {
                                              List<String> paths = [];

                                              for (var file in selectedFiles) {
                                                if (file.path != null) {
                                                  paths.add(file.path!);
                                                }
                                              }

                                              await DioApi()
                                                  .patchAllLeadDetails(
                                                    leadId!,
                                                    paths,
                                                    removedFiles,
                                                  );

                                              /// refresh api
                                              await leadDetailsController
                                                  .getAllLeadDetails(
                                                    context,
                                                    leadId,
                                                  );

                                              /// update local documents list
                                              // documents.assignAll(
                                              //   leadDetailsController
                                              //           .allLeadDetailRes
                                              //           .value
                                              //           .data
                                              //           ?.documents ??
                                              //       [],
                                              // );
                                              isDocumentExist.value = true;
                                              documents.value =
                                                  List<Document>.from(
                                                    leadDetailsController
                                                            .allLeadDetailRes
                                                            .value
                                                            .data
                                                            ?.documents ??
                                                        [],
                                                  );

                                              selectedFiles.clear();
                                              removedFiles.clear();
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Files uploaded successfully",
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                            child: Text(
                                              removedFiles.isNotEmpty
                                                  ? "Update"
                                                  : 'Upload',
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),

                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: selectedFiles.length,
                                  itemBuilder: (context, index) {
                                    final file = selectedFiles[index];

                                    return ListTile(
                                      leading: const Icon(
                                        Icons.insert_drive_file,
                                      ),
                                      title: Text(
                                        file.name,
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          selectedFiles.removeAt(index);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }),

                        // if (removedFiles.isNotEmpty ||
                        //     documents.isNotEmpty ||
                        //     isDocumentExist.value == true) ...[
                        //   const SizedBox(height: 15),
                        Obx(() {
                          if (removedFiles.isEmpty && documents.isEmpty) {
                            return const SizedBox();
                          }
                          print('removedfiles$removedFiles');
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Existing Documents",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    const Spacer(),
                                    if (removedFiles.isNotEmpty &&
                                        selectedFiles.isEmpty)
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              removedFiles.clear();

                                              /// restore original list
                                              documents.value =
                                                  originalDocuments;
                                            },
                                            child: const Text("Cancel"),
                                          ),

                                          ElevatedButton(
                                            onPressed: () async {
                                              List<String> paths = [];

                                              for (var file in selectedFiles) {
                                                if (file.path != null) {
                                                  paths.add(file.path!);
                                                }
                                              }

                                              await DioApi()
                                                  .patchAllLeadDetails(
                                                    leadId!,
                                                    paths,
                                                    removedFiles,
                                                  );

                                              // selectedFiles.clear();
                                              removedFiles.clear();

                                              /// refresh api
                                              await leadDetailsController
                                                  .getAllLeadDetails(
                                                    context,
                                                    leadId,
                                                  );

                                              /// update local documents list
                                              // documents.assignAll(
                                              //   leadDetailsController
                                              //           .allLeadDetailRes
                                              //           .value
                                              //           .data
                                              //           ?.documents ??
                                              //       [],
                                              // );
                                              documents.value =
                                                  List<Document>.from(
                                                    leadDetailsController
                                                            .allLeadDetailRes
                                                            .value
                                                            .data
                                                            ?.documents ??
                                                        [],
                                                  );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Files Updated successfully",
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                            child: const Text("Update"),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 10),

                        Obx(() {
                          if (removedFiles.isEmpty && documents.isEmpty) {
                            return const SizedBox();
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            // itemCount: getResponse.length,
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              // final item = getResponse[index];
                              final item = documents[index];
                              return Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isDark
                                        ? Colors.grey[850]
                                        : Colors.grey.shade100,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          focusColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onTap: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    "Download File",
                                                  ),
                                                  content: const Text(
                                                    "Do you want to download this file?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        );
                                                      },
                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        );
                                                      },
                                                      child: const Text(
                                                        "Download",
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (confirm != true) return;

                                            final documentsPath =
                                                await ExternalPath.getExternalStoragePublicDirectory(
                                                  ExternalPath
                                                      .DIRECTORY_DOCUMENTS,
                                                );

                                            /// CREATE CRM FOLDER
                                            final dir = Directory(
                                              "$documentsPath/CRM",
                                            );

                                            if (!await dir.exists()) {
                                              await dir.create(recursive: true);
                                            }

                                            /// FILE PATH
                                            final filePath =
                                                "${dir.path}/${item.originalName}";

                                            /// DOWNLOAD FILE
                                            await Dio().download(
                                              item.documentUrl ?? '',
                                              filePath,
                                            );

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Saved in $filePath",
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.originalName ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  'Upload date: ${formatDate(item.uploadDate)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    // fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  'File Size: ${formatFileSize(item.size ?? 0)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    // fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            /// store removed filename
                                            if (!removedFiles.contains(
                                              item.originalName,
                                            )) {
                                              removedFiles.add(
                                                item.originalName ?? '',
                                              );
                                            }

                                            /// remove from UI
                                            documents.removeAt(index);
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),

                        // ],
                        const SizedBox(height: 14),

                        // Source / Campaign / Subsource / Status details box
                        // Shown regardless of whether timeline data exists
                        if ((source != null && source!.isNotEmpty) ||
                            (campaign != null && campaign!.isNotEmpty) ||
                            (subSource != null && subSource!.isNotEmpty) ||
                            tag.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[850]
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (source != null && source!.isNotEmpty)
                                    _buildDetailRow('Source:', source!),
                                  if (source != null &&
                                      source!.isNotEmpty &&
                                      ((campaign != null &&
                                              campaign!.isNotEmpty) ||
                                          (subSource != null &&
                                              subSource!.isNotEmpty) ||
                                          tag.isNotEmpty))
                                    const SizedBox(height: 8),
                                  if (campaign != null && campaign!.isNotEmpty)
                                    _buildDetailRow('Campaign:', campaign!),
                                  if (campaign != null &&
                                      campaign!.isNotEmpty &&
                                      ((subSource != null &&
                                              subSource!.isNotEmpty) ||
                                          tag.isNotEmpty))
                                    const SizedBox(height: 8),
                                  if (subSource != null &&
                                      subSource!.isNotEmpty)
                                    _buildDetailRow('Subsource:', subSource!),
                                  if (subSource != null &&
                                      subSource!.isNotEmpty &&
                                      tag.isNotEmpty)
                                    const SizedBox(height: 8),
                                  if (tag.isNotEmpty)
                                    _buildDetailRow('Status:', tag),
                                ],
                              ),
                            ),
                          ),

                        Obx(() {
                          if (updatedTimeline.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  "No details found!",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Timeline",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 15),

                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: updatedTimeline.length,
                                itemBuilder: (context, index) {
                                  final item = updatedTimeline[index];

                                  final isLast =
                                      index == updatedTimeline.length - 1;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: index == 0
                                                    ? Colors.blue.shade50
                                                    : Colors.grey.shade50,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: index == 0
                                                      ? Colors.blue
                                                      : Colors.grey,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Icon(
                                                index == 0
                                                    ? Icons.circle
                                                    : Icons.check,
                                                size: 16,
                                                color: index == 0
                                                    ? Colors.blue
                                                    : Colors.grey,
                                              ),
                                            ),

                                            if (!isLast)
                                              Container(
                                                width: 2,
                                                height: 170,
                                                color: Colors.blue.shade100,
                                              ),
                                          ],
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.grey[850]
                                                  : Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.stage ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),

                                                const SizedBox(height: 2),

                                                Text(
                                                  formatTimelineDate(
                                                    item.date ?? '',
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),

                                                const SizedBox(height: 8),

                                                const Text(
                                                  "Agent: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                  ),
                                                ),

                                                Text(
                                                  item.agent ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),

                                                if (item.note != null &&
                                                    item.note!.isNotEmpty) ...[
                                                  const SizedBox(height: 3),

                                                  const Text(
                                                    "Notes: ",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),

                                                  Text(
                                                    item.note ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> uploadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result != null) {
      selectedFiles.addAll(result.files);
    }
  }

  String formatFileSize(int bytes) {
    const kb = 1024;
    const mb = 1024 * 1024;
    const gb = 1024 * 1024 * 1024;

    if (bytes < kb) {
      return "$bytes B";
    } else if (bytes < mb) {
      return "${(bytes / kb).toStringAsFixed(2)} KB";
    } else if (bytes < gb) {
      return "${(bytes / mb).toStringAsFixed(2)} MB";
    } else {
      return "${(bytes / gb).toStringAsFixed(2)} GB";
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return '';

    final dateTime = DateTime.parse(date).toLocal();

    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  String _processTemplate(String body) {
    String message = body;
    final agentName =
        LocalStorage.sharedPreferences!.getString('user_name') ?? "User";

    message = message.replaceAll(
      RegExp(
        r'[\{\[\<]+\s*(?:customer_name|customer name|name|lead_name|customer)\s*[\}\]\>]+',
        caseSensitive: false,
      ),
      name,
    );
    message = message.replaceAll(
      RegExp(
        r'[\{\[\<]+\s*(?:agent_name|agent name|agent)\s*[\}\]\>]+',
        caseSensitive: false,
      ),
      agentName,
    );
    return message;
  }

  void onWhatsApp(BuildContext context) {
    print("WhatsApp clicked");

    _whatsappSmsController.currentPage = 1;
    _whatsappSmsController.wsData.clear();
    _whatsappSmsController.isMoreDataAvailable.value = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.message, color: Colors.green.shade700, size: 24),
                const SizedBox(width: 10),
                Text(
                  'WhatsApp Templates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.only(top: 10, bottom: 0),
          content: Obx(() {
            if (_whatsappSmsController.isLoading.value == PageState.loading &&
                _whatsappSmsController.wsData.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                    SizedBox(height: 15),
                    Text("Loading templates..."),
                  ],
                ),
              );
            }

            if (_whatsappSmsController.wsData.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  "No templates available",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            return Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Scrollbar(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: _whatsappSmsController.wsData.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final templateData = _whatsappSmsController.wsData[index];
                    final templateBody = templateData.body ?? '';
                    final templateName =
                        templateData.name ?? 'Template ${index + 1}';

                    final processedMessage = _processTemplate(templateBody);

                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        try {
                          if (leadId == null || leadId!.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Lead ID is not available",
                              snackPosition: SnackPosition.TOP,
                            );
                            return;
                          }

                          final templateId = templateData.sId;

                          if (templateId == null || templateId.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Template ID is not available",
                              snackPosition: SnackPosition.TOP,
                            );
                            return;
                          }

                          // Record template usage
                          final response = await DioApi().recordTemplateUsage(
                            leadId: leadId!,
                            templateId: templateId,
                            channel: "whatsapp",
                          );

                          print(
                            "========== TEMPLATE USAGE RESPONSE ==========",
                          );
                          print(response);
                          print(
                            "=============================================",
                          );

                          // Refresh allocation data and wait for it to finish
                          await allocationController.refreshData();

                          // Find the updated lead
                          final updatedLead = allocationController.leads
                              .firstWhereOrNull((lead) => lead.sId == leadId);

                          // Update the timeline shown in the bottom sheet
                          if (updatedLead != null) {
                            updatedTimeline.assignAll(
                              updatedLead.timeline ?? [],
                            );

                            print("========== UPDATED TIMELINE ==========");
                            print("Timeline count: ${updatedTimeline.length}");
                            print("======================================");
                          } else {
                            print("Updated lead not found");
                          }

                          // Close template dialog
                          Navigator.pop(dialogContext);

                          // Open WhatsApp only once
                          await openWhatsApp(
                            phone.toString(),
                            processedMessage,
                          );
                        } catch (e) {
                          print("Template usage error: $e");

                          Get.snackbar(
                            "Error",
                            "Failed to record template usage: $e",
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    templateName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    processedMessage,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.send,
                                color: Colors.green.shade600,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ),
          ],
        );
      },
    );

    /// CALL API AFTER DIALOG OPENS
    Future.microtask(() {
      _whatsappSmsController.getWhatsSms(
        whichSource: 'whatsapp',
        campaignId: campaignId,
      );
    });
  }

  Future<void> openWhatsApp(String phone, String message) async {
    final encodedMessage = Uri.encodeComponent(message);

    final uri = Uri.parse(
      "whatsapp://send?phone=91$phone&text=$encodedMessage",
    );

    print("whatsappURL : $uri");

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // IMPORTANT
      );
    } else {
      print("WhatsApp not installed or cannot open");

      /// Fallback to browser (always works)
      final fallback = Uri.parse("https://wa.me/91$phone?text=$encodedMessage");

      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  void onSms(BuildContext context) {
    print("SMS clicked");

    _whatsappSmsController.currentPage = 1;
    _whatsappSmsController.wsData.clear();
    _whatsappSmsController.isMoreDataAvailable.value = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.sms, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 10),
                Text(
                  'SMS Templates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.only(top: 10, bottom: 0),
          content: Obx(() {
            if (_whatsappSmsController.isLoading.value == PageState.loading &&
                _whatsappSmsController.wsData.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 15),
                    Text("Loading templates..."),
                  ],
                ),
              );
            }

            if (_whatsappSmsController.wsData.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  "No templates available",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            return Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Scrollbar(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: _whatsappSmsController.wsData.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final templateData = _whatsappSmsController.wsData[index];
                    final templateBody = templateData.body ?? '';
                    final templateName =
                        templateData.name ?? 'Template ${index + 1}';

                    final processedMessage = _processTemplate(templateBody);

                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        try {
                          // Check lead ID
                          if (leadId == null || leadId!.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Lead ID is not available",
                              snackPosition: SnackPosition.TOP,
                            );
                            return;
                          }

                          // Get selected template ID
                          final templateId = templateData.sId;

                          if (templateId == null || templateId.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Template ID is not available",
                              snackPosition: SnackPosition.TOP,
                            );
                            return;
                          }

                          // Record template usage
                          final response = await DioApi().recordTemplateUsage(
                            leadId: leadId!,
                            templateId: templateId,
                            channel: "sms",
                          );

                          print(
                            "========== TEMPLATE USAGE RESPONSE ==========",
                          );
                          print(response);
                          print(
                            "=============================================",
                          );
                          await allocationController.refreshData();

                          // Find the updated lead
                          final updatedLead = allocationController.leads
                              .firstWhereOrNull((lead) => lead.sId == leadId);

                          // Update the timeline shown in the bottom sheet
                          if (updatedLead != null) {
                            updatedTimeline.assignAll(
                              updatedLead.timeline ?? [],
                            );

                            print("========== UPDATED SMS TIMELINE ==========");
                            print("Timeline count: ${updatedTimeline.length}");
                            print("==========================================");
                          } else {
                            print(
                              "Updated lead not found after SMS template usage",
                            );
                          }

                          // Close template dialog
                          Navigator.pop(dialogContext);

                          // Open SMS
                          await openSMS(phone.toString(), processedMessage);
                        } catch (e) {
                          Get.snackbar(
                            "Error",
                            "Failed to record SMS template usage: $e",
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    templateName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    processedMessage,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.send,
                                color: Colors.blue.shade600,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ),
          ],
        );
      },
    );

    Future.microtask(() {
      _whatsappSmsController.getWhatsSms(
        whichSource: 'sms',
        campaignId: campaignId,
      );
    });
  }

  Future<void> openSMS(String phone, String message) async {
    final url = "sms:$phone?body=${Uri.encodeComponent(message)}";

    print('SmsURL : $url');

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print("Could not launch SMS");
    }
  }

  // WE USED FOR SHOWING DATA INSIDE CARD OF ALLOCATION PAGE [SOURCE , SUBSOURCE AND CAMPAIGN]
  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        Text(value, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Example timestamp
    final String isoTime = time;

    // Parse and format
    final dateTime = DateTime.parse(isoTime).toLocal();
    final formattedTime = DateFormat('hh:mm a, dd MMM').format(dateTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 128),
                  shape: BoxShape.circle,
                ),
                // child: Icon(statusIcon, color: statusColor, size: 20),
                child: Center(
                  child: Text(
                    // '',
                    (name[0]).toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Content area
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  onTap: (assignedTo != null || isMissedFUps == true)
                      ? () => openBottomSheet(context, timelineData, leadId)
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.grey[900],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    // if (isMissedCall)
                                    //   Container(
                                    //     margin: const EdgeInsets.only(left: 8),
                                    //     padding: const EdgeInsets.symmetric(
                                    //       horizontal: 8,
                                    //       vertical: 2,
                                    //     ),
                                    //     decoration: BoxDecoration(
                                    //       color: Colors.red.withOpacity(0.1),
                                    //       borderRadius: BorderRadius.circular(
                                    //         12,
                                    //       ),
                                    //     ),
                                    //     child: Text(
                                    //       'Missed',
                                    //       style: TextStyle(
                                    //         fontSize: 10,
                                    //         fontWeight: FontWeight.w600,
                                    //         color: Colors.red,
                                    //       ),
                                    //     ),
                                    //   ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                if (phone != null &&
                                    phone != 0 &&
                                    assignedTo != null)
                                  Text(
                                    phone.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Bottom row with time and tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // SOURCE IN ALLOCATION PAGE
                      if (source != null && source!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade50,
                                Colors.orange.shade100,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade900,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Source: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: source!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // CAMPAIGN IN ALLOCATION PAGE
                      if (campaign != null && campaign!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade50,
                                Colors.green.shade100,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade900,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Campaign: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: campaign,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // SUBSOURCE IN ALLOCATION PAGE
                      if (subSource != null && subSource!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade50,
                                Colors.purple.shade100,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.3),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.purple.shade900,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Subsource: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: subSource!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      if (tag.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade50,
                                Colors.blue.shade100,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade900,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Status: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: tag,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 7),

                      if (followUp != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "Follow up date: ${DateFormat('dd/MM/yyyy  hh:mm a').format(followUp!.toLocal())}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade900,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (stageFieldValues != null && stageFieldValues!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...stageFieldValues!.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 12,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red.shade900,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Stage Remark: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: "${field['value'] ?? 'N/A'}"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(width: 12),

              if (assignedTo == null && isMissedFUps == false) ...[
                Column(
                  children: [
                    // ACCEPT BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: accept,
                      child: const Text('Accept'),
                    ),

                    5.heightBox,

                    // REJECT BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade300,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: decline,
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],

              // Call Back Button
              if (assignedTo != null || isMissedFUps == true) ...[
                Column(
                  children: [
                    ///Phone
                    InkWell(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      onTap: onCallBack,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade100,
                              Colors.blue.shade200,
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
                          color: Colors.blue.shade800,
                          size: 20,
                        ),
                      ),
                    ),

                    ///WhatsApp
                    IconButton(
                      onPressed: () => onWhatsApp(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade100,
                              Colors.green.shade200,
                            ],
                          ),
                        ),
                        child: Image.asset(
                          'assets/whatsapp.png',
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),

                    ///SMS
                    IconButton(
                      onPressed: () => onSms(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade100,
                              Colors.brown.shade200,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.sms,
                          color: Colors.brown.shade800,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
