import 'package:flutter/material.dart';

import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart';

import 'package:Project_Kururin_Exhibition/models/admin.dart';

class AdminBookingPage extends StatefulWidget {
  final Admin admin;

  const AdminBookingPage({super.key, required this.admin});

  @override
  State<AdminBookingPage> createState() => _AdminBookingPageState();
}

class _AdminBookingPageState extends State<AdminBookingPage> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventSphere'),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFFEFEFA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Admin Booking Page',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          onAdminDestinationSelected(context, index, widget.admin);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_online),
            label: 'Booking',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
