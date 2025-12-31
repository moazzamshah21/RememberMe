import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rememberme/app/controllers/user_controller.dart';
import 'package:rememberme/app/controllers/contacts_controller.dart';
import 'package:rememberme/app/controllers/favorites_controller.dart';
import 'package:rememberme/app/controllers/search_controller.dart' as app;
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rememberme/app/models/contact_model.dart';
import 'package:rememberme/app/constants/app_colors.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _subscriptionListener;

  @override
  void onInit() {
    super.onInit();
    // Initialize any settings data here
    loadSettings();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserSubscription();
      } else {
        _subscriptionListener?.cancel();
        currentPlan.value = 'Free';
      }
    });
  }

  void loadSettings() {
    // Load settings from storage or API
    // For now, keeping default values
  }

  void _loadUserSubscription() {
    final User? user = _auth.currentUser;
    if (user != null) {
      _subscriptionListener?.cancel();
      _subscriptionListener = _firestore.collection('users').doc(user.uid).snapshots().listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() ;
          if (data != null && data.containsKey('subscriptionPlan')) {
            currentPlan.value = data['subscriptionPlan'];
          }
        }
      });
    }
  }

  Future<void> upgradePlan(String planName) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      Get.snackbar(
        'Error',
        'You must be logged in to upgrade plan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    
    try {
      // Simulate purchase delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Update user subscription in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'subscriptionPlan': planName,
        'subscriptionDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      currentPlan.value = planName;
      isLoading.value = false;
      
      Get.snackbar(
        'Success',
        'Plan upgraded to $planName. All premium features are now unlocked!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to upgrade plan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  void handlePrivacySecurity() {
    // Navigate to privacy & security screen
    Get.snackbar(
      'Privacy & Security',
      'Feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> handleExportData() async {
    // Check if user has a subscription (not Free plan)
    if (currentPlan.value == 'Free') {
      _showExportSubscriptionPopup();
      return;
    }
    
    try {
      isLoading.value = true;
      
      // Get all contacts from ContactsController
      if (!Get.isRegistered<ContactsController>()) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Contacts not available. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }
      
      final contactsController = Get.find<ContactsController>();
      final contacts = contactsController.contacts.toList();
      
      if (contacts.isEmpty) {
        isLoading.value = false;
        Get.snackbar(
          'No Contacts',
          'You have no contacts to export.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }
      
      // Generate PDF
      final pdf = await _generateContactsPDF(contacts);
      
      // Save and share PDF
      await _saveAndSharePDF(pdf, contacts.length);
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to export contacts: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  // Show subscription popup for export data feature
  void _showExportSubscriptionPopup() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.primaryTeal,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Subscription Required',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                  fontFamily: 'PolySans',
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Export Data is a premium feature. Subscribe to any plan (Pro, Premium, or Platinum) to export your contacts.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.mediumGray,
            fontFamily: 'PolySans',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.mediumGray,
                fontFamily: 'PolySans',
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close the dialog
              // The user is already on the Settings screen, so they can see the plans below
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'View Plans',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'PolySans',
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
  
  Future<pw.Document> _generateContactsPDF(List<Contact> contacts) async {
    final pdf = pw.Document();
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email ?? 'User';
    
    // Sort contacts by date added (newest first)
    final sortedContacts = List<Contact>.from(contacts)
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    
    // Add cover page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'My Contacts Export',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Generated on: ${DateTime.now().toString().split('.')[0]}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'Total Contacts: ${contacts.length}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'User: $userName',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.SizedBox(height: 20),
          ];
        },
      ),
    );
    
    // Add contacts pages
    for (int i = 0; i < sortedContacts.length; i += 2) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            final List<pw.Widget> widgets = [];
            
            // Add up to 2 contacts per page
            for (int j = i; j < (i + 2) && j < sortedContacts.length; j++) {
              final contact = sortedContacts[j];
              
              widgets.add(
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 30),
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Contact Name
                      pw.Text(
                        contact.name,
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      
                      // Contact Details in two columns
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildPDFField('Profession', contact.profession),
                                _buildPDFField('Location', contact.location),
                                _buildPDFField('Company', contact.company.isNotEmpty ? contact.company : 'N/A'),
                                _buildPDFField('Gender', contact.gender.isNotEmpty ? contact.gender : 'N/A'),
                                _buildPDFField('Age Range', contact.ageRange.isNotEmpty ? contact.ageRange : 'N/A'),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 20),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildPDFField('Ethnicity', contact.ethnicity.isNotEmpty ? contact.ethnicity : 'N/A'),
                                _buildPDFField('Industry', contact.industry.isNotEmpty ? contact.industry : 'N/A'),
                                _buildPDFField('Date Added', _formatDate(contact.dateAdded)),
                                _buildPDFField('Favorite', contact.isFavorite ? 'Yes' : 'No'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Characteristics
                      if (contact.characteristics.isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 10),
                          child: _buildPDFField('Characteristics', contact.characteristics),
                        ),
                      
                      // Notes
                      if (contact.notes.isNotEmpty && 
                          contact.notes != 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.')
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Notes:',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                contact.notes,
                                style: pw.TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
              
              // Add divider between contacts (except for the last one)
              if (j < (i + 2) - 1 && j < sortedContacts.length - 1) {
                widgets.add(pw.SizedBox(height: 10));
              }
            }
            
            return widgets;
          },
        ),
      );
    }
    
    return pdf;
  }
  
  pw.Widget _buildPDFField(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  Future<void> _saveAndSharePDF(pw.Document pdf, int contactCount) async {
    try {
      // Generate PDF bytes
      final pdfBytes = await pdf.save();
      
      // Get directory for saving
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'contacts_export_$timestamp.pdf';
      final filePath = '${directory.path}/$fileName';
      
      // Save file
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      
      // Share the PDF using share_plus for download
      final xFile = XFile(filePath, mimeType: 'application/pdf');
      await Share.shareXFiles(
        [xFile],
        subject: 'My Contacts Export - $contactCount contacts',
        text: 'Exported contacts from Remember Me app',
      );
      
      Get.snackbar(
        'Success',
        'PDF exported successfully! ($contactCount contacts)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      throw Exception('Failed to save PDF: $e');
    }
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
            onPressed: () async {
              Get.back();
              await _performLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _performLogout() async {
    try {
      isLoading.value = true;

      // Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();

      // Clear UserController data
      if (Get.isRegistered<UserController>()) {
        final userController = Get.find<UserController>();
        userController.userName.value = 'User';
      }

      // Clear ContactsController data
      if (Get.isRegistered<ContactsController>()) {
        final contactsController = Get.find<ContactsController>();
        contactsController.contacts.clear();
      }

      // Clear FavoritesController data
      if (Get.isRegistered<FavoritesController>()) {
        final favoritesController = Get.find<FavoritesController>();
        favoritesController.favoriteContacts.clear();
      }

      // Clear SearchController data
      if (Get.isRegistered<app.AppSearchController>()) {
        final searchController = Get.find<app.AppSearchController>();
        searchController.searchController.clear();
        searchController.searchQuery.value = '';
        searchController.clearAllFilters();
        searchController.filteredContacts.clear();
      }

      isLoading.value = false;

      // Navigate to login screen and clear navigation stack
      Get.offAllNamed('/login');

      // Show success message
      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  bool isCurrentPlan(String planName) {
    return currentPlan.value == planName;
  }
}
