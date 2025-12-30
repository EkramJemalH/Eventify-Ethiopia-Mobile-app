import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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
                  builder: (_) => MyBookingPage(),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications feature coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Privacy & Security Button
          _buildButton(
            'Privacy & Security',
            icon: Icons.security,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy & Security coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Help & Support Button
          _buildButton(
            'Help & Support',
            icon: Icons.help,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help & Support coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
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
                    _getAccountType(user),
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

  String _getAccountType(User? user) {
    if (user == null) return 'Guest';
    
    for (final provider in user.providerData) {
      if (provider.providerId == 'google.com') return 'Google Account';
      if (provider.providerId == 'apple.com') return 'Apple Account';
      if (provider.providerId == 'facebook.com') return 'Facebook Account';
    }
    
    return 'Email Account';
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
                await FirebaseAuth.instance.signOut();
                
                // Navigate to WELCOME/ROLE SELECTION PAGE
                // Use the correct route for your app
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/welcome', // CHANGE THIS to your actual welcome/role selection route
                  (route) => false,
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                print('Logout error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
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
        title: const Text('Confirm Account Deletion'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will permanently:'),
            SizedBox(height: 8),
            Text('• Delete your account'),
            Text('• Remove all your data'),
            Text('• Cancel any upcoming bookings'),
            SizedBox(height: 12),
            Text('Type "DELETE" to confirm:'),
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
              _performAccountDeletion(context);
            },
            child: const Text(
              'Confirm Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performAccountDeletion(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user logged in'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );

      try {
        // First, try to delete user data from Realtime Database
        final dbRef = FirebaseDatabase.instance.ref();
        
        // Delete from users collection
        await dbRef.child('users').child(user.uid).remove();
        
        // Also delete any events created by this user (for organizers)
        final eventsSnapshot = await dbRef.child('events').orderByChild('creatorId').equalTo(user.uid).get();
        if (eventsSnapshot.exists) {
          final events = eventsSnapshot.value as Map<dynamic, dynamic>;
          for (final eventId in events.keys) {
            await dbRef.child('events').child(eventId.toString()).remove();
          }
        }
        
        print('User data deleted from database');
      } catch (e) {
        print('Error deleting user data from database: $e');
        // Continue with auth deletion even if database deletion fails
      }

      // Delete user from Firebase Auth
      await user.delete();
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate to WELCOME/ROLE SELECTION PAGE
      // IMPORTANT: Use the correct route for your app
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/welcome', // CHANGE THIS to your actual welcome/role selection route
        (route) => false,
      );
      
    } on FirebaseAuthException catch (e) {
      // Close loading dialog first
      if (Navigator.canPop(context)) Navigator.pop(context);
      
      print('Auth deletion error: $e');
      String errorMessage = 'Failed to delete account';
      
      if (e.code == 'requires-recent-login') {
        // This error happens when user hasn't authenticated recently
        errorMessage = 'Please log in again before deleting your account';
        
        // Show dialog to ask user to re-authenticate
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Re-authentication Required'),
            content: const Text(
              'For security reasons, please log in again before deleting your account.\n\n'
              'Click OK to logout and login again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close dialog
                  
                  // Logout first
                  await FirebaseAuth.instance.signOut();
                  
                  // Navigate to login page
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/welcome', // Your login/welcome route
                    (route) => false,
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please login again to delete your account'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
      } else if (e.code == 'user-not-found') {
        errorMessage = 'User account not found';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid credentials';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Close loading dialog first
      if (Navigator.canPop(context)) Navigator.pop(context);
      
      print('Unexpected error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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

// ===================== MY BOOKING PAGE (Placeholder) =====================
class MyBookingPage extends StatelessWidget {
  const MyBookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Booking History',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your booking history will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}