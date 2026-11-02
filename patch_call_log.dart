import 'dart:io';

void main() {
  // 1. Patch ClaimedLeadCard.dart
  {
    final file = File('lib/widgets/ClaimedLeadCard.dart');
    var content = file.readAsStringSync();
    final isCrlf = content.contains('\r\n');
    content = content.replaceAll('\r\n', '\n');

    const importTarget = "import 'package:intl/intl.dart';";
    const importReplacement = "import 'package:intl/intl.dart';\nimport 'package:crm_flutter/common_widgets/stage_date_time_picker.dart';";
    if (!content.contains(importTarget)) {
      print('ClaimedLeadCard import target not found');
      return;
    }
    content = content.replaceFirst(importTarget, importReplacement);

    const badgeTarget = '''                                TextSpan(
                                  text: "Stage Remark: ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: "\${field['value'] ?? 'N/A'}",
                                ),''';

    const badgeReplacement = '''                                TextSpan(
                                  text: "\${isTargetStageDateTimeField(field) ? getStageFieldDisplayLabel(field) : 'Stage Remark'}: ",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: isTargetStageDateTimeField(field) && field['value'] != null
                                      ? formatDisplayDateTime(field['value'].toString())
                                      : "\${field['value'] ?? 'N/A'}",
                                ),''';

    if (!content.contains(badgeTarget)) {
      print('ClaimedLeadCard badge target not found');
      return;
    }
    content = content.replaceFirst(badgeTarget, badgeReplacement);

    final result = isCrlf ? content.replaceAll('\n', '\r\n') : content;
    file.writeAsStringSync(result);
    print('CLAIMED_LEAD_CARD PATCH SUCCESS');
  }

  // 2. Patch callLogCard.dart
  {
    final file = File('lib/pages/Allocations/components/callLogCard.dart');
    var content = file.readAsStringSync();
    final isCrlf = content.contains('\r\n');
    content = content.replaceAll('\r\n', '\n');

    // Add import
    const importTarget = "import 'package:crm_flutter/pages/Allocations/components/searchable_sub_status_field.dart';";
    const importReplacement = "import 'package:crm_flutter/pages/Allocations/components/searchable_sub_status_field.dart';\nimport 'package:crm_flutter/common_widgets/stage_date_time_picker.dart';";
    if (!content.contains(importTarget)) {
      print('callLogCard import target not found');
      return;
    }
    content = content.replaceFirst(importTarget, importReplacement);

    // Add dynamicTimes map
    const stateTarget = "    final RxMap<String, DateTime> dynamicDates = <String, DateTime>{}.obs;";
    const stateReplacement = "    final RxMap<String, DateTime> dynamicDates = <String, DateTime>{}.obs;\n    final RxMap<String, TimeOfDay> dynamicTimes = <String, TimeOfDay>{}.obs;";
    if (!content.contains(stateTarget)) {
      print('callLogCard state target not found');
      return;
    }
    content = content.replaceFirst(stateTarget, stateReplacement);

    // Prefill logic
    const prefillTarget = '''          // Pre-fill
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
                    print("Error parsing followUpDate: \$e");
                  }
                }
              } else if (fieldType == 'text') {
                final savedValue = leadData.stageFieldValues?.firstWhere(
                  (f) => f['fieldId'] == fieldId,
                  orElse: () => null,
                );
                textControllers.putIfAbsent(
                  fieldId,
                  () => TextEditingController(
                    text: savedValue?['value']?.toString() ?? '',
                  ),
                );
              }
            }
          }''';

    const prefillReplacement = '''          // Pre-fill
          final leadData = leadDetailsController.allLeadDetailRes.value.data;
          if (leadData != null) {
            for (var field in fields) {
              final fieldId = field['_id']?.toString() ?? '';
              final fieldType = field['fieldType'];
              final isTarget = isTargetStageDateTimeField(field);

              if (fieldType == 'datetime' || isTarget) {
                final savedValue =
                    findSavedStageValue(leadData.stageFieldValues, field);
                DateTime? dt;
                if (savedValue != null && savedValue.toString().isNotEmpty) {
                  dt = DateTime.tryParse(savedValue.toString())?.toLocal();
                } else if (!isTarget &&
                    leadData.followUpDate != null &&
                    leadData.followUpDate!.isNotEmpty) {
                  try {
                    dt = DateTime.parse(leadData.followUpDate!).toLocal();
                  } catch (e) {
                    print("Error parsing followUpDate: \$e");
                  }
                }

                if (dt != null) {
                  dynamicDates[fieldId] = DateTime(dt.year, dt.month, dt.day);
                  dynamicTimes[fieldId] =
                      TimeOfDay(hour: dt.hour, minute: dt.minute);
                }
              } else if (fieldType == 'text') {
                final savedValue =
                    findSavedStageValue(leadData.stageFieldValues, field);
                textControllers.putIfAbsent(
                  fieldId,
                  () => TextEditingController(
                    text: savedValue?.toString() ?? '',
                  ),
                );
              }
            }
          }''';

    if (!content.contains(prefillTarget)) {
      print('callLogCard prefill target not found');
      return;
    }
    content = content.replaceFirst(prefillTarget, prefillReplacement);

    // Save helper definition inside openBottomSheet
    const helperTarget = "    Future<void> fetchStageFields(String stageId) async {";
    const helperReplacement = '''    Future<void> saveStageDateTimeIfComplete(
        String fieldId, dynamic field) async {
      final d = dynamicDates[fieldId];
      final t = dynamicTimes[fieldId];
      if (d == null || t == null || leadId == null) return;
      final combined = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      final key = getStageFieldKey(field);

      try {
        final List<Map<String, dynamic>> currentPayload = [];
        for (var f in stageFields) {
          final fId = f['_id']?.toString() ?? '';
          final fType = f['fieldType'];
          final fKey = getStageFieldKey(f);
          if (fId == fieldId || fKey == key) {
            currentPayload.add({
              if (f['_id'] != null) "fieldId": f['_id'],
              "fieldName": key,
              "fieldType": "datetime",
              "value": combined.toIso8601String(),
            });
          } else if (fType == 'datetime' || isTargetStageDateTimeField(f)) {
            final otherD = dynamicDates[fId];
            final otherT = dynamicTimes[fId];
            if (otherD != null && otherT != null) {
              final otherCombined = DateTime(
                  otherD.year, otherD.month, otherD.day, otherT.hour, otherT.minute);
              currentPayload.add({
                if (f['_id'] != null) "fieldId": f['_id'],
                "fieldName": fKey,
                "fieldType": "datetime",
                "value": otherCombined.toIso8601String(),
              });
            }
          } else if (fType == 'text') {
            final c = textControllers[fId];
            if (c != null && c.text.isNotEmpty) {
              currentPayload.add({
                if (f['_id'] != null) "fieldId": f['_id'],
                "fieldName": fKey,
                "fieldType": "text",
                "value": c.text,
              });
            }
          }
        }

        await DioApi().patchLead(leadId!, {
          "stageFieldValues": currentPayload,
        });
        await leadDetailsController.getAllLeadDetails(context, leadId!);
        Get.snackbar(
          "Success",
          "\${getStageFieldDisplayLabel(field)} updated successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to update \${getStageFieldDisplayLabel(field)}: \$e",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    Future<void> fetchStageFields(String stageId) async {''';

    if (!content.contains(helperTarget)) {
      print('callLogCard helper target not found');
      return;
    }
    content = content.replaceFirst(helperTarget, helperReplacement);

    // Update firstDateTimeField finder
    const firstDateTimeTarget = '''                            final firstDateTimeField = stageFields.firstWhere(
                              (field) => field['fieldType'] == 'datetime',
                              orElse: () => null,
                            );''';
    const firstDateTimeReplacement = '''                            final firstDateTimeField = stageFields.firstWhere(
                              (field) =>
                                  field['fieldType'] == 'datetime' ||
                                  isTargetStageDateTimeField(field),
                              orElse: () => null,
                            );''';
    if (!content.contains(firstDateTimeTarget)) {
      print('callLogCard firstDateTimeTarget not found');
      return;
    }
    content = content.replaceFirst(firstDateTimeTarget, firstDateTimeReplacement);

    // Stage field UI rendering (lines 831-1006)
    const renderTarget = '''                                    if (fieldType == 'datetime') {
                                      final dateValue = dynamicDates[fieldId];
                                      final dateTimeWidget = Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "\$fieldName *",
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
                                                    "Failed to update date: \$e",
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
                                                            ? "Select \$fieldName"
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
                                      return fieldId == firstDateTimeFieldId
                                          ? Column(
                                              children: [
                                                dateTimeWidget,
                                                buildRemarksField(),
                                              ],
                                            )
                                          : dateTimeWidget;
                                    }''';

    const renderReplacement = '''                                    if (fieldType == 'datetime' ||
                                        isTargetStageDateTimeField(field)) {
                                      final date = dynamicDates[fieldId];
                                      final time = dynamicTimes[fieldId];
                                      final displayLabel =
                                          getStageFieldDisplayLabel(field);
                                      final isRequired =
                                          field['required'] == true;

                                      final dateTimeWidget = Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: StageDateTimePicker(
                                          fieldKey: getStageFieldKey(field),
                                          label: displayLabel,
                                          date: date,
                                          time: time,
                                          isRequired: isRequired,
                                          isDark: isDark,
                                          onDateChanged: (pickedDate) {
                                            dynamicDates[fieldId] = pickedDate;
                                            saveStageDateTimeIfComplete(
                                                fieldId, field);
                                          },
                                          onTimeChanged: (pickedTime) {
                                            dynamicTimes[fieldId] = pickedTime;
                                            saveStageDateTimeIfComplete(
                                                fieldId, field);
                                          },
                                          onClear: !isRequired
                                              ? () {
                                                  dynamicDates.remove(fieldId);
                                                  dynamicTimes.remove(fieldId);
                                                }
                                              : null,
                                        ),
                                      );

                                      return fieldId == firstDateTimeFieldId
                                          ? Column(
                                              children: [
                                                dateTimeWidget,
                                                buildRemarksField(),
                                              ],
                                            )
                                          : dateTimeWidget;
                                    }''';

    if (!content.contains(renderTarget)) {
      print('callLogCard render target not found');
      return;
    }
    content = content.replaceFirst(renderTarget, renderReplacement);

    // Remarks button save logic (lines 1120-1152)
    const saveTarget = '''                                                                final textFields = <
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
                                                              );''';

    const saveReplacement = '''                                                                final stageFieldsPayload = <
                                                                    Map<
                                                                      String,
                                                                      dynamic
                                                                    >
                                                                  >[];
                                                              for (var f
                                                                  in stageFields) {
                                                                final fId =
                                                                    f['_id']?.toString() ?? '';
                                                                final fType =
                                                                    f['fieldType'];
                                                                final key =
                                                                    getStageFieldKey(f);
                                                                final isTarget =
                                                                    isTargetStageDateTimeField(f);

                                                                if (fType == 'datetime' || isTarget) {
                                                                  final d = dynamicDates[fId];
                                                                  final t = dynamicTimes[fId];
                                                                  if (d != null && t != null) {
                                                                    final combined = DateTime(
                                                                        d.year, d.month, d.day, t.hour, t.minute);
                                                                    stageFieldsPayload.add({
                                                                      if (f['_id'] != null) "fieldId": f['_id'],
                                                                      "fieldName": key,
                                                                      "fieldType": "datetime",
                                                                      "value": combined.toIso8601String(),
                                                                    });
                                                                  }
                                                                } else if (fType == 'text') {
                                                                  final c =
                                                                      textControllers[fId];
                                                                  if (c !=
                                                                          null &&
                                                                      c
                                                                          .text
                                                                          .isNotEmpty) {
                                                                    stageFieldsPayload.add({
                                                                      if (f['_id'] != null) "fieldId": f['_id'],
                                                                      "fieldName": key,
                                                                      "fieldType": "text",
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
                                                                      stageFieldsPayload,
                                                                },
                                                              );''';

    if (!content.contains(saveTarget)) {
      print('callLogCard save target not found');
      return;
    }
    content = content.replaceFirst(saveTarget, saveReplacement);

    // Read-only card badge
    const badgeTarget = '''                                  TextSpan(
                                    text: "Stage Remark: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: "\${field['value'] ?? 'N/A'}"),''';

    const badgeReplacement = '''                                  TextSpan(
                                    text: "\${isTargetStageDateTimeField(field) ? getStageFieldDisplayLabel(field) : 'Stage Remark'}: ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: isTargetStageDateTimeField(field) && field['value'] != null
                                        ? formatDisplayDateTime(field['value'].toString())
                                        : "\${field['value'] ?? 'N/A'}",
                                  ),''';

    if (!content.contains(badgeTarget)) {
      print('callLogCard badge target not found');
      return;
    }
    content = content.replaceFirst(badgeTarget, badgeReplacement);

    final result = isCrlf ? content.replaceAll('\n', '\r\n') : content;
    file.writeAsStringSync(result);
    print('CALL_LOG_CARD PATCH SUCCESS');
  }
}

