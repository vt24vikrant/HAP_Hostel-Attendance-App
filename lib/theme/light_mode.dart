import 'package:flutter/material.dart';

ThemeData lightMode =ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: const Color.fromARGB(255, 29, 247, 215),
    primary: const Color.fromARGB(255, 4, 163, 236),
    secondary: const Color.fromARGB(255, 62, 250, 234),
    inversePrimary: Colors.grey.shade900,
  ),
  textTheme: ThemeData.light().textTheme.apply(bodyColor: Colors.grey[800], displayColor: Colors.black,),
);