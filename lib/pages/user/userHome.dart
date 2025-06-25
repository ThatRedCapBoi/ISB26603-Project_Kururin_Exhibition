// import 'package:Project_Kururin_Exhibition/pages/user/userBookingForm.dart';
import 'package:Project_Kururin_Exhibition/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Project_Kururin_Exhibition/models/booth.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userNavigation.dart';

import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart'
    as auth; // Alias for FirebaseAuth

class UserHomePage extends StatelessWidget {
  final User user;

  const UserHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('EventSphere'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await auth.FirebaseAuth.instance.signOut();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Text(
                  'Welcome ${user.name}!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Your one-stop platform for seamless exhibition booth reservations. '
                  'Discover flexible packages, book online, and manage your events with ease.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(child: BoothPackageList()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          onUserDestinationSelected(context, index, user);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Modular widget for fetching and displaying booth packages
class BoothPackageList extends StatelessWidget {
  const BoothPackageList({super.key});

  Future<List<BoothPackage>> fetchBoothPackages() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('boothPackages').get();
    return snapshot.docs.map((doc) => BoothPackage.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BoothPackage>>(
      future: fetchBoothPackages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No booth packages found.'));
        } else {
          final boothPackages = snapshot.data!;
          return ListView.builder(
            itemCount: boothPackages.length,
            itemBuilder: (context, index) {
              final booth = boothPackages[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: AspectRatio(
                        aspectRatio: 3 / 2,
                        child: Image.asset(booth.boothImage, fit: BoxFit.cover),
                      ),
                    ),
                    ListTile(
                      leading: Text(
                        'RM${booth.boothPrice.toString()}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          // backgroundColor: Theme.of(context).colorScheme.primary,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        booth.boothName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        booth.boothDescription,
                        style: TextStyle(height: 1.4),
                      ),
                      trailing: Icon(Icons.info_outline),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text(booth.boothName),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'RM${booth.boothPrice}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    Text(
                                      'Decription\n• ${booth.boothDescription}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Capacity\n• ${booth.boothCapacity}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Close"),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
