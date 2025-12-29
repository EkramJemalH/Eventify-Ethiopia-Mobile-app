import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
        
        // Check if user exists in database, if not create entry
        final snapshot = await _dbRef.child('users/${user.uid}').get();
        if (!snapshot.exists) {
          print('🟡 User not found in database, creating entry...');
          await _dbRef.child('users').child(user.uid).set({
            'uid': user.uid,
            'email': user.email ?? email.trim(),
            'fullName': user.displayName ?? '',
            'role': 'explorer',
            'provider': 'email',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
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
  Future<User?> signInWithGoogle({required String role}) async {
    try {
      print('🟡 Starting Google sign in');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('🟡 Google sign in cancelled');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        print('🟢 Google user signed in: ${user.uid}');
        
        // Check if new user
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        
        if (isNewUser) {
          print('🟡 New Google user, adding to database...');
          await _dbRef.child('users').child(user.uid).set({
            'uid': user.uid,
            'email': user.email ?? '',
            'fullName': user.displayName ?? googleUser.displayName ?? '',
            'photoURL': user.photoURL ?? googleUser.photoUrl,
            'role': role,
            'provider': 'google',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
          print('✅ New Google user added to database');
        } else {
          print('🟢 Existing Google user');
        }
      }

      return user;
    } catch (e) {
      print('🔴 Google sign in failed: $e');
      rethrow;
    }
  }

  // ===================== APPLE SIGN IN =====================
  Future<User?> signInWithApple({required String role}) async {
    try {
      print('🟡 Starting Apple sign in');
      
      // For now, return null as Apple Sign-In requires additional setup
      // TODO: Implement Apple Sign-In when iOS app is ready
      print('🟡 Apple Sign-In not implemented yet');
      return null;
    } catch (e) {
      print('🔴 Apple sign in failed: $e');
      rethrow;
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
      await _googleSignIn.signOut();
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

  // ===================== APPLE HELPER METHODS =====================
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}