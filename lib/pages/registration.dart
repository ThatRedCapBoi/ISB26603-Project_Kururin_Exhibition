// import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/databaseServices/eventSphere_db.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/pages/login.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController pwCtrl = TextEditingController();
  final TextEditingController confirmPwCtrl = TextEditingController();

  bool isPasswordVisible = false;
  bool _isLoading = false; // Add a loading state

  void _register() async {
    // Prevent multiple clicks while processing
    if (_isLoading) return;

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    final String name = nameCtrl.text.trim();
    final String email = emailCtrl.text.trim();
    final String phone = phoneCtrl.text.trim();
    final String password = pwCtrl.text;
    final String confirmPassword = confirmPwCtrl.text;

    // Basic client-side validation
    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Check if user already exists
      final existingUser = await EventSphereDB.instance.getUserByEmail(email);
      if (existingUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email already registered. Please login or use a different email.',
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final newUser = User(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      final id = await EventSphereDB.instance.insertUser(
        newUser,
      ); // Capture the ID for logging/debugging
      if (id > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        // Navigate back to login page after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        // This 'else' block might hit if insertUser returns 0 (no rows affected)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Please try again.'),
          ),
        );
      }
    } catch (e) {
      // Catch any unexpected errors during the registration process
      print('Registration error: $e'); // Print to console for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred during registration: ${e.toString()}',
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Always set loading state to false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: pwCtrl,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            TextField(
              controller: confirmPwCtrl,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator() // Show loading indicator while processing
                : ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
            TextButton(
              onPressed:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
