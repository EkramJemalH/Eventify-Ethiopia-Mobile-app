import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  GoogleSignIn? _googleSignIn; // Will be null on web

  AuthService() {
    // Initialize GoogleSignIn only for mobile platforms
    if (!kIsWeb) {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
    }
  }

  // ===================== EMAIL/PASSWORD SIGN UP =====================
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      print('🟡 Starting email sign up for: $email');
      
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;

      if (user != null) {
        print('🟢 Firebase Auth user created: ${user.uid}');
        
        // Add user to Realtime Database
        await _dbRef.child('users').child(user.uid).set({
          'uid': user.uid,
          'email': email.trim(),
          'fullName': fullName.trim(),
          'role': role,
          'provider': 'email',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
        
        print('✅ User added to database: ${user.uid}');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('🔴 Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('🔴 Unexpected Error: $e');
      rethrow;
    }
  }

  // ===================== EMAIL/PASSWORD SIGN IN =====================
  Future<User?> signInWithEmail({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      print('🟡 Starting email sign in for: $email');
      
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;

      if (user != null) {
        print('🟢 User signed in: ${user.uid}');
        
        // Check if user exists in database
        final snapshot = await _dbRef.child('users/${user.uid}').get();
        
        if (!snapshot.exists) {
          // New user - create entry with the role they're signing in as
          print('🟡 User not found in database, creating entry...');
          await _dbRef.child('users').child(user.uid).set({
            'uid': user.uid,
            'email': user.email ?? email.trim(),
            'fullName': user.displayName ?? '',
            'role': role,
            'provider': 'email',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
        } else {
          // Existing user - verify role matches
          final userData = snapshot.value as Map<dynamic, dynamic>;
          final storedRole = userData['role']?.toString() ?? 'explorer';
          
          if (storedRole != role) {
            print('🔴 Role mismatch! User is $storedRole, trying to login as $role');
            await _auth.signOut();
            throw FirebaseAuthException(
              code: 'wrong-role',
              message: 'Please login as $storedRole instead',
            );
          }
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('🔴 Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('🔴 Unexpected Error: $e');
      rethrow;
    }
  }

  // ===================== GOOGLE SIGN IN =====================
  Future<User?> signInWithGoogle({
    required String role,
    bool isSignUp = false,
  }) async {
    try {
      print('🟡 Starting Google sign in for role: $role');
      
      UserCredential userCredential;
      
      if (kIsWeb) {
        // WEB IMPLEMENTATION
        print('🟡 Using Firebase Google Auth for web');
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        // Sign in with popup on web
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // MOBILE IMPLEMENTATION (Android/iOS)
        print('🟡 Using google_sign_in package for mobile');
        
        if (_googleSignIn == null) {
          throw FirebaseAuthException(
            code: 'google-signin-not-initialized',
            message: 'Google Sign-In not initialized for mobile',
          );
        }
        
        final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
        if (googleUser == null) {
          print('🟡 Google sign in cancelled');
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        userCredential = await _auth.signInWithCredential(credential);
      }

      final User? user = userCredential.user;

      if (user != null) {
        await _handleSocialUser(user, role, isSignUp, 'google', userCredential);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('🔴 Firebase Auth Error: ${e.code} - ${e.message}');
      
      // Provide helpful error messages
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
        throw FirebaseAuthException(
          code: 'cancelled',
          message: 'Sign in was cancelled',
        );
      }
      
      rethrow;
    } catch (e) {
      print('🔴 Google sign in failed: $e');
      
      // Check if it's a web configuration error
      if (e.toString().contains('ClientID not set') || e.toString().contains('appClientId')) {
        throw FirebaseAuthException(
          code: 'configuration-needed',
          message: 'Please configure Google Sign-In in Firebase Console',
        );
      }
      
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'Google Sign-In failed. Please try again.',
      );
    }
  }

  // ===================== APPLE SIGN IN =====================
  Future<User?> signInWithApple({
    required String role,
    bool isSignUp = false,
  }) async {
    try {
      print('🟡 Starting Apple sign in for role: $role');
      
      // Check if we're on iOS or macOS for Apple Sign-In
      if (!kIsWeb) {
        // For mobile platforms, Apple Sign-In is only available on iOS/macOS
        // You need to check the platform properly
        throw FirebaseAuthException(
          code: 'platform-not-supported',
          message: 'Apple Sign-In is currently only available on iOS devices',
        );
      }
      
      // For web, you can implement Apple Sign-In with Firebase
      // This requires additional setup in Firebase Console
      throw FirebaseAuthException(
        code: 'not-implemented',
        message: 'Apple Sign-In is not yet implemented for this platform',
      );
    } catch (e) {
      print('🔴 Apple sign in failed: $e');
      rethrow;
    }
  }

  // ===================== HELPER METHOD FOR SOCIAL USERS =====================
  Future<void> _handleSocialUser(
    User user,
    String role,
    bool isSignUp,
    String provider,
    UserCredential? userCredential,
  ) async {
    print('🟢 $provider user signed in: ${user.uid}');
    
    // Check if this is a new user (from additionalUserInfo)
    final bool isNewUser = userCredential?.additionalUserInfo?.isNewUser ?? false;
    print('🟡 Is new user: $isNewUser');
    
    // Check if user exists in database
    final snapshot = await _dbRef.child('users/${user.uid}').get();
    
    if (!snapshot.exists || isNewUser || isSignUp) {
      // New user or signing up - create/update with selected role
      print('🟡 Creating/updating user in database...');
      
      final Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': user.email ?? '',
        'fullName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'role': role,
        'provider': provider,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      if (!snapshot.exists || isNewUser) {
        userData['createdAt'] = DateTime.now().toIso8601String();
      }
      
      await _dbRef.child('users').child(user.uid).set(userData);
      print('✅ User added/updated in database as $role');
    } else {
      // Existing user logging in - verify role matches
      final userData = snapshot.value as Map<dynamic, dynamic>;
      final storedRole = userData['role']?.toString() ?? 'explorer';
      
      if (storedRole != role) {
        print('🔴 Role mismatch! User is $storedRole, trying to login as $role');
        await _auth.signOut();
        if (!kIsWeb && provider == 'google') {
          await _googleSignIn?.signOut();
        }
        throw FirebaseAuthException(
          code: 'wrong-role',
          message: 'Please login as $storedRole instead',
        );
      }
      
      // Update last login time
      await _dbRef.child('users/${user.uid}').update({
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      print('✅ Role matches: $storedRole');
    }
  }

  // ===================== GET USER DATA =====================
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final snapshot = await _dbRef.child('users').child(uid).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.cast<String, dynamic>();
      }
      return null;
    } catch (e) {
      print('🔴 Error getting user data: $e');
      return null;
    }
  }

  // ===================== GET USER ROLE =====================
  Future<String?> getUserRole(String uid) async {
    try {
      final data = await getUserData(uid);
      return data?['role']?.toString();
    } catch (e) {
      print('🔴 Error getting user role: $e');
      return null;
    }
  }

  // ===================== PASSWORD RESET =====================
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      print('✅ Password reset email sent to: $email');
    } catch (e) {
      print('🔴 Password reset failed: $e');
      rethrow;
    }
  }

  // ===================== SIGN OUT =====================
  Future<void> signOut() async {
    try {
      // Sign out from Google on mobile
      if (!kIsWeb && _googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
      
      // Sign out from Firebase Auth
      await _auth.signOut();
      
      print('✅ User signed out');
    } catch (e) {
      print('🔴 Sign out failed: $e');
      rethrow;
    }
  }

  // ===================== AUTH STATE =====================
  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}