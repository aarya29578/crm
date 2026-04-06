import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NoFreshLeadsPage extends StatelessWidget {
  const NoFreshLeadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              "No fresh leads",
              style: TextStyle(
                fontSize: 22,
                color: Colors.black87,
                letterSpacing: 0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Visit this space for new leads to claim. You can claim a lead as soon as it appears here.",

              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                letterSpacing: 0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
