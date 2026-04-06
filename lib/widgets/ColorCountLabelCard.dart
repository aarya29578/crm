import 'package:flutter/material.dart';
//import 'package:crm_flutter/color_palette.dart';

ColorCountLabelCard(context) {
  return Container(
    width: MediaQuery.of(context).size.width / 3.0,
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 72, 209, 79),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: Colors.grey, width: 0.5),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,

      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "1",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 3),
        Text(
          'FOLLOW UP',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 0,
          ),
        ),
      ],
    ),
  );
}
