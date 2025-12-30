import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';
import '../services/auth_service.dart';
import '../explorer_user/ExplorerHome.dart';
import '../organizer/organizer_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  final String role;

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscurePassword = true;
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                'Login',
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

              const SizedBox(height: 50),

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

              const SizedBox(height: 30),

              // Login Button
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
                  onPressed: isLoading ? null : _loginWithEmail,
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
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange,
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
                  onPressed: isLoading ? null : _loginWithGoogle,
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
                  onPressed: isLoading ? null : _loginWithApple,
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
                    'Don\'t have an account? ',
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignupPage(role: widget.role),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
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

  // ===================== EMAIL LOGIN =====================
  void _loginWithEmail() async {
    if (!emailController.text.contains('@')) {
      _showMessage('Please enter a valid email');
      return;
    }

    if (passwordController.text.isEmpty) {
      _showMessage('Please enter your password');
      return;
    }

    setState(() => isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final user = await authService.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: widget.role,
      );

      if (user != null) {
        _showSuccess('Login successful!');
        _navigateToDashboard();
      } else {
        _showError('Login failed. Please check your credentials.');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Please try again later';
          break;
        case 'wrong-role':
          errorMessage = e.message ?? 'Please login with the correct role';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      _showError(errorMessage);
    } catch (e) {
      _showError('An unexpected error occurred');
      print('Email login error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ===================== GOOGLE LOGIN =====================
  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final user = await authService.signInWithGoogle(
        role: widget.role,
        isSignUp: false,
      );
      
      if (user != null) {
        _showSuccess('Google login successful!');
        _navigateToDashboard();
      } else {
        _showError('Google login cancelled.');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Google login failed';
      switch (e.code) {
        case 'wrong-role':
          errorMessage = e.message ?? 'Please login with the correct role';
          break;
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with the same email address. Please use email/password login.';
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
          errorMessage = 'Google login failed: ${e.message}';
      }
      _showError(errorMessage);
      print('Google login error: ${e.code} - ${e.message}');
    } catch (e) {
      _showError('Google login failed. Please try again.');
      print('Google login error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ===================== APPLE LOGIN =====================
  Future<void> _loginWithApple() async {
    setState(() => isLoading = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final user = await authService.signInWithApple(
        role: widget.role,
        isSignUp: false,
      );
      
      if (user != null) {
        _showSuccess('Apple login successful!');
        _navigateToDashboard();
      } else {
        _showError('Apple Sign-In is not available.');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Apple login failed';
      switch (e.code) {
        case 'wrong-role':
          errorMessage = e.message ?? 'Please login with the correct role';
          break;
        case 'not-available':
          errorMessage = 'Apple Sign-In is not available on this device.';
          break;
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with the same email address. Please use email/password login.';
          break;
        case 'cancelled':
          return; // User cancelled, no error message needed
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection';
          break;
        default:
          errorMessage = 'Apple login failed: ${e.message}';
      }
      _showError(errorMessage);
      print('Apple login error: ${e.code} - ${e.message}');
    } catch (e) {
      _showError('Apple login failed. Please try again.');
      print('Apple login error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ===================== FORGOT PASSWORD =====================
  void _forgotPassword() async {
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      _showMessage('Please enter your email address first');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Send password reset link to ${emailController.text}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: emailController.text.trim(),
                );
                _showSuccess('Password reset email sent! Check your inbox.');
              } on FirebaseAuthException catch (e) {
                String errorMessage = 'Failed to send reset email';
                switch (e.code) {
                  case 'user-not-found':
                    errorMessage = 'No user found with this email';
                    break;
                  case 'invalid-email':
                    errorMessage = 'Invalid email address';
                    break;
                  case 'user-disabled':
                    errorMessage = 'This account has been disabled';
                    break;
                  default:
                    errorMessage = 'Error: ${e.message}';
                }
                _showError(errorMessage);
              } catch (e) {
                _showError('Failed to send reset email');
              } finally {
                setState(() => isLoading = false);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
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