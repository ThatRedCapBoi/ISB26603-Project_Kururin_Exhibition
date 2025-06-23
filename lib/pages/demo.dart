import 'package:Project_Kururin_Exhibition/pages/user/userHome.dart';
import 'package:flutter/material.dart';

import 'package:Project_Kururin_Exhibition/widgets/components.dart';

import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';

import 'package:Project_Kururin_Exhibition/pages/homePage.dart';
import 'package:Project_Kururin_Exhibition/pages/registration.dart';
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
    final demoUser = User(
      id: 1,
      name: 'Demo User',
      email: 'demo@user.com',
      phone: '0123456789',
      password: 'password',
    );
    final demoAdmin = Admin(
      id: 1,
      name: 'Demo Admin',
      email: 'demo@admin.com',
      password: '',
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      backgroundColor: Color(0xFFFEFEFA),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 16),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white, // sets the text/icon color
                  textStyle: const TextStyle(color: Colors.white),
                ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white, // sets the text/icon color
                  textStyle: const TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return RegistrationPage();
                      },
                    ),
                  );
                },
                child: Text("Registration"),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white, // sets the text/icon color
                  textStyle: const TextStyle(color: Colors.white),
                ),
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
                child: const Text("Login"),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white, // sets the text/icon color
                  textStyle: const TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserHomePage(user: demoUser),
                    ),
                  );
                },
                child: Text("User Home Page"),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white, // sets the text/icon color
                  textStyle: const TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(user: demoUser),
                    ),
                  );
                },
                child: Text("User Profile"),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white, // sets the text/icon color
                  textStyle: const TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingListPage(user: demoUser),
                    ),
                  );
                },
                child: Text("Booth Booking List"),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white, // sets the text/icon color
                  textStyle: const TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingFormPage(user: demoUser),
                    ),
                  );
                },
                child: Text("Booth Booking Form"),
              ),
              SizedBox(height: 16),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white, // sets the text/icon color
                  textStyle: const TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return AdminHomePage(admin: demoAdmin);
                      },
                    ),
                  );
                },
                child: Text("Admin Homepage"),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      // floatingActionButton: buildFloatingActionButton(context),
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
