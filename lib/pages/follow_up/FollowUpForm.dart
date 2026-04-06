import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:intl/intl.dart';

class FollowUpForm extends StatefulWidget {
  const FollowUpForm({super.key});

  @override
  State<FollowUpForm> createState() => _FollowUpFormState();
}

class _FollowUpFormState extends State<FollowUpForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  DateTime? _selectedDateTime;
  final List<int> minuteOptions = [2, 5, 10, 30, 60];
  int? selectedDuration;
  int? selectedReminder;

  Future<void> _selectDateTime(BuildContext context) async {
    // First pick the date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Then pick the time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDateTime != null
            ? TimeOfDay.fromDateTime(_selectedDateTime!)
            : TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateTimeController.text = _formatDateTime(_selectedDateTime!);
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    // Format as "Fri, 9th Mar 2025, 12:30PM"
    final day = DateFormat('EEE').format(dateTime); // "Fri"
    final date = _getOrdinalDate(dateTime.day); // "9th"
    final month = DateFormat('MMM').format(dateTime); // "Mar"
    final year = dateTime.year; // 2025
    final time = DateFormat('h:mm a').format(dateTime); // "12:30 PM"

    return '$day, $date $month $year, $time';
  }

  String _getOrdinalDate(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          children: [
            const Text(
              "Follow Up",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.only(
            top: 20,
            left: 20,
            bottom: 10,
            right: 20,
          ),
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Follow-up details field
              const SizedBox(height: 20),

              // Combined date & time picker field
              TextFormField(
                controller: _dateTimeController,
                decoration: InputDecoration(
                  labelText: 'Date and Time of Follow-up',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDateTime(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select date and time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  // Duration dropdown
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedDuration,
                      decoration: InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      items: minuteOptions.map((minutes) {
                        return DropdownMenuItem<int>(
                          value: minutes,
                          child: Text('$minutes minutes'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDuration = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Select duration' : null,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Reminder dropdown
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedReminder,
                      decoration: InputDecoration(
                        labelText: 'Remind me before',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      items: minuteOptions.map((minutes) {
                        return DropdownMenuItem<int>(
                          value: minutes,
                          child: Text('$minutes minutes'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedReminder = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Select reminder' : null,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              // Add a Note option
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Add a note (optional)',
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal:
                        0, // Remove horizontal padding for flush alignment
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // Submit button
              Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants
                        .MainPurpleBackground, // Replace with your ColorConstants
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    minimumSize: const Size(100, 48),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Schedule Follow Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
