import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  // Current plan
  final RxString currentPlan = 'Free'.obs;
  
  // Plan prices
  final Map<String, String> planPrices = {
    'Free': '\$0',
    'Pro': '\$4.99/month',
    'Premium': '\$9.99/month',
    'Platinum': '\$19.99/month',
  };

  // Settings state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize any settings data here
    loadSettings();
  }

  void loadSettings() {
    // Load settings from storage or API
    // For now, keeping default values
  }

  void upgradePlan(String planName) {
    isLoading.value = true;
    // Simulate upgrade process
    Future.delayed(const Duration(seconds: 1), () {
      currentPlan.value = planName;
      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Plan upgraded to $planName',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  void handlePrivacySecurity() {
    // Navigate to privacy & security screen
    Get.snackbar(
      'Privacy & Security',
      'Feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void handleExportData() {
    // Handle data export
    Get.snackbar(
      'Export Data',
      'Exporting your contacts...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void handleAbout() {
    // Show about dialog
    Get.dialog(
      AlertDialog(
        title: const Text('About Remember Me'),
        content: const Text('Version 1.0.0\n\nThe Smart Way to Remember People.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void handleLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Handle logout logic here
              Get.snackbar(
                'Logged Out',
                'You have been logged out successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  bool isCurrentPlan(String planName) {
    return currentPlan.value == planName;
  }
}
