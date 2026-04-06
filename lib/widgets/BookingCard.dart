import 'package:flutter/material.dart';
import 'package:crm_flutter/widgets/ScheduleCard.dart';

BookingCard(time, name, organization) {
  return Column(
    children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white),
        child: Booking(time, name, organization),
      ),
      ScheduleCard(),
    ],
  );
}

Booking(time, name, organization) {
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
            Text(
              time,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0,
              ),
            ),
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
      ],
    ),
  );
}
