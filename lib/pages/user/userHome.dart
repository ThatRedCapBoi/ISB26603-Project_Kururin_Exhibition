import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userBookingForm.dart';
import 'package:flutter/material.dart';

import 'package:Project_Kururin_Exhibition/models/booth.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';

import 'package:Project_Kururin_Exhibition/pages/login.dart';

class UserHomePage extends StatelessWidget {
  final List<boothPackage> boothPackages = boothPackage.getBoothPackages();
  final User user;

  UserHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('EventSphere'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Column(
              children: [
                Text(
                  'Welcome ${user.name}!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Your one-stop platform for seamless exhibition booth reservations. '
                  'Discover flexible packages, book online, and manage your events with ease.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Display all booth cards based on index
          boothCard(context, boothPackages[0]),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return BookingFormPage(userEmail: user.email);
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Book Now!', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

Widget boothCard(BuildContext context, boothPackage booth) {
  var boothPackages = boothPackage.getBoothPackages();

  return Expanded(
    child: ListView.builder(
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: Image.asset(booth.boothImage, fit: BoxFit.cover),
                ),
              ),
              ListTile(
                title: Text(
                  booth.boothName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                          content: Text(booth.boothDescription),
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
    ),
  );
}
