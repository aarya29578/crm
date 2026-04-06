import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/text_styles.dart';

PeriodCard(day) {
  return Container(
    padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
    width: double.infinity,
    child: Text(day, style: greyHeading),
  );
}
