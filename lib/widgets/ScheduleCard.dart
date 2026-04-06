import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/color_palette.dart';

ScheduleCard() {
  return Container(
    decoration: BoxDecoration(color: Colors.white),

    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Expanded(
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       border: Border.all(color: Colors.grey.shade200, width: 0.7),
        //     ),
        //     child: IconButton(
        //       icon: Icon(
        //         Icons.arrow_right_alt,
        //         color: ColorConstants.MainPurpleBackground,
        //       ),
        //       onPressed: () {}, // Add your onPressed action
        //       padding: EdgeInsets.all(16), // Makes the tap target larger
        //     ),
        //   ),
        // ),
        // Expanded(
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       border: Border.all(color: Colors.grey.shade200, width: 0.7),
        //     ),
        //     child: IconButton(
        //       icon: Icon(
        //         Icons.calendar_month,
        //         color: ColorConstants.MainPurpleBackground,
        //       ),
        //       onPressed: () {}, // Add your onPressed action
        //       padding: EdgeInsets.all(16), // Makes the tap target larger
        //     ),
        //   ),
        // ),
        // Expanded(
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       border: Border.all(color: Colors.grey.shade200, width: 0.7),
        //     ),
        //     child: IconButton(
        //       icon: Icon(
        //         Icons.chat_bubble_outline,
        //         color: ColorConstants.MainPurpleBackground,
        //       ),
        //       onPressed: () {}, // Add your onPressed action
        //       padding: EdgeInsets.all(16), // Makes the tap target larger
        //     ),
        //   ),
        // ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200, width: 0.7),
            ),
            child: IconButton(
              color: Colors.blue,
              icon: Icon(
                Icons.call,
                color: ColorConstants.MainPurpleBackground,
              ),
              onPressed: () {}, // Add your onPressed action
              padding: EdgeInsets.all(16), // Makes the tap target larger
            ),
          ),
        ),
      ],
    ),
  );
}
