import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:flutter_svg/svg.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.blueAccent,
        title: Center(child: Text("Notifications Tab", style: whiteHeading)),
      ),
      body: Container(
        //alignment: Alignment.center,
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 160,
              child: SvgPicture.asset("assets/svgs/not_found.svg"),
            ),
            Text(
              "No Notifications",
              style: TextStyle(
                fontSize: 22,
                color: Colors.black87,
                letterSpacing: 0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
