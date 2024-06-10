import 'package:flutter/material.dart';

ThemeData darkMode =ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade700,
    primary: Colors.grey.shade600,
    secondary: Colors.grey.shade500,
    inversePrimary: Colors.grey.shade900,
  ),
  textTheme: ThemeData.light().textTheme.apply(bodyColor: Colors.grey[200], displayColor: Colors.white,),
);