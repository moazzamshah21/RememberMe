import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rememberme/app/models/contact_model.dart';

class FavoritesController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxList<Contact> favoriteContacts = <Contact>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  StreamSubscription<QuerySnapshot>? _favoritesSubscription;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupRealtimeListener();
    
    // Listen to auth state changes
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _setupRealtimeListener();
      } else {
        _favoritesSubscription?.cancel();
        favoriteContacts.clear();
      }
    });
  }

  @override
  void onClose() {
    _favoritesSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }

  void _setupRealtimeListener() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      favoriteContacts.clear();
      return;
    }
    
    // Cancel existing subscription if any
    _favoritesSubscription?.cancel();
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      // Set up real-time listener to fetch favorites directly from Firebase
      // Query contacts where userId matches and isFavorite is true
      Query baseQuery = _firestore
          .collection('contacts')
          .where('userId', isEqualTo: currentUser.uid)
          .where('isFavorite', isEqualTo: true);
      
      // Try with orderBy first
      Query orderedQuery = baseQuery.orderBy('updatedAt', descending: true);
      
      _favoritesSubscription = orderedQuery.snapshots().listen(
        (QuerySnapshot snapshot) {
          try {
            final favoritesList = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _documentToContact(doc.id, data);
            }).toList();
            
            // Sort by date added (newest first) as fallback
            favoritesList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            
            favoriteContacts.value = favoritesList;
            isLoading.value = false;
            debugPrint('Real-time favorites update: ${favoritesList.length} favorites for user ${currentUser.uid}');
          } catch (e) {
            debugPrint('Error processing favorites snapshot: $e');
            errorMessage.value = 'Error processing favorites: ${e.toString()}';
            isLoading.value = false;
          }
        },
        onError: (error) {
          // If orderBy fails (index not created), try without orderBy
          final errorString = error.toString().toLowerCase();
          if (errorString.contains('index') || errorString.contains('requires an index')) {
            debugPrint('OrderBy failed for favorites, falling back to query without orderBy: $error');
            _favoritesSubscription?.cancel();
            
            // Retry without orderBy
            _favoritesSubscription = baseQuery.snapshots().listen(
              (QuerySnapshot snapshot) {
                try {
                  final favoritesList = snapshot.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _documentToContact(doc.id, data);
                  }).toList();
                  
                  // Sort by date since we didn't use orderBy
                  favoritesList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                  
                  favoriteContacts.value = favoritesList;
                  isLoading.value = false;
                  debugPrint('Real-time favorites update (no orderBy): ${favoritesList.length} favorites for user ${currentUser.uid}');
                } catch (e) {
                  debugPrint('Error processing favorites snapshot: $e');
                  errorMessage.value = 'Error processing favorites: ${e.toString()}';
                  isLoading.value = false;
                }
              },
              onError: (error) {
                debugPrint('Error in favorites real-time listener: $error');
                errorMessage.value = 'Failed to load favorites: ${error.toString()}';
                isLoading.value = false;
              },
            );
          } else {
            debugPrint('Error in favorites real-time listener: $error');
            errorMessage.value = 'Failed to load favorites: ${error.toString()}';
            isLoading.value = false;
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to setup favorites listener: ${e.toString()}';
      debugPrint('Error setting up favorites real-time listener: $e');
    }
  }

  Contact _documentToContact(String id, Map<String, dynamic> data) {
    // Convert Firestore data to Contact model (same logic as ContactsController)
    final createdAt = data['createdAt'] as Timestamp?;
    final updatedAt = data['updatedAt'] as Timestamp?;
    
    // Use updatedAt for sorting and time period, fallback to createdAt or now
    final dateToUse = updatedAt?.toDate() ?? createdAt?.toDate() ?? DateTime.now();
    final timePeriod = _getTimePeriod(dateToUse);
    
    // Get profession from industries (first industry or empty)
    final industries = data['industries'] as List<dynamic>? ?? [];
    final profession = industries.isNotEmpty ? industries.first.toString() : 'Professional';
    
    // Get location from meeting place
    final location = data['meetingPlace'] as String? ?? '';
    
    // Format characteristics
    final characteristicsList = data['characteristics'] as List<dynamic>? ?? [];
    final characteristics = characteristicsList.join(', ');
    
    // Format industries
    final industriesString = industries.join(', ');
    
    // Handle images - support both old profileImageUrl and new imageUrls array
    final profileImageUrl = data['profileImageUrl'] as String? ?? '';
    final imageUrlsData = data['imageUrls'] as List<dynamic>?;
    List<String> imageUrls = [];
    
    if (imageUrlsData != null && imageUrlsData.isNotEmpty) {
      imageUrls = imageUrlsData.map((e) => e.toString()).toList();
    } else if (profileImageUrl.isNotEmpty) {
      // Migrate from old single image to new array format
      imageUrls = [profileImageUrl];
    }
    
    return Contact(
      id: id,
      timePeriod: timePeriod,
      profession: profession,
      ageRange: data['ageRange'] as String? ?? '',
      name: data['name'] as String? ?? 'Unknown',
      location: location,
      dateAdded: createdAt?.toDate() ?? DateTime.now(),
      updatedAt: dateToUse,
      isFavorite: data['isFavorite'] as bool? ?? false,
      notes: data['description'] as String? ?? '',
      company: data['companyName'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      characteristics: characteristics,
      ethnicity: data['ethnicity'] as String? ?? '',
      industry: industriesString,
      profileImageUrl: profileImageUrl,
      imageUrls: imageUrls,
    );
  }

  String _getTimePeriod(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dateToCheck.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      final difference = today.difference(dateToCheck).inDays;
      if (difference <= 7) {
        return 'Last 7 Days';
      } else {
        return 'Older';
      }
    }
  }

  Future<void> loadFavoriteContacts() async {
    // This method triggers a refresh of the real-time listener
    _setupRealtimeListener();
  }

  Future<void> refreshFavorites() async {
    // Trigger a refresh of the real-time listener
    _setupRealtimeListener();
  }
}
