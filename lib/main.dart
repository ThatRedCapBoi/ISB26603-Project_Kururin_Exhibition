import 'package:flutter/material.dart';

import "common/theme.dart";
import 'widgets/components.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Kururin Exhibition',
      theme: appTheme,
      home: const MyHomePage(title: ' Kururin Exhibition - Sitemap Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Demo - Page Route Sitemap',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ShortDivider(color: Theme.of(context).colorScheme.primary),
            Text(
              'User Environment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) {
                //       return RegistrationPage();
                //     },
                //   ),
                // );
              },
              child: Text("Registration"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) {
                //       return LoginPage();
                //     },
                //   ),
                // );
              },
              child: Text("Login"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) {
                //       return UserProfilePage();
                //     },
                //   ),
                // );
              },
              child: Text("User Profile"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) {
                //       return BoothBookingFormPage();
                //     },
                //   ),
                // );
              },
              child: Text("Booth Booking Form"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) {
                //       return BoothBookingDetailPage();
                //     },
                //   ),
                // );
              },
              child: Text("Booth Booking Detail"),
            ),
            ShortDivider(color: Theme.of(context).colorScheme.primary),
            Text(
              'Administrator Environment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) {
                //       return AdminDashboardPage();
                //     },
                //   ),
                // );
              },
              child: Text("Admin Dashboard"),
            ),
          ],
        ),
      ),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }
}

Widget buildFloatingActionButton(BuildContext context) {
  return FloatingActionButton(
    onPressed: () {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => bookingPaymentPage()),
      // );
    },
    backgroundColor: Theme.of(context).colorScheme.primary,
    child: const Icon(Icons.shopping_cart_rounded, color: Colors.white),
  );
}
