import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/databaseServices/eventSphere_db.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userProfile.dart';
import 'package:Project_Kururin_Exhibition/pages/registration.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userHome.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //validation controllers
  final emailCtrl = TextEditingController();
  final pwCtrl = TextEditingController();

  bool isVisible = false;
  bool _isLoading = false; // Add loading state for login

  void _login() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true; // Set loading state to true
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
      final u = await EventSphereDB.instance.getUserByEmail(email);

      if (u != null && u.password == pw) {
        // Upon successful login, navigate to the user profile page
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserHomePage(user: u)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid login credentials')),
        );
      }
    } catch (e) {
      print('Login error: $e'); // Print to console for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during login: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Always set loading state to false
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
              ? const CircularProgressIndicator() // Show loading indicator
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
          TextButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ), // Direct to profile for update
                ),
            child: const Text('Update Profile'),
          ),
        ],
      ),
    ),
  );
}
