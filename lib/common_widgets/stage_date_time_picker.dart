import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Helper to map lead status / stage name to canonical backend field key:
/// - "Site Visit Planned" -> 'siteVisitDate'
/// - "Site Visit Done" -> 'siteVisitDone'
/// - "Booking Done" (or alias "Meeting Done") -> 'meetingDone'
/// - Any other status -> null
String? getBackendKeyForStageName(String? stageName) {
  if (stageName == null) return null;
  final clean =
      stageName.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  if (clean == 'sitevisitplanned' || clean == 'sitevisitdate') {
    return 'siteVisitDate';
  }
  if (clean == 'sitevisitdone') {
    return 'siteVisitDone';
  }
  if (clean == 'bookingdone' || clean == 'meetingdone') {
    return 'meetingDone';
  }
  return null;
}

/// Helper to get the display label corresponding to a lead status / stage name
String? getDisplayLabelForStageName(String? stageName) {
  final key = getBackendKeyForStageName(stageName);
  if (key == 'siteVisitDate') return 'Site Visit Planned';
  if (key == 'siteVisitDone') return 'Site Visit Done';
  if (key == 'meetingDone') return 'Booking Done';
  return null;
}

/// Checks if a stage name corresponds to one of the three target fields
bool isTargetStageName(String? stageName) {
  return getBackendKeyForStageName(stageName) != null;
}

/// Helper to get the canonical backend key for a stage field
String getStageFieldKey(dynamic field) {
  if (field is String) {
    final mapped = getBackendKeyForStageName(field);
    if (mapped != null) return mapped;
    return field;
  }
  if (field is! Map) return field?.toString() ?? '';
  final rawKey = field['fieldName'] ?? field['key'] ?? field['name'] ?? '';
  final keyStr = rawKey.toString().trim();
  final mapped = getBackendKeyForStageName(keyStr);
  if (mapped != null) return mapped;
  return keyStr;
}

/// Helper to get the required display label for a stage field
String getStageFieldDisplayLabel(dynamic field) {
  final key = getStageFieldKey(field);
  final labelFromKey = getDisplayLabelForStageName(key);
  if (labelFromKey != null) return labelFromKey;

  if (field is Map) {
    return field['name']?.toString() ??
        field['fieldName']?.toString() ??
        (field['fieldType'] == 'datetime' ? 'Date & Time' : 'Field');
  }
  return field?.toString() ?? 'Field';
}

/// Checks if a field is one of the three target lead stage date/time fields
bool isTargetStageDateTimeField(dynamic field) {
  final key = getStageFieldKey(field);
  return key == 'siteVisitDate' ||
      key == 'siteVisitDone' ||
      key == 'meetingDone';
}

/// Extracts a saved value from lead stageFieldValues by fieldId or fieldName
dynamic findSavedStageValue(List<dynamic>? stageFieldValues, dynamic field) {
  if (stageFieldValues == null || stageFieldValues.isEmpty) return null;
  final fieldId = field is Map ? field['_id']?.toString() : null;
  final key = getStageFieldKey(field);

  for (final item in stageFieldValues) {
    if (item is Map) {
      final fId = item['fieldId']?.toString() ?? item['_id']?.toString();
      final fName = item['fieldName']?.toString() ??
          item['name']?.toString() ??
          item['key']?.toString();

      if (fieldId != null && fId != null && fId == fieldId) {
        return item['value'];
      }
      if (fName != null &&
          (fName == key || fName.toLowerCase() == key.toLowerCase())) {
        return item['value'];
      }
    }
  }
  return null;
}

/// Extracts a saved value from lead data (Data object, Map, or stageFieldValues List)
dynamic findSavedStageValueByKey(dynamic leadData, String backendKey) {
  if (leadData == null) return null;

  // 1. If leadData is a List (stageFieldValues)
  if (leadData is List) {
    final direct = findSavedStageValue(leadData, {'fieldName': backendKey});
    if (direct != null) return direct;
    if (backendKey == 'meetingDone') {
      return findSavedStageValue(leadData, {'fieldName': 'bookingDone'});
    }
    return null;
  }

  // 2. If leadData is a Map
  if (leadData is Map) {
    if (leadData.containsKey(backendKey) && leadData[backendKey] != null) {
      return leadData[backendKey];
    }
    if (backendKey == 'meetingDone' &&
        leadData.containsKey('bookingDone') &&
        leadData['bookingDone'] != null) {
      return leadData['bookingDone'];
    }
    final stageFieldValues = leadData['stageFieldValues'];
    if (stageFieldValues is List) {
      final val =
          findSavedStageValue(stageFieldValues, {'fieldName': backendKey});
      if (val != null) return val;
      if (backendKey == 'meetingDone') {
        final bookingVal =
            findSavedStageValue(stageFieldValues, {'fieldName': 'bookingDone'});
        if (bookingVal != null) return bookingVal;
      }
    }
  }

  // 3. If leadData is an object with toJson
  try {
    final json = (leadData as dynamic).toJson();
    if (json is Map) {
      if (json.containsKey(backendKey) && json[backendKey] != null) {
        return json[backendKey];
      }
      if (backendKey == 'meetingDone' &&
          json.containsKey('bookingDone') &&
          json['bookingDone'] != null) {
        return json['bookingDone'];
      }
      final stageFieldValues = json['stageFieldValues'];
      if (stageFieldValues is List) {
        final val =
            findSavedStageValue(stageFieldValues, {'fieldName': backendKey});
        if (val != null) return val;
        if (backendKey == 'meetingDone') {
          final bookingVal = findSavedStageValue(
              stageFieldValues, {'fieldName': 'bookingDone'});
          if (bookingVal != null) return bookingVal;
        }
      }
    }
  } catch (_) {}

  // 4. Check .stageFieldValues property on the object directly if present
  try {
    final stageFieldValues = (leadData as dynamic).stageFieldValues;
    if (stageFieldValues is List) {
      final val =
          findSavedStageValue(stageFieldValues, {'fieldName': backendKey});
      if (val != null) return val;
      if (backendKey == 'meetingDone') {
        final bookingVal = findSavedStageValue(
            stageFieldValues, {'fieldName': 'bookingDone'});
        if (bookingVal != null) return bookingVal;
      }
    }
  } catch (_) {}

  // 5. Direct property access on Data object
  try {
    if (backendKey == 'siteVisitDate') {
      final v = (leadData as dynamic).siteVisitDate;
      if (v != null) return v;
    }
    if (backendKey == 'siteVisitDone') {
      final v = (leadData as dynamic).siteVisitDone;
      if (v != null) return v;
    }
    if (backendKey == 'meetingDone') {
      final v = (leadData as dynamic).meetingDone;
      if (v != null) return v;
    }
  } catch (_) {}

  return null;
}

/// Filters stageFieldValues to only include text-based custom stage fields that have
/// a valid fieldId and fieldType == 'text', strictly conforming to the website and backend schema.
/// Stage-specific datetime fields (siteVisitDate, siteVisitDone, meetingDone) and any datetime fields
/// are strictly excluded because they belong to top-level lead fields or followUpDate.
List<Map<String, dynamic>> filterTextStageFieldValues(
    List<dynamic>? existingList) {
  if (existingList == null || existingList.isEmpty) return [];
  final result = <Map<String, dynamic>>[];
  for (final item in existingList) {
    if (item is Map) {
      final fieldType = item['fieldType']?.toString();
      final key = getStageFieldKey(item);
      final isTarget = isTargetStageDateTimeField(item) ||
          key == 'siteVisitDate' ||
          key == 'siteVisitDone' ||
          key == 'meetingDone' ||
          key == 'bookingDone';

      // Strictly exclude any stage-specific date fields and datetime fields
      if (isTarget || fieldType == 'datetime') {
        continue;
      }

      // Valid stage fields must have an identifier (fieldId, _id, or field)
      final hasId = item['fieldId'] != null ||
          item['_id'] != null ||
          item['field'] != null;
      if (!hasId) {
        continue;
      }

      // Preserve any other existing field (text fields, custom fields)
      result.add(Map<String, dynamic>.from(item));
    }
  }
  return result;
}

/// Helper that filters out any datetime fields or target status date fields from stageFieldValues.
/// Stage-specific dates are top-level lead fields and must never be inserted into stageFieldValues.
List<Map<String, dynamic>> updateStageFieldValuesList({
  required List<dynamic>? existingList,
  required String targetKey,
  required String? combinedIso,
  String? fieldId,
}) {
  return filterTextStageFieldValues(existingList);
}

/// Formats TimeOfDay as "10:30 AM" or "02:30 PM"
String formatTimeOfDay(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return DateFormat('hh:mm a').format(dt);
}

/// Formats ISO datetime string for display (e.g. "05 Nov 2026, 10:30 AM")
String formatDisplayDateTime(String isoStr) {
  final parsed = DateTime.tryParse(isoStr)?.toLocal();
  if (parsed == null) return isoStr;
  return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
}

/// Combines Date and Time into an ISO 8601 string without shifting local time
String combineDateAndTime(DateTime date, TimeOfDay time) {
  final combined = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  return combined.toIso8601String();
}

/// Widget providing separate Date and Time pickers for lead stage fields
class StageDateTimePicker extends StatelessWidget {
  final String fieldKey;
  final String label;
  final String? dateLabel;
  final String? timeLabel;
  final DateTime? date;
  final TimeOfDay? time;
  final bool isRequired;
  final bool isDark;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final VoidCallback? onClear;

  const StageDateTimePicker({
    super.key,
    required this.fieldKey,
    required this.label,
    this.dateLabel,
    this.timeLabel,
    required this.date,
    required this.time,
    this.isRequired = false,
    this.isDark = false,
    required this.onDateChanged,
    required this.onTimeChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey.shade300;
    final fillColor = isDark ? Colors.grey[900]! : Colors.grey.shade50;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey.shade600;

    final effectiveDateLabel = dateLabel ??
        (fieldKey == 'meetingDone' || label == 'Booking Done'
            ? "Booking Done Date"
            : "Date");
    final effectiveTimeLabel = timeLabel ??
        (fieldKey == 'meetingDone' || label == 'Booking Done'
            ? "Booking Done Time"
            : "Time");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                isRequired ? "$label *" : label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            if (onClear != null && (date != null || time != null))
              InkWell(
                onTap: onClear,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    "Clear",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // 1. DATE PICKER CONTROL
            Expanded(
              flex: 3,
              child: InkWell(
                key: ValueKey('stage-date-picker-$fieldKey'),
                onTap: () async {
                  final now = DateTime.now();
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: date ?? now,
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
                  if (pickedDate != null) {
                    onDateChanged(
                      DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                    color: fillColor,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              effectiveDateLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              date == null
                                  ? "Select Date"
                                  : DateFormat('dd MMMM yyyy').format(date!),
                              style: TextStyle(
                                fontSize: 13,
                                color: date == null ? subTextColor : textColor,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_drop_down,
                          color: subTextColor, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 2. TIME PICKER CONTROL
            Expanded(
              flex: 2,
              child: InkWell(
                key: ValueKey('stage-time-picker-$fieldKey'),
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: time ?? TimeOfDay.now(),
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(alwaysUse24HourFormat: false),
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
                  if (pickedTime != null) {
                    onTimeChanged(pickedTime);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                    color: fillColor,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              effectiveTimeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              time == null
                                  ? "Select Time"
                                  : formatTimeOfDay(time!),
                              style: TextStyle(
                                fontSize: 13,
                                color: time == null ? subTextColor : textColor,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_drop_down,
                          color: subTextColor, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

