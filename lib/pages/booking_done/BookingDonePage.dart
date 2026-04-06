import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:crm_flutter/widgets/BookingCard.dart';

class BookingDonePage extends StatelessWidget {
  const BookingDonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),

              child: Text("8 Bookings Done", style: greyHeading),
            ),

            BookingCard(
              "24 D AGO . -> Transferred",
              "Amol Patil",
              "Kolte Patil Bond Digital Lead",
            ),
            SizedBox(height: 10),

            BookingCard(
              "24 D AGO . -> Transferred",
              "Amol Patil",
              "Kolte Patil Bond Digital Lead",
            ),
            SizedBox(height: 10),

            BookingCard(
              "24 D AGO . -> Transferred",
              "Amol Patil",
              "Kolte Patil Bond Digital Lead",
            ),
            SizedBox(height: 10),

            BookingCard(
              "24 D AGO . -> Transferred",
              "Amol Patil",
              "Kolte Patil Bond Digital Lead",
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
