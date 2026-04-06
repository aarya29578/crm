import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/follow_up/FollowUpForm.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:get/get.dart';

class FollowUpDetailPage extends StatelessWidget {
  const FollowUpDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 100, left: 20, bottom: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 81, 197, 85),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Follow Up With Samruddhi satish kale",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Atlantaa Customer Data",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Fri, 9th May, 12:30 PM . 12:32 PM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.only(top: 20, left: 20, bottom: 10, right: 20),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Notes", style: greyHeading),

                NotesLabel(
                  "client koparkhairane me rehta hai 1 bhk main dekh toh raha hai",
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.all(20),
            child: Text("Client Info", style: greyHeading),
          ),

          Container(
            padding: EdgeInsets.only(top: 20, left: 20, bottom: 20, right: 20),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.call, color: Colors.grey, size: 12),
                    Expanded(
                      child: Text(
                        " - 1 MO AGO",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.grey,
                      size: 12,
                    ),
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.grey,
                      size: 12,
                    ),
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.grey,
                      size: 12,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "Samruddhi satish kale",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Atlantaa Customer Data",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          //First Button
          Container(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 20,
              right: 20,
            ),
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Add your button action here
                Get.to(FollowUpForm());
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white60,

                side: const BorderSide(width: 1.0, color: Colors.blueAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    4.0,
                  ), // Slight rectangle corners
                ),
                minimumSize: const Size(100, 48), // Minimum width and height
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Reschedule',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          //Second Button
          Container(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 20,
              right: 20,
            ),
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Add your button action here
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white60,
                side: const BorderSide(width: 1.0, color: Colors.blueAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    4.0,
                  ), // Slight rectangle corners
                ),
                minimumSize: const Size(100, 48), // Minimum width and height
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          Spacer(),

          //Third Button
          Container(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 20,
              right: 20,
            ),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Add your button action here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants
                    .MainPurpleBackground, // Button background color
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    4.0,
                  ), // Slight rectangle corners
                ),
                minimumSize: const Size(100, 48), // Minimum width and height
                elevation: 0,
              ),
              child: const Text(
                'Call Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

NotesLabel(data) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                shape: BoxShape.circle,
              ),
              child: Text("SV"),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 90, 90, 90),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Atlanta Customer Data",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    "Lead Note -- 1 mo ago",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey.shade200),
          child: Text(
            "Add a Note",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
