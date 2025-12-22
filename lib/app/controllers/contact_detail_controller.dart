import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rememberme/app/controllers/contacts_controller.dart';
import 'package:rememberme/app/controllers/favorites_controller.dart';
import 'package:rememberme/app/models/contact_model.dart';

class ContactDetailController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  
  Contact? _contact;
  final RxBool isNotesExpanded = false.obs;
  final RxInt currentImageIndex = 0.obs;
  late final PageController pageController;
  
  final RxList<String> profileImages = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  
  StreamSubscription<DocumentSnapshot>? _contactSubscription;

  Contact? get contact => _contact;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.98);
  }

  @override
  void onClose() {
    _contactSubscription?.cancel();
    pageController.dispose();
    super.onClose();
  }

  void setContact(Contact contactData) {
    _contact = contactData;
    _updateProfileImages();
    _setupRealtimeListener();
    update();
  }

  void _updateProfileImages() {
    if (_contact == null) {
      profileImages.value = ['assets/images/profilepic.png'];
      currentImageIndex.value = 0;
      return;
    }
    
    final oldLength = profileImages.length;
    
    // Use imageUrls if available, otherwise fallback to profileImageUrl
    if (_contact!.imageUrls.isNotEmpty) {
      profileImages.value = List<String>.from(_contact!.imageUrls);
    } else if (_contact!.profileImageUrl.isNotEmpty) {
      profileImages.value = [_contact!.profileImageUrl];
    } else {
      profileImages.value = ['assets/images/profilepic.png'];
    }
    
    // Reset image index if it's out of bounds
    if (currentImageIndex.value >= profileImages.length) {
      currentImageIndex.value = 0;
      if (profileImages.length > 0) {
        pageController.jumpToPage(0);
      }
    }
  }

  void _setupRealtimeListener() {
    if (_contact == null) return;
    
    _contactSubscription?.cancel();
    
    _contactSubscription = _firestore
        .collection('contacts')
        .doc(_contact!.id)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        _updateContactFromFirestore(data);
      }
    }, onError: (error) {
      print('Error in contact real-time listener: $error');
    });
  }

  void _updateContactFromFirestore(Map<String, dynamic> data) {
    if (_contact == null) return;
    
    // Update contact fields from Firestore
    _contact!.notes = data['description'] as String? ?? _contact!.notes;
    _contact!.company = data['companyName'] as String? ?? _contact!.company;
    _contact!.gender = data['gender'] as String? ?? _contact!.gender;
    _contact!.ageRange = data['ageRange'] as String? ?? _contact!.ageRange;
    
    // Update characteristics
    final characteristicsList = data['characteristics'] as List<dynamic>? ?? [];
    _contact!.characteristics = characteristicsList.join(', ');
    
    // Update ethnicity
    _contact!.ethnicity = data['ethnicity'] as String? ?? _contact!.ethnicity;
    
    // Update industry
    final industries = data['industries'] as List<dynamic>? ?? [];
    _contact!.industry = industries.join(', ');
    
    // Update favorite status
    _contact!.isFavorite = data['isFavorite'] as bool? ?? _contact!.isFavorite;
    
    // Update images
    final imageUrlsData = data['imageUrls'] as List<dynamic>?;
    if (imageUrlsData != null && imageUrlsData.isNotEmpty) {
      _contact!.imageUrls = imageUrlsData.map((e) => e.toString()).toList();
    } else {
      final profileImageUrl = data['profileImageUrl'] as String? ?? '';
      if (profileImageUrl.isNotEmpty) {
        _contact!.imageUrls = [profileImageUrl];
      }
    }
    _contact!.profileImageUrl = data['profileImageUrl'] as String? ?? _contact!.profileImageUrl;
    
    _updateProfileImages();
    update();
  }

  void toggleNotesExpansion() {
    isNotesExpanded.value = !isNotesExpanded.value;
  }

  void changeImageIndex(int index) {
    currentImageIndex.value = index;
  }

  Future<void> toggleFavorite() async {
    if (contact == null) return;
    
    final newFavoriteStatus = !contact!.isFavorite;
    contact!.isFavorite = newFavoriteStatus;
    update();
    
    // Update in Firebase
    if (Get.isRegistered<ContactsController>()) {
      final contactsController = Get.find<ContactsController>();
      await contactsController.toggleFavorite(contact!.id, newFavoriteStatus);
    }
    
    // Notify FavoritesController to refresh the list
    if (Get.isRegistered<FavoritesController>()) {
      Get.find<FavoritesController>().loadFavoriteContacts();
    }
  }

  Future<void> updateField(String fieldName, String value) async {
    if (_contact == null) return;
    
    try {
      isLoading.value = true;
      
      // Map field names to Firestore field names
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      switch (fieldName) {
        case 'notes':
          updateData['description'] = value;
          // Update local contact immediately for instant UI feedback
          _contact!.notes = value;
          break;
        case 'company':
          updateData['companyName'] = value;
          _contact!.company = value;
          break;
        case 'gender':
          updateData['gender'] = value;
          _contact!.gender = value;
          break;
        case 'ageRange':
          updateData['ageRange'] = value;
          _contact!.ageRange = value;
          break;
        case 'characteristics':
          // Split by comma and trim
          final characteristics = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          updateData['characteristics'] = characteristics;
          _contact!.characteristics = value;
          break;
        case 'ethnicity':
          updateData['ethnicity'] = value;
          _contact!.ethnicity = value;
          break;
        case 'industry':
          // Split by comma and trim
          final industries = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          updateData['industries'] = industries;
          _contact!.industry = value;
          break;
        default:
          isLoading.value = false;
          return;
      }
      
      // Save to Firestore - await to ensure it completes
      await _firestore
          .collection('contacts')
          .doc(_contact!.id)
          .update(updateData)
          .then((_) {
            print('Successfully updated field $fieldName to Firestore');
          })
          .catchError((error) {
            print('Error updating Firestore: $error');
            throw error;
          });
      
      // Update UI immediately
      update();
      isLoading.value = false;
      
      Get.snackbar(
        'Success',
        'Field updated and saved to Firebase',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      isLoading.value = false;
      print('Error updating field $fieldName: $e');
      Get.snackbar(
        'Error',
        'Failed to save to Firebase: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Maximum number of images allowed
  static const int maxImages = 3;

  Future<void> pickAndAddImage({ImageSource source = ImageSource.gallery}) async {
    try {
      // Check current number of images
      final currentImageCount = profileImages.where((img) => 
        img != 'assets/images/profilepic.png' && 
        !img.startsWith('assets/')
      ).length;
      
      if (currentImageCount >= maxImages) {
        Get.snackbar(
          'Limit Reached',
          'You can only have up to $maxImages images per contact',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }
      
      // Request permissions based on source
      bool hasPermission = false;
      
      if (source == ImageSource.camera) {
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
        if (!hasPermission) return;
        
        final XFile? image = await _imagePicker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 800,
          maxHeight: 800,
        );
        
        if (image != null) {
          await _uploadAndAddImage(File(image.path));
        }
      } else {
        // For gallery, use multi-select
        PermissionStatus status;
        
        if (Platform.isAndroid) {
          try {
            status = await Permission.photos.request();
            if (!status.isGranted) {
              status = await Permission.storage.request();
            }
          } catch (e) {
            status = await Permission.storage.request();
          }
        } else {
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
        
        // Calculate how many images we can still add
        final remainingSlots = maxImages - currentImageCount;
        
        // Use multi-image picker for gallery
        final List<XFile> images = await _imagePicker.pickMultiImage(
          imageQuality: 85,
          maxWidth: 800,
          maxHeight: 800,
        );
        
        if (images.isNotEmpty) {
          // Only upload up to the remaining slots
          final imagesToUpload = images.take(remainingSlots).toList();
          
          // Upload images sequentially
          for (final imageFile in imagesToUpload) {
            await _uploadAndAddImage(File(imageFile.path));
          }
          
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

  Future<void> _uploadAndAddImage(File imageFile) async {
    if (_contact == null) return;
    
    try {
      isUploadingImage.value = true;
      
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        isUploadingImage.value = false;
        Get.snackbar(
          'Error',
          'You must be logged in to upload images',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }
      
      // Create a unique filename
      final String fileName = 'contacts/${currentUser.uid}/${_contact!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      print('Uploading image to Firebase Storage: $fileName');
      
      // Upload to Firebase Storage
      final Reference ref = _storage.ref().child(fileName);
      final UploadTask uploadTask = ref.putFile(imageFile);
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      print('Image upload to Storage completed');
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded successfully. Download URL: $downloadUrl');
      
      // Get current imageUrls from Firestore
      final docSnapshot = await _firestore.collection('contacts').doc(_contact!.id).get();
      
      if (!docSnapshot.exists) {
        throw Exception('Contact document not found in Firestore');
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>? ?? {};
      
      List<String> currentImageUrls = [];
      final imageUrlsData = data['imageUrls'] as List<dynamic>?;
      if (imageUrlsData != null && imageUrlsData.isNotEmpty) {
        currentImageUrls = imageUrlsData.map((e) => e.toString()).toList();
      } else {
        // Migrate from old profileImageUrl
        final profileImageUrl = data['profileImageUrl'] as String? ?? '';
        if (profileImageUrl.isNotEmpty) {
          currentImageUrls = [profileImageUrl];
        }
      }
      
      // Check if we've reached the maximum
      if (currentImageUrls.length >= maxImages) {
        isUploadingImage.value = false;
        Get.snackbar(
          'Limit Reached',
          'Maximum $maxImages images allowed. Please remove an image first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }
      
      // Add new image URL
      currentImageUrls.add(downloadUrl);
      
      print('Updating Firestore with ${currentImageUrls.length} images');
      
      // Update Firestore with the new image URLs
      await _firestore
          .collection('contacts')
          .doc(_contact!.id)
          .update({
            'imageUrls': currentImageUrls,
            'updatedAt': FieldValue.serverTimestamp(),
            // Keep profileImageUrl for backward compatibility (use first image)
            'profileImageUrl': currentImageUrls.first,
          })
          .then((_) {
            print('Successfully saved image URLs to Firestore');
            // Update local contact immediately
            _contact!.imageUrls = List<String>.from(currentImageUrls);
            _contact!.profileImageUrl = currentImageUrls.first;
            _updateProfileImages();
            update();
          })
          .catchError((error) {
            print('Error updating Firestore with image URLs: $error');
            throw error;
          });
      
      isUploadingImage.value = false;
      
      Get.snackbar(
        'Success',
        'Image uploaded and saved to Firebase',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      // Real-time listener will also update the contact automatically
    } catch (e) {
      isUploadingImage.value = false;
      print('Error uploading image: $e');
      Get.snackbar(
        'Error',
        'Failed to upload image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  Future<void> shareContact() async {
    if (_contact == null) return;
    
    try {
      // Build share text with contact information
      final shareText = StringBuffer();
      shareText.writeln('Contact: ${_contact!.name}');
      
      if (_contact!.company.isNotEmpty) {
        shareText.writeln('Company: ${_contact!.company}');
      }
      
      if (_contact!.location.isNotEmpty) {
        shareText.writeln('Location: ${_contact!.location}');
      }
      
      if (_contact!.gender.isNotEmpty) {
        shareText.writeln('Gender: ${_contact!.gender}');
      }
      
      if (_contact!.ageRange.isNotEmpty) {
        shareText.writeln('Age Range: ${_contact!.ageRange}');
      }
      
      if (_contact!.ethnicity.isNotEmpty) {
        shareText.writeln('Ethnicity: ${_contact!.ethnicity}');
      }
      
      if (_contact!.industry.isNotEmpty) {
        shareText.writeln('Industry: ${_contact!.industry}');
      }
      
      if (_contact!.characteristics.isNotEmpty) {
        shareText.writeln('Characteristics: ${_contact!.characteristics}');
      }
      
      if (_contact!.notes.isNotEmpty && _contact!.notes != 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.') {
        shareText.writeln('\nNotes: ${_contact!.notes}');
      }
      
      // Share the contact information
      await Share.share(
        shareText.toString(),
        subject: 'Contact: ${_contact!.name}',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share contact: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
}
