import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/login_page.dart';
import '../services/auth_service.dart';
import 'explorer_user/ExplorerHome.dart';
import 'organizer/organizer_dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedRole = '';
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkIfUserIsLoggedIn();
  }

  void _checkIfUserIsLoggedIn() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user != null) {
      _redirectLoggedInUser(user.uid, authService);
    } else {
      setState(() => _isCheckingAuth = false);
    }
  }

  Future<void> _redirectLoggedInUser(String uid, AuthService authService) async {
    try {
      final userData = await authService.getUserData(uid);
      final role = userData?['role'] ?? 'explorer';

      if (role == 'organizer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OrganizerDashboardPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExploreHome()),
        );
      }
    } catch (_) {
      setState(() => _isCheckingAuth = false);
    }
  }

  void goToSignup(String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(role: role.toLowerCase()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(height: 20),
              Text('Checking your account...', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final double buttonWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
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
                  ElevatedButton(
                    onPressed: () {
                      setState(() => selectedRole = 'explorer');
                      goToSignup('explorer');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedRole == 'explorer' ? Colors.orange : Colors.grey[300],
                      minimumSize: Size(buttonWidth, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'I am an Explorer',
                      style: TextStyle(
                        fontSize: 18,
                        color: selectedRole == 'explorer' ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => selectedRole = 'organizer');
                      goToSignup('organizer');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedRole == 'organizer' ? Colors.orange : Colors.grey[300],
                      minimumSize: Size(buttonWidth, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'I am an Event Organizer',
                      style: TextStyle(
                        fontSize: 18,
                        color: selectedRole == 'organizer' ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: TextButton(
                onPressed: () {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final user = authService.currentUser;
                  if (user != null) {
                    _redirectLoggedInUser(user.uid, authService);
                  } else {
                    goToSignup('explorer'); // default to explorer login
                  }
                },
                child: const Text(
                  'Already have an account? Continue',
                  style: TextStyle(fontSize: 16, color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
