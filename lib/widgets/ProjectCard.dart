import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';

ProjectCard() {
  return Container(
    padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
    width: double.infinity,
    decoration: BoxDecoration(color: Colors.white),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.call, color: Colors.grey),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "43",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "WIP Leads",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),

        Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),

          child: Row(
            children: [
              Icon(Icons.circle, size: 14, color: Colors.red),
              SizedBox(width: 10),
              Expanded(child: Text("Failed")),
              Text(
                "27972",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        DottedLine(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          lineLength: 300,
          lineThickness: 1.0,
          dashLength: 4.0,
          dashColor: Colors.grey.shade200,
          dashGapLength: 4.0,
          dashGapColor: Colors.transparent,
        ),

        Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),

          child: Row(
            children: [
              Icon(Icons.circle, size: 14, color: Colors.green),
              SizedBox(width: 10),
              Expanded(child: Text("Bookings done")),
              Text(
                "8",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        DottedLine(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          lineLength: 300,
          lineThickness: 1.0,
          dashLength: 4.0,
          dashColor: Colors.grey.shade200,
          dashGapLength: 4.0,
          dashGapColor: Colors.transparent,
        ),

        Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),

          child: Row(
            children: [
              Icon(Icons.circle, size: 14, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text("Total bookings")),
              Text(
                "0",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        DottedLine(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          lineLength: 300,
          lineThickness: 1.0,
          dashLength: 4.0,
          dashColor: Colors.grey.shade200,
          dashGapLength: 4.0,
          dashGapColor: Colors.transparent,
        ),

        Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
          child: Row(
            children: [
              Icon(Icons.circle, size: 14, color: Colors.white),

              SizedBox(width: 10),
              Expanded(child: Text("Ignored")),
              Text(
                "1",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
