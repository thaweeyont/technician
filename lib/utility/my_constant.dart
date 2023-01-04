import 'package:flutter/material.dart';

class MyConstant {
  // version application
  static String version_app = '1.0.16';

  // Color
  static Color primary = Color(0xff1b3778);
  static Color dark = Color(0xff00134b);
  static Color light = Color(0xff5060a7);

  // Color Gradient
  static Color dark_f = Color(0xff1b3778);
  static Color dark_e = Color(0xff5b85e3);

  // TextStyle
  TextStyle h1Style() => TextStyle(
        fontSize: 24,
        color: dark,
        fontWeight: FontWeight.bold,
        fontFamily: 'Prompt',
      );
  TextStyle h2Style() => TextStyle(
        fontSize: 18,
        color: dark,
        fontWeight: FontWeight.w700,
        fontFamily: 'Prompt',
      );
  TextStyle h2_5Style() => TextStyle(
        fontSize: 15,
        color: dark,
        fontWeight: FontWeight.w700,
        fontFamily: 'Prompt',
      );
  TextStyle h2_5greenStyle() => TextStyle(
        fontSize: 15,
        color: Colors.green,
        fontWeight: FontWeight.w700,
        fontFamily: 'Prompt',
      );
  TextStyle h2_5whiteStyle() => TextStyle(
        fontSize: 15,
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontFamily: 'Prompt',
      );
  TextStyle h2whiteStyle() => TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontFamily: 'Prompt',
      );
  TextStyle h3Style() => TextStyle(
        fontSize: 14,
        color: dark,
        fontWeight: FontWeight.normal,
        fontFamily: 'Prompt',
      );
  TextStyle mini() => TextStyle(
        fontSize: 13,
        color: dark,
        fontWeight: FontWeight.normal,
        fontFamily: 'Prompt',
      );
  TextStyle h3lightStyle() => TextStyle(
        fontSize: 14,
        color: Colors.grey[400],
        fontWeight: FontWeight.w700,
        fontFamily: 'Prompt',
      );
  TextStyle normalStyle() => TextStyle(
        fontSize: 14,
        color: Colors.grey,
        fontWeight: FontWeight.normal,
        fontFamily: 'Prompt',
      );
  TextStyle normallightStyle() => TextStyle(
        fontSize: 14,
        color: Colors.grey[350],
        fontWeight: FontWeight.normal,
        fontFamily: 'Prompt',
      );
  TextStyle normaldarkStyle() => TextStyle(
        fontSize: 14,
        color: dark,
        fontWeight: FontWeight.normal,
        fontFamily: 'Prompt',
      );
  TextStyle normalwhiteStyle() => TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.normal,
        fontFamily: 'Prompt',
      );
  TextStyle normalredStyle() => TextStyle(
        fontSize: 14,
        color: Colors.red,
        fontWeight: FontWeight.normal,
        fontFamily: 'Prompt',
      );
  TextStyle normalyelloStyle() => TextStyle(
        fontSize: 14,
        color: Colors.orange[300],
        fontWeight: FontWeight.normal,
        fontFamily: 'Prompt',
      );
}
