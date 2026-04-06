import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:crm_flutter/color_palette.dart';

ListTileCard() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: Colors.grey, width: 0.5),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 80,
          padding: EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1 lead is ignored.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 3),
              Text(
                " View Leads",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0,
                  color: Colors.deepPurpleAccent.shade100,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          width: 100,
          height: 80,
          child: SvgPicture.asset("assets/svgs/ignore.svg"),
        ),
      ],
    ),
  );
}
