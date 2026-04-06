import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/widgets/ScheduleCard.dart';

LeadCardPage() {
  return Scaffold(
    backgroundColor: Colors.grey.shade200,
    appBar: AppBar(
      backgroundColor: ColorConstants.MainPurpleBackground,
      title: Text("Ignored Leads", style: TextStyle(color: Colors.white)),
    ),

    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "1 Leads",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0,
          ),
        ),
        LeadCard("3 MO AGO", "Prachi Singh", "Lunaris Lead"),
        ScheduleCard(),
      ],
    ),
  );
}

LeadCard(time, name, organization) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 14),
                      SizedBox(width: 5),
                      Text(
                        "No event scheduled",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Plan your next event",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                      color: const Color.fromARGB(255, 75, 74, 74),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
              width: 110,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 1.0, color: Colors.blueAccent),
                ),
                child: Text(
                  'Schedule',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    ),
  );
}
