import 'package:flutter/material.dart';

CallCard(name, number, someText, time, minutes) {
  return Container(
    padding: EdgeInsets.only(left: 20, top: 10, bottom: 20, right: 20),
    decoration: BoxDecoration(color: Colors.white),
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.call_missed_outgoing, color: Colors.green),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 90, 90, 90),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    number,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    someText,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 10),

                  Text(
                    "Atlantaa Lead",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 92, 91, 91),
                      letterSpacing: 0,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    minutes,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 190, 190, 190),
                      letterSpacing: 0,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.call, color: Colors.deepPurpleAccent),
          ],
        ),
      ],
    ),
  );
}
