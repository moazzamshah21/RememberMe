import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rememberme/app/controllers/contacts_controller.dart';
import 'package:rememberme/app/controllers/settings_controller.dart';
import 'package:rememberme/app/controllers/bottom_tabs_controller.dart';
import 'package:rememberme/app/constants/app_colors.dart';

class AddContactController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  
  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController meetingPlaceController = TextEditingController();
  
  // Selected states
  final RxSet<String> selectedCharacteristics = <String>{}.obs;
  final RxString selectedAgeRange = ''.obs;
  final RxString selectedIndustry = ''.obs; // Changed from Set to String for single selection
  final RxString selectedGender = ''.obs;
  final RxString selectedEthnicity = ''.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxList<File> selectedImages = <File>[].obs; // Changed to support multiple images (max 3)
  
  // Custom characteristics text field controller
  final TextEditingController customCharacteristicController = TextEditingController();
  
  // Maximum number of images allowed
  static const int maxImages = 3;
  
  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      // Check if we've reached the maximum number of images
      if (selectedImages.length >= maxImages) {
        Get.snackbar(
          'Limit Reached',
          'You can only select up to $maxImages images',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }
      
      // Request permissions based on source
      bool hasPermission = false;
      
      if (source == ImageSource.camera) {
        // Request camera permission
        final cameraStatus = await Permission.camera.request();
        hasPermission = cameraStatus.isGranted;
        
        if (!hasPermission) {
          if (cameraStatus.isPermanentlyDenied) {
            Get.snackbar(
              'Permission Required',
              'Camera permission is permanently denied. Please enable it in settings.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.withOpacity(0.8),
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
              mainButton: TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
              ),
            );
          } else {
            Get.snackbar(
              'Permission Required',
              'Camera permission is required to take photos',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white,
            );
          }
          return;
        }
        
        // For camera, pick single image
        if (!hasPermission) {
          return;
        }
        
        final XFile? image = await _imagePicker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 800,
          maxHeight: 800,
        );
        
        if (image != null) {
          selectedImages.add(File(image.path));
        }
      } else {
        // Request storage/photos permission for gallery
        PermissionStatus status;
        
        // Check platform and request appropriate permission
        if (Platform.isAndroid) {
          // For Android 13+ (API 33+), use photos permission, otherwise use storage
          // Try photos first (Android 13+), fallback to storage for older versions
          try {
            status = await Permission.photos.request();
            // If photos permission is denied, try storage as fallback
            if (!status.isGranted) {
              status = await Permission.storage.request();
            }
          } catch (e) {
            // Fallback to storage permission for older Android versions
            status = await Permission.storage.request();
          }
        } else {
          // For iOS, use photos permission
          status = await Permission.photos.request();
        }
        
        hasPermission = status.isGranted;
        
        if (!hasPermission) {
          if (status.isPermanentlyDenied) {
            Get.snackbar(
              'Permission Required',
              'Gallery permission is permanently denied. Please enable it in settings.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.withOpacity(0.8),
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
              mainButton: TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
              ),
            );
          } else {
            Get.snackbar(
              'Permission Required',
              'Gallery permission is required to select photos',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white,
            );
          }
          return;
        }
        
        // For gallery, use multi-image picker
        // Calculate how many images we can still select
        final remainingSlots = maxImages - selectedImages.length;
        
        final List<XFile> images = await _imagePicker.pickMultiImage(
          imageQuality: 85,
          maxWidth: 800,
          maxHeight: 800,
        );
        
        if (images.isNotEmpty) {
          // Only add up to the remaining slots
          final imagesToAdd = images.take(remainingSlots).map((xFile) => File(xFile.path)).toList();
          selectedImages.addAll(imagesToAdd);
          
          // If user selected more than remaining slots, show a message
          if (images.length > remainingSlots) {
            Get.snackbar(
              'Limit Reached',
              'Only the first $remainingSlots image(s) were added. Maximum $maxImages images allowed.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.withOpacity(0.8),
              colorText: Colors.white,
            );
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
  
  // Method to remove an image at a specific index
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }
  
  Future<List<String>> uploadImagesToStorage() async {
    if (selectedImages.isEmpty) {
      return [];
    }
    
    try {
      isUploadingImage.value = true;
      
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }
      
      final List<String> imageUrls = [];
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Upload all images
      for (int i = 0; i < selectedImages.length; i++) {
        try {
          // Create a unique filename for each image
          final String fileName = 'contacts/${currentUser.uid}/${timestamp}_$i.jpg';
          
          // Upload to Firebase Storage
          final Reference ref = _storage.ref().child(fileName);
          final UploadTask uploadTask = ref.putFile(selectedImages[i]);
          
          // Wait for upload to complete
          final TaskSnapshot snapshot = await uploadTask;
          
          // Get download URL
          final String downloadUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
          
          print('Uploaded image $i: $downloadUrl');
        } catch (e) {
          print('Error uploading image $i: $e');
          // Continue with other images even if one fails
        }
      }
      
      isUploadingImage.value = false;
      return imageUrls;
    } catch (e) {
      isUploadingImage.value = false;
      print('Error uploading images: $e');
      throw Exception('Failed to upload images: ${e.toString()}');
    }
  }
  
  Future<void> saveContact() async {
    // Validate all required fields (except company and additional notes)
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the contact name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
    
    if (meetingPlaceController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter where you met',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
    
    if (selectedDate.value == null) {
      Get.snackbar(
        'Error',
        'Please select a meeting date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
    
    if (selectedGender.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select gender',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
    
    if (selectedEthnicity.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select ethnicity',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
    
    if (selectedAgeRange.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select age range',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
    
    if (selectedCharacteristics.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one characteristic',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
    
    if (selectedIndustry.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select an industry',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
    
    // Check if user is logged in
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'You must be logged in to save contacts',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
    
    // Check subscription limit for free users
    if (!_canAddMoreContacts()) {
      _showSubscriptionPopup();
      return;
    }
    
    try {
      isLoading.value = true;
      
      // Upload images first if selected
      List<String> imageUrls = [];
      String? profileImageUrl;
      
      if (selectedImages.isNotEmpty) {
        try {
          imageUrls = await uploadImagesToStorage();
          // Use first image as profile image for backward compatibility
          if (imageUrls.isNotEmpty) {
            profileImageUrl = imageUrls.first;
          }
        } catch (e) {
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Failed to upload images: ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return;
        }
      }
      
      // Prepare contact data
      final contactData = {
        'userId': currentUser.uid,
        'name': nameController.text.trim(),
        'companyName': companyNameController.text.trim(),
        'description': descriptionController.text.trim(),
        'meetingPlace': meetingPlaceController.text.trim(),
        'meetingDate': selectedDate.value != null 
            ? Timestamp.fromDate(selectedDate.value!)
            : Timestamp.fromDate(DateTime.now()),
        'gender': selectedGender.value,
        'ethnicity': selectedEthnicity.value,
        'ageRange': selectedAgeRange.value,
        'characteristics': selectedCharacteristics.toList(),
        'industries': selectedIndustry.value.isNotEmpty ? [selectedIndustry.value] : [],
        'profileImageUrl': profileImageUrl ?? '', // For backward compatibility
        'imageUrls': imageUrls, // Array of image URLs
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isFavorite': false,
      };
      
      // Save to Firestore
      await _firestore
          .collection('contacts')
          .add(contactData);
      
      isLoading.value = false;
      
      // Show success message
      Get.snackbar(
        'Success',
        'Successfully saved the contact',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      // Clear all fields
      clearAllFields();
      
      // Refresh contacts list if ContactsController exists
      try {
        if (Get.isRegistered<ContactsController>()) {
          final contactsController = Get.find<ContactsController>();
          // Refresh contacts - this will update the UI automatically via Obx
          contactsController.refreshContacts();
        }
      } catch (e) {
        print('Error refreshing contacts: $e');
      }
      
      // Navigate back to home screen
      // Use Get.back() which works with both GetX and Navigator navigation
      Get.back();
      
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to save contact: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }
  
  // Check if user can add more contacts
  // Free users can only add 5 contacts
  bool _canAddMoreContacts() {
    try {
      // Get SettingsController to check current plan
      final SettingsController settingsController = Get.isRegistered<SettingsController>()
          ? Get.find<SettingsController>()
          : Get.put(SettingsController());
      
      final currentPlan = settingsController.currentPlan.value;
      
      // If user has a paid plan, allow unlimited contacts
      if (currentPlan != 'Free') {
        return true;
      }
      
      // For free users, check contact count
      final ContactsController contactsController = Get.isRegistered<ContactsController>()
          ? Get.find<ContactsController>()
          : Get.put(ContactsController());
      
      // Free users can add up to 5 contacts
      // If they already have 5 contacts, they can't add more
      const int freePlanContactLimit = 5;
      return contactsController.contacts.length < freePlanContactLimit;
    } catch (e) {
      print('Error checking subscription limit: $e');
      // If there's an error, allow the save to proceed
      return true;
    }
  }
  
  // Show subscription popup dialog
  void _showSubscriptionPopup() {
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
                'Contact Limit Reached',
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
          'You have reached the limit of 5 contacts on the free plan. Subscribe to any plan to add more contacts.',
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
              // Close the Add Contact screen (which was opened with Navigator.push)
              // and switch to Settings tab
              Future.microtask(() {
                // Close AddContactScreen using Navigator since it was opened with Navigator.push
                if (Get.context != null && Navigator.canPop(Get.context!)) {
                  Navigator.pop(Get.context!);
                } else {
                  Get.back(); // Fallback to Get.back() if Navigator doesn't work
                }
                // Switch to Settings tab in BottomTabs (Settings is at index 3)
                // Home=0, Favorites=1, Search=2, Settings=3
                if (Get.isRegistered<BottomTabsController>()) {
                  final bottomTabsController = Get.find<BottomTabsController>();
                  bottomTabsController.changeTab(3); // Settings tab index
                }
              });
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
              'Plan',
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
  
  void clearAllFields() {
    // Clear text controllers
    nameController.clear();
    companyNameController.clear();
    descriptionController.clear();
    meetingPlaceController.clear();
    customCharacteristicController.clear();
    
    // Clear selected states
    selectedCharacteristics.clear();
    selectedAgeRange.value = '';
    selectedIndustry.value = '';
    selectedGender.value = '';
    selectedEthnicity.value = '';
    selectedDate.value = null;
    selectedImages.clear();
  }
  
  @override
  void onClose() {
    nameController.dispose();
    companyNameController.dispose();
    descriptionController.dispose();
    meetingPlaceController.dispose();
    customCharacteristicController.dispose();
    super.onClose();
  }
}
