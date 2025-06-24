// lib/pages/login.dart
import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart'; // This is your custom User model
import 'package:Project_Kururin_Exhibition/pages/registration.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userHome.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminHome.dart'; // Make sure this import is correct and AdminHomePage exists
import 'package:firebase_auth/firebase_auth.dart'
    as auth; // ADDED 'as auth' HERE
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final pwCtrl = TextEditingController();

  bool isVisible = false;
  bool _isLoading = false;

  void _login() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final email = emailCtrl.text.trim();
    final pw = pwCtrl.text;

    if (email.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Authenticate user with Firebase Auth
      // Use 'auth.UserCredential' and 'auth.FirebaseAuth.instance'
      auth.UserCredential userCredential = await auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pw);

      String uid = userCredential.user!.uid;

      // 2. Check if the authenticated user is an administrator
      DocumentSnapshot adminDoc =
          await FirebaseFirestore.instance
              .collection('administrators')
              .doc(uid)
              .get();

      if (adminDoc.exists &&
          adminDoc.data() != null &&
          (adminDoc.data() as Map<String, dynamic>)['isAdmin'] == true) {
        // User is an admin
        final admin = Admin.fromFirestore(
          adminDoc,
        ); // This is your custom Admin model
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin login successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminHomePage(admin: admin),
          ), // Pass the 'admin' object here
        );
      } else {
        // User is a regular user, fetch their profile from 'users' collection
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          final user = User.fromFirestore(
            userDoc,
          ); // This is your custom User model
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserHomePage(user: user),
            ), // Pass the 'user' object here
          );
        } else {
          // This case should ideally not happen if registration worked
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'User profile not found in database. Please register or contact support.',
              ),
            ),
          );
          await auth.FirebaseAuth.instance
              .signOut(); // Use 'auth.FirebaseAuth' here
        }
      }
    } on auth.FirebaseAuthException catch (e) {
      // Use 'auth.FirebaseAuthException' here
      String message = 'An authentication error occurred.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many failed login attempts. Try again later.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      print('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: ${e.toString()}'),
        ),
      );
      print('Login error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Login')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: pwCtrl,
            obscureText: !isVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isVisible = !isVisible;
                  });
                },
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _login, child: const Text('Login')),
          TextButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrationPage(),
                  ),
                ),
            child: const Text('Register Here'),
          ),
        ],
      ),
    ),
  );
}
