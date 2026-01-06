// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class LoginController extends GetxController {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final RxBool obscurePassword = true.obs;
//   final RxBool isLoading = false.obs;
//   final RxBool isGoogleLoading = false.obs;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   // final GoogleSignIn _googleSignIn = GoogleSignIn();

// final GoogleSignIn _googleSignIn = GoogleSignIn(
//   scopes: <String>[
//     'email',
//     'profile',
//   ],
// );


//   void togglePasswordVisibility() {
//     obscurePassword.value = !obscurePassword.value;
//   }

//   bool _isValidEmail(String email) {
//     return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
//   }

//   Future<void> login() async {
//     // Validate email
//     if (emailController.text.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Please enter your email address',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//       );
//       return;
//     }

//     if (!_isValidEmail(emailController.text.trim())) {
//       Get.snackbar(
//         'Error',
//         'Please enter a valid email address',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//       );
//       return;
//     }

//     // Validate password
//     if (passwordController.text.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Please enter your password',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//       );
//       return;
//     }

//     if (passwordController.text.length < 6) {
//       Get.snackbar(
//         'Error',
//         'Password must be at least 6 characters',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//       );
//       return;
//     }

//     try {
//       isLoading.value = true;
      
//       // Sign in with email and password
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text,
//       );

//       // Verify that user is actually authenticated before navigation
//       if (userCredential.user != null && _auth.currentUser != null) {
//         isLoading.value = false;
        
//         // Navigate to home only after successful authentication
//         Get.offNamed('/home');
        
//         Get.snackbar(
//           'Success',
//           'Logged in successfully',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green.withValues(alpha: 0.8),
//           colorText: Colors.white,
//         );
//       } else {
//         isLoading.value = false;
//         Get.snackbar(
//           'Error',
//           'Authentication failed. Please try again',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red.withValues(alpha: 0.8),
//           colorText: Colors.white,
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       isLoading.value = false;
//       String errorMessage = 'An error occurred';
      
//       switch (e.code) {
//         case 'user-not-found':
//           errorMessage = 'No user found with this email address';
//           break;
//         case 'wrong-password':
//           errorMessage = 'Incorrect password';
//           break;
//         case 'invalid-email':
//           errorMessage = 'Invalid email address';
//           break;
//         case 'user-disabled':
//           errorMessage = 'This account has been disabled';
//           break;
//         case 'too-many-requests':
//           errorMessage = 'Too many failed attempts. Please try again later';
//           break;
//         case 'network-request-failed':
//           errorMessage = 'Network error. Please check your connection';
//           break;
//         default:
//           errorMessage = e.message ?? 'An error occurred during login';
//       }
      
//       Get.snackbar(
//         'Login Failed',
//         errorMessage,
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//         duration: const Duration(seconds: 4),
//       );
//     } catch (e) {
//       isLoading.value = false;
//       Get.snackbar(
//         'Error',
//         'An unexpected error occurred: ${e.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//       );
//     }
//   }

//   Future<void> sendPasswordResetEmail(String email) async {
//     if (email.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Please enter your email address',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//       );
//       return;
//     }

//     if (!_isValidEmail(email)) {
//       Get.snackbar(
//         'Error',
//         'Please enter a valid email address',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//       );
//       return;
//     }

//     try {
//       // Show loading indicator
//       Get.dialog(
//         const Center(child: CircularProgressIndicator()),
//         barrierDismissible: false,
//       );

//       // Check if email exists in Firestore
//       final userQuery = await _firestore
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .get();

//       if (userQuery.docs.isEmpty) {
//         // Close loading dialog
//         Get.back();
        
//         Get.snackbar(
//           'Error',
//           'This email doesn\'t exist',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red.withValues(alpha: 0.8),
//           colorText: Colors.white,
//         );
//         return;
//       }

//       await _auth.sendPasswordResetEmail(email: email);
      
//       // Close loading dialog
//       Get.back();
//       // Close input dialog if open
//       Get.back(); 

//       Get.snackbar(
//         'Success',
//         'Password reset email sent to $email',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green.withValues(alpha: 0.8),
//         colorText: Colors.white,
//       );
//     } on FirebaseAuthException catch (e) {
//       // Close loading dialog
//       Get.back();
      
//       String errorMessage = 'An error occurred';
//       switch (e.code) {
//         case 'user-not-found':
//           errorMessage = 'No user found with this email address';
//           break;
//         case 'invalid-email':
//           errorMessage = 'Invalid email address';
//           break;
//         default:
//           errorMessage = e.message ?? 'Failed to send reset email';
//       }

//       Get.snackbar(
//         'Error',
//         errorMessage,
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       // Close loading dialog
//       Get.back();
      
//       Get.snackbar(
//         'Error',
//         'An unexpected error occurred',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//       );
//     }
//   }

//   Future<void> googleLogin() async {
//     try {
//       isGoogleLoading.value = true;

//       // Trigger the Google Sign In flow
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

//       if (googleUser == null) {
//         // User cancelled the sign-in
//         isGoogleLoading.value = false;
//         return;
//       }

//       // Obtain the auth details from the request
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       // Create a new credential
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       // Sign in to Firebase with the Google credential
//       final UserCredential userCredential = await _auth.signInWithCredential(credential);

//       // Verify that user is actually authenticated
//       if (userCredential.user != null && _auth.currentUser != null) {
//         final user = userCredential.user!;
        
//         // Check if this is a new user or existing user
//         final userDoc = await _firestore
//             .collection('users')
//             .doc(user.uid)
//             .get();

//         // If user doesn't exist in Firestore, create their profile
//         if (!userDoc.exists) {
//           await _firestore.collection('users').doc(user.uid).set({
//             'uid': user.uid,
//             'name': user.displayName ?? 'User',
//             'email': user.email ?? '',
//             'displayName': user.displayName ?? 'User',
//             'photoURL': user.photoURL ?? '',
//             'createdAt': FieldValue.serverTimestamp(),
//             'updatedAt': FieldValue.serverTimestamp(),
//           }, SetOptions(merge: true));
//         } else {
//           // Update existing user's data if needed
//           await _firestore.collection('users').doc(user.uid).update({
//             'updatedAt': FieldValue.serverTimestamp(),
//             'email': user.email ?? userDoc.data()?['email'] ?? '',
//             'displayName': user.displayName ?? userDoc.data()?['displayName'] ?? 'User',
//             'photoURL': user.photoURL ?? userDoc.data()?['photoURL'] ?? '',
//           });
//         }

//         isGoogleLoading.value = false;

//         // Navigate to home after successful authentication
//         Get.offNamed('/home');

//         Get.snackbar(
//           'Success',
//           'Logged in with Google successfully',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green.withValues(alpha: 0.8),
//           colorText: Colors.white,
//         );
//       } else {
//         isGoogleLoading.value = false;
//         Get.snackbar(
//           'Error',
//           'Authentication failed. Please try again',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red.withValues(alpha: 0.8),
//           colorText: Colors.white,
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       isGoogleLoading.value = false;
//       String errorMessage = 'An error occurred';

//       switch (e.code) {
//         case 'account-exists-with-different-credential':
//           errorMessage = 'An account already exists with a different sign-in method';
//           break;
//         case 'invalid-credential':
//           errorMessage = 'The credential is invalid or has expired';
//           break;
//         case 'operation-not-allowed':
//           errorMessage = 'Google sign-in is not enabled';
//           break;
//         case 'user-disabled':
//           errorMessage = 'This account has been disabled';
//           break;
//         case 'user-not-found':
//           errorMessage = 'User not found';
//           break;
//         case 'network-request-failed':
//           errorMessage = 'Network error. Please check your connection';
//           break;
//         default:
//           errorMessage = e.message ?? 'An error occurred during Google sign-in';
//       }

//       Get.snackbar(
//         'Google Sign-In Failed',
//         errorMessage,
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//         duration: const Duration(seconds: 4),
//       );
//     } catch (e) {
//       isGoogleLoading.value = false;
//       Get.snackbar(
//         'Error',
//         'An unexpected error occurred: ${e.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//       );
//     }
//   }

//   @override
//   void onClose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  // ───────────────── Controllers ─────────────────
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ───────────────── State ─────────────────
  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;

  // ───────────────── Firebase ─────────────────
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ───────────────── Google Sign-In (v7+) ─────────────────
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // ───────────────── UI helpers ─────────────────
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(email.trim());
  }

  // ───────────────── Email / Password Login ─────────────────
  Future<void> login() async {
    if (emailController.text.isEmpty ||
        !_isValidEmail(emailController.text)) {
      _showError('Please enter a valid email address');
      return;
    }

    if (passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    try {
      isLoading.value = true;

      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        Get.offNamed('/home');
        _showSuccess('Logged in successfully');
      }
    } on FirebaseAuthException catch (e) {
      _showError(_firebaseError(e));
    } catch (e) {
      _showError('Unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  // ───────────────── Google Login ─────────────────
  Future<void> googleLogin() async {
    try {
      isGoogleLoading.value = true;

      // Initialize GoogleSignIn instance
      await _googleSignIn.initialize();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();

      if (googleUser == null) {
        isGoogleLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final AuthCredential credential =
          GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User user = userCredential.user!;

      final DocumentReference userRef =
          _firestore.collection('users').doc(user.uid);

      final DocumentSnapshot userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? 'User',
          'photoURL': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await userRef.update({
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      Get.offNamed('/home');
      _showSuccess('Logged in with Google');
    } on FirebaseAuthException catch (e) {
      _showError(_firebaseError(e));
    } catch (e) {
      _showError('Google Sign-In failed');
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // ───────────────── Password Reset ─────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _showSuccess('Password reset email sent');
    } on FirebaseAuthException catch (e) {
      _showError(_firebaseError(e));
    }
  }

  // ───────────────── Helpers ─────────────────
  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'account-exists-with-different-credential':
        return 'Account exists with different sign-in method';
      case 'network-request-failed':
        return 'Network error';
      default:
        return e.message ?? 'Authentication error';
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.85),
      colorText: Colors.white,
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.85),
      colorText: Colors.white,
    );
  }

  // ───────────────── Cleanup ─────────────────
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
