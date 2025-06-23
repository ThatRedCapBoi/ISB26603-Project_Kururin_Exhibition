import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/pages/login.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userNavigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart' as auth; // Alias for FirebaseAuth

class ProfilePage extends StatefulWidget {
  final User user; // This refers to your custom User model from models/users.dart
  const ProfilePage({super.key, required this.user});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _form = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final usernameCtrl = TextEditingController(); // Added for username
  final pwCtrl = TextEditingController(); // For Firebase Auth password update

  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    nameCtrl.text = widget.user.name;
    emailCtrl.text = widget.user.email;
    phoneCtrl.text = widget.user.phone;
    usernameCtrl.text = widget.user.username; // Initialize username
    // Do NOT pre-fill password for security reasons
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    usernameCtrl.dispose();
    pwCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (_form.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Dismiss keyboard
      // You might want to show a loading indicator here
      // e.g., setState(() { _isLoading = true; });

      final auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No authenticated user found. Please log in again.')),
        );
        // setState(() { _isLoading = false; }); // Turn off loading if any
        return;
      }

      try {
        // 1. Update password if provided
        if (pwCtrl.text.isNotEmpty) {
          if (pwCtrl.text.length < 6) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password must be at least 6 characters long.')),
            );
            // setState(() { _isLoading = false; });
            return;
          }
          await firebaseUser.updatePassword(pwCtrl.text);
        }

        // 2. Update email in Firebase Auth if changed
        if (emailCtrl.text.trim() != firebaseUser.email) {
          await firebaseUser.updateEmail(emailCtrl.text.trim());
        }

        // 3. Update user data in Firestore
        final updatedData = {
          'name': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'username': usernameCtrl.text.trim(), // Include username
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid) // Use Firebase Auth UID as document ID
            .update(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        // Optionally, if the user's email was changed, you might want to force a re-login
        // or guide them to re-login to ensure the auth token is updated.
        // For simplicity, we'll just pop for now.
        Navigator.pop(context); // Pop back after successful save

      } on auth.FirebaseAuthException catch (e) {
        String message = 'Failed to update profile. ';
        if (e.code == 'requires-recent-login') {
          message += 'Please re-authenticate by logging in again to update sensitive fields (like email/password).';
        } else {
          message += e.message ?? 'An unknown authentication error occurred.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile in Firestore: ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      } finally {
        // setState(() { _isLoading = false; }); // Turn off loading indicator
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Enter email' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (v) => v!.isEmpty ? 'Enter phone' : null,
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: usernameCtrl, // Added username field
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => v!.isEmpty ? 'Enter username' : null,
              ),
              TextFormField(
                controller: pwCtrl,
                decoration: const InputDecoration(labelText: 'New Password (leave blank to keep current)'),
                obscureText: true,
                validator: (v) => v!.isNotEmpty && v.length < 6 ? 'Min 6 chars for new password' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          onUserDestinationSelected(context, index, widget.user);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book_online), label: 'Booking'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}