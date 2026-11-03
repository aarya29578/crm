import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Helper to get the canonical backend key for a stage field
String getStageFieldKey(dynamic field) {
  if (field is! Map) return field?.toString() ?? '';
  final rawKey = field['fieldName'] ?? field['key'] ?? field['name'] ?? '';
  final keyStr = rawKey.toString().trim();
  final lower = keyStr.toLowerCase().replaceAll(' ', '').replaceAll('_', '');

  if (keyStr == 'siteVisitDate' ||
      lower == 'sitevisitdate' ||
      lower == 'sitevisitplanned') {
    return 'siteVisitDate';
  }
  if (keyStr == 'siteVisitDone' || lower == 'sitevisitdone') {
    return 'siteVisitDone';
  }
  if (keyStr == 'meetingDone' || lower == 'meetingdone') {
    return 'meetingDone';
  }
  return keyStr;
}

/// Helper to get the required display label for a stage field
String getStageFieldDisplayLabel(dynamic field) {
  final key = getStageFieldKey(field);
  if (key == 'siteVisitDate') {
    return 'Site Visit Planned';
  }
  if (key == 'siteVisitDone') {
    return 'Site Visit Done';
  }
  if (key == 'meetingDone') {
    return 'Meeting Done';
  }
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
                              "Date",
                              style: TextStyle(
                                fontSize: 11,
                                color: subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
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
                              "Time",
                              style: TextStyle(
                                fontSize: 11,
                                color: subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
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

