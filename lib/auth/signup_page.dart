import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import '../services/auth_service.dart';
import '../explorer_user/ExplorerHome.dart';
import '../organizer/organizer_dashboard_page.dart';

class SignupPage extends StatefulWidget {
  final String role;

  const SignupPage({super.key, required this.role});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'as ${widget.role[0].toUpperCase()}${widget.role.substring(1)}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 30),

              _buildInputField(
                controller: fullNameController,
                label: 'Full Name',
              ),

              const SizedBox(height: 20),

              _buildInputField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              _buildPasswordField(
                controller: passwordController,
                label: 'Password',
                obscure: obscurePassword,
                onToggle: () {
                  setState(() => obscurePassword = !obscurePassword);
                },
              ),

              const SizedBox(height: 20),

              _buildPasswordField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                obscure: obscureConfirmPassword,
                onToggle: () {
                  setState(() =>
                      obscureConfirmPassword = !obscureConfirmPassword);
                },
              ),

              const SizedBox(height: 30),

              // Create Account Button
              SizedBox(
                width: buttonWidth,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : _signUpWithEmail,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 20),

              // Google Button
              SizedBox(
                width: buttonWidth,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signUpWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9D9D9),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google.png',
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Apple Button
              SizedBox(
                width: buttonWidth,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signUpWithApple,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9D9D9),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.apple, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Continue with Apple',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginPage(role: widget.role),
                        ),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black.withOpacity(0.5)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
        filled: true,
        fillColor: const Color(0xFFFAEBDB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: Colors.black.withOpacity(0.5)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
        filled: true,
        fillColor: const Color(0xFFFAEBDB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.orange,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  // ===================== EMAIL SIGN UP =====================
  void _signUpWithEmail() async {
    if (fullNameController.text.isEmpty) {
      _showMessage('Please enter your full name');
      return;
    }

    if (!emailController.text.contains('@')) {
      _showMessage('Please enter a valid email');
      return;
    }

    if (passwordController.text.length < 6) {
      _showMessage('Password must be at least 6 characters');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showMessage('Passwords do not match');
      return;
    }

    setState(() => isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final user = await authService.signUpWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        fullName: fullNameController.text.trim(),
        role: widget.role,
      );

      if (user != null) {
        _showSuccess('${widget.role} account created successfully!');
        
        // Navigate to appropriate dashboard
        _navigateToDashboard();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Sign up failed';
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          errorMessage = 'Sign up failed: ${e.message}';
      }
      _showError(errorMessage);
    } catch (e) {
      _showError('An unexpected error occurred');
      print('Email sign up error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ===================== GOOGLE SIGN UP =====================
  Future<void> _signUpWithGoogle() async {
    setState(() => isLoading = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final user = await authService.signInWithGoogle(
        role: widget.role,
        isSignUp: true,
      );
      
      if (user != null) {
        _showSuccess('Google sign up successful!');
        _navigateToDashboard();
      } else {
        _showError('Google sign up cancelled.');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Google sign up failed';
      switch (e.code) {
        case 'wrong-role':
          errorMessage = e.message ?? 'Role error occurred';
          break;
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with the same email address.';
          break;
        case 'invalid-credential':
          errorMessage = 'The credential is invalid or has expired';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google sign-in is not enabled';
          break;
        case 'user-disabled':
          errorMessage = 'This user has been disabled';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection';
          break;
        case 'popup-closed-by-user':
          return; // User cancelled, no error message needed
        default:
          errorMessage = 'Google sign up failed: ${e.message}';
      }
      _showError(errorMessage);
      print('Google sign up error: ${e.code} - ${e.message}');
    } catch (e) {
      _showError('Google sign up failed. Please try again.');
      print('Google sign up error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ===================== APPLE SIGN UP =====================
  Future<void> _signUpWithApple() async {
    setState(() => isLoading = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final user = await authService.signInWithApple(
        role: widget.role,
        isSignUp: true,
      );
      
      if (user != null) {
        _showSuccess('Apple sign up successful!');
        _navigateToDashboard();
      } else {
        _showError('Apple Sign-In is not available.');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Apple sign up failed';
      switch (e.code) {
        case 'wrong-role':
          errorMessage = e.message ?? 'Role error occurred';
          break;
        case 'not-available':
          errorMessage = 'Apple Sign-In is not available on this device.';
          break;
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with the same email address.';
          break;
        case 'cancelled':
          return; // User cancelled, no error message needed
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection';
          break;
        default:
          errorMessage = 'Apple sign up failed: ${e.message}';
      }
      _showError(errorMessage);
      print('Apple sign up error: ${e.code} - ${e.message}');
    } catch (e) {
      _showError('Apple sign up failed. Please try again.');
      print('Apple sign up error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ===================== HELPER METHODS =====================
  void _navigateToDashboard() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (widget.role == 'explorer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExploreHome(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrganizerDashboardPage(),
          ),
        );
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}