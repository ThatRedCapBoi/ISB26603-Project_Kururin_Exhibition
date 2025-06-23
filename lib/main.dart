import 'package:Project_Kururin_Exhibition/pages/homePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core

import "common/theme.dart";

// Make main an async function
void main() async { // Add 'async' keyword here
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase here
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Kururin Exhibition',
      theme: appTheme,
      // home: const demoHomePage(title: ' Kururin Exhibition - Sitemap Demo'),
      home: HomePage(),
    );
  }
}