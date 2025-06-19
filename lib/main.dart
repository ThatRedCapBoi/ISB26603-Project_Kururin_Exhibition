import 'package:flutter/material.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import "common/theme.dart";

import 'package:Project_Kururin_Exhibition/pages/demo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Kururin Exhibition',
      theme: appTheme,
      home: const demoHomePage(title: ' Kururin Exhibition - Sitemap Demo'),
    );
  }
}
