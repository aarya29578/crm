import 'dart:convert';
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/common_widgets/call_storage.dart';
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
  List<dynamic> stageFields = [];
  Map<String, dynamic> stageFieldValues = {}; // fieldId -> value
  Map<String, TextEditingController> textControllers = {};
  Map<String, DateTime?> dynamicDates = {};
  bool isLoadingFields = false;
  String? selectedRating;
  bool isSubmitting = false;
  final List<String> ratingOptions = [
    "Hot",
    "Warm",
    "Cold",
    "Very Hot",
    "Dead",
    "High",
  ];
  String? _dateTimeError;
  Map<String, String?> dynamicDateErrors = {};

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

      final stages = homeController.allLeadStageRes.value.data ?? [];
      final leadData = leadDetailsController.allLeadDetailRes.value.data;

      print(
        "PopupAfterCallUi: initState - stages: ${stages.length}, leadData: ${leadData != null}",
      );

      if (leadData != null) {
        setState(() {
          // Only set rating if it's a known option to avoid dropdown crash
          final priority = leadData.priority;
          selectedRating =
              (priority != null && ratingOptions.contains(priority))
              ? priority
              : null;
        });
      }

      if (selectedStageId == null && leadData?.leadStageId?.sId != null) {
        setState(() {
          selectedStageId = leadData!.leadStageId!.sId;
        });
      }

      print("PopupAfterCallUi: initState - selectedStageId: $selectedStageId");

      if (selectedStageId != null) {
        await fetchStageFields(selectedStageId!);

        final selectedStageObj =
            stages.where((e) => e.sId == selectedStageId).isNotEmpty
            ? stages.firstWhere((e) => e.sId == selectedStageId)
            : null;

        if (selectedStageObj != null) {
          print(
            "PopupAfterCallUi: initState - stage name: ${selectedStageObj.name}, hasSubStatus: ${selectedStageObj.hasSubStatus}",
          );
        }

        if (selectedStageObj?.hasSubStatus == true) {
          print(
            "PopupAfterCallUi: initState - fetching sub statuses for $selectedStageId",
          );
          await homeController.getFailedSubLStage(
            selectedStageId: selectedStageId,
          );

          final subStatuses = homeController.allSubLStageRes.value.data ?? [];
          print(
            "PopupAfterCallUi: initState - sub statuses fetched: ${subStatuses.length}",
          );

          if (leadData?.subStatusId?.sId != null) {
            setState(() {
              selectedSubStatusId = leadData!.subStatusId!.sId;
            });
            print(
              "PopupAfterCallUi: initState - pre-filled selectedSubStatusId: $selectedSubStatusId",
            );
          }
        }
      }
      setState(() {}); // Force update UI
    });
  }

  Future<void> fetchStageFields(String stageId) async {
    setState(() {
      isLoadingFields = true;
      stageFields = [];
      // Clean up old controllers/dates if needed, but maybe keep them if stage is same
    });

    try {
      final res = await DioApi().getLeadStageById(stageId);
      if (res['success'] == true) {
        final List<dynamic> fields = res['data']['fields'] ?? [];
        setState(() {
          stageFields = fields;
          _prefillDynamicFields();
        });
      }
    } catch (e) {
      print("Error fetching stage fields: $e");
    } finally {
      setState(() {
        isLoadingFields = false;
      });
    }
  }

  void _prefillDynamicFields() {
    final leadData = leadDetailsController.allLeadDetailRes.value.data;
    if (leadData == null) return;

    // 1. Always pre-fill the standard dt if followUpDate exists in lead data
    if (leadData.followUpDate != null && leadData.followUpDate!.isNotEmpty) {
      try {
        dt = DateTime.parse(leadData.followUpDate!).toLocal();
      } catch (e) {
        print("Error parsing leadData.followUpDate: $e");
      }
    }

    // 2. Pre-fill dynamic fields from configuration
    for (var field in stageFields) {
      final fieldId = field['_id'];
      final fieldType = field['fieldType'];

      if (fieldType == 'datetime') {
        // If there's a dynamic datetime field, it often corresponds to followUpDate
        if (leadData.followUpDate != null &&
            leadData.followUpDate!.isNotEmpty) {
          try {
            final date = DateTime.parse(leadData.followUpDate!).toLocal();
            dynamicDates[fieldId] = date;
          } catch (e) {
            print("Error parsing dynamic datetime: $e");
          }
        }
      } else if (fieldType == 'text') {
        final savedValue = leadData.stageFieldValues?.firstWhere(
          (f) => f['fieldId'] == fieldId,
          orElse: () => null,
        );
        if (savedValue != null) {
          if (!textControllers.containsKey(fieldId)) {
            textControllers[fieldId] = TextEditingController();
          }
          textControllers[fieldId]!.text =
              savedValue['value']?.toString() ?? '';
        }
      }
    }
    // 3. Pre-fill priority
    if (leadData.priority != null &&
        ratingOptions.contains(leadData.priority)) {
      selectedRating = leadData.priority;
    } else {
      selectedRating = null;
    }
  }

  Future<DateTime?> _pickDateTime() async {
    // final DateTime? date = await showDatePicker(
    //   context: context,
    //   initialDate: DateTime.now(),
    //   firstDate: DateTime.now(),
    //   lastDate: DateTime(2100),
    // );
    ///WITH COLOR THEME
    final now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: dt ?? now,
      firstDate: DateTime(2000),
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

    if (date == null) return null;

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

    if (time == null) return null;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (combined.isBefore(DateTime.now())) {
      setState(() {
        _dateTimeError = "Cannot select a past date or time";
      });
      Get.snackbar(
        "Error",
        "Cannot select a past date or time",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }

    setState(() {
      _dateTimeError = null;
      dt = combined;
    });
    return dt;
  }

  Future<DateTime?> _pickCustomDateTime(String fieldId) async {
    final now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: dynamicDates[fieldId] ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return null;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        dynamicDates[fieldId] ?? DateTime.now(),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (time == null) return null;

    final newDt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (newDt.isBefore(DateTime.now())) {
      setState(() {
        dynamicDateErrors[fieldId] = "Cannot select a past date or time";
      });
      Get.snackbar(
        "Error",
        "Cannot select a past date or time",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }

    setState(() {
      dynamicDateErrors[fieldId] = null;
      dynamicDates[fieldId] = newDt;
      // If this is a follow-up related field, sync with dt
      dt = newDt;
    });
    return newDt;
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.call_end_rounded,
                        color: Colors.blue,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Call Status",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Obx(() {
                  if (homeController.countLoading.value == PageState.loading) {
                    return const CircularProgressIndicator();
                  }

                  final stages =
                      homeController.allLeadStageRes.value.data ?? [];
                  final selectedStageObj =
                      stages.where((e) => e.sId == selectedStageId).isNotEmpty
                      ? stages.firstWhere((e) => e.sId == selectedStageId)
                      : null;
                  final hasSubStatus = selectedStageObj?.hasSubStatus == true;

                  print(
                    "PopupAfterCallUi Obx rebuild: selectedStageId: $selectedStageId, hasSubStatus: $hasSubStatus",
                  );

                  final leadData =
                      leadDetailsController.allLeadDetailRes.value.data;
                  final visitedStageIds = leadData?.visitedStageIds ?? [];
                  final filteredStages = stages
                      .where((stage) => stage.name?.toLowerCase() != 'new')
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue:
                            filteredStages.any((s) => s.sId == selectedStageId)
                            ? selectedStageId
                            : null,
                        decoration: InputDecoration(
                          labelText: "Current Stage",
                          prefixIcon: const Icon(
                            Icons.layers_outlined,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: filteredStages.map((stage) {
                          return DropdownMenuItem<String>(
                            value: stage.sId,
                            enabled: true,
                            child: Text(
                              stage.name ?? '',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            setState(() {
                              selectedStageId = value;
                              selectedSubStatusId = null; // reset substatus
                            });

                            final selectedStageObj = stages.firstWhere(
                              (e) => e.sId == value,
                            );

                            /// FETCH DYNAMIC FIELDS
                            fetchStageFields(value);

                            /// CALL API IF HAS SUBSTATUS
                            if (selectedStageObj.hasSubStatus == true) {
                              await homeController.getFailedSubLStage(
                                selectedStageId: value,
                              );
                            }
                          }
                        },
                      ),

                      if (hasSubStatus) ...[
                        if (homeController.subStageLoading.value ==
                            PageState.loading)
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else ...[
                          (() {
                            final subStatuses =
                                homeController.allSubLStageRes.value.data ?? [];
                            print(
                              "PopupAfterCallUi subStatus Obx render: subStatuses count = ${subStatuses.length}",
                            );

                            if (subStatuses.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text("No Sub Status Available"),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: DropdownButtonFormField<String>(
                                initialValue:
                                    subStatuses.any(
                                      (sub) => sub.id == selectedSubStatusId,
                                    )
                                    ? selectedSubStatusId
                                    : null,
                                decoration: InputDecoration(
                                  labelText: "Select Sub Status",
                                  prefixIcon: const Icon(
                                    Icons.subdirectory_arrow_right_rounded,
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
                                ),
                                items: subStatuses.map((sub) {
                                  return DropdownMenuItem<String>(
                                    value: sub.id,
                                    child: Text(sub.name ?? ''),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedSubStatusId = val;
                                  });
                                },
                              ),
                            );
                          })(),
                        ],
                      ],
                    ],
                  );
                }),

                const SizedBox(height: 20),

                // Rating Dropdown
                DropdownButtonFormField<String>(
                  initialValue:
                      (selectedRating != null &&
                          ratingOptions.contains(selectedRating))
                      ? selectedRating
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
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
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
                  onChanged: (value) {
                    setState(() {
                      selectedRating = value;
                    });
                  },
                ),

                if (isFollowUp) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "Follow Up Date ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => _pickDateTime(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _dateTimeError != null
                              ? Colors.red
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            color: _dateTimeError != null
                                ? Colors.red
                                : Colors.blue,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dt == null
                                  ? "Select Date & Time"
                                  : DateFormat(
                                      'dd MMM yyyy • hh:mm a',
                                    ).format(dt!),
                              style: TextStyle(
                                fontSize: 15,
                                color: dt == null
                                    ? Colors.grey.shade600
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_dateTimeError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        _dateTimeError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],

                if (isLoadingFields)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (stageFields.isNotEmpty)
                  _buildDynamicFields(),

                const SizedBox(height: 24),
                const Text(
                  "Remarks & Notes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter any important notes from the call...",
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.note_alt_outlined, color: Colors.blue),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),

                30.heightBox,

                ///Here will be the dropdown buttom using data(showing data in dropdown) stages[index].name
                // const Spacer(),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isSubmitting
                        ? null // button disabled while a request is already in flight
                        : () async {
                            final callData = PendingCallData.data;

                            if (callData == null) {
                              print("No pending call data");
                              Navigator.pop(context);
                              return;
                            }

                            if (selectedStageId == null) {
                              Get.snackbar(
                                "Error",
                                "Please select Call Status",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (hasSubStatus && selectedSubStatusId == null) {
                              Get.snackbar(
                                "Error",
                                "Please select Sub Status",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (isFollowUp &&
                                dt != null &&
                                dt!.isBefore(DateTime.now())) {
                              Get.snackbar(
                                "Error",
                                "Cannot select a past date or time",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            callData["lead_stage_id"] = selectedStageId;
                            callData["remarks"] = notesController.text;
                            callData["sub_status_id"] = hasSubStatus
                                ? selectedSubStatusId
                                : null;

                            if (isFollowUp && dt != null) {
                              callData["followUpDate"] = dt!.toIso8601String();
                            }

                            if (selectedRating != null) {
                              callData["priority"] = selectedRating;
                            }

                            final textFields = <Map<String, dynamic>>[];
                            DateTime? dynamicFollowUpDate;

                            for (var field in stageFields) {
                              final fieldId = field['_id'];
                              final fieldType = field['fieldType'];

                              if (fieldType == 'datetime' &&
                                  dynamicDates[fieldId] != null) {
                                dynamicFollowUpDate = dynamicDates[fieldId];
                                if (dynamicFollowUpDate!.isBefore(
                                  DateTime.now(),
                                )) {
                                  Get.snackbar(
                                    "Error",
                                    "Cannot select a past date or time",
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                              } else if (fieldType == 'text') {
                                final controller = textControllers[fieldId];
                                if (controller != null &&
                                    controller.text.isNotEmpty) {
                                  textFields.add({
                                    "fieldId": fieldId,
                                    "fieldType": "text",
                                    "value": controller.text,
                                  });
                                }
                              }
                            }

                            if (dynamicFollowUpDate != null) {
                              callData["followUpDate"] = dynamicFollowUpDate
                                  .toIso8601String();
                            }
                            if (textFields.isNotEmpty) {
                              callData["stageFieldValues"] = jsonEncode(
                                textFields,
                              );
                            }

                            // Lock the button NOW, right before the API call
                            setState(() => isSubmitting = true);

                            print("Hitting API...");

                            try {
                              await DioApi().postPhoneCall(callData);
                              print("API SUCCESS");

                              PendingCallData.data = null;

                              await Get.find<FollowUpController>()
                                  .syncWithApi();

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
                              // unlock only on failure — on success the dialog is already gone
                              if (mounted) {
                                setState(() => isSubmitting = false);
                              }
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Continue with Changes",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stageFields.map((field) {
        final fieldId = field['_id'];
        final fieldType = field['fieldType'];
        final fieldName =
            field['name'] ??
            (fieldType == 'datetime' ? 'Date & Time' : 'Field');

        if (fieldType == 'datetime') {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$fieldName *",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _pickCustomDateTime(fieldId),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.blue,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dynamicDates[fieldId] == null
                                ? "Select $fieldName"
                                : DateFormat(
                                    'dd MMM yyyy • hh:mm a',
                                  ).format(dynamicDates[fieldId]!),
                            style: TextStyle(
                              fontSize: 15,
                              color: dynamicDates[fieldId] == null
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
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
          if (!textControllers.containsKey(fieldId)) {
            textControllers[fieldId] = TextEditingController();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fieldName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: textControllers[fieldId],
                  decoration: InputDecoration(
                    hintText: "Enter $fieldName",
                    prefixIcon: const Icon(
                      Icons.edit_note_rounded,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      }).toList(),
    );
  }
}

Widget _buildNotesPlusMenunameSection(
  String? title,
  String? hintText,
  controller,
) {
  return SizedBox(
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
