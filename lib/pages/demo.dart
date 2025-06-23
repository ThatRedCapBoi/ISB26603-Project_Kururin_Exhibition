import 'package:Project_Kururin_Exhibition/pages/user/userHome.dart';
import 'package:flutter/material.dart';
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
    // Corrected User instantiation with String id and username
    final demoUser = User(
      id: 'demo_user_uid_123', // Placeholder Firebase UID
      name: 'Demo User',
      email: 'demo@example.com',
      phone: '123-456-7890',
      username: 'demouser1', // Added username
    );

    // Corrected Admin instantiation with String id
    final demoAdmin = Admin(
      id: 'demo_admin_uid_456', // Placeholder Firebase UID
      name: 'Demo Admin',
      email: 'admin@example.com',
      isAdmin: true,
      username: 'adminuser1', // Added username
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Existing demo buttons...
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
                child: const Text("Homepage"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const LoginPage();
                      },
                    ),
                  );
                },
                child: const Text("Login Page"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const RegistrationPage();
                      },
                    ),
                  );
                },
                child: const Text("Registration Page"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return UserHomePage(user: demoUser);
                      },
                    ),
                  );
                },
                child: const Text("User Homepage"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ProfilePage(user: demoUser);
                      },
                    ),
                  );
                },
                child: const Text("User Profile Page"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return BookingListPage(user: demoUser);
                      },
                    ),
                  );
                },
                child: const Text("User Booking List Page"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return BookingFormPage(user: demoUser);
                      },
                    ),
                  );
                },
                child: const Text("User Booking Form Page (New)"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
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
                child: const Text("Admin Homepage"),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}