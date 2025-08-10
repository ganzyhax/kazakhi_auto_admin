import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFEAEFFF);
  static const Color greyBackground = Color(0xFFF6F6F6);
  static const Color secondary = Colors.white;
  static const Color primary = Color(0xFF0F4C81);

  static final LinearGradient gradientPrimary = const LinearGradient(
    colors: [Color(0xff052DC1), Color(0xff052DC1)],
    stops: [0.25, 0.75],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static final LinearGradient gradientWhite = const LinearGradient(
    colors: [Colors.white, Color.fromARGB(255, 71, 68, 68)],
    stops: [0.25, 0.75],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static final LinearGradient gradientGrey = const LinearGradient(
    colors: [Color(0xff9fadb9), Color(0xff9fadb9)],
    stops: [0.25, 0.75],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
