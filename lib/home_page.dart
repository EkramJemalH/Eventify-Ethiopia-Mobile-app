import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedRole = ''; // stores selected role

  void showRoleMessage(String role) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You selected $role!'),
        duration: const Duration(seconds: 2),
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

            // Circular profile/banner image
            ClipOval(
              child: Image.asset(
                'assets/images/profile.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // Welcome text
            const Text(
              'Welcome to Eventify Ethiopia',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Subtitle text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Discover Ethiopia’s Events All in One Place,\nwho are you',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 13, 13, 13),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Role buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  // Explorer button
                  ElevatedButton(
                    onPressed: () {
                      setState(() => selectedRole = 'Explorer');
                      showRoleMessage('I am an Explorer');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedRole == 'Explorer'
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
                        color: selectedRole == 'Explorer'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Event Organizer button
                  ElevatedButton(
                    onPressed: () {
                      setState(() => selectedRole = 'Event Organizer');
                      showRoleMessage('I am an Event Organizer');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedRole == 'Event Organizer'
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
                        color: selectedRole == 'Event Organizer'
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
