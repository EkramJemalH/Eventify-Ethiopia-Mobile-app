import 'package:flutter/material.dart';
import '../auth/login_page.dart'; // Add this import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedRole = ''; // stores selected role

  void goToLogin(String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(role: role.toLowerCase()), // Navigate to LoginPage
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Logo
            ClipOval(
              child: Image.asset(
                'assets/images/profile.png', // Use your logo
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Welcome to Eventify Ethiopia',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Discover Ethiopia’s Events All in One Place,\nWho are you?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  // Explorer button
                  ElevatedButton(
                    onPressed: () {
                      setState(() => selectedRole = 'explorer');
                      goToLogin('explorer'); // Navigate to login
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedRole == 'explorer'
                          ? Colors.orange
                          : Colors.grey[300],
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'I am an Explorer',
                      style: TextStyle(
                        fontSize: 18,
                        color: selectedRole == 'explorer'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Event Organizer button
                  ElevatedButton(
                    onPressed: () {
                      setState(() => selectedRole = 'organizer');
                      goToLogin('organizer'); // Navigate to login
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedRole == 'organizer'
                          ? Colors.orange
                          : Colors.grey[300],
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'I am an Event Organizer',
                      style: TextStyle(
                        fontSize: 18,
                        color: selectedRole == 'organizer'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}