import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:crm_flutter/widgets/LeadCard.dart';
import 'package:crm_flutter/widgets/ScheduleCard.dart';

class IgnoredLeadsPage extends StatelessWidget {
  const IgnoredLeadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: ColorConstants.MainPurpleBackground,
        title: Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          child: Text(
            "Ignored Leads",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            color: Colors.white,
            width: double.infinity,
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: Text(
                    "Claimed (new to old)",
                    style: TextStyle(
                      color: ColorConstants.MainPurpleBackground,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: 180, // Adjust height to match your text size
                  width: 3,
                  color: Colors.grey.shade200,
                  margin: EdgeInsets.symmetric(
                    horizontal: 10,
                  ), // Same effect as SizedBox(width: 10)
                ),
                Center(
                  child: Text(
                    "Filters (0)",
                    style: TextStyle(
                      color: ColorConstants.MainPurpleBackground,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
            color: Colors.white,
            child: Row(
              children: [
                Icon(Icons.search, size: 20),
                SizedBox(width: 10),
                Text(
                  'Search by name or number',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Text("1 Leads", style: greyHeading),
          ),
          LeadCard("3 MO AGO", "Prachi Singh", "Lunaris Lead"),
          ScheduleCard(),
          //Expanded(child: Container(color: Colors.grey.shade200)),
        ],
      ),
    );
  }
}
