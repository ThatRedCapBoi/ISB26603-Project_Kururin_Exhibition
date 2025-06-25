import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/pages/homepage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
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
            const SizedBox(height: 16),
            Text(
              'Welcome, ${widget.admin.name}!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(child: expandableCard(context)),
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

class _ExpandableCard extends StatefulWidget {
  const _ExpandableCard({super.key});

  @override
  State<_ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<_ExpandableCard> {
  late Future<Map<String, int>> _dashboardCounts;

  @override
  void initState() {
    super.initState();
    _dashboardCounts = _fetchDashboardCounts();
  }

  Future<Map<String, int>> _fetchDashboardCounts() async {
    final usersSnap =
        await FirebaseFirestore.instance.collection('users').get();
    final boothPackagesSnap =
        await FirebaseFirestore.instance.collection('boothPackages').get();
    final boothBookingsSnap =
        await FirebaseFirestore.instance.collection('bookings').get();

    return {
      'users': usersSnap.size,
      'boothPackages': boothPackagesSnap.size,
      'boothBookings': boothBookingsSnap.size,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _dashboardCounts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final counts = snapshot.data ?? {};

        return GridView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          children: [
            _DashboardCard(
              title: 'Booth Bookings',
              count: counts['boothBookings'] ?? 0,
              icon: Icons.event_available,
              color: Colors.blue,
            ),
            _DashboardCard(
              title: 'Booth Packages',
              count: counts['boothPackages'] ?? 0,
              icon: Icons.store,
              color: Colors.green,
            ),
            _DashboardCard(
              title: 'Users',
              count: counts['users'] ?? 0,
              icon: Icons.people,
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }
}

Widget expandableCard(BuildContext context) {
  return _ExpandableCard();
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      surfaceTintColor: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
