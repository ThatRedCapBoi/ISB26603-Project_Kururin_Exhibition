import 'package:Project_Kururin_Exhibition/pages/homePage.dart';
import 'package:flutter/material.dart';

import "common/theme.dart";

// import 'package:Project_Kururin_Exhibition/pages/demo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
