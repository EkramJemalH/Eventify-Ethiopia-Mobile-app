import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'explorer_user/my_booking_page.dart';

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

          // User Info Card
          _buildUserInfoCard(context),

          const SizedBox(height: 24),

          // Booking History Button
          _buildButton(
            'Booking History',
            icon: Icons.history,
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

          // Notifications Button
          _buildButton(
            'Notifications',
            icon: Icons.notifications,
            onPressed: () {
              // TODO: Notifications settings
            },
          ),

          const SizedBox(height: 16),

          // Privacy & Security Button
          _buildButton(
            'Privacy & Security',
            icon: Icons.security,
            onPressed: () {
              // TODO: Privacy settings
            },
          ),

          const SizedBox(height: 16),

          // Help & Support Button
          _buildButton(
            'Help & Support',
            icon: Icons.help,
            onPressed: () {
              // TODO: Help & Support
            },
          ),

          const SizedBox(height: 16),

          // About Button
          _buildButton(
            'About',
            icon: Icons.info,
            onPressed: () {
              _showAboutDialog(context);
            },
          ),

          const SizedBox(height: 32),

          // Delete Account Button
          _buildButton(
            'Delete Account',
            icon: Icons.delete,
            color: Colors.red.shade50,
            textColor: Colors.red,
            onPressed: () {
              _showDeleteAccountDialog(context);
            },
          ),

          const SizedBox(height: 16),

          // Logout Button
          _buildButton(
            'Logout',
            icon: Icons.logout,
            color: Colors.orange,
            textColor: Colors.white,
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),

          const SizedBox(height: 40),

          // App Version
          const Center(
            child: Text(
              'Eventify Ethiopia v1.0.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== USER INFO CARD =====================
  Widget _buildUserInfoCard(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Card(
      elevation: 0,
      color: const Color(0xFFFAEBDB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User email
            Text(
              user?.email ?? 'User',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Account type
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user?.providerData.first.providerId == 'google.com' 
                        ? 'Google Account' 
                        : user?.providerData.first.providerId == 'apple.com'
                          ? 'Apple Account'
                          : 'Email Account',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================== BUTTON WIDGET =====================
  Widget _buildButton(
    String text, {
    required IconData icon,
    required VoidCallback onPressed,
    Color color = const Color(0xFFFAEBDB),
    Color textColor = Colors.black,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== DIALOGS =====================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              try {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.signOut();
                
                // Navigate to home page (role selection)
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This action cannot be undone. All your data will be permanently deleted including:'),
            SizedBox(height: 8),
            Text('• Your profile information'),
            Text('• Your booking history'),
            Text('• Your event data'),
            SizedBox(height: 12),
            Text('Are you absolutely sure?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmDeleteDialog(context);
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Enter "DELETE" to confirm account deletion:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Eventify Ethiopia'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eventify Ethiopia is your one-stop platform to discover and book amazing events across Ethiopia.',
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Discover events by category'),
            Text('• Book tickets securely'),
            Text('• Create events (Organizers)'),
            Text('• Manage your bookings'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}