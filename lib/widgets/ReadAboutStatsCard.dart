import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

Widget ReadAboutStatsCard() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    width: double.infinity,
    decoration: const BoxDecoration(color: Colors.white),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Read about stats",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildStatsRow("Activity Stats"),
        const SizedBox(height: 10),
        _buildDottedDivider(),
        const SizedBox(height: 10),
        _buildStatsRow("Leads Received Stats"),
        const SizedBox(height: 10),
        _buildDottedDivider(),
        const SizedBox(height: 10),
        _buildStatsRow("Calls Stats"),
        const SizedBox(height: 10),
        _buildDottedDivider(),
        const SizedBox(height: 10),
        _buildStatsRow("Revenue Stats"),
      ],
    ),
  );
}

Widget _buildStatsRow(String label) {
  return Row(
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(5),
        child: const Icon(Icons.message, color: Colors.white),
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(label)),
      const Icon(Icons.keyboard_arrow_right),
    ],
  );
}

Widget _buildDottedDivider() {
  return DottedLine(
    direction: Axis.horizontal,
    alignment: WrapAlignment.center,
    lineLength: double.infinity,
    lineThickness: 1.0,
    dashLength: 4.0,
    dashColor: Colors.grey.shade300,
    dashGapLength: 4.0,
    dashGapColor: Colors.transparent,
  );
}
