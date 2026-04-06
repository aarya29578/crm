import 'package:flutter/material.dart';
import 'package:crm_flutter/widgets/ProjectCard.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class LeadsReceivedPage extends StatelessWidget {
  const LeadsReceivedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Date Today Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FormBuilderDateTimePicker(
                name: 'date',
                initialValue: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                inputType: InputType.date,
                format: DateFormat('dd MMM, yyyy'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  border: InputBorder.none,
                  hintText: 'Select date',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  isDense: true,
                ),
                valueTransformer: (value) {
                  if (value == null) return null;
                  final today = DateTime.now();
                  final isToday =
                      value.year == today.year &&
                      value.month == today.month &&
                      value.day == today.day;
                  return isToday
                      ? 'Today, ${DateFormat('dd MMM').format(value)}'
                      : DateFormat('EEE, dd MMM').format(value);
                },
                onChanged: (DateTime? value) {
                  // Handle date change
                },
              ),
            ),

            //First empty Card Container
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: 180,
                    height: 160,
                    child: SvgPicture.asset("assets/svgs/not_found.svg"),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No leads received yet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "You don't have any leads received data",
                    style: TextStyle(fontSize: 16, letterSpacing: 0),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            ProjectCard(),

            SizedBox(height: 10),

            ProjectCard(),

            SizedBox(height: 10),

            ProjectCard(),
          ],
        ),
      ),
    );
  }
}
