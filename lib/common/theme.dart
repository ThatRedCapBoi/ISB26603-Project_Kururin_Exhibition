import 'package:flutter/material.dart';

final appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    primary: Colors.deepPurple,
    secondary: Colors.deepPurpleAccent,
    tertiary: Colors.black,
  ),
  useMaterial3: true,

  appBarTheme: AppBarTheme(
    backgroundColor:
        Colors.deepPurple, // Set the AppBar background color to primary
    foregroundColor: Colors.white, // Set the AppBar text/icon color
  ),
  // textTheme: TextTheme(
  //   displayMedium: TextStyle(
  //     fontSize: 24,
  //     fontWeight: FontWeight.bold,
  //     color: Color.fromARGB(218, 16, 67, 155),
  //   ),
  //   displaySmall: TextStyle(
  //     fontSize: 20,
  //     fontWeight: FontWeight.bold,
  //     color: Color.fromARGB(218, 16, 67, 155),
  //   ),
  //   bodySmall: TextStyle(fontSize: 16, color: Color.fromARGB(218, 16, 67, 155)),
  //   // Add more styles as needed
  // ),
);
