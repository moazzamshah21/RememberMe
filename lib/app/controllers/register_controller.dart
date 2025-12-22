import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> register() async {
    // Validate name
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your full name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // Validate email
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // Validate password
    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // Validate confirm password
    if (confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please confirm your password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      // Verify Firebase is initialized
      if (_auth.app == null) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Firebase is not initialized. Please restart the app',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }
      
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Verify that user is actually created before proceeding
      if (userCredential.user != null && _auth.currentUser != null) {
        final user = userCredential.user!;
        
        // Update user display name in Firebase Auth
        try {
          await user.updateDisplayName(nameController.text.trim());
          await user.reload();
        } catch (e) {
          // If updating display name fails, continue anyway
          print('Failed to update display name: $e');
        }

        // Save user data to Firestore
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'displayName': nameController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          
          print('User data saved to Firestore successfully');
        } catch (e) {
          // Log error but don't fail registration if Firestore save fails
          print('Failed to save user data to Firestore: $e');
          // Still show success since auth was created
        }

        isLoading.value = false;
        
        // Navigate to home only after successful registration
        Get.offNamed('/home');
        
        Get.snackbar(
          'Success',
          'Account created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Registration failed. Please try again',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String errorMessage = 'An error occurred';
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak. Please use a stronger password';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email address';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled. Please contact support';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please try again later';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during registration';
      }
      
      Get.snackbar(
        'Registration Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      isLoading.value = false;
      String errorMessage = 'An unexpected error occurred';
      
      // Handle platform-specific errors
      String errorString = e.toString().toLowerCase();
      if (errorString.contains('platform') || errorString.contains('pigeon')) {
        errorMessage = 'Platform error. Please ensure Firebase is properly configured and try again';
      } else if (errorString.contains('network')) {
        errorMessage = 'Network error. Please check your internet connection';
      } else {
        errorMessage = 'Registration failed. Please try again';
      }
      
      Get.snackbar(
        'Registration Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      
      // Log the full error for debugging
      print('Registration error: $e');
    }
  }

  void googleRegister() {
    // Handle Google registration
    print('Google register pressed');
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
