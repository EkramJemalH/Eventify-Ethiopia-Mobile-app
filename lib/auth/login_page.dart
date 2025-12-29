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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 10),
              
              Text(
                'as ${widget.role[0].toUpperCase()}${widget.role.substring(1)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 40),
              
              _buildTextField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 20),
              
              _buildPasswordField(),
              
              const SizedBox(height: 10),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: isLoading ? null : _loginWithEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
              ),
              
              const SizedBox(height: 30),
              
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
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
                  child: const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 16),
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
                  child: const Text(
                    'Continue with Apple',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignupPage(role: widget.role),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
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

  // ===================== LOGIN METHODS =====================
  Future<void> _loginWithEmail() async {
    // Validation
    if (emailController.text.trim().isEmpty) {
      _showMessage('Please enter your email');
      return;
    }

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
      );

      if (user != null) {
        // Check user role from database
        final userData = await authService.getUserData(user.uid);
        
        if (userData != null) {
          final userRole = userData['role'];
          
          // Check if selected role matches database role
          if (userRole != widget.role) {
            _showError('Please login as ${userRole[0].toUpperCase()}${userRole.substring(1)}');
          } else {
            _showSuccess('Login successful!');
            _navigateToDashboard(userRole);
          }
        } else {
          _showError('User data not found');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email';
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
          errorMessage = 'Too many attempts. Try again later';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      _showError(errorMessage);
    } catch (e) {
      _showError('An unexpected error occurred');
      print('Login error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithGoogle(role: widget.role);
      
      if (user != null) {
        // For Google sign-in, check role after sign-in
        final userData = await authService.getUserData(user.uid);
        
        if (userData != null) {
          final userRole = userData['role'];
          _showSuccess('Google login successful!');
          _navigateToDashboard(userRole);
        } else {
          _showError('User data not found after Google sign-in');
        }
      }
    } on FirebaseAuthException catch (e) {
      _showError('Google login failed: ${e.message}');
    } catch (e) {
      _showError('Google login failed');
      print('Google login error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loginWithApple() async {
    setState(() => isLoading = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithApple(role: widget.role);
      
      if (user != null) {
        // For Apple sign-in, check role after sign-in
        final userData = await authService.getUserData(user.uid);
        
        if (userData != null) {
          final userRole = userData['role'];
          _showSuccess('Apple login successful!');
          _navigateToDashboard(userRole);
        } else {
          _showError('User data not found after Apple sign-in');
        }
      } else {
        _showError('Apple Sign-In is not available yet. Please use email or Google.');
      }
    } on FirebaseAuthException catch (e) {
      _showError('Apple login failed: ${e.message}');
    } catch (e) {
      _showError('Apple login failed');
      print('Apple login error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _navigateToDashboard(String role) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (role == 'explorer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>  ExploreHome(),
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

  // ===================== UI HELPER METHODS =====================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
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

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: obscurePassword,
      style: TextStyle(color: Colors.black.withOpacity(0.5)),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
        filled: true,
        fillColor: const Color(0xFFFAEBDB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.orange,
          ),
          onPressed: () => setState(() => obscurePassword = !obscurePassword),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isEmpty || !controller.text.contains('@')) {
                _showError('Please enter a valid email');
                return;
              }
              
              try {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.resetPassword(controller.text.trim());
                Navigator.pop(ctx);
                _showSuccess('Password reset email sent! Check your inbox.');
              } on FirebaseAuthException catch (e) {
                _showError('Failed to send reset email: ${e.message}');
              } catch (e) {
                _showError('Failed to send reset email');
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
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