import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: ColorConstants.MainPurpleBackground,
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: Colors.white,
            letterSpacing: 0,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 40,
          left: 20,
          bottom: 20,
          right: 20,
        ),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              // Lock the calendar to only show month view
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 16),
            if (_selectedDay != null)
              Text(
                'Selected day: ${_selectedDay!.toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
