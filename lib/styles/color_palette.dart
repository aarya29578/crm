import 'package:flutter/material.dart';

class ColorConstants {
  static Color ScaffoldBackground = hexToColor('#f0f1f5');
  static Color LightLabelGrey = hexToColor('#b9c0c4');
  static Color MainPurpleBackground = Color(0xFF1471FF);
  //static Color MainPurpleBackground = hexToColor('#6261fd');
  static Color MainGreyText = hexToColor('#97a1aa');
  static Color MainWhiteText = hexToColor('#c9f0bc');
  static Color FollowUpCardColor = hexToColor('#88d56d');
}

Color hexToColor(String hex) {
  assert(
    RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex),
    'hex color must be #rrggbb or #rrggbbaa',
  );

  return Color(
    int.parse(hex.substring(1), radix: 16) +
        (hex.length == 7 ? 0xff000000 : 0x00000000),
  );
}

extension ColorExtension on String {
  Color toColor() {
    Color? color;
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      color = Color(int.parse("0x$hexColor"));
    }
    return color!;
  }
}
