import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/pages/homepage.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AdminHomePage extends StatefulWidget {
  final Admin admin;

  const AdminHomePage({super.key, required this.admin});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventSphere Admin Dashboard'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      // backgroundColor: const Color(0xFFFEFEFA),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 16),
            Text(
              'Welcome, ${widget.admin.name}!',
              style: TextStyle(
                fontSize: 24, // Increased font size for welcome message
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            // Updated adminTable to use Firestore
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Call the function from adminNavigation.dart
          onAdminDestinationSelected(
            context,
            index,
            widget.admin,
          ); // Changed function name
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Users'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
