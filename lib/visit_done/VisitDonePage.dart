import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:crm_flutter/widgets/DoneCard.dart';

class VisitDonePage extends StatelessWidget {
  const VisitDonePage({super.key});

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
              child: Text("31 Visits Done", style: greyHeading),
            ),

            DoneCard(
              "6 D AGO",
              "Sanjay Kanojia",
              "Raheja Solaris Digital Lead",
              " Follow Up - 2 h",
            ),
            SizedBox(height: 20),

            DoneCard(
              "6 D AGO",
              "Sanjay Kanojia",
              "Raheja Solaris Digital Lead",
              " Follow Up - 2 h",
            ),
            SizedBox(height: 20),

            DoneCard(
              "6 D AGO",
              "Sanjay Kanojia",
              "Raheja Solaris Digital Lead",
              " Follow Up - 2 h",
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
