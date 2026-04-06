import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/text_styles.dart';

IconTileRow(iconName, color, text, ontap) {
  return InkWell(
    onTap: ontap,
    child: Container(
      padding: EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Icon(iconName, color: color),
          SizedBox(width: 10),
          Text(text, style: blackSmallTitle),
        ],
      ),
    ),
  );
}
