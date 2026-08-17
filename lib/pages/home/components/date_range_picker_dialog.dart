import 'package:crm_flutter/styles/color_palette.dart';
import 'package:flutter/material.dart';

class DateRangePickerDialogg extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const DateRangePickerDialogg({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<DateRangePickerDialogg> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<DateRangePickerDialogg> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _endDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, reset end date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not selected';
    return '${_getWeekday(date)}, ${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getWeekday(DateTime date) {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
  }

  String _getMonthName(int month) {
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];
  }

  String? get _validationError {
    if (_startDate == null && _endDate == null) return null;
    if (_startDate == null) return 'Please select start date';
    if (_endDate == null) return 'Please select end date';
    if (_endDate!.isBefore(_startDate!)) {
      return 'End date cannot be before start date';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = _validationError == null;
    final Color primaryColor = Theme.of(context).primaryColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorConstants.MainPurpleBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select Date Range',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Start Date Card
                  _DateSelectionCard(
                    title: 'Start Date',
                    date: _startDate,
                    onTap: _selectStartDate,
                    isSelected: _startDate != null,
                  ),

                  const SizedBox(height: 16),

                  // Arrow between dates
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // End Date Card
                  _DateSelectionCard(
                    title: 'End Date',
                    date: _endDate,
                    onTap: _selectEndDate,
                    isSelected: _endDate != null,
                  ),

                  const SizedBox(height: 20),

                  // Validation Error
                  if (_validationError != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.orange.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _validationError!,
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Selected Range Summary
                  if (isValid)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorConstants.MainPurpleBackground.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Range:',
                            style: TextStyle(
                              color: ColorConstants.MainPurpleBackground,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Clear Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (_startDate != null || _endDate != null)
                          ? _clearSelection
                          : null,
                      icon: const Icon(Icons.clear_rounded, size: 15),
                      label: const Text('Clear'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Apply Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isValid
                          ? () {
                              Navigator.of(context).pop({
                                'startDate': _startDate,
                                'endDate': _endDate,
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.MainPurpleBackground,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSelectionCard extends StatelessWidget {
  final String title;
  final DateTime? date;
  final VoidCallback onTap;
  final bool isSelected;

  const _DateSelectionCard({
    required this.title,
    required this.date,
    required this.onTap,
    required this.isSelected,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Tap to select';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? ColorConstants.MainPurpleBackground.withValues(alpha: 0.4)
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: isSelected ? primaryColor : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected ? primaryColor : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
