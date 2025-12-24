import 'package:flutter/material.dart';
import 'my_booking_page.dart'; // 👈 ADD THIS

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 40),

          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Back',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Settings Title
          const Center(
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Booking History Button
          _buildButton(
            'Booking History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyBookingPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Delete Account Button
          _buildButton(
            'Delete Account',
            onPressed: () {
              // TODO: Delete account logic
            },
          ),

          const SizedBox(height: 16),

          // Logout Button
          _buildButton(
            'Logout',
            onPressed: () {
              // TODO: Logout logic
            },
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text, {
    required VoidCallback onPressed,
    Color color = const Color(0xFFFAEBDB),
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 250,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
