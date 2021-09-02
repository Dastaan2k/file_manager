import 'dart:ui';

import 'package:flutter/material.dart';

class CustomColor
{
  static Color lightBackground = HexColor("#EBEBEB");
  static Color darkBackgroundFront = HexColor("#32ae85").withOpacity(0.08);
}


class HexColor extends Color {

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}