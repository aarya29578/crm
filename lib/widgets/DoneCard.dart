import 'package:flutter/material.dart';
import 'package:crm_flutter/widgets/ScheduleCard.dart';

DoneCard(time, name, organization, followup) {
  return Column(
    children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white),
        child: Done(time, name, organization, followup),
      ),
      ScheduleCard(),
    ],
  );
}

Done(time, name, organization, followup) {
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.white),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.call, size: 14, color: Colors.grey),
            SizedBox(width: 5),
            Expanded(
              child: Text(
                time,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
            ),

            Icon(Icons.local_fire_department, size: 18, color: Colors.red),
            Icon(Icons.local_fire_department, size: 18, color: Colors.grey),
            Icon(Icons.local_fire_department, size: 18, color: Colors.grey),
          ],
        ),
        SizedBox(height: 10),
        Text(
          name,
          style: TextStyle(
            color: const Color.fromARGB(255, 75, 74, 74),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          organization,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 20),
        Text(
          followup,
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
