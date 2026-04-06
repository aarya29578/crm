import 'package:flutter/material.dart';
//import 'package:crm_flutter/color_palette.dart';

countLabelCard(count, label) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: Colors.grey, width: 0.5),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),

        Text(
          label.toString(),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    ),
  );
}
