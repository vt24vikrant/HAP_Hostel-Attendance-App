import 'package:flutter/material.dart';

ThemeData lightMode =ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Color.fromARGB(255, 29, 247, 215),
    primary: Color.fromARGB(255, 1, 136, 103),
    secondary: Color.fromARGB(255, 4, 166, 155),
    inversePrimary: Colors.grey.shade900,
  ),
  textTheme: ThemeData.light().textTheme.apply(bodyColor: Colors.grey[800], displayColor: Colors.black,),
);