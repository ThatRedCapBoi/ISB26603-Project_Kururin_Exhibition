import 'package:flutter/material.dart';

import 'package:Project_Kururin_Exhibition/widgets/components.dart';

import 'package:Project_Kururin_Exhibition/models/admin.dart';

import 'package:Project_Kururin_Exhibition/pages/homePage.dart';
// import 'package:Project_Kururin_Exhibition/pages/registration.dart';
import 'package:Project_Kururin_Exhibition/pages/login.dart';

import 'package:Project_Kururin_Exhibition/pages/user/userProfile.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userBookingList.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userBookingForm.dart';

import 'package:Project_Kururin_Exhibition/pages/admin/adminHome.dart';

class demoHomePage extends StatefulWidget {
  const demoHomePage({super.key, required this.title});

  final String title;

  @override
  State<demoHomePage> createState() => _demoHomePageState();
}

class _demoHomePageState extends State<demoHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      backgroundColor: Color(0xFFFEFEFA),
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
              'Base Environment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return HomePage();
                    },
                  ),
                );
              },
              child: Text("Home Page"),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginPage();
                    },
                  ),
                );
              },
              child: Text("Login"),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ProfilePage();
                    },
                  ),
                );
              },
              child: Text("User Profile"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return BookingListPage(userEmail: 'test@mail.com');
                    },
                  ),
                );
              },
              child: Text("Booth Booking List"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return BookingFormPage(userEmail: 'test@mail.com');
                    },
                  ),
                );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      // Replace with a valid Admin instance for demonstration
                      Admin demoAdmin = Admin(
                        id: 1,
                        name: 'Demo Admin 2025',
                        email: 'demo@admin.com',
                        password: '',
                      );
                      return AdminHomePage(admin: demoAdmin);
                    },
                  ),
                );
              },
              child: Text("Admin Homepage"),
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
