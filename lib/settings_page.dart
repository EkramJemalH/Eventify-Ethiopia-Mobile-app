import 'package:flutter/material.dart';

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
          const SizedBox(height: 40), // Top margin for Settings title
          // Settings Title centered
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
          // Booking History Button (aligned left)
          _buildButton('Booking History', onPressed: () {
            // Navigate to booking history page if needed
          }),
          const SizedBox(height: 16),
          // Delete Account Button
          _buildButton('Delete Account', onPressed: () {
            // Delete account logic
          }),
          const SizedBox(height: 16),
          // Logout Button (orange)
          _buildButton(
            'Logout',
            onPressed: () {
              // Logout logic
            },
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text,
      {required VoidCallback onPressed, Color color = const Color(0xFFFAEBDB)}) {
    return Align(
      alignment: Alignment.centerLeft, // Left align
      child: SizedBox(
        width: 250, // Slightly higher width
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
