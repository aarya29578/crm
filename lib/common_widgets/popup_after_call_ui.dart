import 'dart:async';
import 'dart:convert';
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/common_widgets/call_storage.dart';
import 'package:crm_flutter/common_widgets/stage_date_time_picker.dart';
import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/local_storage/up_coming_followups_controller.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/Allocations/allocations_controller.dart';
import 'package:crm_flutter/pages/Allocations/components/searchable_sub_status_field.dart';
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
  final bool isIncoming;
  const PopupAfterCallUi({
    super.key,
    required this.leadId,
    this.stageName,
    this.isIncoming = false,
  });

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
  Map<String, TimeOfDay?> dynamicTimes = {};
  bool isLoadingFields = false;
  String? selectedRating;
  bool isSubmitting = false;
  bool _allowDialogClose=false;
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

  void _logCallFormEvent(String event, {String? detail}) {
    debugPrint(
      '[call-session] ${DateTime.now().toIso8601String()} '
      'event=$event${detail == null ? '' : ' detail=$detail'}',
    );
  }

  @override
  void initState() {
    super.initState();

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
          await homeController.getFailedSubLStage(
            selectedStageId: selectedStageId,
          );

          final subStatuses = homeController.allSubLStageRes.value.data ?? [];

          if (leadData?.subStatusId?.sId != null) {
            setState(() {
              selectedSubStatusId = leadData!.subStatusId!.sId;
            });
          }
        }
      }

      if (mounted) {
        setState(() {});
      }
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
      final fieldId = field['_id']?.toString() ?? '';
      final fieldType = field['fieldType'];
      final isTarget = isTargetStageDateTimeField(field);

      if (fieldType == 'datetime' || isTarget) {
        final savedValue =
            findSavedStageValue(leadData.stageFieldValues, field);
        DateTime? date;
        if (savedValue != null && savedValue.toString().isNotEmpty) {
          date = DateTime.tryParse(savedValue.toString())?.toLocal();
        } else if (!isTarget &&
            leadData.followUpDate != null &&
            leadData.followUpDate!.isNotEmpty) {
          try {
            date = DateTime.parse(leadData.followUpDate!).toLocal();
          } catch (e) {
            print("Error parsing dynamic datetime: $e");
          }
        }
        if (date != null) {
          dynamicDates[fieldId] = DateTime(date.year, date.month, date.day);
          dynamicTimes[fieldId] =
              TimeOfDay(hour: date.hour, minute: date.minute);
        }
      } else if (fieldType == 'text') {
        final savedValue =
            findSavedStageValue(leadData.stageFieldValues, field);
        if (savedValue != null) {
          if (!textControllers.containsKey(fieldId)) {
            textControllers[fieldId] = TextEditingController();
          }
          textControllers[fieldId]!.text = savedValue.toString();
        }
      }
    }
    for (final key in ['siteVisitDate', 'siteVisitDone', 'meetingDone']) {
      final savedValue = findSavedStageValueByKey(leadData, key);
      if (savedValue != null && savedValue.toString().isNotEmpty) {
        final parsed = DateTime.tryParse(savedValue.toString())?.toLocal();
        if (parsed != null) {
          dynamicDates[key] = DateTime(parsed.year, parsed.month, parsed.day);
          dynamicTimes[key] = TimeOfDay(hour: parsed.hour, minute: parsed.minute);
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

  Future<DateTime?> _pickStageDateTime(
    String targetKey,
    String dateLabel,
    String timeLabel,
  ) async {
    final now = DateTime.now();
    final d = dynamicDates[targetKey];
    final t = dynamicTimes[targetKey];
    final initialDate = d ?? now;
    final initialTime = t ?? TimeOfDay.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select $dateLabel',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.orange),
          ),
          child: child!,
        );
      },
    );

    if (date == null || !mounted) return null;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Select $timeLabel',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.black,
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
              dialogTheme: const DialogThemeData(
                backgroundColor: Colors.orange,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (time == null || !mounted) return null;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      dynamicDates[targetKey] =
          DateTime(date.year, date.month, date.day);
      dynamicTimes[targetKey] = time;
    });

    return combined;
  }

  Widget _buildStatusDateTimePicker() {
    final stages = homeController.allLeadStageRes.value.data ?? [];
    final selectedStageObj = stages.where((e) => e.sId == selectedStageId).isNotEmpty
        ? stages.firstWhere((e) => e.sId == selectedStageId)
        : null;
    final stageName = selectedStageObj?.name;
    final isFollowUpStage = stageName == "Follow Up";
    final targetKey = getBackendKeyForStageName(stageName);

    if (isFollowUpStage) {
      return _buildPickerContainer(
        key: const ValueKey('follow-up-date-picker'),
        label: "Follow Up Date ",
        dtValue: dt,
        error: _dateTimeError,
        onTap: () => _pickDateTime(),
      );
    }

    if (targetKey != null) {
      final String labelText;
      final String timeLabelText;
      if (targetKey == 'siteVisitDate') {
        labelText = "Site Visit Planned Date";
        timeLabelText = "Site Visit Planned Time";
      } else if (targetKey == 'siteVisitDone') {
        labelText = "Site Visit Done Date";
        timeLabelText = "Site Visit Done Time";
      } else {
        labelText = "Booking Done Date";
        timeLabelText = "Booking Done Time";
      }

      final d = dynamicDates[targetKey];
      final t = dynamicTimes[targetKey];
      final DateTime? currentVal = (d != null && t != null)
          ? DateTime(d.year, d.month, d.day, t.hour, t.minute)
          : (d != null ? DateTime(d.year, d.month, d.day) : null);

      return _buildPickerContainer(
        key: ValueKey('stage-date-picker-$targetKey'),
        label: labelText,
        dtValue: currentVal,
        error: null,
        onTap: () => _pickStageDateTime(targetKey, labelText, timeLabelText),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPickerContainer({
    Key? key,
    required String label,
    required DateTime? dtValue,
    required String? error,
    required VoidCallback onTap,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: error != null ? Colors.red : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: error != null ? Colors.red : Colors.blue,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dtValue == null
                        ? "Select Date & Time"
                        : DateFormat('dd MMM yyyy • hh:mm a').format(dtValue),
                    style: TextStyle(
                      fontSize: 15,
                      color: dtValue == null
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
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
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
    final subStatusLabel = subStatusLabelForStage(selectedStageObj?.name);

    // final stageChanged =
    //     selectedStageId != null && selectedStageId != currentStageId;

    // final followUpValid = !isFollowUp || dt != null;

    // final canSubmit = stageChanged && followUpValid;

    // final canSubmit = selectedStageId != null && (!isFollowUp || dt != null);

    // print("Stages from bottomsheetUi: ${stages[index].name}");
    return PopScope(
      canPop: _allowDialogClose,
      child: SafeArea(
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
                    final subStatusLabel = subStatusLabelForStage(
                      selectedStageObj?.name,
                    );
      
                    print(
                      "PopupAfterCallUi Obx rebuild: selectedStageId: $selectedStageId, hasSubStatus: $hasSubStatus",
                    );
      
                    final leadData =
                        leadDetailsController.allLeadDetailRes.value.data;
                    final visitedStageIds = leadData?.visitedStageIds ?? [];
                    final filteredStages = stages
                        .where((stage) => stage.name?.toLowerCase() != 'new')
                        .toList();
      debugPrint('Current-stage options: ${filteredStages.length}');
debugPrint('selectedStageId: $selectedStageId');
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
                                return Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text("No $subStatusLabel Available"),
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
                                    labelText: subStatusLabel,
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
      
                  _buildStatusDateTimePicker(),
      
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
                                _logCallFormEvent('pending_call_data_missing');
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
                                  "Please select $subStatusLabel",
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
      
                              final selectedStageObj = stages
                                      .where((e) => e.sId == selectedStageId)
                                      .isNotEmpty
                                  ? stages.firstWhere((e) => e.sId == selectedStageId)
                                  : null;
                              final targetKey =
                                  getBackendKeyForStageName(selectedStageObj?.name);
                              final targetLabel =
                                  getDisplayLabelForStageName(selectedStageObj?.name);

                              if (targetKey != null && targetLabel != null) {
                                final d = dynamicDates[targetKey];
                                final t = dynamicTimes[targetKey];
                                if ((d != null && t == null) ||
                                    (d == null && t != null)) {
                                  Get.snackbar(
                                    "Error",
                                    "Please select both date and time for $targetLabel",
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                if (d != null && t != null) {
                                  final combinedIso = combineDateAndTime(d, t);
                                  callData[targetKey] = combinedIso;
                                }
                              }

                              String? dynamicFollowUpIso;
                              final stageFieldItems =
                                  <Map<String, dynamic>>[];

                              for (var field in stageFields) {
                                final fieldId = field['_id']?.toString() ?? '';
                                final fieldType = field['fieldType'];
                                final isTarget =
                                    isTargetStageDateTimeField(field);
                                final key = getStageFieldKey(field);
                                final displayLabel =
                                    getStageFieldDisplayLabel(field);
                                final isRequired = field['required'] == true;

                                if (fieldType == 'datetime') {
                                  if (!isTarget) {
                                    final d = dynamicDates[fieldId];
                                    final t = dynamicTimes[fieldId];
                                    if (d != null && t != null) {
                                      final combined = DateTime(
                                        d.year,
                                        d.month,
                                        d.day,
                                        t.hour,
                                        t.minute,
                                      );
                                      dynamicFollowUpIso =
                                          combined.toIso8601String();
                                    } else if (d != null || t != null) {
                                      Get.snackbar(
                                        "Error",
                                        "Please select both date and time for $displayLabel",
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                      return;
                                    } else if (isRequired) {
                                      Get.snackbar(
                                        "Error",
                                        "$displayLabel is required",
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                      return;
                                    }
                                  }
                                } else if (fieldType == 'text') {
                                  final controller = textControllers[fieldId];
                                  if (controller != null &&
                                      controller.text.isNotEmpty) {
                                    stageFieldItems.add({
                                      if (field['_id'] != null)
                                        "fieldId": field['_id'],
                                      "fieldName": key,
                                      "fieldType": "text",
                                      "value": controller.text,
                                    });
                                  } else if (isRequired) {
                                    Get.snackbar(
                                      "Error",
                                      "$displayLabel is required",
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }
                                }
                              }

                              final leadData =
                                  leadDetailsController.allLeadDetailRes.value.data;
                              if (leadData?.stageFieldValues != null) {
                                for (var item in filterTextStageFieldValues(
                                    leadData!.stageFieldValues)) {
                                  final k = item['fieldName'];
                                  if (!stageFieldItems.any((x) =>
                                      x['fieldName'] == k ||
                                      x['fieldId'] == item['fieldId'])) {
                                    stageFieldItems.add(item);
                                  }
                                }
                              }

                              if (isFollowUp && dt != null) {
                                callData["followUpDate"] =
                                    dt!.toIso8601String();
                              } else if (callData["followUpDate"] == null &&
                                  dynamicFollowUpIso != null) {
                                callData["followUpDate"] = dynamicFollowUpIso;
                              }

                              final textFieldsOnly = stageFieldItems
                                  .where((item) =>
                                      item['fieldType'] == 'text' &&
                                      (item['fieldId'] != null ||
                                          item['_id'] != null) &&
                                      item['value'] != null &&
                                      item['value'].toString().isNotEmpty)
                                  .toList();

                              if (textFieldsOnly.isNotEmpty) {
                                callData["stageFieldValues"] = jsonEncode(
                                  textFieldsOnly,
                                );
                              }
      
                              // Lock the button NOW, right before the API call
                              setState(() => isSubmitting = true);
      
                              _logCallFormEvent('form_submission_started');
      
                              try {
                                if (widget.isIncoming ||
                                    callData["device_call_id"] != null) {
                                  await DioApi().postIncomingCall(callData);
                                  PendingCallData.data = null;
                                  PendingCallData.outboundSessionId = null;
                                } else {
                                  await CallHelper.submitPendingCall(callData);
                                }
                                _logCallFormEvent('form_submission_verified');
                                try {
                                  await Get.find<FollowUpController>()
                                      .syncWithApi();
                                } catch (error) {
                                  _logCallFormEvent(
                                    'follow_up_sync_failed',
                                    detail: error.runtimeType.toString(),
                                  );
                                }
      if (!mounted) return;

setState(() {
  _allowDialogClose = true;
});

await WidgetsBinding.instance.endOfFrame;

if (!mounted) return;
Navigator.of(context, rootNavigator: true).pop();

/// Refresh AFTER dialog closes
unawaited(_refreshCallScreens());
                               } catch (e) {
                                _logCallFormEvent(
                                  'form_submission_failed_or_unverified',
                                  detail: e.runtimeType.toString(),
                                );
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshCallScreens() async {
    try {
      await allocationController.refreshData();
    } catch (error) {
      _logCallFormEvent(
        'allocation_refresh_failed',
        detail: error.runtimeType.toString(),
      );
    }
    try {
      await callLogController.getApi();
    } catch (error) {
      _logCallFormEvent(
        'call_history_refresh_failed',
        detail: error.runtimeType.toString(),
      );
    }
    try {
      await homeController.getDashboardData(
        startDate: homeController.selectedStartDate.value,
        endDate: homeController.selectedEndDate.value,
        statusIds: homeController.selectedStatusIds,
      );
    } catch (error) {
      _logCallFormEvent(
        'home_dashboard_refresh_failed',
        detail: error.runtimeType.toString(),
      );
    }
  }

  Widget _buildDynamicFields() {
    final filtered = stageFields.where((field) {
      return !isTargetStageDateTimeField(field) &&
          !isTargetStageName(field['name']?.toString());
    }).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filtered.map((field) {
        final fieldId = field['_id']?.toString() ?? '';
        final fieldType = field['fieldType'];
        final isTarget = isTargetStageDateTimeField(field);
        final fieldName = getStageFieldDisplayLabel(field);
        final isRequired = field['required'] == true;

        if (fieldType == 'datetime' || isTarget) {
          final date = dynamicDates[fieldId];
          final time = dynamicTimes[fieldId];
          final currentVal = (date != null && time != null)
              ? DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                )
              : (date != null
                  ? DateTime(date.year, date.month, date.day)
                  : null);

          return _buildPickerContainer(
            label: isRequired ? "$fieldName *" : fieldName,
            dtValue: currentVal,
            error: null,
            onTap: () => _pickStageDateTime(
              fieldId,
              fieldName,
              "$fieldName Time",
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
